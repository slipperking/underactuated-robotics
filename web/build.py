# /// script
# dependencies = ["beautifulsoup4", "pagefind[extended]"]
# ///
import argparse
import json
import posixpath
import re
import shutil
import subprocess
import sys
from pathlib import Path, PurePosixPath

try:
    from bs4 import BeautifulSoup, Tag
except ImportError:
    print("Error: beautifulsoup4 required. Run with: uv run web/build.py")
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
WEB_DIR = ROOT / "web"
DIST_DIR = WEB_DIR / "dist"
ASSETS_SRC = WEB_DIR / "assets"

THESIS_TITLE = "Notes on Underactuated Robotics"
GITHUB_URL = "https://github.com/slipperking/underactuated-robotics"
BASE_URL = "/"  # overridden by --base-url CLI arg
HEADING_TAGS = {"h2", "h3", "h4", "h5", "h6"}

TOC_MIN_LEVEL = 2
HEADING_NUMBER_RE = re.compile(
    r"^(?:Chapter\s+(?P<chapter>\d+):\s*(?P<chapter_label>.*)|"
    r"Appendix\s+(?P<appendix>[A-Z]):\s*(?P<appendix_label>.*)|"
    r"(?P<number>\d+(?:\.\d+)*)(?:[.)]\s*|\s+)(?P<label>.*))$"
)

