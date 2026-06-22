#import "packages.typ": *
#import "packages.typ" as _packages
#import "math.typ": *
#import "graphics.typ": *
#import "styles.typ": pdf-styles, web-styles, explicit-label
#import "theorems.typ" as _thm
#import "web.typ" as _web

#let theorem = _thm.theorem
#let lemma = _thm.lemma
#let proposition = _thm.proposition
#let corollary = _thm.corollary
#let conjecture = _thm.conjecture
#let definition = _thm.definition
#let problem = _thm.problem
#let remark = _thm.remark
#let example = _thm.example
#let claim = _thm.claim
#let proof = _thm.proof
#let solution = _thm.solution
#let qed-symbol = _thm.qed-symbol
#let theorem-toc-entry = _thm.theorem-toc-entry

#let thm-counter = _thm.thm-counter
#let thm-state = _thm.thm-state
#let render-mode = _web.render-mode
#let route-folders = _web.route-folders
#let pdf-doc-label = _web.pdf-doc-label
#let web-doc-label = _web.web-doc-label
#let notes-title = _web.notes-title
#let course = _web.course
#let authors = _web.authors
#let date = _web.date
#let source-url = _web.source-url
#let abstract = _web.abstract
#let docs-cover = _web.docs-cover
#let docs-frontmatter = _web.docs-frontmatter
#let docs-chapter = _web.docs-chapter
#let docs-section = _web.docs-section
#let docs-subchapter = _web.docs-subchapter
#let docs-subsubchapter = _web.docs-subsubchapter
#let docs-appendix = _web.docs-appendix
#let docs-backmatter = _web.docs-backmatter

#let lbl = explicit-label