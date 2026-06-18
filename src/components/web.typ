#import "styles.typ": paper-styles, web-styles
#import "theorems.typ": theorem-toc-entry
#import "packages.typ": thm-counter, thm-state
#import "/src/source.typ" as source

#let notes-title = source.title
#let course = source.course
#let authors = source.authors
#let date = source.date
#let source-url = source.source-url
#let abstract = source.abstract
#let pdf-doc-label = <pdf-notes>

#let render-mode = state("render-mode", "web")
#let route-base = state("route-base", "/")

#let _resolve-route(route, base) = {
  if type(route) == function {
    route(base)
  } else {
    route
  }
}

#let _normalize-route(route) = {
  let value = route
  if not value.starts-with("/") {
    value = "/" + value
  }
  if not value.ends-with("/") {
    value = value + "/"
  }
  value
}

#let _route-id(route) = {
  let route = _normalize-route(route)
  let inner = route.slice(1, route.len() - 1)
  if inner == "" {
    "home"
  } else {
    inner.replace("/", "-")
  }
}

#let _route-path(route) = {
  let route = _normalize-route(route)
  let inner = route.slice(1, route.len() - 1)
  if inner == "" {
    "index.html"
  } else {
    inner + "/index.html"
  }
}
#let _document-path(route) = "/" + _route-path(route)

#let _dirs-for(path) = path.split("/").slice(0, path.split("/").len() - 1).filter(part => part != "")
#let _root-prefix(path) = range(_dirs-for(path).len()).map(_ => "../").join("")
#let _pretty-path(path) = if path == "index.html" {
  "index.html"
} else if path.ends-with("/index.html") {
  path.slice(0, path.len() - "index.html".len())
} else {
  path
}
#let _href-from(current-path, target-path) = _root-prefix(current-path) + _pretty-path(target-path)
#let _asset-href(current-path, asset-path) = _root-prefix(current-path) + asset-path

#let _page-info(
  title: none,
  route: none,
  kind: "section",
  description: none,
) = {
  assert(title != none, message: "docs page needs a title")
  assert(route != none, message: "docs page needs a route")
  let route = _normalize-route(route)
  (
    id: _route-id(route),
    title: title,
    route: route,
    path: _route-path(route),
    doc-path: _document-path(route),
    kind: kind,
    description: description,
  )
}

#let _page-heading(page) = {
  let headings = query(selector(heading).within(label("doc-" + page.id)))
  if headings.len() > 0 { headings.first() } else { none }
}

#let _heading-number(h) = {
  if h != none and h.numbering != none {
    counter(heading).display(at: h.location())
  } else {
    none
  }
}

#let _page-depth(page) = {
  let h = _page-heading(page)
  if h == none { 0 } else { calc.max(0, h.level - 1) }
}

#let _page-label(page) = context {
  let h = _page-heading(page)
  let number = _heading-number(h)

  if page.kind == "chapter" and number != none {
    [Chapter #number: #page.title]
  } else if (page.kind == "section" or page.kind == "subchapter") and number != none {
    [#sym.section#number #page.title]
  } else if page.kind == "appendix" and number != none {
    [Appendix #number: #page.title]
  } else if number != none {
    [#number #page.title]
  } else {
    [#page.title]
  }
}

#let _pages() = query(<page-meta>).map(it => it.value)
#let _icon(name, path) = html.elem("img", attrs: (class: "icon", src: path, alt: name))

#let _nav-link(current, page) = context {
  let depth = _page-depth(page)
  let cls = (
    "nav-item",
    if page.id == current.id { "active" } else { none },
  )
    .filter(x => x != none)
    .join(" ")

  html.elem("li", attrs: (class: cls, style: "--depth: " + str(depth)), {
    html.elem("a", attrs: (href: _href-from(current.path, page.path)), _page-label(page))
  })
}

#let _global-nav(current) = context {
  let pages = _pages()
  html.elem("nav", attrs: (class: "global-nav", "aria-label": "Site navigation"), {
    html.elem("ul", {
      for page in pages {
        _nav-link(current, page)
      }
    })
  })
}

#let _toc-entry(class, location, body, depth: 0) = html.elem(
  "li",
  attrs: (
    class: class,
    style: "--toc-depth: " + str(depth),
  ),
  {
    link(location, body)
  },
)

#let _heading-toc-entry(h) = {
  let number = _heading-number(h)
  if number == none {
    h.body
  } else {
    [#number #h.body]
  }
}

#let _local-toc(current) = context {
  let doc-label = label("doc-" + current.id)
  let headings = query(selector(heading).within(doc-label)).filter(h => h.level > 1)
  let theorem-markers = query(selector(<meta:thm-env-counter>).within(doc-label))

  let entries = ()
  for h in headings {
    entries.push((level: h.level, kind: "heading", loc: h.location(), body: _heading-toc-entry(h)))
  }
  for marker in theorem-markers {
    let thm = thm-state.thm-stored.at(marker.location()).last()
    if thm.supplement != "Proof" and thm.supplement != "Solution" and thm.supplement != "Remark" {
      entries.push((level: 3, kind: "theorem", loc: thm.loc, body: theorem-toc-entry(thm)))
    }
  }
  entries = entries.sorted(key: e => e.loc.position().page * 100000 + e.loc.position().y / 1pt)

  html.elem("nav", attrs: (class: "local-toc", "aria-label": "On this page"), {
    html.elem("h2", [On This Page])
    if entries.len() == 0 {
      html.elem("p", attrs: (class: "muted"), [No subsections yet.])
    } else {
      html.elem("ul", {
        for entry in entries {
          let depth = calc.max(0, entry.level - 2)
          let cls = "toc-" + entry.kind
          _toc-entry(cls, entry.loc, entry.body, depth: depth)
        }
      })
    }
  })
}

