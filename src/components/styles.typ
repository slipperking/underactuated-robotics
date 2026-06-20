#import "packages.typ": *
#import "math.typ": *
#import "theorems.typ": *

#let _web-theorem-ref(it) = {
  if type(it.target) != label {
    return it
  }

  let targets = query(it.target)
  if targets.len() == 0 {
    return it
  }

  let target = targets.last()
  if target.func() == math.equation {
    return it
  }

  let markers = query(selector(<meta:thm-env-counter>).after(target.location(), inclusive: true))
  if markers.len() == 0 {
    return [#str(it.target)]
  }

  let thm = markers.first().value
  let ref-supplement = it.citation.supplement
  (thm.ref-fmt)(thm + (loc: target.location(), ref-supplement: ref-supplement))
}

#let shared-styles(doc) = {
  show math.equation: it => {
    let label = it.fields().at("label", default: none)
    if label != none {
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
  doc
}

#let pdf-styles(doc) = {
  show: shared-styles
  set document(
    title: "Notes on Underactuated Robotics",
    author: "Slipper King and Saint Even",
  )
  set par(justify: true)
  set page(numbering: "1", margin: 1.75in)

  show: thm-rules.with(qed-symbol: qed-symbol)

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
  show: shared-styles
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
  show ref: _web-theorem-ref
  show: itemize.default-enum-list
  show: itemize.config.ref.with(supplement: "Part")
  set enum(numbering: "1")

  doc
}
