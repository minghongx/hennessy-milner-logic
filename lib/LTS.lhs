/*
```haskell
module LTS where

import Data.Set (Set)
import qualified Data.Set as S

import Data.Map (Map)
import qualified Data.Map as M
```
*/

```haskell
data FiniteLTS s a = FiniteLTS
  { states     :: Set s
  , labels     :: Set a
  , transition :: Map (s, a) (Set s)
  }
```

```haskell
fromTransitions :: (Ord s, Ord a) => [(s, a, s)] -> FiniteLTS s a
fromTransitions ts =
  FiniteLTS
    { states = S.fromList [x | (s, _, t) <- ts, x <- [s, t]]
    , labels = S.fromList [a | (_, a, _) <- ts]
    , transition = M.fromListWith S.union
        [ ((s, a), S.singleton t) | (s, a, t) <- ts ]
    }
```
