#import "/src/components/index.typ": docs-appendix
#import "/lib.typ": *

#docs-appendix(
  title: [Test $alpha / 2$],
  route: prev => prev + "test/",
)[
  In the field of controlling and training of autonomous stuff, there are three popular ways
  + reinforcement learning (in quadrupeds)
  + imitation learning (in manipulation robots)
  + mechanics optimization (as in ATLAS)
]

#include "test/index.typ"