ICON_HAMBURGER = (
    '<svg width="20" height="20" viewBox="0 0 20 20" fill="none"'
    ' stroke="currentColor" stroke-width="2">'
    '<path d="M3 5h14M3 10h14M3 15h14"/></svg>'
)
ICON_SEARCH = (
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none"'
    ' stroke="currentColor" stroke-width="2">'
    '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>'
)
ICON_GITHUB = (
    '<svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">'
    '<path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17'
    ".55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94"
    "-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87"
    " 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59"
    ".82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27"
    "s1.36.09 2 .27c1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82"
    " 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01"
    ' 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8z"/>'
    "</svg>"
)
ICON_TOC = (
    '<svg width="20" height="20" viewBox="0 0 20 20" fill="none"'
    ' stroke="currentColor" stroke-width="2">'
    '<path d="M3 4h14M3 8h10M3 12h12M3 16h8"/></svg>'
)
ICON_THEME_LIGHT = (
    '<svg viewBox="0 0 512 512" width="18" height="18" aria-hidden="true" fill="currentColor">'
    '<path d="M361.5 1.2c5 2.1 8.6 6.6 9.6 11.9L391 121l107.9 19.8c5.3 1 9.8 4.6 11.9 9.6'
    "s1.5 10.7-1.6 15.2L446.9 256l62.3 90.3c3.1 4.5 3.7 10.2 1.6 15.2s-6.6 8.6-11.9 9.6"
    "L391 391 371.1 498.9c-1 5.3-4.6 9.8-9.6 11.9s-10.7 1.5-15.2-1.6L256 446.9l-90.3 62.3"
    "c-4.5 3.1-10.2 3.7-15.2 1.6s-8.6-6.6-9.6-11.9L121 391 13.1 371.1c-5.3-1-9.8-4.6-11.9"
    "-9.6s-1.5-10.7 1.6-15.2L65.1 256 2.8 165.7c-3.1-4.5-3.7-10.2-1.6-15.2s6.6-8.6 11.9-9.6"
    "L121 121 140.9 13.1c1-5.3 4.6-9.8 9.6-11.9s10.7-1.5 15.2 1.6L256 65.1 346.3 2.8"
    'c4.5-3.1 10.2-3.7 15.2-1.6zM160 256a96 96 0 1 1 192 0 96 96 0 1 1 -192 0z'
    "m224 0a128 128 0 1 0 -256 0 128 128 0 1 0 256 0z\"/></svg>"
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def heading_level(tag: Tag) -> int:
    """Return the numeric level of an hN tag (2–6)."""
    return int(tag.name[1])


def ensure_anchor_id(node: Tag, fallback_text: str) -> str:
    """Ensure *node* has an id attribute, generating one from text if absent."""
    node_id = node.get("id", "")
    if node_id:
        return node_id
    slug = re.sub(r"[^\w-]", "-", fallback_text.lower())[:60].strip("-") or "section"
    node["id"] = slug
    return slug


def split_heading_prefix(text: str) -> tuple[str | None, str]:
    """Return (number_prefix, label) for a heading-like string."""
    text = " ".join(text.split())
    match = HEADING_NUMBER_RE.match(text)
    if match:
        number = (
            match.group("chapter")
            or match.group("appendix")
            or match.group("number")
        )
        label = (
            match.group("chapter_label")
            or match.group("appendix_label")
            or match.group("label")
            or ""
        )
        return number, label.strip()
    return None, text


def clean_nav_title_text(text: str) -> str:
    """Strip leading chapter/section number prefixes from plain-text nav labels."""
    _number, label = split_heading_prefix(text)
    return label


def heading_inner_html(heading: Tag) -> str:
    """Return a heading's inner HTML exactly as rendered."""
    cloned = BeautifulSoup(str(heading), "html.parser").find(heading.name)
    return cloned.decode_contents().strip() if cloned else ""


def section_filename(section_id: str) -> str:
    """Map a top-level section id to its output filename."""
    return "index.html" if section_id == "cover" else f"{section_id}/index.html"


def relative_href(current_file: str, target_file: str, anchor: str | None = None) -> str:
    """Build a relative URL from one generated page to another."""
    current_dir = PurePosixPath(current_file).parent.as_posix()
    rel = posixpath.relpath(target_file, current_dir if current_dir != "." else ".")
    if rel == "index.html":
        rel = "./"
    elif rel.endswith("/index.html"):
        rel = rel[: -len("index.html")]
    return f"{rel}#{anchor}" if anchor else rel


def asset_href(current_file: str, asset_path: str) -> str:
    """Build a relative URL from a generated page to a shared asset."""
    current_dir = PurePosixPath(current_file).parent.as_posix()
    return posixpath.relpath(asset_path, current_dir if current_dir != "." else ".")


# ---------------------------------------------------------------------------
# Step 1: Compile Typst → HTML
# ---------------------------------------------------------------------------

def compile_typst() -> Path:
    """Compile the notes to a single HTML file via Typst."""
    full_html = DIST_DIR / "full.html"
    DIST_DIR.mkdir(parents=True, exist_ok=True)
    cmd = [
        "typst", "compile",
        "--features", "html",
        "--format", "html",
        "--package-path", str(ROOT / "packages"), # local packages
        "--input", "html=true",
        str(ROOT / "main.typ"),
        str(full_html),
    ]
    print(f"  Compiling HTML: {' '.join(cmd[-3:])}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        for line in result.stderr.splitlines():
            if line.startswith("error:"):
                print(line, file=sys.stderr)
        sys.exit(1)
    warnings = [l for l in result.stderr.splitlines() if l.startswith("warning:")]
    if warnings:
        print(f"    ({len(warnings)} warnings suppressed)")
    print(f"    -> {full_html.name} ({full_html.stat().st_size // 1024} KB)")
    return full_html


# ---------------------------------------------------------------------------
# Step 2: Compile PDFs
# ---------------------------------------------------------------------------

def compile_pdfs() -> None:
    """Compile the PDF version of the notes."""
    pdf_dir = DIST_DIR / "pdf"
    pdf_dir.mkdir(parents=True, exist_ok=True)
    out = pdf_dir / "notes.pdf"
    cmd = [
        "typst", "compile",
        "--features", "html",   # so that target() works
        "--package-path", str(ROOT / "packages"), # local packages
        str(ROOT / "main.typ"),
        str(out),
    ]
    print("  Compiling PDF...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        for line in result.stderr.splitlines():
            if line.startswith("error:"):
                print(line, file=sys.stderr)
        print("  WARNING: PDF compilation failed", file=sys.stderr)
        return
    warnings = [l for l in result.stderr.splitlines() if l.startswith("warning:")]
    if warnings:
        print(f"    ({len(warnings)} warnings suppressed)")
    print(f"    -> pdf/notes.pdf ({out.stat().st_size // 1024} KB)")


# ---------------------------------------------------------------------------
# Step 3: Parse and split into chapters
# ---------------------------------------------------------------------------

def theorem_toc_entry(theorem_box: Tag, section: Tag, level: int) -> dict | None:
    """Build a local TOC entry for a theorem-like block, or None if not applicable.

    *level* should be the parent heading level + 1 so the entry sits one
    indent step deeper than its containing section heading in the TOC.
    """
    classes = theorem_box.get("class", [])
    if "thm-box" not in classes or "thm-remark" in classes:
        return None

    head = theorem_box.find("p", class_="thm-head")
    if head is None:
        return None

    text = " ".join(head.get_text(" ", strip=True).split())
    if not text:
        return None

    anchor_id = ensure_anchor_id(theorem_box, text)

    return {
        "level": level,
        "kind": "theorem",
        "id": anchor_id,
        "text": text,
        "html": head.decode_contents().strip(),
    }


def extract_local_toc(section: Tag) -> list[dict]:
    """Walk *section* and collect heading + theorem entries for the local TOC."""
    toc: list[dict] = []
    current_heading_level = TOC_MIN_LEVEL

    for node in section.descendants:
        if not isinstance(node, Tag):
            continue

        if node.name in HEADING_TAGS:
            lvl = heading_level(node)
            heading_id = ensure_anchor_id(node, node.get_text(strip=True))
            current_heading_level = lvl
            toc.append({
                "level": lvl,
                "kind": "heading",
                "id": heading_id,
                "text": node.get_text(strip=True),
                "html": heading_inner_html(node),
            })
            continue

        entry = theorem_toc_entry(node, section, level=current_heading_level + 1)
        if entry is not None:
            toc.append(entry)

    return toc


def discover_structure(
    soup: BeautifulSoup,
) -> tuple[
    list[tuple[str, str, str]],
    list[tuple[str, str, str, str]],
    dict[str, int],
    list[tuple[str | None, list[str]]],
]:
    """Discover pages and navigation entries from chapter-section blocks.

    Returns:
        pages:      [(sid, filename, page_title), ...]
        nav_items:  [(sid, filename, page_title, nav_title_html), ...]
        nav_depths: {sid: depth}
        parts:      [(part_title | None, [sid, ...]), ...]
    """
    pages: list[tuple[str, str, str]] = []
    nav_items: list[tuple[str, str, str, str]] = []
    nav_depths: dict[str, int] = {}

    for section in soup.find_all("section", class_="chapter"):
        sid = section.get("id", "")
        if not sid:
            continue

        title_heading = section.find(["h1", "h2", "h3", "h4", "h5", "h6"], recursive=False)
        if title_heading is not None:
            depth = max(0, heading_level(title_heading) - 1)
        else:
            attr_depth = section.get("data-nav-depth")
            if attr_depth is not None:
                try:
                    depth = max(0, int(attr_depth))
                except ValueError:
                    depth = len(section.find_parents("section", class_="chapter"))
            else:
                depth = len(section.find_parents("section", class_="chapter"))

        page_title = (
            clean_nav_title_text(title_heading.get_text(" ", strip=True))
            if title_heading
            else sid.replace("-", " ").title()
        )
        nav_title_html = (
            heading_inner_html(title_heading) if title_heading else page_title
        )

        if sid == "cover":
            page_title = "Home"
            nav_title_html = "Home"

        filename = section_filename(sid)
        pages.append((sid, filename, page_title))
        nav_items.append((sid, filename, page_title, nav_title_html))
        nav_depths[sid] = depth

    parts: list[tuple[str | None, list[str]]] = [
        (None, [sid for sid, *_ in nav_items])
    ]
    return pages, nav_items, nav_depths, parts


# ---------------------------------------------------------------------------
# Navigation HTML builders
# ---------------------------------------------------------------------------

def build_global_nav(
    nav_items: list[tuple[str, str, str, str]],
    parts: list[tuple],
    current_id: str,
    nav_depths: dict[str, int],
    current_file: str,
) -> tuple[str, list[str]]:
    """Build the global navigation sidebar HTML.

    Returns (html_string, list_of_active_group_ids).
    """
    chapter_map = {sid: (href, title, nav_html) for sid, href, title, nav_html in nav_items}

    def build_nav_tree(section_ids: list[str]) -> list[dict]:
        roots: list[dict] = []
        stack: list[tuple[int, dict]] = []
        for sid in section_ids:
            depth = nav_depths.get(sid, 0)
            node: dict = {"sid": sid, "depth": depth, "children": []}
            while stack and stack[-1][0] >= depth:
                stack.pop()
            (stack[-1][1]["children"] if stack else roots).append(node)
            stack.append((depth, node))
        return roots

    def render_nodes(nodes: list[dict], level: int = 0) -> tuple[list[str], bool, list[str]]:
        indent = "  " * level
        lines = [f"{indent}<ul>"]
        contains_active = False
        active_group_ids: list[str] = []

        for node in nodes:
            sid = node["sid"]
            target_file, _title, nav_title_html = chapter_map[sid]
            depth = node["depth"]
            node_is_active = sid == current_id

            classes = []
            if node_is_active:
                classes.append("active")
            if depth > 0:
                classes.append("nav-sub")
                classes.append(f"nav-depth-{depth}")
            if node["children"]:
                classes.append("nav-parent")

            cls = f' class="{" ".join(classes)}"' if classes else ""
            href = relative_href(current_file, target_file)
            lines.append(f"{indent}  <li{cls}>")

            if node["children"]:
                controls_id = f"nav-group-{sid}"
                child_lines, child_active, child_group_ids = render_nodes(
                    node["children"], level + 3
                )
                node_contains_active = node_is_active or child_active
                lines += [
                    f'{indent}    <div class="nav-item-row">',
                    f'{indent}      <a href="{href}">{nav_title_html}</a>',
                    f'{indent}      <button class="nav-collapse-toggle" type="button"'
                    f' aria-expanded="true" aria-label="Collapse subsection"'
                    f' aria-controls="{controls_id}"></button>',
                    f"{indent}    </div>",
                    f'{indent}    <div class="nav-children" id="{controls_id}">',
                    *child_lines,
                    f"{indent}    </div>",
                ]
                if node_contains_active:
                    active_group_ids.append(controls_id)
                active_group_ids.extend(child_group_ids)
                contains_active = contains_active or node_contains_active
            else:
                lines.append(f'{indent}    <a href="{href}">{nav_title_html}</a>')
                contains_active = contains_active or node_is_active

            lines.append(f"{indent}  </li>")

        lines.append(f"{indent}</ul>")
        return lines, contains_active, active_group_ids

    lines = ['<nav class="global-nav" aria-label="Global navigation">']
    active_nav_groups: list[str] = []
    for part_title, section_ids in parts:
        if part_title:
            lines.append(f'  <div class="nav-part">{part_title}</div>')
        part_lines, _active, part_groups = render_nodes(build_nav_tree(section_ids), 1)
        lines.extend(part_lines)
        active_nav_groups.extend(part_groups)
    lines.append("</nav>")
    return "\n".join(lines), active_nav_groups


def build_local_toc(toc: list[dict]) -> str:
    """Build the local TOC sidebar HTML.

    Indentation is driven entirely by item["level"]:
      level 2 → toc-l2 (base, no extra indent)
      level 3 → toc-l3 (one step in)
      level 4 → toc-l4, etc.
    Theorem entries are extracted with level = parent_heading_level + 1,
    so they already sit one step deeper than their section — no special
    offset logic needed here.
    """
    if not toc:
        return ""

    title = "On this page"
    lines = [
        f'<nav class="local-toc" aria-label="{title}">',
        f"  <h3>{title}</h3>",
        "  <ul>",
    ]

    for item in toc:
        level = item["level"]
        # Clamp to the range the CSS handles (toc-l2 … toc-l6).
        css_level = max(TOC_MIN_LEVEL, min(level, 6))

        classes = [f"toc-l{css_level}"]
        if item["kind"] == "heading":
            classes.append("toc-page")
        elif item["kind"] == "theorem":
            classes.append("toc-theorem")

        cls = f' class="{" ".join(classes)}"'
        label_html = item.get("html") or item["text"]
        indent = "    " if css_level == TOC_MIN_LEVEL else "      "
        lines.append(f'{indent}<li{cls}><a href="#{item["id"]}">{label_html}</a></li>')

    lines += ["  </ul>", "</nav>"]
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Page assembly
# ---------------------------------------------------------------------------

def build_page(
    section_html: str,
    global_nav: str,
    active_nav_groups: list[str],
    local_toc: str,
    title: str,
    thesis_title: str,
    prev_link: tuple[str, str] | None,
    next_link: tuple[str, str] | None,
    current_file: str,
) -> str:
    """Assemble a complete HTML page."""
    prev_btn = (
        f'<a href="{relative_href(current_file, prev_link[0])}" class="nav-prev">'
        f"&larr; {prev_link[1]}</a>"
        if prev_link else "<span></span>"
    )
    next_btn = (
        f'<a href="{relative_href(current_file, next_link[0])}" class="nav-next">'
        f"{next_link[1]} &rarr;</a>"
        if next_link else "<span></span>"
    )

    search_label = "Search"
    home_href = relative_href(current_file, "index.html")
    favicon_href = asset_href(current_file, "assets/favicon.svg")
    stylesheet_href = asset_href(current_file, "assets/style.css")
    script_href = asset_href(current_file, "assets/modifications.js")
    active_nav_groups_json = json.dumps(active_nav_groups)

    return f"""\
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title} — {thesis_title}</title>
  <meta name="author" content="Fabien Mathieu">
  <meta name="pagefind-base" content="{BASE_URL}">
  <link rel="icon" href="{favicon_href}" type="image/svg+xml">
  <link rel="stylesheet" href="{stylesheet_href}">
  <script>
    (function(){{
      var t=localStorage.getItem("theme")||"auto";
      if(t==="auto")t=matchMedia("(prefers-color-scheme:dark)").matches?"dark":"light";
      document.documentElement.dataset.theme=t;
    }})();
  </script>
  <script>
    (function(){{
      var activeNavGroups={active_nav_groups_json};
      var collapsed={{}};
      try{{collapsed=JSON.parse(sessionStorage.getItem("global-nav-collapsed")||"{{}}")||{{}};}}
      catch(_){{}}
      for(var i=0;i<activeNavGroups.length;i++){{delete collapsed[activeNavGroups[i]];}}
      var ids=Object.keys(collapsed).filter(function(id){{return collapsed[id];}});
      if(!ids.length)return;
      var s=document.createElement("style");
      s.id="nav-collapsed-state";
      s.textContent=ids.map(function(id){{return"#"+id+"{{display:none;}}"}}).join("");
      document.head.appendChild(s);
    }})();
  </script>
</head>
<body>
  <header class="topbar" data-pagefind-ignore>
    <div class="topbar-left">
      <button class="sidebar-toggle-btn" id="sidebar-toggle-left" aria-label="Menu">{ICON_HAMBURGER}</button>
      <a href="{home_href}" class="topbar-title">{thesis_title}</a>
    </div>
    <div class="topbar-right">
      <button class="search-trigger" aria-label="{search_label} (Ctrl+K)">{ICON_SEARCH} <kbd>Ctrl+K</kbd></button>
      <button class="theme-toggle" aria-label="Toggle theme" title="Toggle theme">{ICON_THEME_LIGHT}</button>
      <a href="{GITHUB_URL}" class="github-link" aria-label="GitHub" target="_blank" rel="noopener">{ICON_GITHUB}</a>
      <button class="sidebar-toggle-btn" id="sidebar-toggle-right" aria-label="Table of contents">{ICON_TOC}</button>
    </div>
  </header>
  <div class="layout">
    <aside class="sidebar-left" data-pagefind-ignore>
      {global_nav}
    </aside>
    <main class="content">
      {section_html}
      <footer class="page-nav" data-pagefind-ignore>
        {prev_btn}
        {next_btn}
      </footer>
    </main>
    <aside class="sidebar-right" data-pagefind-ignore>
      {local_toc}
    </aside>
  </div>
  <div class="sidebar-backdrop" id="sidebar-backdrop"></div>
  <div class="search-overlay" id="search-overlay">
    <div class="search-dialog">
      <div class="search-header">
        <input type="text" class="search-input" id="search-input"
               placeholder="{search_label}..." autocomplete="off">
        <kbd class="search-close">Esc</kbd>
      </div>
      <div class="search-results" id="search-results"></div>
    </div>
  </div>
  <script src="{script_href}"></script>
</body>
</html>"""


# ---------------------------------------------------------------------------
# Step 3 (cont.): Split full HTML into per-chapter pages
# ---------------------------------------------------------------------------

def split_and_generate(full_html: Path) -> None:
    """Parse the monolithic HTML, split by chapter sections, write individual pages."""
    out_dir = DIST_DIR
    out_dir.mkdir(parents=True, exist_ok=True)

    print("  Parsing HTML...")
    soup = BeautifulSoup(full_html.read_text(encoding="utf-8"), "html.parser")
    pages, nav_items, nav_depths, parts = discover_structure(soup)

    chapter_map = {sid: (fname, title) for sid, fname, title in pages}

    # Collect section Tag objects
    sections: dict[str, Tag] = {}
    for section in soup.find_all("section", class_="chapter"):
        sid = section.get("id", "")
        if sid in chapter_map:
            sections[sid] = section
    print(f"    Found {len(sections)} chapter sections")

    # Collect endnotes / footnotes
    endnotes_section = soup.find("section", attrs={"role": "doc-endnotes"})
    footnote_map: dict[str, Tag] = {}
    if endnotes_section:
        for li in endnotes_section.find_all("li", id=True):
            footnote_map[li["id"]] = li
        print(f"    Found {len(footnote_map)} footnotes")

    # Build id → filename map for cross-chapter link rewriting
    id_to_file: dict[str, str] = {}
    for sid, fname, _title in pages:
        if sid not in sections:
            continue
        id_to_file[sid] = fname
        for elem in sections[sid].find_all(attrs={"id": True}):
            id_to_file[elem["id"]] = fname

    # Map footnote ids to the chapter that references them
    if footnote_map:
        for sid, fname, _title in pages:
            if sid not in sections:
                continue
            for ref_a in sections[sid].find_all("a", attrs={"role": "doc-noteref"}):
                target_id = ref_a.get("href", "").lstrip("#")
                if target_id in footnote_map:
                    id_to_file[target_id] = fname

    cross_links_total = 0

    for i, (sid, fname, title) in enumerate(pages):
        if sid not in sections:
            print(f"    WARNING: section '{sid}' not found, skipping")
            continue

        # Clone the section so we can mutate it freely
        page_section: Tag | None = BeautifulSoup(str(sections[sid]), "html.parser").find("section")
        if page_section is None:
            print(f"    WARNING: could not clone section '{sid}', skipping")
            continue

        # Remove nested chapter sections — they get their own pages
        for nested in page_section.find_all("section", class_="chapter"):
            nested.decompose()

        local_toc = extract_local_toc(page_section)
        global_nav, active_nav_groups = build_global_nav(
            nav_items, parts, sid, nav_depths, fname
        )
        local_toc_html = build_local_toc(local_toc)

        prev_link = (nav_items[i - 1][1], nav_items[i - 1][3]) if i > 0 else None
        next_link = (nav_items[i + 1][1], nav_items[i + 1][3]) if i < len(pages) - 1 else None

        # Rewrite cross-chapter internal links
        cross_links = 0
        for a_tag in page_section.find_all("a", href=True):
            href = a_tag["href"]
            if href.startswith("#"):
                target_id = href[1:]
                target_file = id_to_file.get(target_id)
                if target_file and target_file != fname:
                    a_tag["href"] = relative_href(fname, target_file, target_id)
                    cross_links += 1

        # Collect and inline footnotes referenced on this page
        footnotes_html = ""
        if footnote_map:
            chapter_footnotes: list[Tag] = []
            for ref_a in page_section.find_all("a", attrs={"role": "doc-noteref"}):
                target_id = ref_a.get("href", "").lstrip("#")
                if target_id in footnote_map:
                    chapter_footnotes.append(footnote_map[target_id])

            if chapter_footnotes:
                for fn in chapter_footnotes:
                    for a_tag in fn.find_all("a", href=True):
                        href = a_tag["href"]
                        if href.startswith("#"):
                            tid = href[1:]
                            target_file = id_to_file.get(tid)
                            if target_file and target_file != fname:
                                a_tag["href"] = relative_href(fname, target_file, tid)
                                cross_links += 1
                items = "\n".join(fn.decode() for fn in chapter_footnotes)
                footnotes_html = (
                    '\n<section class="footnotes" role="doc-endnotes">'
                    "\n<hr>\n"
                    '<ol style="list-style-type: none">\n'
                    f"{items}\n"
                    "</ol>\n</section>"
                )

        section_html = page_section.decode_contents() + footnotes_html
        cross_links_total += cross_links

        page = build_page(
            section_html=section_html,
            global_nav=global_nav,
            active_nav_groups=active_nav_groups,
            local_toc=local_toc_html,
            title=title,
            thesis_title=THESIS_TITLE,
            prev_link=prev_link,
            next_link=next_link,
            current_file=fname,
        )

        out_path = out_dir / fname
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(page, encoding="utf-8")
        print(f"    -> {out_path.relative_to(out_dir).as_posix()} ({len(local_toc)} TOC, {cross_links} xlinks)")

    print(f"    Total cross-chapter links rewritten: {cross_links_total}")


# ---------------------------------------------------------------------------
# Step 4: Copy assets
# ---------------------------------------------------------------------------

def copy_assets() -> None:
    """Copy CSS/JS assets to dist/assets/."""
    assets_dist = DIST_DIR / "assets"
    assets_dist.mkdir(parents=True, exist_ok=True)
    for src in ASSETS_SRC.glob("*"):
        if src.is_file():
            shutil.copy2(src, assets_dist / src.name)
            print(f"  -> assets/{src.name}")


# ---------------------------------------------------------------------------
# Step 5: Pagefind search index
# ---------------------------------------------------------------------------

def run_pagefind() -> None:
    """Index the built site with Pagefind."""
    pf_args = ["--site", str(DIST_DIR), "--output-subdir", "assets/pagefind"]
    candidates = [
        [sys.executable, "-m", "pagefind"] + pf_args,
        ["pagefind"] + pf_args,
        ["npx", "-y", "pagefind"] + pf_args,
    ]
    for cmd in candidates:
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            if result.returncode == 0:
                print("  Pagefind indexing complete")
                return
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue
    print("  WARNING: Pagefind not available, search will be disabled")
    print("  Install with: pip install pagefind, or npm i -g pagefind")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Build the HTML notes")
    parser.add_argument("--skip-pdf", action="store_true", help="Skip PDF compilation")
    parser.add_argument("--skip-compile", action="store_true", help="Skip Typst HTML compilation")
    parser.add_argument("--skip-search", action="store_true", help="Skip Pagefind indexing")
    parser.add_argument(
        "--base-url", default="/",
        help="Base URL prefix for deployment (e.g. /underactuated-robotics/)",
    )
    args = parser.parse_args()

    global BASE_URL
    BASE_URL = args.base_url

    print("=== Building HTML notes ===\n")

    if DIST_DIR.exists():
        for child in DIST_DIR.iterdir():
            if child.name == "assets":
                pagefind_dir = child / "pagefind"
                if pagefind_dir.exists():
                    shutil.rmtree(pagefind_dir)
                continue
            if child.name == "pdf":
                continue
            if args.skip_compile and child.name == "full.html":
                continue
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()

    # 1. Compile Typst → HTML
    if not args.skip_compile:
        print("[1/5] Compiling Typst -> HTML")
        full_html = compile_typst()
    else:
        print("[1/5] Skipping Typst compilation")
        full_html = DIST_DIR / "full.html"
        if not full_html.exists():
            print(f"  Error: {full_html.name} not found. Run without --skip-compile first.")
            sys.exit(1)

    # 2. Split into per-chapter pages
    print("\n[2/5] Splitting into chapter pages")
    split_and_generate(full_html)
    try:
        full_html.unlink()
    except (FileNotFoundError, PermissionError) as exc:
        print(f"  Warning: could not remove {full_html.name}: {exc}")

    # 3. Compile PDFs
    if not args.skip_pdf:
        print("\n[3/5] Compiling PDFs")
        compile_pdfs()
    else:
        print("\n[3/5] Skipping PDF compilation")

    # 4. Assets
    print("\n[4/5] Generating assets")
    copy_assets()

    # 5. Pagefind
    if not args.skip_search:
        print("\n[5/5] Running Pagefind search indexer")
        run_pagefind()
    else:
        print("\n[5/5] Skipping search indexing")

    print(f"\nDone! Open {DIST_DIR / 'index.html'} in a browser.")


if __name__ == "__main__":
    main()
