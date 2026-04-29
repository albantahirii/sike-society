-- |
-- Module      : Characters
-- Description : Definitions of the seven members of Sike Society.
--
-- This module gives concrete form to the seven members declared
-- abstractly in 'Types'. Each member receives an initial energy,
-- influence, operational state, set of authorized domains, and
-- — where applicable — a clone origin.
--
-- The values here are not arbitrary. They reflect the canonical
-- character of each member as established in the design document:
-- Sike at the apex, the rest in close formation around him, with
-- small differences expressing the specifics of role and nature.
module Characters
  ( -- * Archetypes
    archetype,

    -- * Initial member definitions
    initialMember,
    initialMembers,

    -- * Initial world
    initialWorld,
  )
where

import qualified Data.Map.Strict as Map
import Types

-- | The poetic archetype of a member — a single phrase that captures
-- the essence of who they are within Sike Society.
--
-- Archetypes are not gameplay mechanics. They exist to anchor the
-- simulation in the artistic origin of the project: each member is
-- not merely a bundle of statistics, but a symbolic presence with
-- a recognisable spirit.
--
-- >>> archetype Sike
-- "The Visionary"
-- >>> archetype DrLeyton
-- "The Healer"
archetype :: MemberId -> String
archetype Sike = "The Visionary"
archetype Tobi = "The Keeper"
archetype Travis = "The Enforcer"
archetype Skye = "The Watcher"
archetype Leyton = "The Memory"
archetype Terry100 = "The Listener"
archetype DrLeyton = "The Healer"

-- | Construct the initial 'Member' value for a given identity.
--
-- The seven members are deliberately close in raw power: they are
-- equals serving a common purpose, with only small numeric differences
-- to express the specifics of their roles. Sike alone reaches the
-- maximum of 100/100, signalling his position at the head.
--
-- DrLeyton and Tobi sit one step below at 98/95 — the immortal healer
-- and the sovereign of the unexplored seas. The remaining four members
-- share a uniform 97/90, reflecting their status as equal pillars of
-- the society.
--
-- The 'state' field is initialised to 'Active' for every member: the
-- society awakens at full operational readiness.
initialMember :: MemberId -> Member
initialMember Sike =
  Member
    { memberId = Sike,
      energy = 100,
      influence = 100,
      state = Active,
      domains = [Earth, Ocean, Sky, Hidden],
      originatedFrom = Nothing
    }
initialMember Tobi =
  Member
    { memberId = Tobi,
      energy = 98,
      influence = 95,
      state = Active,
      domains = [Ocean, Earth],
      originatedFrom = Nothing
    }
initialMember Travis =
  Member
    { memberId = Travis,
      energy = 97,
      influence = 90,
      state = Active,
      domains = [Ocean],
      originatedFrom = Nothing
    }
initialMember Skye =
  Member
    { memberId = Skye,
      energy = 97,
      influence = 90,
      state = Active,
      domains = [Sky],
      originatedFrom = Nothing
    }
initialMember Leyton =
  Member
    { memberId = Leyton,
      energy = 97,
      influence = 90,
      state = Active,
      domains = [Hidden, Earth],
      originatedFrom = Nothing
    }
initialMember Terry100 =
  Member
    { memberId = Terry100,
      energy = 97,
      influence = 90,
      state = Active,
      domains = [Earth, Ocean, Sky, Hidden],
      originatedFrom = Nothing
    }
initialMember DrLeyton =
  Member
    { memberId = DrLeyton,
      energy = 98,
      influence = 95,
      state = Active,
      domains = [Hidden],
      originatedFrom = Just Leyton
    }

-- | The complete initial roster of Sike Society as a 'Map' keyed by
-- 'MemberId'. This is the structure the 'World' will hold.
--
-- The roster is constructed by mapping 'initialMember' across every
-- value of 'MemberId'. Adding a new member to the data type would
-- automatically extend this roster — the type system enforces
-- completeness.
initialMembers :: Map.Map MemberId Member
initialMembers = Map.fromList [(mid, initialMember mid) | mid <- allMembers]

-- | The initial state of the world at tick 0: the moment of awakening.
--
-- The society begins in peace. No threats are active. Intelligence
-- has not yet been gathered. The treasury is empty. From this clean
-- slate, the simulation will unfold according to the rules in
-- 'Interaction' and 'Simulation'.
initialWorld :: World
initialWorld =
  World
    { worldMembers = initialMembers,
      worldThreats = [],
      worldTick = 0,
      worldIntelligence = 0,
      worldTreasury = 0
    }