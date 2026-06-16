#import "/lib.typ": *
= List of Theorems
#thm-state.thm-display(
  thm => thm.supplement != "Proof" and thm.supplement != "Solution" and thm.supplement != "Remark",
  final: true,
  fmt: thm => {
    let head = [*#thm.supplement~#thm.number*]
    if thm.name != none {
      head = head + [~(#thm.name)]
    }
    [#link(thm.loc, [#head~#box(width: 1fr, repeat[.])~#thm.loc.page()])\ ]
  },
)
