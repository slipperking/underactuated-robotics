#import "/src/components/index.typ": docs-appendix, pdf-doc-label, render-mode
#import "/lib.typ": *

#show: docs-appendix.with(
  title: "List of Theorems",
  route: "list-of-theorems",
  description: "Collected theorem-like statements from the notes.",
)

#let theorem-heading(thm) = {
  let head = [*#thm.supplement~#thm.number*]
  if thm.name != none {
    head += [~(#thm.name)]
  }
  head
}

#let theorem-entry(thm) = [
  #link(thm.loc, [#theorem-heading(thm)~#box(width: 1fr, repeat[.])~#thm.loc.page()])\
]

#let theorem-entry-web(web-thm, pdf-thm) = {
  html.elem("p", attrs: (class: "theorem-list-entry"), {
    link(web-thm.loc, html.elem("span", attrs: (class: "theorem-list-title"), {
      theorem-heading(web-thm)
      html.elem("span", attrs: (class: "theorem-list-end"), [])
    }))
    html.elem("span", attrs: (class: "theorem-list-dots"), [])
    link(pdf-thm.loc, html.elem("span", attrs: (class: "theorem-list-page"), [#pdf-thm.loc.page()]))
  })
}

#let theorem-filter(thm) = {
  thm.supplement != "Proof" and thm.supplement != "Solution" and thm.supplement != "Remark"
}

#let theorem-list() = context {
  if render-mode.get() == "web" {
    html.elem("div", attrs: (id: "theorem-list", class: "theorem-list"), [])
  } else {
    []
  }
}

#theorem-list()
