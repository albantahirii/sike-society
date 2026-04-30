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

    -- * Character state
    CharacterState (..),

    -- ** State helpers
    canEngage,
    isResting,

    -- * Member identity
    MemberId (..),

    -- ** Identity helpers
    isLeader,
    isClone,
    allMembers,

    -- * Member structure
    Member (..),

    -- ** Member helpers
    operatesIn,
    isAlive,
    stateFromEnergy,

    -- * Threats
    ThreatKind (..),
    Threat (..),

    -- ** Threat helpers
    isNeutralized,
    threatDomain,
    isCatastrophic,

    -- * World state
    World (..),
    Tick,
    Intelligence,

    -- ** World helpers
    lookupMember,
    activeThreats,
    membersInDomain,
    isPeaceful,
    addCoins,

    -- * Type classes
    Engageable (..),
    Threatening (..),
  )
where

import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map

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

-- | The 'CharacterState' captures the operational status of a member
-- of Sike Society at a given moment in the simulation.
--
-- States are not arbitrary: they encode what a member can and cannot do.
-- A 'Dormant' member cannot engage a threat. A 'Harmonized' member is at
-- peak readiness. Transitions between states are driven by energy levels
-- and engagement history (see 'Interaction').
data CharacterState
  = -- | At full operational capacity, ready for any assignment.
    Active
  | -- | Reduced capacity after engagement; still functional.
    Strained
  | -- | Energy depleted; cannot engage, only recover.
    Dormant
  | -- | Currently engaged with a threat; heightened alertness.
    Vigilant
  | -- | Post-engagement, fully restored, in a state of equilibrium.
    Harmonized
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Whether a member in this state is permitted to engage a threat.
--
-- A 'Dormant' member must first recover before being assigned to combat.
-- All other states permit engagement, though effectiveness varies.
--
-- >>> canEngage Active
-- True
-- >>> canEngage Dormant
-- False
canEngage :: CharacterState -> Bool
canEngage Dormant = False
canEngage _ = True

-- | True if the state represents a member who is recovering rather than
-- actively contributing to society's operations.
--
-- Currently only 'Dormant' counts as resting; all other states are
-- considered active forms of contribution.
isResting :: CharacterState -> Bool
isResting Dormant = True
isResting _ = False

-- | A 'MemberId' is the unique identity of one of the seven members
-- of Sike Society. Each constructor refers to a single, specific member;
-- there is no anonymous or duplicate membership.
--
-- The choice of an algebraic data type here (rather than, say, an 'Int'
-- or a 'String') is deliberate: it makes the seven-membership of the
-- society a property guaranteed by the type system. The compiler will
-- refuse any code that attempts to invent an eighth member.
data MemberId
  = -- | The head of Sike Society. Sees one step into the future.
    Sike
  | -- | Guardian of the waters; keeper of peace beneath the surface.
    Tobi
  | -- | Enforcer in the ocean; dismantles illegal underwater businesses.
    Travis
  | -- | Guardian of the sky; intercepts illegal aerial movement.
    Skye
  | -- | Keeper of ancient knowledge; the first inhabitant of the world.
    Leyton
  | -- | The listener; intelligence officer with combat capability.
    Terry100
  | -- | The healer; clone of Leyton, guardian of the secret of immortality.
    DrLeyton
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | True if the member is the leader of Sike Society.
--
-- There is exactly one leader: 'Sike'. This function exists to make
-- leadership a queryable property rather than scattered conditionals.
--
-- >>> isLeader Sike
-- True
-- >>> isLeader Tobi
-- False
isLeader :: MemberId -> Bool
isLeader Sike = True
isLeader _ = False

-- | True if the member was created as a clone of another.
--
-- Currently only 'DrLeyton' is a clone (of 'Leyton'). The clone
-- relationship is part of the canonical lore of Sike Society and is
-- modeled here as a structural property of identity.
isClone :: MemberId -> Bool
isClone DrLeyton = True
isClone _ = False

-- | The complete roster of Sike Society, in canonical order.
--
-- This function leverages the 'Enum' and 'Bounded' instances of 'MemberId'
-- to enumerate every member without manual listing. Adding a new member
-- to the data type would automatically extend this roster.
--
-- >>> length allMembers
-- 7
allMembers :: [MemberId]
allMembers = [minBound .. maxBound]

