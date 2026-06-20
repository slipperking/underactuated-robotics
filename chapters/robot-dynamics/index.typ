#import "/src/components/index.typ": docs-chapter
#import "/lib.typ": *

#docs-chapter(
  title: "Robot Dynamics",
  route: "robot-dynamics",
  description: "Introductory material for robot dynamics and control.",
  children: [
    #include "system-modeling/index.typ"
    #include "test/index.typ"
  ],
)[
  In the field of controlling and training of autonomous stuff, there are three popular ways
  + reinforcement learning (in quadrupeds)
  + imitation learning (in manipulation robots)
  + mechanics optimization (as in ATLAS)
  
  #thm-state.thm-restate("def:underactuated-and-fully-actuated", final: true)
]
