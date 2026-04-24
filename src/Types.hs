-- |
-- Module      : Types
-- Description : Core algebraic data types for the Sike Society simulation.
--
-- This module defines the fundamental vocabulary of the simulation:
-- domains, states, identities, and the structures built from them.
-- All other modules depend on the types declared here.
--
-- The design follows type-driven principles: invalid states are made
-- unrepresentable, and the type signatures of later functions become
-- self-documenting consequences of these definitions.
module Types
  ( -- * Domains
    Domain (..),

    -- ** Domain helpers
    isPhysical,
    isHidden,
  )
where

-- | A 'Domain' is a region of the world in which members can act and
-- threats can appear. Three of the four are physical; the fourth is
-- the symbolic layer of memory and information.
--
-- Each member of Sike Society operates in one or more domains, and
-- a threat can only be engaged by a member whose domain set includes
-- the threat's domain.
data Domain
  = -- | The surface world: cities, forests, land.
    Earth
  | -- | The seas and unexplored deep waters.
    Ocean
  | -- | The aerial domain: clouds, atmosphere.
    Sky
  | -- | The unseen layer of memory, information, and ancient knowledge.
    Hidden
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | True if the given domain is one of the three physical domains.
--
-- >>> isPhysical Earth
-- True
-- >>> isPhysical Hidden
-- False
isPhysical :: Domain -> Bool
isPhysical Earth = True
isPhysical Ocean = True
isPhysical Sky = True
isPhysical Hidden = False

-- | True if the given domain is the symbolic 'Hidden' layer.
--
-- This is the dual of 'isPhysical'.
isHidden :: Domain -> Bool
isHidden Hidden = True
isHidden _ = False