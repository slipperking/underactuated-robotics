#import "styles.typ": paper-styles, web-styles
#import "theorems.typ": theorem-toc-entry
#import "packages.typ": thm-counter, thm-state

#let notes-title = "Notes on Underactuated Robotics"
#let course = "MIT OpenCourseWare 6.8210"
#let authors = "Slipper King and Saint Even"
#let date = "June 16, 2026"
#let source-url = "https://github.com/slipperking/underactuated-robotics"
#let abstract = [
  Covers nonlinear dynamics and control of underactuated mechanical systems, with an emphasis on computational methods. Topics include the nonlinear dynamics of robotic manipulators, applied optimal and robust control and motion planning. Discussions include examples from biology and applications to legged locomotion, compliant manipulation, underwater robots, and flying machines.
]

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
  number: none,
  depth: 0,
  description: none,
  heading-counter: none,
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
    number: number,
    depth: depth,
    description: description,
    heading-counter: heading-counter,
  )
}

#let _page-label(page) = if page.kind == "chapter" and page.number != none {
  [Chapter #page.number: #page.title]
} else if page.kind == "section" and page.number != none {
  [#sym.section#page.number #page.title]
} else if page.kind == "appendix" and page.number != none {
  [Appendix #page.number: #page.title]
} else {
  [#page.title]
}

#let _pages() = query(<page-meta>).map(it => it.value)
#let _icon(name, path) = html.elem("img", attrs: (class: "icon", src: path, alt: name))

#let _nav-link(current, page) = {
  let cls = (
    "nav-item",
    "nav-depth-" + str(page.depth),
    if page.id == current.id { "active" } else { none },
  ).filter(x => x != none).join(" ")

  html.elem("li", attrs: (class: cls), {
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

#let _toc-entry(class, location, body) = html.elem("li", attrs: (class: class), {
  html.elem("span", body)
})

#let _local-toc(current) = context {
  let doc-label = label("doc-" + current.id)
  let headings = query(selector(heading).within(doc-label))
    .filter(h => h.level > 1)
  let theorem-markers = query(selector(<meta:thm-env-counter>).within(doc-label))

  let entries = ()
  for h in headings {
    entries.push((level: h.level, kind: "heading", loc: h.location(), body: h.body))
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
          let cls = "toc-" + entry.kind + " toc-l" + str(calc.min(entry.level, 6))
          _toc-entry(cls, entry.loc, entry.body)
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
    html.elem("button", attrs: (class: "icon-button sidebar-toggle", id: "sidebar-toggle-right", "aria-label": "Page contents"), {
      _icon("Contents", _asset-href(current.path, "assets/toc.svg"))
    })
  })
})

#let _cover-content(current) = {
  html.elem("section", attrs: (class: "cover"), {
    html.elem("p", attrs: (class: "course"), course)
    html.elem("h1", notes-title)
    html.elem("p", attrs: (class: "authors"), [by #smallcaps[Slipper King] and #smallcaps[Saint Even]])
    html.elem("p", attrs: (class: "date"), date)
    html.elem("div", attrs: (class: "abstract"), abstract)
    html.elem("p", attrs: (class: "download"), {
      html.elem("a", attrs: (class: "button", href: _href-from(current.path, "pdf/notes.pdf")), [Download PDF])
    })
  })
}

#let _pdf-cover() = [
  #align(center)[
    #v(2cm)
    #text(size: 24pt, weight: "bold")[Underactuated Robotics]

    #text(size: 13pt)[MIT OpenCourseWare 6.8210]

    #text(size: 13pt)[Slipper King and Saint Even]

    #text(size: 11pt)[June 16, 2026]

    `Source: https://github.com/slipperking/underactuated-robotics`
  ]

  #block(inset: 10pt)[#abstract]
  #outline()
]

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
        #if page.heading-counter != none {
          counter(heading).update(page.heading-counter)
          thm-counter.thm-counters.update(_ => (:))
        }
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
  number: none,
  depth: 0,
  description: none,
  heading-counter: none,
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
    number: number,
    depth: depth,
    description: description,
    heading-counter: heading-counter,
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

#let docs-cover(..args) = _docs-page(kind: "cover", depth: 0, cover: true, ..args)
#let docs-frontmatter(..args) = _docs-page(kind: "frontmatter", depth: 0, ..args)
#let docs-chapter(..args) = _docs-page(kind: "chapter", depth: 0, ..args)
#let docs-section(..args) = _docs-page(kind: "section", depth: 1, ..args)
#let docs-subchapter(..args) = _docs-page(kind: "subchapter", depth: 2, ..args)
#let docs-appendix(..args) = _docs-page(kind: "appendix", depth: 0, ..args)
#let docs-backmatter(..args) = _docs-page(kind: "backmatter", depth: 0, ..args)

#let notes() = context {
  if target() == "bundle" {
    include "/src/assets/index.typ"
    document("pdf/notes.pdf", title: [#notes-title], author: (authors,))[
      #show: paper-styles
      #render-mode.update("pdf")
      #route-base.update("/")
      #include "/chapters/index.typ"
    ]
    render-mode.update("web")
    route-base.update("/")
    include "/chapters/index.typ"
  } else {
    show: paper-styles
    render-mode.update("pdf")
    route-base.update("/")
    include "/chapters/index.typ"
  }
}
