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
  interact m t = (m', t')
    where
      m' = m { energy = max 0 (energy m - hostility t) }
      t' = t { threatEnergy = max 0 (threatEnergy t - influence m) }

  effectiveness m t
    | not (operatesIn (threatLocation t) m) = 0
    | otherwise = (energy m * influence m) `div` 100

-- | 'Member' is 'Transformable': its 'CharacterState' may be replaced
-- while every other field of the record remains intact.
instance Transformable Member where
  transform newState m = m { state = newState }

-- | Terry100 listens to the world and gathers intelligence.
terryListens :: Int -> World -> World
terryListens amount w =
  w { worldIntelligence = worldIntelligence w + amount }

-- | DrLeyton restores energy to a wounded member. Energy is capped at 100.
drLeytonHeals :: MemberId -> Int -> World -> World
drLeytonHeals mid amount w =
  w { worldMembers = Map.adjust heal mid (worldMembers w) }
  where
    heal m = m { energy = min 100 (energy m + amount) }

-- | Travis collects ocean coins from the abusers of the seas.
travisCollects :: Int -> World -> World
travisCollects amount w =
  w { worldTreasury = worldTreasury w + amount }
