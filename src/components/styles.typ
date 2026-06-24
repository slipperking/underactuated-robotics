#import "packages.typ": *
#import "math.typ": *
#import "theorems.typ": *

#let pdf-doc-label = <pdf-notes>
#let web-doc-label = <web-notes>

#let secondary-label-assignment-counter = state("secondary-label-assignment", 0)
#let secondary-label-assignment-map = state("secondary-label-assignment-map", (:))

#let explicit-label(a, b, prefix: "") = {
  let (body, original-label) = if type(b) == str or type(b) == label {
    (a, b)
  } else if type(a) == str or type(a) == label {
    (b, a)
  } else { panic("One of the explicit-label parameters must be a string or label.") }
  secondary-label-assignment-counter.update(c => c + 1)
  context {
    let counter = secondary-label-assignment-counter.get()
    let unique-label = label(prefix + "secondary-label-" + str(counter))
    [#body#unique-label]
    secondary-label-assignment-map.update(map => {
      let array = map.at(str(original-label), default: ())
      map.insert(str(original-label), array + (unique-label,))
      map
    })
  }
}

#let eq-ref-fmt(eq) = {
  let eq-num = counter(math.equation).at(eq.location()).at(0) + 1
  link(eq.location(), [(#_scoped-number(eq-num, loc: eq.location()))])
}

#let shared-styles(doc, mode: "pdf") = {
  show: layout-limiter.with(max-iterations: 5)
  show ref: it => {
    if type(it.target) == label {
      context {
        let label-matches = secondary-label-assignment-map
          .final()
          .at(str(it.target), default: ())
          .filter(_label => query(selector(_label)).len() > 0)
        if label-matches.len() == 0 { return it }

        if mode == "web" {
          ref(label-matches.last())
          if label-matches.len() != 0 {
            html.span(
              {
                for _label in label-matches {
                  html.span(ref(_label), class: "typst-multi-label")
                }
              },
              class: "typst-multi-label-list",
            )
          } else {
            it
          }
        } else {
          let first-match
          if label-matches.len() != 0 {
            first-match = label-matches.first()
            ref(first-match)
          }

          if label-matches.len() > 1 {
            let html-label = if label-matches.len() > 0 and label-matches.last() != first-match {
              label-matches.last()
            }
            $#[]^#text(link(html-label, $dagger.triple$ * 3), size: 0.8em)$
          }
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
    let target = if it.element == none {
      let targets = query(selector(it.target))
      if targets.len() == 0 {
        return it
      }
      if _is-web-render() { targets.last() } else { targets.first() }
    } else {
      it.element
    }
    if target.func() == math.equation {
      eq-ref-fmt(target)
    } else {
      it
    }
  }
  show: thm-rules.with(qed-symbol: qed-symbol, mode: mode)
  let enum-numbering = (..it) => {
    counter("typst-enum").update(it.pos())
    numbering("1.1.", ..it)
  }

  // adds referenceable enumerations.
  // note that the method used to increment enumerations through the numbering will only work with pdfs, htmls don't call the function. Hence they are separately handled.
  set enum(numbering: enum-numbering, full: true)

  show ref: it => {
    let el = if it.element == none {
      let locations = query(selector(it.target)).last(default: none)
    } else { it.element }
    if (
      el != none
        and (
          el.func() == metadata
            and type(el.value) == dictionary
            and el.value.keys().contains("type")
            and el.value.type == "typst-enum-item-label"
        )
    ) {
      link(el.location(), [Part~#numbering("1.1", ..counter("typst-enum").at(el.location()))])
    } else {
      it
    }
  }
  doc
}

#let pdf-styles(doc) = {
  show: shared-styles.with(mode: "pdf")
  set par(justify: true)
  set page(numbering: "1", margin: 1.75in)

  set figure(placement: alignment.top)
  show figure.caption: it => context [
    *#it.supplement~#it.counter.display()#it.separator*#it.body
  ]

  show heading: it => [#it#heading-reset-marker(it.level)]
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
    title: "Notes on Complex Analysis",
    author: "Slipper King",
  )

  show math.equation: it => {
    if it.block and it.numbering != none {
      let number = counter(math.equation).display(it.numbering)
      it.body + tag(number)
    } else {
      it
    }
  }

  show enum.where(start: auto): it => context {
    if target() != "html" { return it }

    counter("typst-enum").update(0)

    let items = it
      .children
      .enumerate()
      .map(((i, item)) => {
        let n = if item.number == auto { i + 1 } else { item.number }
        enum.item(item.number, [#counter("typst-enum").update((n,))#item.body])
      })

    set enum(start: 1)
    enum(..items)
  }
  set par(justify: true)
  show heading: it => [#it#heading-reset-marker(it.level)]
  show math.equation.where(block: true): it => context {
    // prevent double wrapping with previous numbering show rule.
    // also, in figures, html will be paged, so no div.
    if it.numbering == none and target() != "paged" {
      html.elem("div", attrs: (class: "display-math"), it)
    } else { it }
  }
  show figure.where(kind: "thm-env"): it => it.body

  doc
}