-- | A 'Member' is the full description of a Sike Society member at a
-- given moment in the simulation. It bundles together the member's
-- identity, current vital statistics, operational state, and the
-- domains in which they are authorized to act.
--
-- Members are values, not objects: they have no methods and no hidden
-- state. Every transformation of a 'Member' produces a new 'Member',
-- preserving the purity of the simulation.
data Member = Member
  { -- | The unique identity of this member.
    memberId :: MemberId,
    -- | Current energy level, in the range [0, 100]. Drives state.
    energy :: Int,
    -- | Influence accumulated through successful engagements.
    influence :: Int,
    -- | Current operational state, derived from energy and history.
    state :: CharacterState,
    -- | The domains in which this member is permitted to act.
    domains :: [Domain],
    -- | For clones, the original member from whom they were derived.
    -- 'Nothing' for non-clones.
    originatedFrom :: Maybe MemberId
  }
  deriving (Show, Eq)

-- | True if the member is authorized to act in the given domain.
--
-- This is the structural rule that prevents, for example, 'Skye' from
-- engaging a threat in the ocean: their 'domains' field does not
-- include 'Ocean', and so 'operatesIn' returns 'False'.
--
-- >>> let skye = Member Skye 80 50 Active [Sky] Nothing
-- >>> operatesIn Sky skye
-- True
-- >>> operatesIn Ocean skye
-- False
operatesIn :: Domain -> Member -> Bool
operatesIn d m = d `elem` domains m

-- | True if the member has any energy remaining.
--
-- A member with zero energy is considered fully depleted. While the
-- simulation does not eliminate members, this predicate is used to
-- gate certain interactions (a fully depleted member cannot be
-- assigned to a new engagement).
isAlive :: Member -> Bool
isAlive m = energy m > 0

-- | Compute the appropriate 'CharacterState' for a given energy level.
--
-- This implements the energy-to-state transition rule from the design
-- document: members with high energy are 'Active', mid-range energy
-- yields 'Strained', and low energy forces 'Dormant'. Engagement and
-- post-engagement states ('Vigilant', 'Harmonized') are set explicitly
-- by interaction logic, not derived from energy alone.
--
-- >>> stateFromEnergy 80
-- Active
-- >>> stateFromEnergy 40
-- Strained
-- >>> stateFromEnergy 10
-- Dormant
stateFromEnergy :: Int -> CharacterState
stateFromEnergy e
  | e >= 60 = Active
  | e >= 20 = Strained
  | otherwise = Dormant

-- | The 'ThreatKind' enumerates the canonical types of evil that
-- Sike Society defends the world against. Each kind has its own
-- narrative origin in the lore and its own characteristic domain.
--
-- New threat kinds may be added as the simulation evolves; the type
-- system will then require all engagement and response logic to be
-- updated accordingly.
data ThreatKind
  = -- | Underwater creatures running illegal businesses in the deep.
    OceanAbuser
  | -- | Pilots transporting illegal cargo through the skies.
    SpyPigeons
  | -- | The historic adversary of Sike Society; capable of returning.
    Aliens
  | -- | Old evils from the deep past, recognizable only to Leyton.
    AncientDisturbance
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | A 'Threat' is an active, ongoing menace in the simulated world.
-- It carries a kind, a domain of operation, a measure of how dangerous
-- it currently is, and the energy it has remaining before being
-- neutralized.
--
-- Threats are values: when a member engages a threat, the result is
-- a new 'Threat' with reduced energy, not a mutated original.
data Threat = Threat
  { -- | The kind of threat (its narrative identity).
    threatKind :: ThreatKind,
    -- | The domain in which the threat is currently operating.
    threatLocation :: Domain,
    -- | How much damage this threat inflicts per engagement.
    -- Higher values mean members lose more energy when engaging.
    hostility :: Int,
    -- | The threat's own remaining vitality. When this reaches zero,
    -- the threat is neutralized and removed from the world.
    threatEnergy :: Int
  }
  deriving (Show, Eq)

-- | True if the threat has been neutralized (has no energy remaining).
--
-- A neutralized threat is logically eliminated from the world and
-- should be removed by the simulation engine in the next step.
--
-- >>> isNeutralized (Threat SpyPigeons Sky 5 0)
-- True
-- >>> isNeutralized (Threat SpyPigeons Sky 5 10)
-- False
isNeutralized :: Threat -> Bool
isNeutralized t = threatEnergy t <= 0

-- | The domain in which the threat is operating.
--
-- A trivial accessor, included as a named function for readability
-- in higher-level code. Reads as: "the domain of this threat".
threatDomain :: Threat -> Domain
threatDomain = threatLocation

