//#import "@preview/ctheorems:1.1.3": *
#import "@preview/layout-ltd:0.1.0": layout-limiter
#import "@local/ctheorems:2.0.0": *
#import "@local/itemize:0.2.0" as itemize
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4" as cetz-plot
#import "@preview/physica:0.9.8": *
#import "@preview/physica:0.9.8": va as Va, vb as Vb, vu as Vu
#import "@preview/fancy-tiling:1.0.0": *
#import "@preview/mannot:0.3.3"
#import "@preview/fletcher:0.5.8"
#import thm-themes.ams: *

#let cvector = cetz.vector
#let cmatrix = cetz.matrix

#let _is-html = sys.inputs.at("html", default: "false") == "true" // target() == "html"
#let chapter-title-mode = state("chapter-title-mode", "chapter")

#let html-frame-wrapper(body, block: false) = if _is-html {
  if block {
    html.elem("div", attrs: (class: "typst-frame-wrapper typst-frame-block"), body)
  } else {
    html.elem("span", attrs: (class: "typst-frame-wrapper typst-frame-inline"), body)
  }
} else {
  body
}

#let ray(body, dy: 0em, tag: none) = {
  let body = pad(top: 0em, $#body$)

  mannot.core-mark(body, tag: tag, color: none, outset: (top: 0em), overlay: (width, height, color) => {
    place(bottom, dy: dy, math.stretch(sym.arrow, size: width))
  })
}

#let sray(body, tag: none) = {
  return ray($script(body)$, dy: 0.3em, tag: tag)
}

#let section-numbering-depth = 2

#let _heading-numbers(depth: section-numbering-depth, loc: none) = {
  let arr = if loc != none {
    counter(heading).at(loc)
  } else {
    counter(heading).get()
  }
  arr.slice(0, calc.min(depth, arr.len()))
}

#let _scoped-number(value, depth: section-numbering-depth, loc: none) = {
  let nums = _heading-numbers(depth: depth, loc: loc)
  let scoped = nums + (value,)
  scoped.map(str).join(".")
}

#let reset-heading-scoped-counters() = {
  counter(footnote).update(0)
  counter(math.equation).update(0)
}

#let scoped-equation-numbering(..args) = [(#_scoped-number(args.at(0)))]

#let heading-reset-marker(level) = context if level <= section-numbering-depth {
  reset-heading-scoped-counters()
}

// use the uppercase terms for no upright.
#let vb(x) = Vb(math.upright(x))
#let vu(x) = Vu(vb(x))
#let va(x) = Va(vb(x))

