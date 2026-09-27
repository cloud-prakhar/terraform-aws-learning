#!/usr/bin/env python3
"""Check that every relative Markdown link in the repository resolves.

Verifies that linked files/directories exist and that #anchors match a
heading in the target file (using GitHub's heading-slug rules).
External (http/https/mailto) links are not checked.

Usage: python3 scripts/check-links.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
FENCE = re.compile(r"^\s*(```|~~~)")
SKIP_DIRS = {".git", ".terraform", "node_modules"}


def strip_code(text: str, keep_inline: bool = False) -> list[str]:
    """Return lines with fenced code blocks blanked out.

    Inline code is removed too (links inside it are not links), unless
    keep_inline is set: headings keep their inline-code text in the slug.
    """
    lines, in_fence = [], False
    for line in text.splitlines():
        if FENCE.match(line):
            in_fence = not in_fence
            lines.append("")
            continue
        if in_fence:
            lines.append("")
        elif keep_inline:
            lines.append(line.replace("`", ""))
        else:
            lines.append(re.sub(r"`[^`]*`", "", line))
    return lines


def slugify(heading: str) -> str:
    heading = re.sub(r"<[^>]+>", "", heading)  # drop inline HTML
    heading = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", heading)  # [text](url) -> text
    heading = heading.strip().lower()
    heading = re.sub(r"[^\w\- ]", "", heading)  # keep letters, digits, _, -, space
    return heading.replace(" ", "-")


def anchors(path: Path) -> set[str]:
    seen: dict[str, int] = {}
    result = set()
    for line in strip_code(path.read_text(encoding="utf-8"), keep_inline=True):
        match = HEADING.match(line)
        if not match:
            continue
        slug = slugify(match.group(2))
        count = seen.get(slug, 0)
        seen[slug] = count + 1
        result.add(slug if count == 0 else f"{slug}-{count}")
    return result


def main() -> int:
    errors = []
    files = [p for p in ROOT.rglob("*.md") if not SKIP_DIRS.intersection(p.parts)]
    cache: dict[Path, set[str]] = {}
    for md in files:
        for number, line in enumerate(strip_code(md.read_text(encoding="utf-8")), 1):
            for target in LINK.findall(line):
                if re.match(r"^(https?:|mailto:)", target):
                    continue
                path_part, _, anchor = target.partition("#")
                dest = (md.parent / path_part).resolve() if path_part else md
                where = f"{md.relative_to(ROOT)}:{number}"
                if not dest.exists():
                    errors.append(f"{where}: missing target '{target}'")
                    continue
                if anchor:
                    if dest.is_dir():
                        dest = dest / "README.md"
                    if dest.suffix != ".md" or not dest.exists():
                        continue
                    if dest not in cache:
                        cache[dest] = anchors(dest)
                    if anchor.lower() not in cache[dest]:
                        errors.append(f"{where}: missing anchor '#{anchor}' in {dest.relative_to(ROOT)}")
    for error in errors:
        print(error)
    print(f"Checked {len(files)} Markdown files: {len(errors)} broken link(s).")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
