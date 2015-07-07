-- | This module defines a generic non-empty data structure, which adds an additional
-- | element to any container type.

module Data.NonEmpty 
  ( NonEmpty(..)
  , (:|)
  , foldl1
  , foldMap1
  , fold1
  ) where

import Prelude

import Data.Foldable
import Data.Traversable

-- | A non-empty container of elements of type a.
-- |
-- | For example:
-- |
-- | ```purescript
-- | nonEmptyList :: NonEmpty List Int
-- | nonEmptyList = 0 :| empty
-- | ```
data NonEmpty f a = NonEmpty a (f a)

infix 5 :|

-- | An infix synonym for `NonEmpty`.
(:|) :: forall f a. a -> f a -> NonEmpty f a
(:|) = NonEmpty

-- | foldl1
foldl1 :: forall f a s. (Foldable f) => (a -> a -> a) -> NonEmpty f a -> a
foldl1 f (NonEmpty a fa) = foldl f a fa

-- | Fold a non-empty structure, collecting results in a `Semigroup`. 
foldMap1 :: forall f a s. (Semigroup s, Foldable f) => (a -> s) -> NonEmpty f a -> s
foldMap1 f (NonEmpty a fa) = foldl (\s a1 -> s <> f a1) (f a) fa

-- | Fold a non-empty structure.
fold1 :: forall f s. (Semigroup s, Foldable f) => NonEmpty f s -> s
fold1 = foldMap1 id

instance showNonEmpty :: (Show a, Show (f a)) => Show (NonEmpty f a) where
  show (NonEmpty a fa) = "(NonEmpty " ++ show a ++ " " ++ show fa ++ ")"

instance eqNonEmpty :: (Eq a, Eq (f a)) => Eq (NonEmpty f a) where
  eq (NonEmpty a1 fa1) (NonEmpty a2 fa2) = a1 == a2 && fa1 == fa2

instance ordNonEmpty :: (Ord a, Ord (f a)) => Ord (NonEmpty f a) where
  compare (NonEmpty a1 fa1) (NonEmpty a2 fa2) = 
    case compare a1 a2 of
      EQ -> compare fa1 fa2
      other -> other
      
instance functorNonEmpty :: (Functor f) => Functor (NonEmpty f) where
  map f (NonEmpty a fa) = NonEmpty (f a) (map f fa)
      
instance foldableNonEmpty :: (Foldable f) => Foldable (NonEmpty f) where
  foldMap f (NonEmpty a fa) = f a <> foldMap f fa
  foldl f b (NonEmpty a fa) = foldl f (f b a) fa
  foldr f b (NonEmpty a fa) = f a (foldr f b fa)
      
instance traversableNonEmpty :: (Traversable f) => Traversable (NonEmpty f) where
  sequence (NonEmpty a fa) = NonEmpty <$> a <*> sequence fa
  traverse f (NonEmpty a fa) = NonEmpty <$> f a <*> traverse f fa