#import "/src/components/index.typ": docs-chapter
#import "/lib.typ": *

#show: docs-chapter.with(
  title: "Robot Dynamics",
  route: "robot-dynamics",
  description: "Introductory material for robot dynamics and control.",
  children: [
    #include "system-modeling/index.typ"
    #include "test/index.typ"
  ],
)

In the field of controlling and training of autonomous stuff, there are three popular ways
+ reinforcement learning (in quadrupeds)
+ imitation learning (in manipulation robots)
+ mechanics optimization (as in ATLAS)

#thm-state.thm-restate("def:underactuated-and-fully-actuated", final: true)

#lbl(<def:enums>, definition[
  #lorem(60)

  $ H i $ <eq:hi>

  1. 2
  + #enum-lbl(<itm:testenum>) what

  @itm:testenum @eq:hi
])
