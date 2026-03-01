#!/usr/bin/env python3
"""
Generate AoC wiki markdown files from Gleam day solution headers.
Headers are doc comments at the top of each day_XX.gleam file:
  /// Title: ...
  /// Link: ...
  /// Difficulty: ...
  /// Tags: tag1 tag2 ...

Output layout:
  wiki/Home.md          — progress grid + tag cloud
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

ALL_DAYS = list(range(1, 26))

# Emoji only — no text label
DIFF_ICON = {
    "xs": "🟢",
    "s":  "🟡",
    "m":  "🟠",
    "l":  "🔴",
    "xl": "💀",
}


# ─── Parsing ───────────────────────────────────────────────────────────────────

def parse_day_file(path: Path) -> dict | None:
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


def collect_all_solutions() -> list[dict]:
    solutions = []
    for year_dir in sorted(SRC_DIR.glob("year_*")):
        year = int(year_dir.name.split("_")[1])
        for day_file in sorted(year_dir.glob("day_*.gleam")):
            meta = parse_day_file(day_file)
            if meta:
                meta["year"] = year
                meta["year_dir"] = year_dir.name        # e.g. "year_2024"
                meta["day_file"] = day_file.name        # e.g. "day_01.gleam"
                solutions.append(meta)
    return solutions


def diff_icon(d: str) -> str:
    return DIFF_ICON.get(d, d.upper())


# ─── Home ─────────────────────────────────────────────────────────────────────

def gen_tag_cloud(tag_map: dict[str, list[dict]]) -> str:
    """Inline tag cloud sorted by frequency (descending), with count hint."""
    # Sort by count desc, then alpha
    tags_by_freq = sorted(tag_map.items(), key=lambda kv: (-len(kv[1]), kv[0]))
    parts = [f"[{tag}](tags/{tag}.md)&nbsp;`{len(sols)}`" for tag, sols in tags_by_freq]
    return "  ".join(parts)


def gen_home(solutions: list[dict], tag_map: dict[str, list[dict]]) -> str:
    solved: dict[tuple[int, int], dict] = {(s["year"], s["day"]): s for s in solutions}
    years = sorted({s["year"] for s in solutions})
    total = len(solutions)

    # Year nav links → point to src/year_XXXX/README.md (relative from wiki/)
    year_links = " | ".join(f"[{y}](../src/year_{y}/README.md)" for y in years)

    lines = [
        "# aocgl — Advent of Code in Gleam\n\n",
        "[Advent of Code](https://adventofcode.com) puzzle solutions written in [Gleam](https://gleam.run).\n\n",
        f"> **{total} problems solved** across **{len(years)} years**"
        f" — [Tags](tags/index.md) · [Difficulty](difficulty.md)\n\n",
        f"**Years:** {year_links}\n\n",
        "---\n\n",
    ]

    # Progress grid
    year_header = " | ".join(f"[{y}](../src/year_{y}/README.md)" for y in years)
    lines.append(f"| Day | {year_header} |\n")
    lines.append("|:---:|" + ":-:|" * len(years) + "\n")

    for day in ALL_DAYS:
        cells = []
        for year in years:
            s = solved.get((year, day))
            cells.append(f"[⭐]({s['link']})" if s else " ")
        lines.append(f"| {day} | " + " | ".join(cells) + " |\n")

    # Tag cloud
    lines.append("\n---\n\n")
    lines.append("## 🏷️ Tags\n\n")
    lines.append(gen_tag_cloud(tag_map) + "\n")

    return "".join(lines)


# ─── Per-year README ───────────────────────────────────────────────────────────

def gen_year(year: int, solutions: list[dict], all_years: list[int]) -> str:
    """Written to src/year_XXXX/README.md — paths are relative to that location."""
    sols = sorted(solutions, key=lambda s: s["day"])

    # Nav: home + all years; other years link to their own README
    nav_parts = ["[Home](../../wiki/Home.md)"]
    for y in all_years:
        if y == year:
            nav_parts.append(str(y))
        else:
            nav_parts.append(f"[{y}](../year_{y}/README.md)")
    nav = " | ".join(nav_parts)

    stars = len(sols) * 2

    # Build per-year tag cloud
    year_tags: dict[str, int] = defaultdict(int)
    for s in sols:
        for t in s["tags"]:
            year_tags[t] += 1
    tag_cloud_parts = sorted(year_tags.items(), key=lambda kv: (-kv[1], kv[0]))
    tag_cloud = "  ".join(
        f"[{tag}](../../wiki/tags/{tag}.md)&nbsp;`{count}`"
        for tag, count in tag_cloud_parts
    )

    lines = [
        f"# Advent of Code {year}\n\n",
        f"{nav}\n\n",
        f"## ⭐ {stars}/50\n\n",
        f"{tag_cloud}\n\n",
        "| Day | Title | Difficulty | Tags | Source |\n",
        "|:---:|-------|:----------:|------|--------|\n",
    ]

    for s in sols:
        # tag links relative to src/year_XXXX/ → ../../wiki/tags/
        tags = ", ".join(f"[{t}](../../wiki/tags/{t}.md)" for t in s["tags"])
        src  = f"[{s['day_file']}]({s['day_file']})"   # same directory
        lines.append(
            f"| [{s['day']}]({s['link']}) "
            f"| [{s['title']}]({s['link']}) "
            f"| {diff_icon(s['difficulty'])} "
            f"| {tags} "
            f"| {src} |\n"
        )

    return "".join(lines)


# ─── Tags ─────────────────────────────────────────────────────────────────────

def gen_tag_index(tag_map: dict[str, list[dict]]) -> str:
    lines = [
        "# 🏷️ Tags Index\n\n",
        "[← Home](../Home.md)\n\n",
        "| Tag | Problems |\n",
        "|-----|--------:|\n",
    ]
    for tag in sorted(tag_map.keys()):
        lines.append(f"| [{tag}]({tag}.md) | {len(tag_map[tag])} |\n")
    return "".join(lines)


def gen_tag_page(tag: str, solutions: list[dict]) -> str:
    """Lives at wiki/tags/{tag}.md; source relative to repo root."""
    sols = sorted(solutions, key=lambda s: (s["year"], s["day"]))
    lines = [
        f"# Tag: `{tag}`\n\n",
        "[← Tags Index](index.md)\n\n",
        "| Year | Day | Title | Difficulty | Other Tags | Source |\n",
        "|------|:---:|-------|:----------:|------------|--------|\n",
    ]
    for s in sols:
        other_tags = ", ".join(f"[{t}]({t}.md)" for t in s["tags"] if t != tag)
        # source relative from wiki/tags/ → ../../src/year_XXXX/day_XX.gleam
        src = f"[{s['day_file']}](../../src/{s['year_dir']}/{s['day_file']})"
        lines.append(
            f"| {s['year']} "
            f"| [{s['day']}]({s['link']}) "
            f"| [{s['title']}]({s['link']}) "
            f"| {diff_icon(s['difficulty'])} "
            f"| {other_tags} "
            f"| {src} |\n"
        )
    return "".join(lines)


# ─── Difficulty ───────────────────────────────────────────────────────────────

def gen_difficulty(solutions: list[dict]) -> str:
    diff_map: dict[str, list[dict]] = defaultdict(list)
    for s in solutions:
        diff_map[s["difficulty"]].append(s)

    lines = [
        "# 🎯 Solutions by Difficulty\n\n",
        "[← Home](Home.md)\n\n",
    ]
    for diff in ["xs", "s", "m", "l", "xl"]:
        sols = diff_map.get(diff, [])
        if not sols:
            continue
        sols = sorted(sols, key=lambda s: (s["year"], s["day"]))
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
    # Recreate wiki/ (keep tags/ subdir clean too)
    if WIKI_DIR.exists():
        shutil.rmtree(WIKI_DIR)
    WIKI_DIR.mkdir()
    tags_dir = WIKI_DIR / "tags"
    tags_dir.mkdir()

    solutions = collect_all_solutions()
    all_years = sorted({s["year"] for s in solutions})
    print(f"Collected {len(solutions)} solutions across {len(all_years)} years.")

    # Build tag map once
    tag_map: dict[str, list[dict]] = defaultdict(list)
    for s in solutions:
        for t in s["tags"]:
            tag_map[t].append(s)

    # wiki/Home.md
    (WIKI_DIR / "Home.md").write_text(gen_home(solutions, tag_map))
    print("  Wrote wiki/Home.md")

    # wiki/difficulty.md
    (WIKI_DIR / "difficulty.md").write_text(gen_difficulty(solutions))
    print("  Wrote wiki/difficulty.md")

    # wiki/tags/
    (tags_dir / "index.md").write_text(gen_tag_index(tag_map))
    print("  Wrote wiki/tags/index.md")
    for tag, sols in sorted(tag_map.items()):
        (tags_dir / f"{tag}.md").write_text(gen_tag_page(tag, sols))
    print(f"  Wrote {len(tag_map)} tag pages under wiki/tags/")

    # src/year_XXXX/README.md
    by_year: dict[int, list[dict]] = defaultdict(list)
    for s in solutions:
        by_year[s["year"]].append(s)

    for year, sols in sorted(by_year.items()):
        dest = SRC_DIR / f"year_{year}" / "README.md"
        dest.write_text(gen_year(year, sols, all_years))
        print(f"  Wrote src/year_{year}/README.md")

    print(f"\nDone!")


if __name__ == "__main__":
    main()
