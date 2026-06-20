#import "/src/components/index.typ": docs-appendix
#import "/lib.typ": *

#docs-appendix(
  title: [Test $alpha / 2$],
  route: "test",
  children: [
    #include "gamma/index.typ"
    #include "omicron/index.typ"
  ],
)[
  In the field of controlling and training of autonomous systems, there are three popular methods
  + reinforcement learning (in quadrupeds)
  + imitation learning (in manipulation robots)
  + mechanics optimization (as in ATLAS)
]
