#import "/lib.typ": chapter-section
#set heading(numbering: "1.1")

#chapter-section("robot-dynamics")[
  #include "robot-dynamics/index.typ"
]

#pagebreak()
#set heading(numbering: "A.1")
#counter(heading).update(0)
#include "appendices/index.typ"

#chapter-section("bibliography")[
  #bibliography("/references.bib", full: true)
]
