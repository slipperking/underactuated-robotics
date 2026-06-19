#import "/src/components/index.typ": docs-section
#import "/lib.typ": *

#show: docs-section.with(
  title: [Omicron $integral_0^(2 uppi)$],
  route: prev => prev + "test/",
  description: "State-space modeling and control-affine dynamics.",
)
