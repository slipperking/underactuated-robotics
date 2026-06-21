#import "packages.typ": *
#import "math.typ": *
#import "theorems.typ": *

#let pdf-doc-label = <pdf-notes>
#let web-doc-label = <web-notes>

#let secondary-label-assignment = state("secondary-label-assignment", 0)

#let shared-styles(doc, mode: "pdf") = {
  show: thm-rules.with(qed-symbol: qed-symbol)
  show math.equation: it => {
    let label = it.fields().at("label", default: none)
    if label != none {
      math.equation(block: true, numbering: scoped-equation-numbering, it)
    } else {
      it
    }
  }
  let label = if mode == "pdf" {
    pdf-doc-label
  } else {
    web-doc-label
  }
  show ref: it => {
    // todo: perhaps use a show rule with a state of some sort to auto assign a unique identifier to each element so we can have pdf html cross support.
    let targets = query(selector(it.target).within(label))
    if targets.len() == 0 {
      return it
    }

    let target = targets.last()
    if target.func() == math.equation {
      let eq-num = counter(math.equation).at(target.location()).at(0) + 1
      link(target.location(), [(#_scoped-number(eq-num, loc: target.location()))])
    } else {
      it
    }
  }
  doc
}

#let pdf-styles(doc) = {
  show: shared-styles.with(mode: "pdf")
  set document(
    title: "Notes on Underactuated Robotics",
    author: "Slipper King and Saint Even",
  )
  set par(justify: true)
  set page(numbering: "1", margin: 1.75in)

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
  show: shared-styles.with(mode: "web")
  set document(
    title: "Notes on Underactuated Robotics",
    author: "Slipper King and Saint Even",
  )

  show math.equation: it => {
    if it.block and it.numbering != none {
      let number = counter(math.equation).display(it.numbering)
      it.body + tag(number)
    } else {
      it
    }
  }

  set par(justify: true)
  show heading: it => [#it#heading-reset-marker(it.level)]
  show math.equation.where(block: true): it => html.elem("div", attrs: (class: "display-math"), it)
  show figure.where(kind: "thm-env"): it => it.body
  show: itemize.default-enum-list
  show: itemize.config.ref.with(supplement: "Part")
  set enum(numbering: "1")

  doc
}
