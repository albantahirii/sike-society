-- |
-- Module      : Threats
-- Description : The four canonical threats faced by Sike Society.
--
-- This module defines the concrete threats that menace the world.
-- Each threat carries a kind, an operating domain, a hostility level,
-- and a remaining vitality. Some threats are connected to others by
-- narrative ties: the Spy Pigeons trade their intelligence to the
-- Aliens, who in turn arrive better prepared because of it.
--
-- Engagement logic — how threats are confronted, weakened, and
-- neutralized — is not defined here. It belongs to 'Interaction'.
-- This module describes only what the threats are.
module Threats
  ( -- * Threat construction
    initialThreat,

    -- * Canonical threat values
    spyPigeons,
    oceanAbuser,
    aliens,
    ancientDisturbance,

    -- * Display
    describeThreat,
  )
where

import Types

-- | Construct a 'Threat' value from a 'ThreatKind' using its canonical
-- statistics. Each kind has a fixed domain of operation, a fixed
-- hostility level, and a fixed initial energy reflecting its threat
-- to the world.
--
-- The values here are calibrated so that small threats (Spy Pigeons)
-- can be neutralized quickly, while catastrophic threats (Aliens)
-- demand a coordinated and sustained response from the society.
initialThreat :: ThreatKind -> Threat
initialThreat OceanAbuser =
  Threat
    { threatKind = OceanAbuser,
      threatLocation = Ocean,
      hostility = 25,
      threatEnergy = 50
    }
initialThreat SpyPigeons =
  Threat
    { threatKind = SpyPigeons,
      threatLocation = Sky,
      hostility = 15,
      threatEnergy = 30
    }
initialThreat Aliens =
  Threat
    { threatKind = Aliens,
      threatLocation = Earth,
      hostility = 80,
      threatEnergy = 150
    }
initialThreat AncientDisturbance =
  Threat
    { threatKind = AncientDisturbance,
      threatLocation = Hidden,
      hostility = 60,
      threatEnergy = 100
    }

-- | The Spy Pigeons threat — surveillance birds operating in the sky,
-- selling the intelligence they gather to the Aliens.
spyPigeons :: Threat
spyPigeons = initialThreat SpyPigeons

-- | The Ocean Abuser threat — illegal underwater operators exploiting
-- the seas for profit.
oceanAbuser :: Threat
oceanAbuser = initialThreat OceanAbuser

-- | The Alien threat — the historic adversary of Sike Society,
-- informed by intelligence purchased from the Spy Pigeons.
aliens :: Threat
aliens = initialThreat Aliens

-- | The Ancient Disturbance threat — old evils stirring in the
-- hidden domain, recognizable only to Leyton.
ancientDisturbance :: Threat
ancientDisturbance = initialThreat AncientDisturbance

-- | Render a single 'Threat' as a multi-line string suitable for
-- terminal output. The first line shows kind, domain, and statistics;
-- the second line carries a narrative caption that hints at the
-- threat's place in the wider story.
describeThreat :: Threat -> String
describeThreat t =
  pad 14 (show (threatKind t))
    ++ "[" ++ pad 7 (show (threatLocation t)) ++ "]  "
    ++ "hostility: " ++ pad 4 (show (hostility t))
    ++ "energy: " ++ show (threatEnergy t)
    ++ "\n                ..." ++ caption (threatKind t)
  where
    pad n s = s ++ replicate (max 1 (n - length s)) ' '
    caption SpyPigeons = "sells intel to the Aliens"
    caption Aliens = "informed by Spy Pigeons"
    caption OceanAbuser = "exploits the deep waters"
    caption AncientDisturbance = "stirs in forgotten places"