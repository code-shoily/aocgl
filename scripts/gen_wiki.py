#!/usr/bin/env python3
"""
Generate AoC wiki markdown files from Gleam day solution headers.
Headers are doc comments at the top of each day_XX.gleam file:
  /// Title: ...
  /// Link: ...
  /// Difficulty: ...
  /// Tags: tag1 tag2 ...
"""

import os
import re
import shutil
from pathlib import Path
from collections import defaultdict

SRC_DIR = Path("/home/mafinar/repos/gleam/aocgl/src")
WIKI_DIR = Path("/home/mafinar/repos/gleam/aocgl/wiki")
README_PATH = Path("/home/mafinar/repos/gleam/aocgl/README.md")

ALL_YEARS = list(range(2015, 2026))
ALL_DAYS = list(range(1, 26))

DIFFICULTY_ICON = {
    "xs": "🟢 XS",
    "s":  "🟡 S",
    "m":  "🟠 M",
    "l":  "🔴 L",
    "xl": "💀 XL",
}


def parse_day_file(path: Path) -> dict | None:
    """Extract header metadata from a day_XX.gleam file."""
    meta = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line.startswith("///"):
                break
            m = re.match(r'///\s+(\w+):\s+(.*)', line)
            if m:
                key = m.group(1).lower()
                val = m.group(2).strip()
                meta[key] = val

    if not all(k in meta for k in ("title", "link", "difficulty", "tags")):
        return None

    day_num = int(re.search(r'day_(\d+)', path.stem).group(1))
    meta["day"] = day_num
    # Support both "tag1 tag2" and "tag1, tag2" formats
    meta["tags"] = [t.strip(",").strip() for t in re.split(r'[,\s]+', meta["tags"]) if t.strip(",").strip()]
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
                meta["src_path"] = f"src/{year_dir.name}/{day_file.name}"
                solutions.append(meta)
    return solutions


def diff_icon(d: str) -> str:
    return DIFFICULTY_ICON.get(d, d.upper())


# ─── Home: grid-style progress table ──────────────────────────────────────────

def gen_home(solutions: list[dict]) -> str:
    solved: dict[tuple[int,int], dict] = {}
    for s in solutions:
        solved[(s["year"], s["day"])] = s

    years = sorted({s["year"] for s in solutions})
    total = len(solutions)
    stars = total * 2  # assume both parts done

    year_links = " | ".join(f"[{y}]({y}.md)" for y in years)

    lines = [
        "# aocgl — Advent of Code in Gleam\n\n",
        "[Advent of Code](https://adventofcode.com) puzzle solutions written in [Gleam](https://gleam.run).\n\n",
        f"> **{total} problems solved** across **{len(years)} years** — see [Tags](tags/index.md) or [Difficulty](difficulty.md) for more views.\n\n",
        f"**Years:** {year_links}\n\n",
        "---\n\n",
    ]

    # Build grid header
    year_header = " | ".join(f"[{y}]({y}.md)" for y in years)
    lines.append(f"| Day | {year_header} |\n")
    lines.append("|:---:|" + ":-:|" * len(years) + "\n")

    for day in ALL_DAYS:
        cells = []
        for year in years:
            s = solved.get((year, day))
            if s:
                cells.append(f"[⭐]({s['link']})")
            else:
                cells.append(" ")
        lines.append(f"| {day} | " + " | ".join(cells) + " |\n")

    return "".join(lines)


# ─── Per-year page ─────────────────────────────────────────────────────────────

def gen_year(year: int, solutions: list[dict], all_years: list[int]) -> str:
    sols = sorted(solutions, key=lambda s: s["day"])

    nav_parts = ["[Home](Home.md)"]
    for y in all_years:
        if y == year:
            nav_parts.append(str(y))
        else:
            nav_parts.append(f"[{y}]({y}.md)")
    nav = " | ".join(nav_parts)

    solved_count = len(sols)
    stars = solved_count * 2

    lines = [
        f"# Advent of Code {year}\n\n",
        f"{nav}\n\n",
        f"## ⭐ {stars}/50\n\n",
        "| Day | Title | Difficulty | Tags | Source |\n",
        "|:---:|-------|:----------:|------|--------|\n",
    ]

    for s in sols:
        tags = ", ".join(f"[{t}](tags/{t}.md)" for t in s["tags"])
        src = f"[source](../{s['src_path']})"
        lines.append(
            f"| [{s['day']}]({s['link']}) "
            f"| [{s['title']}]({s['link']}) "
            f"| {diff_icon(s['difficulty'])} "
            f"| {tags} "
            f"| {src} |\n"
        )

    return "".join(lines)


