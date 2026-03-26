#import "@preview/touying:0.6.3": *
#import themes.simple: *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/itemize:0.2.0" as el
#import "@preview/thmbox:0.3.0": *

#show: thmbox-init(counter-level: 1)
#set heading(numbering: none)

#show: simple-theme.with(aspect-ratio: "16-10")

#let circle-line-enum = el.default-enum-list.with(
  size: (1.5em, auto),
  body-indent: .5em,
  label-align: (center + horizon, auto),
  label-format: (circle.with(stroke: 1pt + gray, fill: white, width: 1.4em), auto),
  body-format: (
    inner: (
      stroke: ((left: 2pt + black), auto),
      outset: (((left: 1.5em + 1pt, top: 0em), (left: 1.5em + 1pt, top: 1.3em)), auto),
    ),
  ),
)
#set enum(numbering: "1.1")

#let definition = definition.with(color: black, numbering: none)
#let Act = math.italic("Act")
#let transition = math.stretch($->$, size: 1.3em)
#let tt = h(0pt,weak:true) + math.italic("tt")
#let ff = h(0pt,weak:true) + math.italic("ff")
#let satisfies = math.forces

#title-slide[
  = Hennessy–Milner Logic
  #v(2em)

  Minghong Xu
  #v(1em)

  March 27
] <touying:hidden>

== Background <touying:hidden>

#definition[Model Checking][
Given a system _Sys_ and a specification _Spec_, does _Sys_ satisfy _Spec_?
- Represent _Sys_ as a Model $M$
- Express _Spec_ as a formula $phi$ of a (decidable) logic
- Check if $phi$ is satisfied by $M$
]

== Outline <touying:hidden>
#circle-line-enum[
  + Labelled Transition System
    #v(0.5em)

  + Hennessy–Milner Logic
    #v(0.5em)

  + Existence of a Distinguishing Formula
    #v(0.5em)

  + Computing Minimal Distinguishing Formula
]

== Labelled Transition System

#definition[Labelled Transition System][
An LTS is a triple $(S, Act, transition)$ consisting of
- a set $S$ of states
- a set $Act$ of (actions) label
- a transition relation $transition thick subset.eq S times Act times S $
]

#figure(
diagram(
spacing: 5em,
node((0,0), `s0`),
edge(`a`, "-|>"),
node((1,0), `s1`),
edge((1,0), (0,0), `b`, "-|>", bend: -60deg),
edge(`a`, "-|>"),
node((2,0), `s2`),
),
gap: 1em,
caption: [An LTS whose $S = {"s0", "s1", "s2"}$ and $Act = {a, b}$],
numbering: none,
)

== Labelled Transition System

#definition[Image][
The _image_ of a state $s$ for a label $a$ is the set of all state that $s$ can transition into with $a$: \
$"image"(s, a) = brace.l s' | s transition^a s' brace.r$
]

#pause

#definition[Image-Finite][
An LTS is _image-finite_ if for every state $s$ and label $a$, the set $"image"(s,a)$ is finite
]
Every finite-state LTS is image-finite.

== Hennessy–Milner Logic

#v(1em)
$ phi ::= thick tt | med ff | phi and phi | phi or phi | chevron.l a chevron.r phi | [a]phi quad "where" a in Act $

#pause

#v(1em)
Suppose $s$ is a state in an LTS,
$
s &satisfies thick tt #h(6em) && \
s &satisfies phi_1 and phi_2 && "if" s satisfies phi_1 "and" s satisfies phi_2 \
s &satisfies phi_1 or  phi_2 && "if" s satisfies phi_1 "or"  s satisfies phi_2 \
s &satisfies chevron.l a chevron.r phi && "if" exists s'. s' in "image"(s, a) and s' satisfies phi \
s &satisfies [a] phi && "if" forall s'. s' in "image"(s, a) -> s' satisfies phi
$

== Hennessy–Milner Logic
Denotation $[|dot|]$:
$
[|tt|] &= S \
[|ff|] &= emptyset \
[| phi_1 and phi_2 |] &= [|phi_1|] inter [|phi_2|] \
[| phi_1 or phi_2 |] &= [|phi_1|] union [|phi_2|] \
[| chevron.l a chevron.r phi |] &= {s | exists s'. s' in "image"(s, a) and s' in [|phi|] } \
[|[a]phi|] &= {s | forall s'. s' in "image"(s, a) -> s' in [|phi|] } \
$
$s satisfies phi "iff" s in [|phi|]$, in other words, $[|phi|]$ contains all states that _satisfy_ $phi$.

== Existence of a Distinguishing Formula

#definition[Theory and theory equivalence][
The _theory_ of a state $s$ is the set of all formulae it satisfies: $"theory(s)" = {phi | s satisfies phi}$. \
$"theoryEq"(s, t) := quad "theory"(s) = "theory"(t)$
]

#pause

#theorem(numbering: none)[Hennessy–Milner][
For any image-finite LTS, $"theoryEq" = med ~$.
]

#pause

If $s$ and $t$ are two states in an image-finite LTS and $s tilde.not t$, then $"theory"(s) eq.not "theory"(t)$, so $exists$ HML formula $phi$ s.t. $s satisfies phi$ and $t satisfies.not phi$.

== Computing Minimal Distinguishing Formula

Character length of the formula?

#pause

$hash$modalities the formula contains?

#pause

#definition[MIN-DIST][
Is there a HML formula $phi$ distinguishing $s tilde.not t$ with the fewest modalities?
]

#pause

#theorem(color: black, numbering: none)[MIN-DIST is NP-hard][
Deciding MIN-DIST is NP-hard, and it is not in NP.
]

== Computing Minimal Distinguishing Formula

#v(0.5em)

So, unfortunately, there is no algorithm that efficiently computes a minimal HML distinguishing formula.
#v(1em)

#pause

But if we measure the size of a formula in a different way, then efficient algorithms are possible.

#definition[Modal-depth][
The largest $hash$ of nested modalities in a formula is its _modal-depth_.
]

== Computing Minimal Distinguishing Formula

#figure(
diagram(
spacing: 5em,
node((0,0), `s0`),
edge(`a`, "-|>"),
node((1,0), `s1`),
edge((1,0), (0,0), `b`, "-|>", bend: -60deg),
edge(`a`, "-|>"),
node((2,0), `s2`),
),
gap: 1em,
caption: [An LTS whose $S = {"s0", "s1", "s2"}$ and $Act = {a, b}$],
numbering: none,
)
#v(1em)

$phi_1 = chevron.l a chevron.r chevron.l a chevron.r tt$ distinguishes $s_0$ and $s_1$ #pause since $s_0 in [|phi_1|]$ and $s_1 in.not [|phi_1|]$.
#v(0.5em)

#pause

However, it is not minimal #pause since $phi_2 = [b] ff$ also distinguishes $s_0$ and $s_1$ with fewer modalities.

= Questions?

