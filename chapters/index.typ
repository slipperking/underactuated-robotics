#import "/src/components/index.typ": render-mode, route-base, thm-counter

#set heading(numbering: none)
#route-base.update("/")
#include "cover.typ"
#include "preface/index.typ"

#set heading(numbering: "1.1")
#counter(heading).update(0)
#include "robot-dynamics/index.typ"

#context if render-mode.get() == "pdf" {
  pagebreak()
}

#set heading(numbering: "A.1")
#counter(heading).update(0)
#route-base.update("/appendices/")
#include "appendices/index.typ"

#set heading(numbering: none)
#route-base.update("/")
#include "bibliography/index.typ"
