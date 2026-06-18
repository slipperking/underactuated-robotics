#import "/lib.typ": *
#import "/src/components/index.typ": render-mode

#let _theorem-filter(thm) = {
  thm.supplement != "Proof" and thm.supplement != "Solution" and thm.supplement != "Remark"
}

#let _theorem-entry(thm, linked: true) = {
  let head = [*#thm.supplement~#thm.number*]
  if thm.name != none {
    head = head + [~(#thm.name)]
  }
  if linked {
    [#link(thm.loc, [#head #thm.loc.page()])\ ]
  } else {
    [#head #thm.loc.page()\ ]
  }
}

#let list-of-theorems(at: auto, final: true, within-doc: none, linked: true) = [
  #if within-doc != none {
    context {
      let markers = query(selector(<meta:thm-env-counter>).within(within-doc))
      for marker in markers {
        let thm = thm-state.thm-stored.at(marker.location()).last()
        if _theorem-filter(thm) {
          _theorem-entry(thm, linked: linked)
        }
      }
    }
  } else {
    thm-state.thm-display(
      _theorem-filter,
      at: at,
      final: final,
      fmt: thm => _theorem-entry(thm, linked: linked),
    )
  }
]

#let list-of-theorems-auto() = context {
  if render-mode.get() == "pdf" {
    list-of-theorems(final: true)
  } else {
    list-of-theorems(within-doc: label("doc-robot-dynamics-system-modeling"), final: false, linked: false)
  }
}
