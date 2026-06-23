#import "/lib.typ": *

#show: docs-subchapter.with(
  title: [Omicron $integral_0^(2 uppi)$],
  route: "omicron",
  description: "State-space modeling and control-affine dynamics.",
)
#lorem(200)
#explicit-label(<eq:omicron>, $ omicron $)
#lorem(200)
@eq:omicron, @eq:euler-energy-mass
#proof[
  #lorem(40)
  #lbl($ F = m a $, <idk>)// qedhere
  @idk
]
#solution[
  #lorem(40)
]
