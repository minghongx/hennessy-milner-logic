/*
```haskell
module HML where

import LTS (FiniteLTS, image)

import Data.HashSet (HashSet)
import qualified Data.HashSet as S

type Set = HashSet
```
*/

#let tt = math.italic("tt")
#let ff = math.italic("ff")

Given a set of actions Act, a formula of HML is defined by the BNF grammar:
$ phi ::= tt | ff | phi and phi | phi or phi | chevron.l a chevron.r phi | [a]phi quad "where" a in "Act" $
$tt$ and $ff$ denote the formulae that are valid at every state and at no state, respectively. \
$chevron.l a chevron.r phi$ denotes that it is possible to perform $a$-transition to a sate satisfying $phi$; whereas $[a]phi$ denotes that $a$-transition necessarily leads to a sate satisfiying $phi$.

We define formulae in Haskell as an inductive data type parametric in the Act type.
```haskell
data Form a
    = TT | FF
    | Con (Form a) (Form a)
    | Dis (Form a) (Form a)
    | Dia a (Form a)
    | Box a (Form a)
    deriving (Eq)
```
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
Treating $ff$ as primitive and negation as derived has a technical advantage: recursive definitions on the structure of formulae (e.g. satisfaction relation) can be given in a uniform way.

We also introduce derived modalities indexed by sets of actions:
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
They make common expression, such as deadlock $["Act"]ff$ and $a$-transition must happen next $chevron.l a chevron.r #h(0pt,weak:true) tt and ["Act" without {a}]ff$, much more perspicuous.

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

```haskell
(|=) :: FiniteLTS s a -> s -> Form a -> Bool
(|=) lts s = \case
    TT        -> True
    FF        -> False
    Con f1 f2 -> (|=) lts s f1 && (|=) lts s f2
    Dis f1 f2 -> (|=) lts s f1 || (|=) lts s f2
    Dia a  f  -> any (\s' -> (|=) lts s' f) (image lts s a)
    Box a  f  -> all (\s' -> (|=) lts s' f) (image lts s a)
```
