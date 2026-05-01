-- |
-- Module      : Interaction
-- Description : Continuous and engagement rules of the simulation.
--
-- Placeholder. Implementation begins in the next session.
module Interaction () where

import Types
 
-- | 'Member' is 'Interactable' with any 'Threat'. Both sides pay a cost:
-- the member loses energy equal to the threat's hostility, and the threat
-- loses energy equal to the member's influence. Neither drops below zero.
instance Interactable Member where
  interact :: Member -> Threat -> (Member, Threat)
  interact m t = (m', t')
    where
      m' = m { energy = max 0 (energy m - hostility t) }
      t' = t { threatEnergy = max 0 (threatEnergy t - influence m) }
 
  -- | Effectiveness is zero when a member cannot operate in the threat's
  -- domain. Otherwise it scales with energy and influence.
  effectiveness :: Member -> Threat -> Int
  effectiveness m t
    | not (operatesIn (threatLocation t) m) = 0
    | otherwise = (energy m * influence m) `div` 100
 
-- | 'Member' is 'Transformable': its 'CharacterState' may be replaced
-- while every other field of the record remains intact.
instance Transformable Member where
  transform :: CharacterState -> Member -> Member
  transform newState m = m { state = newState }
 