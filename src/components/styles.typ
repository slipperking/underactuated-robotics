#import "packages.typ": *
#import "math.typ": *
#import "theorems.typ": *

#let paper-styles(doc) = {
  set document(
    title: "Notes on Underactuated Robotics",
    author: "Slipper King and Saint Even",
  )
  set par(justify: true)
  set page(numbering: "1", margin: 1.75in)

  show: thm-rules.with(qed-symbol: qed-symbol)
  show math.equation: it => {
    if it.fields().keys().contains("label") {
      math.equation(block: true, numbering: scoped-equation-numbering, it)
    } else {
      it
    }
  }

  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      let eq-num = counter(math.equation).at(el.location()).at(0) + 1
      link(el.location(), [(#_scoped-number(eq-num, loc: el.location()))])
    } else {
      it
    }
  }

  set figure(placement: alignment.top)
  show figure.caption: it => context [
    *#it.supplement~#it.counter.display()#it.separator*#it.body
  ]

  show heading: it => [#it#heading-reset-marker(it.level)]

  show: itemize.default-enum-list
  show: itemize.config.ref.with(supplement: "Part")
  set enum(numbering: "1")

  set figure(numbering: (n, ..) => {
    numbering("1.1", counter(heading).get().first(), n)
  })
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }

  doc
}

#let web-styles(doc) = {
  set document(
    title: "Notes on Underactuated Robotics",
    author: "Slipper King and Saint Even",
  )
  set par(justify: true)
  set math.equation(numbering: none)

  show figure.where(kind: "thm-env"): it => it.body
  show: itemize.default-enum-list
  show: itemize.config.ref.with(supplement: "Part")
  set enum(numbering: "1")

  doc
}
