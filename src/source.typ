#let title = "Notes on Underactuated Robotics"
#let course = "MIT OpenCourseWare 6.8210"
#let authors = "Slipper King and Saint Even"
#let date = "June 16, 2026"
#let abstract = [
  Covers nonlinear dynamics and control of underactuated mechanical systems, with an emphasis on computational methods. Topics include the nonlinear dynamics of robotic manipulators, applied optimal and robust control and motion planning. Discussions include examples from biology and applications to legged locomotion, compliant manipulation, underwater robots, and flying machines.
]

#let web-view-recommendation = [
  For the best web viewing experience, we recommend using a Mozilla-based browser such as Firefox. This will be subject to change as browsers improve their MathML support.
]

#let source-url = "https://github.com/slipperking/underactuated-robotics"

#let web-cover(href) = {
  html.elem("section", attrs: (class: "cover"), {
    html.elem("p", attrs: (class: "course"), course)
    html.elem("h1", title)
    html.elem("p", attrs: (class: "authors"), [by #smallcaps[Slipper King] and #smallcaps[Saint Even]])
    html.elem("p", attrs: (class: "date"), date)
    html.elem("div", attrs: (class: "abstract"), abstract)
    html.elem("div", attrs: (class: "recommendation"), web-view-recommendation)
    html.elem("p", attrs: (class: "download"), {
      html.elem("a", attrs: (class: "button", href: href("pdf/notes.pdf")), [Download PDF])
    })
  })
}

#let pdf-cover(outline-target: heading) = [
  #set document(
    title: "Notes on Underactuated Robotics",
    author: "Slipper King and Saint Even",
  )
  #align(center)[
    #v(2cm)
    #text(size: 24pt, weight: "bold")[Underactuated Robotics]

    #text(size: 13pt)[MIT OpenCourseWare 6.8210]

    #text(size: 13pt)[#smallcaps[Slipper King] and #smallcaps[Saint Even]]

    #text(size: 11pt)[June 16, 2026]

    `Source: https://github.com/slipperking/underactuated-robotics`
  ]

  #block(inset: 10pt)[#abstract]
  #outline(target: outline-target)
]
