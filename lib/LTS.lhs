#import "@preview/thmbox:0.3.0": *
#show: thmbox-init()
#let definition = definition.with(color: black)
#let gray = rgb("#797979")
#let proposition = proposition.with(color: gray)

= Labelled transition system <LTS>

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

A transition system describle the behaviour of discrete (state space is discrete) state-changing systems. It consists of states and transitions between states. From any given state, the future behaviour of the system is independent from how the state is reached.

A labelled transition system is a type of transition system whose transition has a label, indicating the cause of the transition or an action resulting from the transition.

#let Act = math.italic("Act")
#let transition = math.stretch($->$, size: 1.3em)

#definition[Labelled Transition System][
A ($Act$)-labelled transition system (LTS) is a triple $(S, Act, transition)$ consisting of
- a set $S$ of states
- a set $Act$ of (actions) labels
- a transition relation $transition med subset.eq S times Act times S $
For $(s, a, s') in med transition$ we write $s transition^a s'$.
]
Note that $S$ and $Act$ are not necessarily finite or even countable. Since the importance of infinity for LTS is unclear, and it is also unclear how to express infinity using Haskell's type system, we chose to consider only the subclass of LTS whose states and labels are both finite.

#remark[
The difference between a finite LTS and a finite automaton is that the latter has designated final states, because its purpose is to output the result of the computation upon termination. Although the former does not have final states, we can use logical formulae to describe certain states as "final," such as _deadlock_ states.
]

We define finite-state finite-label LTS in Haskell as a generalized algebraic data type parametric in the state and action type.
```haskell
type Set = HashSet -- unordered finite set
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
#remark(
    variant: "TODO",
    title: "Type-driven design",
    color: rgb("#d1242f")
)[
What I actually had in mind was not to represent things using the type `Set x`. Rather, the states should just be all inhabitants of a finite type `s`, the labels all inhabitants of a finite type `a`, and the transition function a Map from an inhabitant of `(s, a)` to some inhabitants of `s`. I just do not know how to express this in Haskell's type system.
]
We note that this differs somewhat from its mathematical definition: we replaced the set of transitions with a map of images.

#definition[Image][
The _image_ of a state $s$ for a label $a$ is the set of all state that $s$ can transition into with $a$: $"image"(s, a) = brace.l s' | s transition^a s' brace.r$
]
```haskell
image :: FiniteLTS s a -> s -> a -> Set s
image FiniteLTS{images} s a = M.findWithDefault S.empty (s, a) images
```
The design of this type differs from the definition due to the following four considerations:
- An LTS can be viewed as a directed graph with labeled edges.
- As in Haskell there is no single graph representation that is at once canonical, intuitive, and efficient @haskell-graph, the representation should be tailored to the operations it is meant to support.
- The operation we perform most often on this graph is: given a state-label combination, determining which states it can transition to.
- Once instantiated, this graph is typically not modified.
Since the operation performed most frequently is image lookup, we replace the transition relation with a map to images. Furthermore, as the graph is typically not modified after instantiation, there is no need to consider how additions or deletions of states, labels, or transitions should be synchronized with the other components, nor to take into account the time and space complexity of such modifications.

Note that each image is a finite set in this design.
#definition[Image-Finite][
An LTS is _image-finite_ if for every state $s$ and label $a$, the set $"image"(s,a)$ is finite
]
This introduces no limitation, since we assume finite-state.
#proposition[
Every finite-state LTS is also image-finite
]
#proof[
Since every subset of finite set is finite and $"image"(s, a) subset.eq S$.
]

Since we also assume finite-label, it is worth noting that it is finitely branching.
#definition(color: gray)[Finitely Branching][
An LTS is _finitely branching_ if it is image-finite and all states have finite sets of
outgoing labels.
]

Under this design, it is still straightforward to decide whether $(s, a, s') in med transition$.
```haskell
hasTransition :: (s, a, s) -> FiniteLTS s a -> Bool
hasTransition (s, a, s') lts@FiniteLTS{} = s' `S.member` image lts s a
```

In addition, LTS can be constructed from a list of transitions.
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

Notice that LTS allows a state to have multiple outgoing transitions with the same label, so it is generally nondeterministic.
#definition(color: gray)[Deterministic][
An LTS is _deterministic_ if for every two transitions $s transition^a s'$ and $s transition^a s''$ it holds that $s' = s''$. \
In other words, $|"image"(s,a)| lt.eq 1$.
]
```haskell
isDeterministic :: FiniteLTS s a -> Bool
isDeterministic FiniteLTS{images} = all ((<= 1) . S.size) (M.elems images)
```