#let _prev-next(current) = context {
  let pages = _pages()
  let idx = pages.position(page => page.id == current.id)
  let prev = if idx != none and idx > 0 { pages.at(idx - 1) } else { none }
  let next = if idx != none and idx < pages.len() - 1 { pages.at(idx + 1) } else { none }

  html.elem("nav", attrs: (class: "page-nav", "aria-label": "Previous and next pages"), {
    if prev != none {
      html.elem("a", attrs: (class: "page-nav-card nav-prev", href: _href-from(current.path, prev.path)), {
        html.elem("span", attrs: (class: "page-nav-arrow"), [←])
        html.elem("span", attrs: (class: "page-nav-kicker"), [Previous])
        html.elem("span", attrs: (class: "page-nav-title"), _page-label(prev))
      })
    } else {
      html.elem("span", attrs: (class: "page-nav-spacer"))
    }
    if next != none {
      html.elem("a", attrs: (class: "page-nav-card nav-next", href: _href-from(current.path, next.path)), {
        html.elem("span", attrs: (class: "page-nav-kicker"), [Next])
        html.elem("span", attrs: (class: "page-nav-title"), _page-label(next))
        html.elem("span", attrs: (class: "page-nav-arrow"), [→])
      })
    } else {
      html.elem("span", attrs: (class: "page-nav-spacer"))
    }
  })
}

#let _topbar(current) = html.elem("header", attrs: (class: "topbar"), {
  html.elem("div", attrs: (class: "topbar-left"), {
    html.elem("button", attrs: (class: "icon-button sidebar-toggle", id: "sidebar-toggle-left", "aria-label": "Menu"), {
      _icon("Menu", _asset-href(current.path, "assets/menu.svg"))
    })
    html.elem("a", attrs: (class: "topbar-title", href: _href-from(current.path, "index.html")), notes-title)
  })
  html.elem("div", attrs: (class: "topbar-right"), {
    html.elem("button", attrs: (class: "icon-button theme-toggle", "aria-label": "Toggle theme"), {
      _icon("Theme", _asset-href(current.path, "assets/theme.svg"))
    })
    html.elem("a", attrs: (class: "icon-button github-link", href: source-url, "aria-label": "GitHub source"), {
      _icon("GitHub", _asset-href(current.path, "assets/github.svg"))
    })
    html.elem(
      "button",
      attrs: (class: "icon-button sidebar-toggle", id: "sidebar-toggle-right", "aria-label": "Page contents"),
      {
        _icon("Contents", _asset-href(current.path, "assets/toc.svg"))
      },
    )
  })
})

#let _cover-content(current) = source.web-cover(path => _href-from(current.path, path))

#let _pdf-cover() = source.pdf-cover(outline-target: selector(heading).within(pdf-doc-label))

#let _html-page(page, body) = [
  #metadata(page) <page-meta>
  #document(page.doc-path, title: [#page.title])[
    #show: web-styles
    #html.elem("link", attrs: (rel: "stylesheet", href: _asset-href(page.path, "assets/site.css")))
    #_topbar(page)
    #html.elem("div", attrs: (class: "layout"))[
      #html.elem("aside", attrs: (class: "sidebar-left"))[
        #_global-nav(page)
      ]
      #html.elem("main", attrs: (class: "content", id: "main"))[
        #if page.kind != "cover" {
          html.elem("h1", attrs: (class: "page-title"), _page-label(page))
        }
        #body
        #_prev-next(page)
      ]
      #html.elem("aside", attrs: (class: "sidebar-right"))[
        #_local-toc(page)
      ]
    ]
    #html.elem("div", attrs: (class: "sidebar-backdrop", id: "sidebar-backdrop"))
    #html.elem("script", attrs: (src: _asset-href(page.path, "assets/site.js")), [])
  ] #label("doc-" + page.id)
]

#let _docs-page(
  title: none,
  route: none,
  kind: "section",
  description: none,
  cover: false,
  body,
) = context {
  let mode = render-mode.get()
  let parent-route = route-base.get()
  let route = _resolve-route(route, parent-route)
  let page = _page-info(
    title: title,
    route: route,
    kind: kind,
    description: description,
  )

  if target() == "bundle" and mode == "web" {
    let page-body = if cover { _cover-content(page) } else { body }
    _html-page(page, page-body)
    route-base.update(page.route)
  } else if cover {
    _pdf-cover()
    route-base.update(page.route)
  } else {
    body
    route-base.update(page.route)
  }
}

#let docs-cover(..args) = _docs-page(kind: "cover", cover: true, ..args)
#let docs-frontmatter(..args) = _docs-page(kind: "frontmatter", ..args)
#let docs-chapter(..args) = _docs-page(kind: "chapter", ..args)
#let docs-section(..args) = _docs-page(kind: "section", ..args)
#let docs-subchapter(..args) = _docs-page(kind: "subchapter", ..args)
#let docs-appendix(..args) = _docs-page(kind: "appendix", ..args)
#let docs-backmatter(..args) = _docs-page(kind: "backmatter", ..args)

#let notes() = context {
  if target() == "bundle" {
    include "/src/assets/index.typ"
    [
      #document("pdf/notes.pdf", title: [#notes-title], author: (authors,))[
        #show: paper-styles
        #render-mode.update("pdf")
        #route-base.update("/")
        #include "/chapters/index.typ"
      ] #pdf-doc-label
    ]
    render-mode.update("web")
    route-base.update("/")
    include "/chapters/index.typ"
  } else {
    [
      #[
        #show: paper-styles
        #render-mode.update("pdf")
        #route-base.update("/")
        #include "/chapters/index.typ"
      ] #pdf-doc-label
    ]
  }
}
