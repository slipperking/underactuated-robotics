#import "/src/components/index.typ": render-mode, thm-counter

#include "cover.typ"

#set heading(numbering: none)
#include "preface/index.typ"

#set heading(numbering: "1.1")
#counter(heading).update(0)
#thm-counter.thm-counters.update(_ => (:))
#include "robot-dynamics/index.typ"

#context if render-mode.get() == "pdf" {
  pagebreak()
}

#set heading(numbering: "A.1")
#counter(heading).update(0)
#thm-counter.thm-counters.update(_ => (:))
#include "appendices/index.typ"

#set heading(numbering: none)
#include "bibliography/index.typ"
