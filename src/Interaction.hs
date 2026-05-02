-- |
-- Module      : Interaction
-- Description : Interaction rules and narrative actions for the simulation.
module Interaction
  ( terryListens,
    drLeytonHeals,
    travisCollects,
  )
where

import qualified Data.Map.Strict as Map
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

-- | Terry100 listens to the world and gathers intelligence.
-- Adds the given amount to the society's collective awareness.
terryListens :: Int -> World -> World
terryListens amount w =
  w { worldIntelligence = worldIntelligence w + amount }

-- | DrLeyton restores energy to a wounded member. Energy is capped at 100.
-- If the member is not present, the world is returned unchanged.
drLeytonHeals :: MemberId -> Int -> World -> World
drLeytonHeals mid amount w =
  w { worldMembers = Map.adjust heal mid (worldMembers w) }
  where
    heal m = m { energy = min 100 (energy m + amount) }

-- | Travis collects ocean coins from the abusers of the seas
-- and deposits them in the society's treasury.
travisCollects :: Int -> World -> World
travisCollects amount w =
  w { worldTreasury = worldTreasury w + amount }