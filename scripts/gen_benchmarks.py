#!/usr/bin/env python3
import subprocess
import platform
import os
import re
from datetime import datetime
from collections import defaultdict
from pathlib import Path
import subprocess
import platform
import os
from datetime import datetime
from pathlib import Path

REPO_DIR = Path(__file__).resolve().parent.parent
WIKI_DIR = REPO_DIR / "wiki"
BENCHMARK_FILE = WIKI_DIR / "benchmarks.md"
README_FILE = REPO_DIR / "README.md"
SRC_DIR = REPO_DIR / "src"

def get_cpu_info():
    try:
        # Try to get detailed CPU info on Linux
        output = subprocess.check_output(["lscpu"], text=True)
        for line in output.splitlines():
            if "Model name" in line:
                return line.split(":", 1)[1].strip()
    except Exception:
        pass
    return platform.processor() or "Unknown CPU"

def run_benchmarks():
    print("Running Gleam benchmarks... This might take a while.")
    result = subprocess.run(
        ["gleam", "run", "-m", "common/benchmark"],
        capture_output=True,
        text=True,
        cwd=REPO_DIR
    )
    if result.returncode != 0:
        print("Error running benchmarks:")
        print(result.stderr)
        return None
    return result.stdout

def parse_day_file(path: Path):
    meta = {}
    if not path.exists():
        return meta
    
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line.startswith("///"):
                break
            m = re.match(r'///\s+(\w+):\s+(.*)', line)
            if m:
                meta[m.group(1).lower()] = m.group(2).strip()
    return meta

def get_difficulty_icon(diff_code: str) -> str:
    icons = {
        "xs": "🟢",
        "s":  "🟡",
        "m":  "🟠",
        "l":  "🔴",
        "xl": "💀",
    }
    code = diff_code.lower()
    return f"{icons.get(code, code.upper())}"

def parse_benchmarks(output):
    lines = output.strip().splitlines()
    if not lines or "year,day,time_ms" not in lines[0]:
        return []
    
    results = []
    for line in lines[1:]:
        parts = line.split(",")
        if len(parts) == 3:
            year, day, time_ms = parts[0], parts[1], float(parts[2])
            
            # Extract metadata from source code
            src_file = SRC_DIR / f"year_{year}" / f"day_{day.zfill(2)}.gleam"
            meta = parse_day_file(src_file)
            
            # Default fallbacks
            title = meta.get("title", f"Day {day}")
            link = meta.get("link", f"https://adventofcode.com/{year}/day/{day}")
            difficulty = meta.get("difficulty", "M")
            
            results.append({
                "year": year,
                "day": int(day),
                "time_ms": time_ms,
                "title": title,
                "link": link,
                "difficulty_icon": get_difficulty_icon(difficulty)
            })
    return sorted(results, key=lambda x: (x["year"], x["day"]))

def generate_markdown(results, system_info):
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    lines = [
        "# ⚡ Benchmarks\n\n",
        "[← Home](../README.md)\n\n",
        "## System Information\n\n",
        f"- **Run Date:** {now}\n",
        f"- **OS:** {system_info['os']} {system_info['release']}\n",
        f"- **CPU:** {system_info['cpu']}\n\n",
        "## Performance Results\n\n",
    ]
    
    by_year = defaultdict(list)
    for res in results:
        by_year[res['year']].append(res)
        
    for year in sorted(by_year.keys()):
        lines.append(f"### {year}\n\n")
        lines.append("| Day | Title | Difficulty | Time (ms) |\n")
        lines.append("|:---:|-------|:----------:|----------:|\n")
        for res in by_year[year]:
            lines.append(f"| {res['day']} | [{res['title']}]({res['link']}) | {res['difficulty_icon']} | {res['time_ms']:.3f} |\n")
        lines.append("\n")
        
    return "".join(lines)

def update_readme():
    if not README_FILE.exists():
        return
    
    text = README_FILE.read_text()
    link_text = "[Benchmarks](wiki/benchmarks.md)"
    
    if link_text in text:
        return
    
    # Try to find the stats block to add the link
    stats_start = "<!-- STATS_START -->"
    if stats_start in text:
        # Find the line with Tags and Difficulty and add Benchmarks
        parts = text.split(stats_start, 1)
        next_part = parts[1]
        if "[Difficulty]" in next_part:
            new_next = next_part.replace("[Difficulty](wiki/difficulty.md)", "[Difficulty](wiki/difficulty.md) · " + link_text)
            README_FILE.write_text(parts[0] + stats_start + new_next)
            print("Updated README.md with benchmark link.")

def main():
    if not WIKI_DIR.exists():
        WIKI_DIR.mkdir()

    output = run_benchmarks()
    if not output:
        return

    results = parse_benchmarks(output)
    if not results:
        print("No results found.")
        return

    system_info = {
        "os": platform.system(),
        "release": platform.release(),
        "cpu": get_cpu_info()
    }

    markdown = generate_markdown(results, system_info)
    BENCHMARK_FILE.write_text(markdown)
    print(f"Wrote benchmarks to {BENCHMARK_FILE}")

    update_readme()
    print("Done!")

if __name__ == "__main__":
    main()
