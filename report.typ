#set document(
  title: [Hennessy–Milner Logic],
  author: "Minghong Xu"
)

#set page(height: auto)

#show title: set text(size: 18pt)
#show title: set align(center)
#show title: set block(below: 1.5em)

#title()

#align(center)[
  #text(size: 14pt)[Minghong Xu] \
  #link("mailto:minghong.xu@student.uva.nl") \
  #v(0.5em)
  #datetime.today().display("[month repr:long] [day], [year]")
  #v(1em)
]

#align(center, block(width: 70%, [
  #set par(justify: true)
  #set text(size: 12pt)
  *Abstract*
  #v(-0.5em)
  #set align(left)

#lorem(80)

  #v(1em)
]))

#set outline.entry(
  fill: box(width: 1fr, repeat(h(5pt) + "." + h(5pt))) + h(8pt)
)
#outline()
#pagebreak()

#set page(numbering: "1")
#counter(page).update(1)

#show heading: set block(above: 2em, below: 1em)

#import "@preview/thmbox:0.3.0": *
#show: thmbox-init()
#let definition = definition.with(color: black)

= Introduction

#definition[Model Checking @2007-turing-award][
Given a system _Sys_ and a specification _Spec_, does _Sys_ satisfy _Spec_?
- Represent _Sys_ as a Model $M$
- Express _Spec_ as a formula $phi$ of a (decidable) logic
- Check if $phi$ is satisfied by $M$
]

#pagebreak()
#include "lib/LTS.lhs"
#pagebreak()
#include "lib/HML.lhs"
#pagebreak()
#include "lib/Bisim.lhs"
#pagebreak()
#include "lib/Distinguish.lhs"

#pagebreak()
#bibliography("references.yml",
  title: "References",
  style: "association-for-computing-machinery",
  full: true,
)
