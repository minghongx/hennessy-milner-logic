/*
```haskell
module HML where

import Data.Set (Set)
import qualified Data.Set as S
```
*/

#let tt = math.italic("tt")
#let ff = math.italic("ff")

```haskell
data Form a
    = TT | FF
    | Con (Form a) (Form a)
    | Dis (Form a) (Form a)
    | Dia a (Form a)
    | Box a (Form a)
    deriving (Eq, Ord, Show)

neg :: Form a -> Form a
neg = \case
    TT -> FF
    FF -> TT
    Con p q -> Dis (neg p) (neg q)
    Dis p q -> Con (neg p) (neg q)
    Dia a p -> Box a (neg p)
    Box a p -> Dia a (neg p)
```

$
chevron.l A chevron.r phi := or.big_(a_n in A)[a_n]phi "and" chevron.l emptyset chevron.r phi = tt
wide wide
[A]phi := and.big_(a_n in A)[a_n]phi "and" [emptyset]phi = ff
$
```haskell
diaS :: Set a -> Form a -> Form a
diaS as p = S.foldr (\a acc -> Dis (Dia a p) acc) FF as

boxS :: Set a -> Form a -> Form a
boxS as p = S.foldr (\a acc -> Con (Box a p) acc) TT as
```
