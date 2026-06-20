#import "packages.typ": *

#let _plain-thm-fmt = thm-fmt-block.with(
  name-fmt: x => emph(smallcaps([(#x)])),
)

#let _plain-text(value) = {
  if value == none {
    ""
  } else if type(value) == str {
    value
  } else if type(value) == int or type(value) == float or type(value) == decimal {
    str(value)
  } else if type(value) == content {
    let fields = value.fields()
    if fields.keys().contains("text") {
      fields.text
    } else if fields.keys().contains("children") {
      fields.children.map(_plain-text).join("")
    } else if fields.keys().contains("body") {
      _plain-text(fields.body)
    } else if fields.keys().contains("child") {
      _plain-text(fields.child)
    } else if value.func() == [ ].func() {
      " "
    } else {
      ""
    }
  } else {
    str(value)
  }
}

#let _slug(value) = lower(_plain-text(value))
  .replace(" ", "-")
  .replace(".", "-")
  .replace("(", "")
  .replace(")", "")

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
  let id = if numbered and thm.number != none {
    "thm-" + _slug(head) + "-" + _slug(thm.number)
  } else {
    none
  }
  let attrs = (class: "thm-box " + css-class)
  if id != none {
    attrs.insert("id", id)
  }

  html.elem("div", attrs: attrs, {
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

#let theorem(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-theorem, "Theorem", "thm-theorem")
  } else {
    _ams-theorem.with(fmt: _plain-thm-fmt)
  }
  env(..args)
}

#let lemma(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-lemma, "Lemma", "thm-lemma")
  } else {
    _ams-lemma.with(fmt: _plain-thm-fmt)
  }
  env(..args)
}

#let proposition(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-proposition, "Proposition", "thm-proposition")
  } else {
    _ams-proposition.with(fmt: _plain-thm-fmt)
  }
  env(..args)
}

#let corollary(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-corollary, "Corollary", "thm-corollary")
  } else {
    _ams-corollary.with(fmt: _plain-thm-fmt)
  }
  env(..args)
}

#let conjecture(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-conjecture, "Conjecture", "thm-conjecture")
  } else {
    _ams-conjecture.with(fmt: _plain-thm-fmt)
  }
  env(..args)
}

#let definition(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-definition, "Definition", "thm-definition")
  } else {
    _ams-definition
  }
  env(..args)
}

#let problem(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-problem, "Problem", "thm-problem")
  } else {
    _ams-problem
  }
  env(..args)
}

#let remark(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-remark, "Remark", "thm-remark", numbered: false)
  } else {
    _ams-remark
  }
  env(..args)
}

#let example(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-example, "Example", "thm-example")
  } else {
    _ams-example
  }
  env(..args)
}

#let claim(..args) = context {
  let env = if is-web-target() {
    _html-thm-env(_ams-claim, "Claim", "thm-claim", numbered: false)
  } else {
    _ams-claim
  }
  env(..args)
}

#let proof(..args) = context {
  let env = if is-web-target() {
    _ams-proof.with(fmt: _html-proof-like-fmt("Proof", "thm-proof"))
  } else {
    _ams-proof
  }
  env(..args)
}

#let solution(..args) = context {
  let env = if is-web-target() {
    _ams-solution.with(fmt: _html-proof-like-fmt("Solution", "thm-solution", collapsible: true))
  } else {
    _ams-solution
  }
  env(..args)
}

#let theorem-toc-entry(thm) = {
  let head = [#thm.supplement]
  if thm.number != none {
    head += [ #thm.number]
  }
  if thm.name != none {
    head += [ (#thm.name)]
  }
  head
}
