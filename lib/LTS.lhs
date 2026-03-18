/*
```haskell
module LTS where

import Data.Hashable
import Data.HashSet (HashSet)
import qualified Data.HashSet as S
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as M
```
*/

```haskell
type Set = HashSet
type Map = HashMap

data FiniteLTS s a where
  FiniteLTS ::
    (Hashable s, Hashable a) =>
    { states :: Set s,
      labels :: Set a,
      images :: Map (s, a) (Set s)
    } ->
    FiniteLTS s a
```

```haskell
fromTransitions :: (Hashable s, Hashable a) => [(s, a, s)] -> FiniteLTS s a
fromTransitions ts =
  FiniteLTS
    { states = S.fromList [x | (s, _, t) <- ts, x <- [s, t]],
      labels = S.fromList [a | (_, a, _) <- ts],
      images = M.fromListWith S.union
        [ ((s, a), S.singleton t) | (s, a, t) <- ts ]
    }
```

```haskell
image :: FiniteLTS s a -> s -> a -> Set s
image FiniteLTS{images} s a = M.findWithDefault S.empty (s, a) images
```