-- | True if the threat is at a level of hostility that requires
-- coordinated response from multiple members.
--
-- The threshold is calibrated to the canonical lore: only the alien
-- incursion historically required a full mobilization of Sike Society.
-- This predicate is used by 'Sike' to decide when to assign multiple
-- members to a single engagement.
--
-- >>> isCatastrophic (Threat Aliens Earth 90 100)
-- True
-- >>> isCatastrophic (Threat SpyPigeons Sky 10 30)
-- False
isCatastrophic :: Threat -> Bool
isCatastrophic t = hostility t >= 50

-- | A 'Tick' is a discrete step in simulated time. Tick 0 is the
-- moment of awakening; subsequent ticks represent the unfolding of
-- events as the world evolves.
type Tick = Int

-- | An 'Intelligence' value is the society's accumulated awareness of
-- the world, gathered primarily by 'Terry100'. Higher values allow
-- threats to be detected earlier; the value is capped to prevent
-- runaway accumulation.
type Intelligence = Int

-- | A 'World' is the complete state of the simulation at a single
-- moment. It contains every member, every active threat, the current
-- tick, and the society's collected intelligence.
--
-- The 'World' is immutable. Each step of the simulation produces a
-- new 'World' that reflects the consequences of the rules and events
-- of that step. This makes the entire history of the simulation a
-- sequence of pure functions, perfectly reproducible from any
-- starting state.
data World = World
  { -- | All seven members of Sike Society, keyed by identity for
    -- efficient lookup and update.
    worldMembers :: Map MemberId Member,
    -- | All active external threats. The ordering is not significant;
    -- threats are processed by domain match, not by list position.
    worldThreats :: [Threat],
    -- | The current simulation tick. Begins at 0 and increases by
    -- one with each call to the step function.
    worldTick :: Tick,
    -- | The society's collective intelligence level. Increases passively
    -- through 'Terry100' and is consumed by some interactions.
    worldIntelligence :: Intelligence,
    -- | The society's collective treasury of ocean coins, gathered by
    -- 'Travis' from creatures abusing the seas. Held in common, never
    -- distributed individually.
    worldTreasury :: Int
  }
  deriving (Show, Eq)

-- | Look up a member by identity in the world.
--
-- Returns 'Nothing' if no such member exists, though in a well-formed
-- world all seven members should always be present. The 'Maybe' return
-- type is a safety mechanism that forces callers to consider the
-- absence case explicitly.
lookupMember :: MemberId -> World -> Maybe Member
lookupMember mid w = Map.lookup mid (worldMembers w)

-- | All threats that are still active in the world (not neutralized).
--
-- Filters out any threats whose energy has dropped to zero. The result
-- is the set of menaces the society currently has to deal with.
activeThreats :: World -> [Threat]
activeThreats w = filter (not . isNeutralized) (worldThreats w)

-- | All members whose authorized domains include the given domain.
--
-- This is the primary mechanism by which the simulation routes
-- engagement: a threat in the sky can only be addressed by members
-- whose domains include 'Sky'.
--
-- The result preserves the canonical ordering of members.
membersInDomain :: Domain -> World -> [Member]
membersInDomain d w =
  filter (operatesIn d) (Map.elems (worldMembers w))

-- | True if no active threats remain in the world.
--
-- A peaceful world is one in which the society can rest, recover, and
-- engage in passive activities (intelligence gathering, healing).
isPeaceful :: World -> Bool
isPeaceful w = null (activeThreats w)

-- | Add coins to the society's collective treasury.
--
-- This is the canonical way for the simulation to record income from
-- 'Travis' encounters with illegal underwater operators. The treasury
-- is shared, never assigned to an individual member.
addCoins :: Int -> World -> World
addCoins amount w = w { worldTreasury = worldTreasury w + amount }

-- | The 'Engageable' class describes anything that can engage a threat
-- in combat. The canonical instance is 'Member', but the abstraction
-- leaves room for future entities (allied factions, summoned defenders)
-- without modifying existing engagement logic.
--
-- An 'engage' call returns the modified engager and the modified threat,
-- reflecting the bidirectional cost of combat: both sides change.
class Engageable a where
  -- | Engage a threat. Returns the updated engager and threat.
  engage :: a -> Threat -> (a, Threat)

  -- | The current effectiveness of this engager against the given threat.
  -- Used by the command logic to choose the best member for a task.
  effectiveness :: a -> Threat -> Int

-- | The 'Threatening' class describes anything that can pose a threat
-- to the world. The canonical instance is 'Threat', but the abstraction
-- allows for richer adversary types in future iterations of the simulation.
class Threatening a where
  -- | The current hostility level of this threatening entity.
  hostilityLevel :: a -> Int

  -- | The domain in which this threatening entity operates.
  operatingDomain :: a -> Domain
  