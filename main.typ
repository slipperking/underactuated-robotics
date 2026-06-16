#import "/lib.typ": *
#import "show-rules.typ": paper-styles

#show: paper-styles

#set document(
  title: "Notes on Underactuated Robotics",
  author: "Slipper King and Saint Even",
)

#{
  if not _is-html {
    set page(background: rotate(30deg, {
      let f(n) = {
        if n <= 1 {
          $#box($script(integral)$)$
        } else {
          let prev = f(n - 1)
          $#prev _(#prev)^(#prev)$
        }
      }

      text(fill: black.transparentize(70%))[$#f(8)$]
    }))
    align(center)[
      #v(2cm)
      #text(size: 24pt, weight: "bold")[Notes on Underactuated Robotics (OCW 6.8210)]

      #text(size: 13pt)[Slipper King and Saint Even]

      #text(size: 11pt)[June 16, 2026]

      `Source: https://github.com/slipperking/underactuated-robotics`
    ]
    outline()
    set page(background: none)
  } else {
    chapter-section("cover")[
      #html.elem("header", attrs: (class: "paper-header"))[
        #html.elem("h1", attrs: (class: "paper-title"))[
          Notes on Underactuated Robotics
        ]
        #html.elem("p", attrs: (class: "author"))[by #smallcaps[Slipper King] and #smallcaps[Saint Even]]
        #html.elem("p", attrs: (class: "date"))[June 16, 2026]
        #html.elem("p", attrs: (class: "paper-misc"))[
          Typst Source: https://github.com/slipperking/underactuated-robotics
        ]
        #html.elem("p", attrs: (class: "pdf-download"))[
          #html.elem("a", attrs: (href: "pdf/notes.pdf", class: "btn-pdf"))[
            Download PDF
          ]
        ]
        #html.elem("div", attrs: (class: "abstract"))[
          The conversion process was heavily facilitated by the use of LLMs; thus, there may be errors.
        ]
      ]
      //#outline()
    ]
  }
}

#include "chapters/index.typ"