# ─── Tags: index + individual pages ───────────────────────────────────────────

def gen_tag_index(tag_map: dict[str, list[dict]]) -> str:
    lines = [
        "# 🏷️ Tags Index\n\n",
        "[← Home](../Home.md)\n\n",
        "Each tag links to a dedicated page with all matching solutions.\n\n",
        "| Tag | Count |\n",
        "|-----|------:|\n",
    ]
    for tag in sorted(tag_map.keys()):
        count = len(tag_map[tag])
        lines.append(f"| [{tag}]({tag}.md) | {count} |\n")
    return "".join(lines)


def gen_tag_page(tag: str, solutions: list[dict]) -> str:
    sols = sorted(solutions, key=lambda s: (s["year"], s["day"]))
    lines = [
        f"# Tag: `{tag}`\n\n",
        "[← Tags Index](index.md)\n\n",
        "| Year | Day | Title | Difficulty | Other Tags | Source |\n",
        "|------|:---:|-------|:----------:|------------|--------|\n",
    ]
    for s in sols:
        other_tags = ", ".join(f"[{t}]({t}.md)" for t in s["tags"] if t != tag)
        src = f"[source](../../{s['src_path']})"
        lines.append(
            f"| {s['year']} "
            f"| [{s['day']}]({s['link']}) "
            f"| [{s['title']}]({s['link']}) "
            f"| {diff_icon(s['difficulty'])} "
            f"| {other_tags} "
            f"| {src} |\n"
        )
    return "".join(lines)


# ─── Difficulty page ───────────────────────────────────────────────────────────

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
        lines.append(f"## {diff_icon(diff)}\n\n")
        lines.append("| Year | Day | Title | Tags | Source |\n")
        lines.append("|------|:---:|-------|------|--------|\n")
        for s in sols:
            tags = ", ".join(f"[{t}](tags/{t}.md)" for t in s["tags"])
            src = f"[source]({s['src_path']})"
            lines.append(
                f"| {s['year']} "
                f"| [{s['day']}]({s['link']}) "
                f"| [{s['title']}]({s['link']}) "
                f"| {tags} "
                f"| {src} |\n"
            )
        lines.append("\n")
    return "".join(lines)


# ─── Main ──────────────────────────────────────────────────────────────────────

def main():
    # Clean and recreate wiki dir
    if WIKI_DIR.exists():
        shutil.rmtree(WIKI_DIR)
    WIKI_DIR.mkdir()
    tags_dir = WIKI_DIR / "tags"
    tags_dir.mkdir()

    solutions = collect_all_solutions()
    all_years = sorted({s["year"] for s in solutions})
    print(f"Collected {len(solutions)} solutions.")

    # Home
    (WIKI_DIR / "Home.md").write_text(gen_home(solutions))
    print("  Wrote wiki/Home.md")

    # Per-year
    by_year: dict[int, list[dict]] = defaultdict(list)
    for s in solutions:
        by_year[s["year"]].append(s)

    for year, sols in sorted(by_year.items()):
        (WIKI_DIR / f"{year}.md").write_text(gen_year(year, sols, all_years))
        print(f"  Wrote wiki/{year}.md")

    # Tags
    tag_map: dict[str, list[dict]] = defaultdict(list)
    for s in solutions:
        for t in s["tags"]:
            tag_map[t].append(s)

    (tags_dir / "index.md").write_text(gen_tag_index(tag_map))
    print("  Wrote wiki/tags/index.md")

    for tag, sols in sorted(tag_map.items()):
        (tags_dir / f"{tag}.md").write_text(gen_tag_page(tag, sols))
        print(f"  Wrote wiki/tags/{tag}.md")

    # Difficulty
    (WIKI_DIR / "difficulty.md").write_text(gen_difficulty(solutions))
    print("  Wrote wiki/difficulty.md")

    print(f"\nDone! {len(tag_map)} tag files + index, {len(all_years)} year files.")


if __name__ == "__main__":
    main()
