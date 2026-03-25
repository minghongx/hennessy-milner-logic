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

#align(center, block(width: 72%, [
  #set par(justify: true)
  #set text(size: 12pt)
  *Abstract*
  #v(-0.5em)
  #set align(left)

This report develops Hennessy–Milner logic for labelled transition system and shows that, over image-finite systems, bisimilar states are exactly those indistinguishable by HML formulae. On this basis, it studies the computation of minimal distinguishing formulae for non-bisimilar states. Throughout, the theoretical development is accompanied by corresponding Haskell implementations.

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

The (action-)labelled (state-)transition system is a standard model for representing the operational behaviour of reactive and concurrent systems. Hennessy–Milner logic is a modal logic for this model: its action-indexed modalities express what a state possibly or necessarily do after a given action. Its central feature is captured by the Hennessy–Milner theorem: over image-finite systems, two states satisfy exactly the same formulae of Hennessy–Milner logic if and only if they are bisimilar. This correspondence makes it the logical foundation for studying behavioural inequivalence via so-called distinguishing formulae.

This report is organized as follows. In @LTS, we define image-finite labelled transition system. In @HML, we define the syntax and semantics of Hennessy–Milner logic. In @Bisim, we define simulation, bisimulation, and bisimilarity. In @Distinguish, we study the computation of minimal distinguishing formulae. Each section pairs the theoretical development with corresponding Haskell implementations.

#pagebreak()
#include "lib/LTS.lhs"
#pagebreak()
#include "lib/HML.lhs"
#pagebreak()
#include "lib/Bisim.lhs"
#pagebreak()
#include "lib/Distinguish.lhs"
#pagebreak()

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Coda

#let Act = math.italic("Act")
#let transition = math.stretch($->$, size: 1.3em)
#let tt = h(0pt,weak:true) + math.italic("tt")
#let ff = h(0pt,weak:true) + math.italic("ff")

#figure(
diagram(
spacing: 4em,
node((0,0), `s0`),
edge(`a`, "-|>"),
node((1,0), `s1`),
edge((1,0), (0,0), `b`, "-|>", bend: -60deg),
edge(`a`, "-|>"),
node((2,0), `s2`),
),
caption: [A test LTS whose $S = {"s0", "s1", "s2"}$ and $Act = {a, b}$],
gap: 1.2em,
) <testLTS>

We construct in Haskell the LTS shown in @testLTS.
```haskell
ghci> test = LTS.fromTransitions [("s0",'a',"s1"), ("s1",'a',"s2"), ("s1",'b',"s0")]
```

The formula $phi_1 = chevron.l a chevron.r chevron.l a chevron.r tt$ distinguishes $s_0$ and $s_1$ since $s_0 in [|phi_1|]$ and $s_1 in.not [|phi_1|]$.
```haskell
ghci> denote test (Dia 'a' $ Dia 'a' TT)
fromList ["s0"]
```

However, it is not minimal since $phi_2 = [b] ff$ also distinguishes $s_0$ and $s_1$ with fewer modalities.
```haskell
ghci> distinguish test "s0" "s1"
['b']ff
ghci> denote test $ distinguish test "s0" "s1"
fromList ["s0", "s2"]
```

#pagebreak()
#bibliography("references.yaml",
  title: "References",
  style: "association-for-computing-machinery",
  full: true,
)
