#import "@preview/thmbox:0.3.0": *
#show: thmbox-init()
#let gray = rgb("#797979")
#let proposition = proposition.with(color: gray)

= Hennessy–Milner logic <HML>

/*
```haskell
module HML where

import LTS (FiniteLTS(..))
import qualified LTS

import Data.HashSet (HashSet)
import qualified Data.HashSet as S

type Set = HashSet
```
*/

== Syntax

#let tt = math.italic("tt")
#let ff = math.italic("ff")
#let Act = math.italic("Act")

Given a set of actions $Act$, a formula of HML is defined by the BNF grammar:
$ phi ::= tt | ff | phi and phi | phi or phi | chevron.l a chevron.r phi | [a]phi quad "where" a in Act $
$tt$ and $ff$ denote the formulae that are valid at every state and at no state, respectively. \
$chevron.l a chevron.r phi$ denotes that it is possible to perform $a$-transition to a state satisfying $phi$; whereas $[a]phi$ denotes that $a$-transition necessarily leads to a state satisfying $phi$.

We define formulae in Haskell as an recursive data type parametric in the action type.
```haskell
data Form a
    = TT | FF
    | Con (Form a) (Form a)
    | Dis (Form a) (Form a)
    | Dia a (Form a)
    | Box a (Form a)
    deriving (Eq)
```

We introduce two abbreviations for sets of actions:
$
chevron.l A chevron.r phi := or.big_(a_n in A) chevron.l a_n chevron.r phi, "with" chevron.l emptyset chevron.r phi = ff
wide wide
[A]phi := and.big_(a_n in A)[a_n]phi, "with" [emptyset]phi = tt
$
```haskell
diaS :: Set a -> Form a -> Form a
diaS as p = S.foldr (\a acc -> Dis (Dia a p) acc) FF as

boxS :: Set a -> Form a -> Form a
boxS as p = S.foldr (\a acc -> Con (Box a p) acc) TT as
```
They make common expression, such as _deadlock_ $[Act]ff$ and _$a$-transition must happen next_ $chevron.l a chevron.r #h(0pt,weak:true) tt and [Act without {a}]ff$, much more perspicuous.

/*
```haskell
instance Show a => Show (Form a) where
    show = \case
        TT -> "tt"
        FF -> "ff"
        Con f1 f2 -> "(" ++ show f1 ++ " ∧ " ++ show f2 ++ ")"
        Dis f1 f2 -> "(" ++ show f1 ++ " ∨ " ++ show f2 ++ ")"
        Dia a  f  -> "⟨" ++ show a ++ "⟩" ++ show f
        Box a  f  -> "[" ++ show a ++ "]" ++ show f
```
*/

== Satisfaction relation

#let satisfies = math.forces

Suppose $s$ is a state in a LTS. Then we recursively define the notion of a formula $phi$ being _satisfied_ in LTS at state $s$ as follow:
$
s &satisfies tt #h(6em) && \
s &satisfies phi_1 and phi_2 && "if" s satisfies phi_1 "and" s satisfies phi_2 \
s &satisfies phi_1 or  phi_2 && "if" s satisfies phi_1 "or"  s satisfies phi_2 \
s &satisfies chevron.l a chevron.r phi && "if" exists s'. s' in "image"(s, a) and s' satisfies phi \
s &satisfies [a] phi && "if" forall s'. s' in "image"(s, a) -> s' satisfies phi
$
```haskell
satisfy :: FiniteLTS s a -> s -> Form a -> Bool
satisfy lts s =
  let (⊩)   = satisfy   lts
      image = LTS.image lts
   in \case
        TT -> True
        FF -> False
        Con f1 f2 -> s ⊩ f1 && s ⊩ f2
        Dis f1 f2 -> s ⊩ f1 || s ⊩ f2
        Dia a f -> any (\s' -> s' ⊩ f) (image s a)
        Box a f -> all (\s' -> s' ⊩ f) (image s a)
```

== Denotational semantics

For a formula $phi$, its denotation $[|phi|] subset.eq S$ is recursively defined as follows:
$
[|tt|] &= S & [|ff|] &= emptyset \
[| phi_1 and phi_2 |] &= [|phi_1|] inter [|phi_2|] & [| phi_1 or phi_2 |] &= [|phi_1|] union [|phi_2|] \
[| chevron.l a chevron.r phi |] &= {s | exists s'. s' in "image"(s, a) and s' in [|phi|] }  & [|[a]phi|] &= {s | forall s'. s' in "image"(s, a) -> s' in [|phi|] } \
$
#proposition[Semantic Equivalence][
$s satisfies phi "iff" s in [|phi|]$
]
#proof[ Structural induction on $phi$. ]

This tells us $[|phi|]$ contains all states that _satisfy_ $phi$. We can use this characterization to implement the denotation in a one-liner:
```haskell
denote :: FiniteLTS s a -> Form a -> Set s
denote lts f = let (⊩) = satisfy lts in S.filter (\s -> s ⊩ f) lts.states
```
Negation is not primitive in HML. This is not a problem because HML is closed under negation.
#proposition[Closure under Negation][
For every HML formula $phi$, there exists $not phi$ such that $[|not phi|] = S without [|phi|]$ for every LTS
]
#proof[ Structural induction on $phi$. ]

This means whenever $phi$ is a HML formula, there is also a formula expressing $not phi$ true exactly at the states where $phi$ is false, namely, for all $s in S$, $s satisfies not phi$ iff $s satisfies.not phi$. In this sense, negation is redundant.

We recover negation as a function that transforms a formula into its negated form.
```haskell
neg :: Form a -> Form a
neg = \case
    TT -> FF
    FF -> TT
    Con f1 f2 -> Dis (neg f1) (neg f2)
    Dis f1 f2 -> Con (neg f1) (neg f2)
    Dia a f -> Box a (neg f)
    Box a f -> Dia a (neg f)
```
Treating negation as derived has a technical advantage: recursive definitions on the structure of formulae (e.g. satisfaction relation) can be given in a uniform way.
