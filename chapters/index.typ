#import "/src/components/index.typ": render-mode, route-folders, thm-counter, thm-state

#include "cover.typ"

#set heading(numbering: none)
#route-folders.update(())
#thm-counter.thm-counters.update((:))
#thm-state.thm-stored.update(())
#include "preface/index.typ"

#set heading(numbering: "1.1")
#counter(heading).update(0)
#route-folders.update(())
#thm-counter.thm-counters.update((:))
#thm-state.thm-stored.update(())
#include "robot-dynamics/index.typ"

#context if render-mode.get() == "pdf" {
  pagebreak()
}

#set heading(numbering: "A.1")
#counter(heading).update(0)
#route-folders.update(("appendices",))
#thm-counter.thm-counters.update((:))
#thm-state.thm-stored.update(())
#include "appendices/index.typ"

#set heading(numbering: none)
#route-folders.update(())
#thm-counter.thm-counters.update((:))
#thm-state.thm-stored.update(())
#include "bibliography/index.typ"
