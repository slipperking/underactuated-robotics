#import "/src/components/index.typ": docs-section, incr-sec
#import "/lib.typ": *

#show: docs-section.with(
  title: [Zeta $integral_0^(2 uppi)$],
  ..incr-sec("test/"),
  description: "State-space modeling and control-affine dynamics.",
)