#let _plain-thm-fmt = thm-fmt-block.with(
  name-fmt: x => emph(smallcaps([(#x)])),
)

#let _ams-theorem = theorem
#let _ams-lemma = lemma
#let _ams-proposition = proposition
#let _ams-corollary = corollary
#let _ams-conjecture = conjecture
#let _ams-definition = definition
#let _ams-problem = problem
#let _ams-remark = remark
#let _ams-example = example
#let _ams-claim = claim
#let _ams-proof = proof
#let _ams-solution = solution
#let qed-symbol = $square$

#let _html-thm-fmt(head, css-class, numbered: true) = thm => {
  let title = if numbered and thm.number != none {
    [#head #thm.number]
  } else {
    [#head]
  }

  html.elem("div", attrs: (class: "thm-box " + css-class), {
    html.elem("p", attrs: (class: "thm-head"), {
      html.elem("strong", title)
      if thm.name != none [ (#thm.name)]
      [.]
    })
    thm.body
  })
}

#let _html-thm-env(env, head, css-class, numbered: true) = env.with(
  fmt: _html-thm-fmt(head, css-class, numbered: numbered),
)

#let _html-proof-like-fmt(head, css-class, collapsible: false) = thm => {
  let title = if thm.name != none {
    [#head #thm.name]
  } else {
    [#head]
  }

  if collapsible {
    html.elem("details", attrs: (class: "thm-proof thm-solution"), {
      html.elem("summary", attrs: (class: "proof-head solution-head"), html.elem("em", [#title.]))
      thm.body
      html.elem("p", attrs: (class: "qed"), [#qed-symbol])
    })
  } else {
    html.elem("div", attrs: (class: "thm-proof"), {
      html.elem("p", attrs: (class: "proof-head"), html.elem("em", [#title.]))
      thm.body
      html.elem("p", attrs: (class: "qed"), [#qed-symbol])
    })
  }
}

#let theorem = if _is-html {
  _html-thm-env(_ams-theorem, "Theorem", "thm-theorem")
} else {
  _ams-theorem.with(fmt: _plain-thm-fmt)
}

#let lemma = if _is-html {
  _html-thm-env(_ams-lemma, "Lemma", "thm-lemma")
} else {
  _ams-lemma.with(fmt: _plain-thm-fmt)
}

#let proposition = if _is-html {
  _html-thm-env(_ams-proposition, "Proposition", "thm-proposition")
} else {
  _ams-proposition.with(fmt: _plain-thm-fmt)
}

#let corollary = if _is-html {
  _html-thm-env(_ams-corollary, "Corollary", "thm-corollary")
} else {
  _ams-corollary.with(fmt: _plain-thm-fmt)
}

#let conjecture = if _is-html {
  _html-thm-env(_ams-conjecture, "Conjecture", "thm-conjecture")
} else {
  _ams-conjecture.with(fmt: _plain-thm-fmt)
}

#let definition = if _is-html {
  _html-thm-env(_ams-definition, "Definition", "thm-definition")
} else {
  _ams-definition
}

#let problem = if _is-html {
  _html-thm-env(_ams-problem, "Problem", "thm-problem")
} else {
  _ams-problem
}

#let remark = if _is-html {
  _html-thm-env(_ams-remark, "Remark", "thm-remark", numbered: false)
} else {
  _ams-remark
}

#let example = if _is-html {
  _html-thm-env(_ams-example, "Example", "thm-example")
} else {
  _ams-example
}

#let claim = if _is-html {
  _html-thm-env(_ams-claim, "Claim", "thm-claim", numbered: false)
} else {
  _ams-claim
}

#let proof = if _is-html {
  _ams-proof.with(fmt: _html-proof-like-fmt("Proof", "thm-proof"))
} else {
  _ams-proof
}

#let solution = if _is-html {
  _ams-solution.with(fmt: _html-proof-like-fmt("Solution", "thm-solution", collapsible: true))
} else {
  _ams-solution
}

#let dx = $dd(x)$
#let dy = $dd(y)$
#let dz = $dd(z)$
#let dzbar = $dd(overline(z))$
#let dzeta = $dd(zeta)$
#let dzetabar = $dd(overline(zeta))$
#let dtheta = $dd(theta)$
#let dt = $dd(t)$
#let dr = $dd(r)$

#let supp = math.op("supp")
#let diam = math.op("diam")
#let Log = math.op("Log")
#let logp = math.op($log^+$)
#let arg = math.op("arg")
#let Arg = math.op("Arg")
#let Aut = math.op("Aut")
#let Res = math.op("Res", limits: true)
#let Re = math.op($frak(Re)$)
#let Im = math.op($frak(Im)$)
#let Ind = math.op("Ind")
#let wp = math.op($\u{2118}$) // $pee$ waiting for tinymist update

#let length = $op("length")$
#let jinterior = $op("int")$
#let jexterior = $op("ext")$
#let uppi = $upright(pi)$
#let I-num = $upright(I)$
#let II-num = $upright(I #h(-0.15em) I)$
#let III-num = $upright(I #h(-0.15em) I #h(-0.15em) I)$
#let Order = $cal(O)$
#let order = $cal(o)$
#let diff = $partial$

#let ee = $upright(e)$
#let ii = $upright(i)$
#let taui = $2 uppi ii$

#let nothing = sym.diameter
#let emptyset = sym.diameter
#let abs(x) = $lr(| #x |)$
#let ceil(x) = $lr(⌈ #x ⌉)$
#let floor(x) = $lr(⌊ #x ⌋)$
#let interior(x) = $attach(limits(#x), t: circle.small)$

#let doubletilde(x) = $tilde(tilde(#x))$

#let widearc(x) = $accent(x, paren.t)$

#let halflength-arrow(start, end, scalar: 0, mark: (end: ">>", fill: black), ..args) = {
  let pstart = (start, scalar, 90deg, end)
  let pend = (end, scalar, -90deg, start)
  cetz.draw.line(
    (pstart, 25%, pend),
    (pstart, 75%, pend),
    ..args,
    mark: mark,
  )
}

#let sub-vectors(a, b) = (rel: a, to: ((0, 0), -100%, b))


#let add-vectors(..vectors) = {
  vectors.pos().fold((0, 0, 0), (a, b) => (rel: a, to: b))
}
#let scale-vector(vector, scale) = {
  ((0, 0), scale * 100%, vector)
}

#let directional_points(offset: (0, 0), angle: 0, length: 1e-6, n: 10) = {
  let vec = ((0, 0), 100%, angle, (length, 0))
  let out = ()

  for i in range(n + 1) {
    out.push((rel: ((0, 0), i / n * 100%, vec), to: offset))
  }
  out
}

