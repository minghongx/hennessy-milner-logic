#import "@preview/thmbox:0.3.0": *
#show: thmbox-init()
#let definition = definition.with(color: black)
#let gray = rgb("#797979")
#let proposition = proposition.with(color: gray)

#let Act = math.italic("Act")
#let transition = math.stretch($->$, size: 1.3em)

= Bisimulation

/*
```haskell
module Bisim where

import LTS (FiniteLTS(..))
import qualified LTS

import Data.Hashable
import Data.HashSet (HashSet)
import qualified Data.HashSet as S

type Set = HashSet

cartesianProduct :: (Hashable a, Hashable b) => Set a -> Set b -> Set (a, b)
cartesianProduct x y = S.fromList $ liftA2 (,) (S.toList x) (S.toList y)
```
*/

It is technically simpler to consider bisimulations on a single LTS. Since any two LTSs can be combined by taking their disjoint union, we shall assume from now on that we are working with a single LTS.

#definition[Simulation][
A relation $R subset.eq S times S$ is a _simulation_ if whenever $(s, t) in R$:
- for all $a in Act$, and for all $s' in "image"(s,a)$, there is $t' in "image"(t,a)$ s.t. $(s', t') in R$.
]
```haskell
type Relation s = Hashable s => Set (s, s)

isSimulation :: FiniteLTS s a -> Relation s -> Bool
isSimulation lts@FiniteLTS {labels} r =
  let image = LTS.image lts
      condition (s, t) =
        all
          ( \a ->
              all
                ( \s' ->
                    any
                      (\t' -> (s', t') `S.member` r)
                      (image t a)
                )
                (image s a)
          )
          labels
   in all condition r
```

#definition[Bisimulation][
A relation $R subset.eq S times S$ is a _bisimulation_ if both $R$ and its converse are simulations.
]
```haskell
isBisimulation :: FiniteLTS s a -> Relation s -> Bool
isBisimulation lts r =
  isSimulation lts r && isSimulation lts (S.map (\(s, t) -> (t, s)) r)
```
#definition[Bisimilarity][
Two states $s$ and $t$ are _bisimilar_, written $s ~ t$, iff $(s,t) in R$ for some bisimulation $R$. \
]
Set-theoretically, $(s,t) in med ~ med arrow.l.r.long exists R. med (s,t) in R and R in {R | R "is a bisimulation"}$. By the definition of union, it follows that $~ med = union.big {R | R "is a bisimulation"}$.

#proposition[][
Bisimilarity is the unique largest bisimulation.
] <largest-bisim>
#proof[
The class of bisimulations is closed under union; hence, $~$ is itself a bisimulation. Since it is the union of all bisimulations, it is the unique largest bisimulation.
]

Unfortunately, this set-theoretic definition does not translate easily into functional programming. We therefore turn to an alternative definition that is more natural from a functional perspective.
#definition[Fixpoint definition of bisimilarity][
Let
$
F : cal(P)(S times S) -> cal(P)(S times S)
$
be defined by
$
(s, t) in F(R)
$
iff, for all $a in Act$,
$
forall_(s' in "image"(s, a)) exists_(t' in "image"(t,a)) (s', t') in R
$
and
$
forall_(t' in "image"(t,a)) exists_(s' in "image"(s,a)) (s', t') in R
$

Bisimilarity is then defined as the greatest fixed point of $F$.
]
#remark[
Knaster–Tarski theorem guarantees the existence of a greatest fixed point of $F$.
]
```haskell
bisimilarity :: FiniteLTS s a -> Relation s
bisimilarity lts@FiniteLTS {states, labels} =
  let image = LTS.image lts

      top = cartesianProduct states states

      condition r (s, t) =
        all
          ( \a ->
              all
                ( \s' ->
                    any
                      (\t' -> (s', t') `S.member` r)
                      (image t a)
                )
                (image s a)
                &&
              all
                ( \t' ->
                    any
                      (\s' -> (s', t') `S.member` r)
                      (image s a)
                )
                (image t a)
          )
          labels

      gfp r =
        let r' = S.filter (condition r) r
         in if r' == r then r else gfp r'

   in gfp top
```

Then we can easily decide whether $s ~ t$.
```haskell
bisimilar :: FiniteLTS s a -> s -> s -> Bool
bisimilar lts@FiniteLTS{} s t = (s, t) `S.member` bisimilarity lts
```
