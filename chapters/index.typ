#import "/src/components/index.typ": render-mode, thm-counter

#context if render-mode.get() == "pdf" [
  #set heading(numbering: "1.1")

  #include "cover.typ"
  #include "preface/index.typ"
  #counter(heading).update(0)
  #thm-counter.thm-counters.update(_ => (:))
  #include "robot-dynamics/index.typ"

  #pagebreak()
  #set heading(numbering: "A.1")
  #counter(heading).update(0)
  #include "appendices/index.typ"

  #include "bibliography/index.typ"
] else [
  #include "cover.typ"
  #include "preface/index.typ"
  #include "robot-dynamics/index.typ"
  #include "appendices/index.typ"
  #include "bibliography/index.typ"
]