#let quick-plot(
  canvas: none,
  extra-plot: none,
  canvas-args: none,
  scale: 1.4,
  x-min: -1,
  x-max: 6,
  y-min: -1,
  y-max: 6,
  wrap: true,
  ..args,
) = context {
  let x-range = x-max - x-min
  let y-range = y-max - y-min
  let size = (x-range * scale, y-range * scale)
  let plot = {
    import cetz.draw: *
    cetz-plot.plot.plot(
      size: size,
      axis-style: "school-book",
      x-min: x-min,
      x-max: x-max,
      y-min: y-min,
      y-max: y-max,
      x-tick-step: none,
      y-tick-step: none,
      ..args.named(),
      {
        cetz-plot.plot.add(x => 0, domain: (0, 0))
        extra-plot
        cetz-plot.plot.annotate({
          canvas
        })
      },
    )
  }

  if wrap {
    return cetz.canvas(..canvas-args, plot)
  } else {
    return plot
  }
}
// this must be used around any normal figure to show in html
#let figure-wrapper(..items, columns: auto) = context {
  let figures = items.pos()
  let column-count = if columns == auto { figures.len() } else { columns }
  let body = grid(
    columns: column-count, gutter: 1fr,
    inset: 1em,
    align: alignment.center,
    ..figures.map(item => grid.cell([#item])),
  )

  if target() == "html" {
    body
  } else {
    place(
      alignment.top + alignment.center,
      float: true,
      body,
    )
  }
}

#let dot-tiling(pattern_dist: 2pt, radius: 0.4pt) = tiling(
  size: (pattern_dist, pattern_dist),
  relative: "parent",
  place(
    circle(
      radius: radius,
      fill: black,
    ),
  ),
)

#let arc-center(
  center,
  ..args,
) = {
  let start = args.at("start", default: auto)
  let start-angle = if start == auto {
    let stop = args.at("stop", default: auto)
    let delta = args.at("delta", default: auto)
    if stop != auto and delta != auto { stop - delta } else { 0deg }
  } else { start }

  let radius = args.at("radius", default: 1)
  let (rx, ry) = if type(radius) == array { radius } else { (radius, radius) }
  let (cx, cy, cz) = if center.len() == 2 {
    center.push(0)
    center
  } else { center }

  let start-pos = (
    cx + rx * calc.cos(start-angle),
    cy + ry * calc.sin(start-angle),
    cz,
  )

  cetz.draw.arc(start-pos, ..args)
}


#let math-rect(snippet, ..args) = {
  box(
    math.equation(numbering: none, block: true, $ inline(#snippet) $),
    fill: luma(100%, 80%),
    outset: 1pt,
    ..args,
  )
}

#if _is-html {
  qedhere = none
}

#let citation(width: 55%, author, body) = {
  if _is-html {
    html.elem("blockquote", attrs: (class: "epigraph"), {
      html.elem("p", body)
      html.elem("footer", author)
    })
  } else {
    align(right, block(width: width, inset: 0em)[
      #set text(style: "italic", size: 0.95em)
      #align(left, body)
      #align(right, author)
    ])
  }
}


#let chapter-section(id, depth: auto, title-mode: "chapter", body) = context {
  if _is-html == true {
    let nav-depth = if depth == auto { none } else { str(depth) }
    let attrs = if nav-depth == none {
      (class: "chapter", id: id)
    } else {
      (class: "chapter", id: id, "data-nav-depth": nav-depth)
    }
    chapter-title-mode.update(title-mode)
    html.elem("section", attrs: attrs, body)
  } else {
    body
  }
}

#let part-marker(id, title) = context {
  if _is-html == true {
    html.elem("section", attrs: (class: "part", id: id), {
      html.elem("h1", attrs: (class: "part-title"), title)
    })
  }
}

#let arrow-populate = (n, offset01: 0, ..mark) => {
  return range(n)
    .map(num => 100% * (num + offset01) / n)
    .map(pos => (
      symbol: ">>",
      fill: black,
      ..mark.named(),
      pos: pos,
      shorten-to: none,
    ))
}
