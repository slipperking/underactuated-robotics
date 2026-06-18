#import "/src/components/index.typ": docs-appendix, pdf-doc-label, render-mode
#import "/lib.typ": *

#show: docs-appendix.with(
  title: "List of Theorems",
  route: "/appendices/list-of-theorems/",
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
  let pdf-markers = query(selector(<meta:thm-env-counter>).within(pdf-doc-label))
  if render-mode.get() == "web" {
    let web-markers = if pdf-markers.len() == 0 {
      ()
    } else {
      query(selector(<meta:thm-env-counter>).after(pdf-markers.last().location(), inclusive: false))
    }
    for i in range(calc.min(web-markers.len(), pdf-markers.len())) {
      let web-thm = thm-state.thm-stored.at(web-markers.at(i).location()).last()
      let pdf-thm = thm-state.thm-stored.at(pdf-markers.at(i).location()).last()
      if theorem-filter(web-thm) and theorem-filter(pdf-thm) {
        theorem-entry-web(web-thm, pdf-thm)
      }
    }
  } else {
    for marker in pdf-markers {
      let thm = thm-state.thm-stored.at(marker.location()).last()
      if theorem-filter(thm) {
        theorem-entry(thm)
      }
    }
  }
}

#theorem-list()
