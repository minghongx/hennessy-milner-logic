#import "@preview/thmbox:0.3.0": *
#show: thmbox-init()
#let gray = rgb("#797979")
#let definition = definition.with(color: black)
#let proposition = proposition.with(color: gray)
#let theorem = theorem.with(color: black)
#let corollary = corollary.with(color: black)

#let satisfies = math.forces
#let Act = math.italic("Act")
#let transition = math.stretch($->$, size: 1.3em)

= Computing minimal distinguishing formulae <Distinguish>

/*
```haskell
module Distinguish where

import HML (Form(..), neg)
import LTS (FiniteLTS(..))
import qualified LTS
import Bisim (bisimilar)

import Data.HashSet (HashSet)
import qualified Data.HashSet as S

type Set = HashSet
```
*/

== Preliminaries

#definition(color: gray)[Theory and theory equivalence][
The _theory_ of a state $s$ is the set of all formulae it satisfies: $"theory(s)" = {phi | s satisfies phi}$. \
Two states $s$ and $t$ are theory-equivalent, written $"theoryEq"(s, t)$, if $"theory"(s) = "theory"(t)$.
]

#theorem(color: gray)[Bisimulation invariance][
Let $phi$ be a HML formula. If $s satisfies phi$ and $(s,t) in R$ for some bisimulation $R$, then $t satisfies phi$.
] <bisim-invariance>
#proof[ Structural induction on $phi$. ]

#corollary(color: gray)[Bisimulation implies theory equivalence][
If $(s, t) in R$ for some bisimulation $R$ (i.e. $s ~ t$), then $"theoryEq"(s,t)$.
] <bisim-theoryeq>
#proof[ Notice that the converse of bisimulation is also a bisimulation and use @bisim-invariance twice. ]

#lemma(color: gray)[
For any image-finite LTS, $"theoryEq"$ is a bisimulation.
] <theoryeq-bisim>
#proof[ TODO ]

== Logically distinguishing

A key feature of HML is that bisimilar states cannot be logically distinguished.
#theorem[Hennessy–Milner][
For any image-finite LTS, $"theoryEq" = med ~$.
] <hennessy-milner>
#proof[ @bisim-theoryeq exactly says $~ med subset.eq "theoryEq"$. By @theoryeq-bisim and the fact that $~$ is the union of all bisimulations (@largest-bisim), $"theoryEq" subset.eq med ~$. ]

#corollary[Existence of a distinguishing formula][
If $s$ and $t$ are two states in an image-finite LTS and $s tilde.not t$, then there exists a HML formula $phi$ such that $s satisfies phi$ and $t satisfies.not phi$.
]
#proof[
By @hennessy-milner, $s tilde.not t$ implies $"theory"(s) eq.not "theory"(t)$, so there exists a HML formula $phi in "theory"(s)$ but $phi in.not "theory"(t)$.
]

When the reason that two states are not bisimilar is subtle, a distinguishing formula can help identify the source of the inequivalence. So HML is useful for explaining behavioural inequivalence.

== Computational complexity

Our goal is to find a succinct distinguishing HML formula that explains why two states are not bisimilar. This requires a notion of formula size, with the most succinct formula being one of minimal size. The most straightforward notion is the character length of the formula. However, a more appropriate measure is the number of modalities it contains, since fewer modalities mean fewer verification steps and thus a lower cognitive burden.

```haskell
size :: Form a -> Int
size = \case
    TT -> 0
    FF -> 0
    Con f1 f2 -> size f1 + size f2
    Dis f1 f2 -> size f1 + size f2
    Dia _ f -> size f + 1
    Box _ f -> size f + 1
```

#definition[MIN-DIST][
Is there a HML formula $phi$ distinguishing $s tilde.not t$ with the fewest modalities?
]

#theorem[MIN-DIST is NP-hard][
Deciding MIN-DIST is NP-hard, and it is not in NP.
]
#proof[ By a reduction from CNF-SAT. See @distinguish. ]

So, unfortunately, there is currently no algorithm that computes a minimal HML distinguishing formula. But if we measure the size of a formula in a different way, rather than by the number of modalities, then efficient algorithms are possible.

== An efficient algorithm for minimal modal-depth

#definition[Modal-depth][
The largest number of nested modalities in a formula is its _modal-depth_.
]
```haskell
modalDepth :: Form a -> Integer
modalDepth = \case
    TT -> 0
    FF -> 0
    Con f1 f2 -> max (modalDepth f1) (modalDepth f2)
    Dis f1 f2 -> max (modalDepth f1) (modalDepth f2)
    Dia _ f -> modalDepth f + 1
    Box _ f -> modalDepth f + 1
```

```haskell
kBisimilar :: FiniteLTS s a -> Integer -> s -> s -> Bool
kBisimilar _ k _ _ | k <= 0 = True
kBisimilar lts@FiniteLTS{labels} k s t =
  let image = LTS.image lts
   in all
        ( \a ->
            all
              ( \s' ->
                  any
                    (\t' -> kBisimilar lts (k - 1) s' t')
                    (image t a)
              )
              (image s a)
              &&
            all
              ( \t' ->
                  any
                    (\s' -> kBisimilar lts (k - 1) t' s')
                    (image s a)
              )
              (image t a)
        )
        labels
```

```haskell
data Depth
  = Depth Integer
  | Infinity
  deriving (Eq, Ord, Show)

minModalDepth :: FiniteLTS s a -> s -> s -> Depth
minModalDepth lts s t
  | bisimilar lts s t = Infinity
  | otherwise = Depth (search 1)
  where
    search k
      | kBisimilar lts k s t = search (k + 1)
      | otherwise = k
```

```haskell
delta :: FiniteLTS s a -> Integer -> s -> s -> Set (a, s)
delta lts@FiniteLTS{labels} i s t =
  let image = LTS.image lts
   in S.fromList
        [ (a, s')
        | a  <- S.toList labels
        , s' <- S.toList (image s a)
        , all
            (\t' -> minModalDepth lts s' t' <= Depth (i - 1))
            (image t a)
        ]
```

```haskell
distinguish :: FiniteLTS s a -> s -> s -> Form a
distinguish lts@FiniteLTS{} s t =
  case minModalDepth lts s t of
    Infinity -> error "distinguish: the given states are bisimilar"
    Depth i ->
      let image = LTS.image lts
          deltai = delta lts i s t
       in case select deltai of
            Nothing ->
              neg $ distinguish lts t s
            Just (a, s') ->
              Dia a $
                iteratedCon $
                  S.map (distinguish lts s') (image t a)

select :: Set x -> Maybe x
select = S.foldr (\x _ -> Just x) Nothing

-- https://en.wikipedia.org/wiki/Iterated_binary_operation
iteratedCon :: Set (Form a) -> Form a
iteratedCon fs
  | S.null fs = TT
  | otherwise = foldr1 Con (S.toList fs)
```
