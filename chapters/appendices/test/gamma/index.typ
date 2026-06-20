#import "/src/components/index.typ": docs-subchapter
#import "/lib.typ": *

#show: docs-subchapter.with(
  title: [Gamma $beta$],
  route: "gamma",
  children: [
    #include "zeta/index.typ"
  ],
)

DUHH