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

#let is-web-target() = target() == "html" or target() == "bundle" or sys.inputs.at("html", default: "false") == "true"
