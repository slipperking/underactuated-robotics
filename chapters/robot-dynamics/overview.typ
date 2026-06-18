#import "/src/components/index.typ": docs-chapter
#import "/lib.typ": *

#show: docs-chapter.with(
  title: "Robot Dynamics",
  route: "/robot-dynamics/",
  number: 1,
  heading-counter: (0,),
  description: "Introductory material for robot dynamics and control.",
)

= Robot Dynamics

In the field of controlling and training of autonamous stuff, there are three popular ways
+ reinforcement learning (in quadrupeds)
+ imitation learning (in manipulation robots)
+ mechanics optimization (as in ATLAS)
