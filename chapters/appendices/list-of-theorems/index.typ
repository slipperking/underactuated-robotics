#import "/lib.typ": *
#import "/src/components/web.typ": theorem-heading

#show: docs-appendix.with(
  title: "List of Theorems",
  route: "list-of-theorems",
  description: "Collected theorem-like statements from the notes.",
)

#let theorem-entry(thm) = [
  #link(thm.loc, [#theorem-heading(thm)~#box(width: 1fr, repeat[.])~#thm.loc.page()])\
]

#let theorem-entry-web(web-thm, pdf-thm) = {
  let pdf-link-loc = if pdf-thm == none { web-thm.loc } else { pdf-thm.loc }
  let pdf-page = if pdf-thm == none { [?] } else { pdf-thm.loc.page() }

  html.elem("p", attrs: (class: "theorem-list-entry"), {
    link(web-thm.loc, html.elem("span", attrs: (class: "theorem-list-title"), {
      theorem-heading(web-thm)
      html.elem("span", attrs: (class: "theorem-list-end"), [])
    }))
    html.elem("span", attrs: (class: "theorem-list-dots"), [])
    link(pdf-link-loc, html.elem("span", attrs: (class: "theorem-list-page"), [#pdf-page]))
  })
}

#let theorem-filter(thm) = {
  thm.supplement != "Proof" and thm.supplement != "Solution" and thm.supplement != "Remark"
}

#let theorem-list() = context {
  if render-mode.get() == "web" {
    let web-thms = query(selector(<meta:thm-env-counter>).within(web-doc-label))
      .map(marker => marker.value)
      .filter(theorem-filter)
    let pdf-thms = query(selector(<meta:thm-env-counter>).within(pdf-doc-label))
      .map(marker => marker.value)
      .filter(theorem-filter)

    html.elem("div", attrs: (id: "theorem-list", class: "theorem-list"), {
      for i in range(web-thms.len()) {
        let web-thm = web-thms.at(i)
        let pdf-thm = pdf-thms.at(i, default: none)
        theorem-entry-web(web-thm, pdf-thm)
      }
    })
  } else {
    thm-state.thm-display(theorem-filter, final: true, fmt: theorem-entry)
  }
}

#theorem-list()
