#import "/src/components/index.typ": docs-appendix
#import "/lib.typ": *
#import "logic.typ": list-of-theorems-auto

#show: docs-appendix.with(
  title: "List of Theorems",
  route: "/appendices/list-of-theorems/",
  number: "A",
  description: "Collected theorem-like statements from the notes.",
)

= List of Theorems
#list-of-theorems-auto()
