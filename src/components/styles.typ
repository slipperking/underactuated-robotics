#import "packages.typ": *
#import "math.typ": *
#import "theorems.typ": *

#let pdf-doc-label = <pdf-notes>
#let web-doc-label = <web-notes>

#let secondary-label-assignment-counter = state("secondary-label-assignment", 0)
#let secondary-label-assignment-map = state("secondary-label-assignment-map", (:))

#let lbl(original-label, body) = {
  context {
    let counter = secondary-label-assignment-counter.get()
    let unique-label = label("secondary-label-" + str(counter))

    [#body#unique-label]

    secondary-label-assignment-map.update(map => {
      let array = map.at(str(original-label), default: ())
      map.insert(str(original-label), array + (unique-label,))
      map
    })
  }
  secondary-label-assignment-counter.update(c => c + 1)
}

#let shared-styles(doc, mode: "pdf") = {
  show ref: it => {
    if type(it.target) == label {
      context {
        let label-matches = secondary-label-assignment-map.final().at(str(it.target), default: ())

        if label-matches.len() != 0 {
          if mode == "web" {
            ref(label-matches.last())
            html.span(
              {
                for _label in label-matches {
                  html.span(ref(_label), class: "typst-multi-label")
                }
              },
              class: "typst-multi-label-list",
            )
          } else {
            for _label in label-matches {
              ref(_label)
            }
          }
        } else {
          it
        }
      }
    } else {
      it
    }
  }
  show math.equation: it => {
    let label = it.fields().at("label", default: none)
    if label != none {
      math.equation(block: true, numbering: scoped-equation-numbering, it)
    } else {
      it
    }
  }
  show ref: it => {
    let targets = query(selector(it.target))
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
  show: thm-rules.with(qed-symbol: qed-symbol)
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
