#import "packages.typ": *
#import "math.typ": *
#import "theorems.typ": *

#let _theorem-ref-content(thm, html-loc, pdf-loc: none) = {
  let supplement = thm.supplement
  if thm.ref-supplement != none {
    supplement = thm.ref-supplement
  }
  let head = if supplement != none and supplement != [] {
    [#supplement~]
  } else {
    []
  }

  if state("render-mode").get() == "web" {
    html.elem("span", attrs: (class: "ref-link-group"), {
      head
      link(html-loc, thm.number)
      html.elem("span", attrs: (class: "link-choice-tooltip"), {
        link(html-loc, [HTML])
        if pdf-loc != none {
          link(pdf-loc, [PDF])
        }
      })
    })
  } else {
    [#head#link(html-loc, thm.number)]
  }
}

#let _theorem-marker-for(target) = {
  if target.func() == figure and target.kind != "thm-env" {
    return none
  }

  let markers = query(selector(<meta:thm-env-counter>).after(target.location(), inclusive: true))
  if markers.len() == 0 {
    return none
  }

  markers.first()
}

#let _maybe-theorem-ref(it) = {
  if type(it.target) != label {
    return none
  }

  let targets = query(it.target)
  if targets.len() == 0 {
    return none
  }

  let target = if state("render-mode").get() == "web" { targets.last() } else { targets.first() }
  let marker = _theorem-marker-for(target)
  if marker == none {
    return none
  }

  let thm = thm-state.thm-stored.at(marker.location()).last()
  let anchor = if target.func() == figure { target.location() } else { marker.location() }
  let ref-supplement = it.citation.supplement
  let pdf-anchor = none
  if state("render-mode").get() == "web" and targets.len() > 1 {
    let pdf-target = targets.first()
    let pdf-marker = _theorem-marker-for(pdf-target)
    if pdf-marker != none {
      pdf-anchor = if pdf-target.func() == figure { pdf-target.location() } else { pdf-marker.location() }
    }
  }

  _theorem-ref-content(thm + (loc: anchor, ref-supplement: ref-supplement), anchor, pdf-loc: pdf-anchor)
}

#let _theorem-ref(it) = {
  let resolved = _maybe-theorem-ref(it)
  if resolved == none { it } else { resolved }
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
    let resolved = _maybe-theorem-ref(it)
    if resolved != none {
      return resolved
    }

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
  show math.equation.where(block: true): it => html.elem("div", attrs: (class: "display-math"), it)
  show figure.where(kind: "thm-env"): it => it.body
  show ref: _theorem-ref
  show: itemize.default-enum-list
  show: itemize.config.ref.with(supplement: "Part")
  set enum(numbering: "1")

  doc
}
