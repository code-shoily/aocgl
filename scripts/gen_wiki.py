#!/usr/bin/env python3
"""
Generate AoC wiki markdown files from Gleam day solution headers.
Headers are doc comments at the top of each day_XX.gleam file:
  /// Title: ...
  /// Link: ...
  /// Difficulty: ...
  /// Tags: tag1 tag2 ...

Output layout:
  README.md             — stats block injected between <!-- STATS_START/END -->
  wiki/difficulty.md    — solutions by difficulty tier
  wiki/tags/index.md    — tag directory
  wiki/tags/{tag}.md    — one page per tag
  src/year_XXXX/README.md  — per-year solution table
"""

import re
import shutil
from pathlib import Path
from collections import defaultdict

REPO_DIR  = Path("/home/mafinar/repos/gleam/aocgl")
SRC_DIR   = REPO_DIR / "src"
WIKI_DIR  = REPO_DIR / "wiki"
README    = REPO_DIR / "README.md"

STATS_START = "<!-- STATS_START -->"
STATS_END   = "<!-- STATS_END -->"

ALL_DAYS = list(range(1, 26))

DIFF_ICON = {
    "xs": "🟢",
    "s":  "🟡",
    "m":  "🟠",
    "l":  "🔴",
    "xl": "💀",
}


# ─── Parsing ───────────────────────────────────────────────────────────────────

def parse_day_file(path):
    meta = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line.startswith("///"):
                break
            m = re.match(r'///\s+(\w+):\s+(.*)', line)
            if m:
                meta[m.group(1).lower()] = m.group(2).strip()

    if not all(k in meta for k in ("title", "link", "difficulty", "tags")):
        return None

    day_num = int(re.search(r'day_(\d+)', path.stem).group(1))
    meta["day"] = day_num
    meta["tags"] = [t.strip(",") for t in re.split(r'[,\s]+', meta["tags"]) if t.strip(",")]
    meta["difficulty"] = meta["difficulty"].lower()
    return meta


def collect_all_solutions():
    solutions = []
    for year_dir in sorted(SRC_DIR.glob("year_*")):
        year = int(year_dir.name.split("_")[1])
        for day_file in sorted(year_dir.glob("day_*.gleam")):
            meta = parse_day_file(day_file)
            if meta:
                meta["year"] = year
                meta["year_dir"] = year_dir.name
                meta["day_file"] = day_file.name
                solutions.append(meta)
    return solutions


def diff_icon(d):
    return DIFF_ICON.get(d, d.upper())


def tag_cloud(tag_counts, link_prefix):
    """tag_counts: {tag: count}; link_prefix: relative path to wiki/tags/ dir."""
    parts = sorted(tag_counts.items(), key=lambda kv: (-kv[1], kv[0]))
    return "  ".join(
        f"[{tag}]({link_prefix}{tag}.md)&nbsp;`{count}`"
        for tag, count in parts
    )


# ─── README stats block (injected between markers) ────────────────────────────

def gen_stats_block(solutions, tag_map):
    solved = {(s["year"], s["day"]): s for s in solutions}
    years  = sorted({s["year"] for s in solutions})
    total  = len(solutions)

    # Year nav → src/year_XXXX/README.md (relative from repo root)
    year_links = " | ".join(f"[{y}](src/year_{y}/README.md)" for y in years)

    lines = [
        f"> **{total} problems solved** across **{len(years)} years**"
        f" — [Tags](wiki/tags/index.md) · [Difficulty](wiki/difficulty.md)\n\n",
        f"**Years:** {year_links}\n\n",
    ]

    # Progress grid
    year_header = " | ".join(f"[{y}](src/year_{y}/README.md)" for y in years)
    lines.append(f"| Day | {year_header} |\n")
    lines.append("|:---:|" + ":-:|" * len(years) + "\n")
    for day in ALL_DAYS:
        cells = [f"[⭐]({solved[(y, day)]['link']})" if (y, day) in solved else " " for y in years]
        lines.append(f"| {day} | " + " | ".join(cells) + " |\n")

    # Global tag cloud; links relative from repo root
    global_counts = {tag: len(sols) for tag, sols in tag_map.items()}
    lines.append("\n### 🏷️ Tags\n\n")
    lines.append(tag_cloud(global_counts, "wiki/tags/") + "\n")

    return "".join(lines)


def patch_readme(stats_block):
    """Replace content between STATS_START / STATS_END markers in README.md."""
    text = README.read_text()
    pattern = re.compile(
        rf"{re.escape(STATS_START)}.*?{re.escape(STATS_END)}",
        re.DOTALL,
    )
    replacement = f"{STATS_START}\n{stats_block}{STATS_END}"
    new_text, count = pattern.subn(replacement, text)
    if count == 0:
        raise ValueError("STATS_START/END markers not found in README.md")
    README.write_text(new_text)


# ─── Per-year README ──────────────────────────────────────────────────────────

