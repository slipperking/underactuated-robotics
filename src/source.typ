#let title = "Notes on Underactuated Robotics"
#let course = "MIT OpenCourseWare 6.8210"
#let authors = "Slipper King and Saint Even"
#let date = "June 16, 2026"
#let source-url = "https://github.com/slipperking/underactuated-robotics"
#let abstract = [
  Covers nonlinear dynamics and control of underactuated mechanical systems, with an emphasis on computational methods. Topics include the nonlinear dynamics of robotic manipulators, applied optimal and robust control and motion planning. Discussions include examples from biology and applications to legged locomotion, compliant manipulation, underwater robots, and flying machines.
]

#let web-cover(href) = {
  html.elem("section", attrs: (class: "cover"), {
    html.elem("p", attrs: (class: "course"), course)
    html.elem("h1", title)
    html.elem("p", attrs: (class: "authors"), [by #smallcaps[Slipper King] and #smallcaps[Saint Even]])
    html.elem("p", attrs: (class: "date"), date)
    html.elem("div", attrs: (class: "abstract"), abstract)
    html.elem("p", attrs: (class: "download"), {
      html.elem("a", attrs: (class: "button", href: href("pdf/notes.pdf")), [Download PDF])
    })
  })
}

#let pdf-cover(outline-target: heading) = [
  #align(center)[
    #v(2cm)
    #text(size: 24pt, weight: "bold")[Underactuated Robotics]

    #text(size: 13pt)[MIT OpenCourseWare 6.8210]

    #text(size: 13pt)[Slipper King and Saint Even]

    #text(size: 11pt)[June 16, 2026]

    `Source: https://github.com/slipperking/underactuated-robotics`
  ]

  #block(inset: 10pt)[#abstract]
  #outline(target: outline-target)
]
