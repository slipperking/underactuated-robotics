# underactuated-robotics

Typst 0.15+ is required.

Build the PDF:

```powershell
New-Item -ItemType Directory -Force build
typst compile --package-path packages main.typ build/notes.pdf
```

Build the website bundle:

```powershell
if (Test-Path web/dist) { Remove-Item web/dist -Recurse -Force }
typst compile --features html,bundle --format bundle --package-path packages main.typ web/dist
```

The bundle build emits the HTML pages and shared assets from Typst, and embeds
the prebuilt `build/notes.pdf` as `pdf/notes.pdf`. No Python split pipeline is
used.

## Authoring structure

- `main.typ` only calls the build entrypoint.
- `lib.typ` is the public math/theorem/helper API used by chapter files.
- `chapters/**/index.typ` files are the author-facing structure and include
  children in reading order.
- Leaf chapter files contain ordinary Typst markup. At the top, they declare
  their page metadata with `#show: docs-section.with(...)` or the matching
  page type, then write content directly.
- To add a section, add its folder/file with a page-local `#show` declaration
  and include it from the nearest parent `index.typ`; `main.typ` does not need
  to change.
- `src/components/` contains build, style, theorem, math, and graphics internals.
- `src/assets/` contains files emitted by bundle export.
