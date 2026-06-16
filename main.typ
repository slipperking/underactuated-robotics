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
          $#box($text(, size: #8pt)$)$
        } else {
          let prev = f(n - 1)
          $#prev _(#prev)^(#prev)$
        }
      }

      text(fill: black.transparentize(70%))[#scale($#f(8)$, 60%)]
    }))
    align(center)[
      #v(2cm)
      #text(size: 24pt, weight: "bold")[Underactuated Robotics]

      #text(size: 13pt)[MIT OpenCourseWare 6.8210]

      #text(size: 13pt)[Slipper King and Saint Even]

      #text(size: 11pt)[June 16, 2026]

      `Source: https://github.com/slipperking/underactuated-robotics`
    ]

    block(inset: 10pt)[
      Covers nonlinear dynamics and control of underactuated mechanical systems, with an emphasis on computational methods. Topics include the nonlinear dynamics of robotic manipulators, applied optimal and robust control and motion planning. Discussions include examples from biology and applications to legged locomotion, compliant manipulation, underwater robots, and flying machines.
    ]
    outline()
    set page(background: none)
  } else {
    chapter-section("cover")[
      #html.elem("header", attrs: (class: "paper-header"))[
        #html.elem("h1", attrs: (class: "paper-title"))[
          Notes on Underactuated Robotics
        ]
        #html.elem("p", attrs: (class: "paper-misc"))[
          MIT OpenCourseWare 6.8210
        ]
        #html.elem("p", attrs: (class: "author"))[by #smallcaps[Slipper King] and #smallcaps[Saint Even]]
        #html.elem("p", attrs: (class: "date"))[June 16, 2026]
        #html.elem("p", attrs: (class: "paper-misc"))[
          Typst Source: https://github.com/slipperking/underactuated-robotics
        ]
        #html.elem("div", attrs: (class: "abstract"))[
          Covers nonlinear dynamics and control of underactuated mechanical systems, with an emphasis on computational methods. Topics include the nonlinear dynamics of robotic manipulators, applied optimal and robust control and motion planning. Discussions include examples from biology and applications to legged locomotion, compliant manipulation, underwater robots, and flying machines.

        ]
        #html.elem("p", attrs: (class: "pdf-download"))[
          #html.elem("a", attrs: (href: "pdf/notes.pdf", class: "btn-pdf"))[
            Download PDF
          ]
        ]
      ]
      //#outline()
    ]
  }
}

#include "chapters/index.typ"