def gen_year(year, solutions, all_years):
    """Written to src/year_XXXX/README.md."""
    sols = sorted(solutions, key=lambda s: s["day"])

    nav_parts = ["[Home](../../README.md)"]
    for y in all_years:
        nav_parts.append(str(y) if y == year else f"[{y}](../year_{y}/README.md)")
    nav = " | ".join(nav_parts)

    year_tag_counts = {}
    for s in sols:
        for t in s["tags"]:
            year_tag_counts[t] = year_tag_counts.get(t, 0) + 1

    lines = [
        f"# Advent of Code {year}\n\n",
        f"{nav}\n\n",
        f"## ⭐ {len(sols) * 2}/50\n\n",
        tag_cloud(year_tag_counts, "../../wiki/tags/") + "\n\n",
        "| Day | Title | Difficulty | Tags | Source |\n",
        "|:---:|-------|:----------:|------|--------|\n",
    ]

    for s in sols:
        tags = ", ".join(f"[{t}](../../wiki/tags/{t}.md)" for t in s["tags"])
        lines.append(
            f"| [{s['day']}]({s['link']}) "
            f"| [{s['title']}]({s['link']}) "
            f"| {diff_icon(s['difficulty'])} "
            f"| {tags} "
            f"| [{s['day_file']}]({s['day_file']}) |\n"
        )

    return "".join(lines)


# ─── Tags ─────────────────────────────────────────────────────────────────────

def gen_tag_index(tag_map):
    lines = [
        "# 🏷️ Tags Index\n\n",
        "[← Home](../../README.md)\n\n",
        "| Tag | Problems |\n",
        "|-----|--------:|\n",
    ]
    for tag in sorted(tag_map.keys()):
        lines.append(f"| [{tag}]({tag}.md) | {len(tag_map[tag])} |\n")
    return "".join(lines)


def gen_tag_page(tag, solutions):
    """Lives at wiki/tags/{tag}.md."""
    sols = sorted(solutions, key=lambda s: (s["year"], s["day"]))
    lines = [
        f"# Tag: `{tag}`\n\n",
        "[← Tags Index](index.md)  |  [← Home](../../README.md)\n\n",
        "| Year | Day | Title | Difficulty | Other Tags | Source |\n",
        "|------|:---:|-------|:----------:|------------|--------|\n",
    ]
    for s in sols:
        other = ", ".join(f"[{t}]({t}.md)" for t in s["tags"] if t != tag)
        src   = f"[{s['day_file']}](../../src/{s['year_dir']}/{s['day_file']})"
        lines.append(
            f"| {s['year']} "
            f"| [{s['day']}]({s['link']}) "
            f"| [{s['title']}]({s['link']}) "
            f"| {diff_icon(s['difficulty'])} "
            f"| {other} "
            f"| {src} |\n"
        )
    return "".join(lines)


# ─── Difficulty ───────────────────────────────────────────────────────────────

def gen_difficulty(solutions):
    diff_map = defaultdict(list)
    for s in solutions:
        diff_map[s["difficulty"]].append(s)

    lines = [
        "# 🎯 Solutions by Difficulty\n\n",
        "[← Home](../README.md)\n\n",
    ]
    for diff in ["xs", "s", "m", "l", "xl"]:
        sols = sorted(diff_map.get(diff, []), key=lambda s: (s["year"], s["day"]))
        if not sols:
            continue
        lines.append(f"## {diff_icon(diff)} {diff.upper()}\n\n")
        lines.append("| Year | Day | Title | Tags | Source |\n")
        lines.append("|------|:---:|-------|------|--------|\n")
        for s in sols:
            tags = ", ".join(f"[{t}](tags/{t}.md)" for t in s["tags"])
            src  = f"[{s['day_file']}](../src/{s['year_dir']}/{s['day_file']})"
            lines.append(
                f"| {s['year']} "
                f"| [{s['day']}]({s['link']}) "
                f"| [{s['title']}]({s['link']}) "
                f"| {tags} "
                f"| {src} |\n"
            )
        lines.append("\n")
    return "".join(lines)


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    # Recreate wiki/ (no Home.md)
    if WIKI_DIR.exists():
        shutil.rmtree(WIKI_DIR)
    WIKI_DIR.mkdir()
    tags_dir = WIKI_DIR / "tags"
    tags_dir.mkdir()

    solutions  = collect_all_solutions()
    all_years  = sorted({s["year"] for s in solutions})
    print(f"Collected {len(solutions)} solutions across {len(all_years)} years.")

    tag_map = defaultdict(list)
    for s in solutions:
        for t in s["tags"]:
            tag_map[t].append(s)

    # Patch README.md in-place
    patch_readme(gen_stats_block(solutions, tag_map))
    print("  Patched README.md (<!-- STATS_START/END -->)")

    # wiki/difficulty.md
    (WIKI_DIR / "difficulty.md").write_text(gen_difficulty(solutions))
    print("  Wrote wiki/difficulty.md")

    # wiki/tags/
    (tags_dir / "index.md").write_text(gen_tag_index(tag_map))
    for tag, sols in sorted(tag_map.items()):
        (tags_dir / f"{tag}.md").write_text(gen_tag_page(tag, sols))
    print(f"  Wrote {len(tag_map)} tag pages + index under wiki/tags/")

    # src/year_XXXX/README.md
    by_year = defaultdict(list)
    for s in solutions:
        by_year[s["year"]].append(s)

    for year, sols in sorted(by_year.items()):
        (SRC_DIR / f"year_{year}" / "README.md").write_text(gen_year(year, sols, all_years))
        print(f"  Wrote src/year_{year}/README.md")

    print("\nDone!")


if __name__ == "__main__":
    main()
