#import "/lib.typ": *

#show: docs-chapter.with(
  title: "Preliminaries",
  route: "preliminaries",
  description: ".",
)
// todo, potentially add lin alg results and definitions
#let t(..args) = tiling(size: (30pt, 30pt), spacing: (10pt, 10pt), ..args)[
  #square(width: 100%, height: 100%, stroke: 1pt, fill: blue)
]


#potential-frame(rect(fill: t(offset: (0%, -0%), angle: 20deg), width: 200pt, height: 100pt, stroke: 1pt))
