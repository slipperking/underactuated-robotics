#import "/lib.typ": *

#show: docs-chapter.with(
  title: "Preliminaries",
  route: "preliminaries",
  description: ".",
)
// todo, potentially add lin alg results and definitions
#let t(..args) = tiling(size: (4pt, 4pt), ..args)[
  #line(start: (0%, 50%), end: (100%, 50%), stroke: 1pt + blue)
]

#potential-frame(rect(fill: t(angle: 45deg), width: 100pt, height: 60pt, stroke: 1pt))
