/*
```haskell
module HML where
```
*/

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
