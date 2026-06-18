#import "/src/components/index.typ": docs-appendix, pdf-doc-label, render-mode
#import "/lib.typ": *

#show: docs-appendix.with(
  title: "List of Theorems",
  route: "/appendices/list-of-theorems/",
  description: "Collected theorem-like statements from the notes.",
)

= List of Theorems

#let theorem-entry(thm) = {
  let head = [*#thm.supplement~#thm.number*]
  if thm.name != none {
    head += [~(#thm.name)]
  }
  if render-mode.get() == "web" {
    [#link(thm.loc, [#head #thm.loc.page()])\ ]
  } else {
    [#link(thm.loc, [#head~#box(width: 1fr, repeat[.])~#thm.loc.page()])\ ]
  }
}

#let theorem-filter(thm) = {
  thm.supplement != "Proof" and thm.supplement != "Solution" and thm.supplement != "Remark"
}

#let theorem-list() = context {
  let pdf-markers = query(selector(<meta:thm-env-counter>).within(pdf-doc-label))
  let markers = if render-mode.get() == "html" {
    if pdf-markers.len() == 0 {
      pdf-markers
    } else {
      query(selector(<meta:thm-env-counter>).after(pdf-markers.last(), inclusive: false))
    }
  } else {
    pdf-markers
  }
  for marker in markers {
    let thm = thm-state.thm-stored.at(marker.location()).last()
    if theorem-filter(thm) {
      theorem-entry(thm)
    }
  }
}

#theorem-list()
