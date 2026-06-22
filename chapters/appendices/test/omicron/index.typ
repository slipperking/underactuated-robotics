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
  $ F = m a $ // qedhere
]
#solution[
  #lorem(40)

  + k
  + g // #lbl(<itm:enum2>, [f])
  + f // qedhere

]

+ k
+ #lbl(<itm:enum>, [f])
+ f // qedhere
@itm:enum
