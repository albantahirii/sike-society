-- |
-- Module      : Main
-- Description : Entry point for Sike Society demonstrations.
--
-- This module exists at the boundary between the pure simulation core
-- and the impure outside world. All I/O happens here. Every other
-- module in the project remains pure: deterministic, referentially
-- transparent, free of side effects.
--
-- The entry point runs two canonical scenarios in sequence: the
-- society at the moment of awakening (peaceful), and the society
-- under threat (with two interconnected adversaries active).
module Main (main) where

import Characters (describeWorld, initialWorld)
import Threats (aliens, describeThreat, spyPigeons)
import Types (World (..), activeThreats)

-- | A demonstration world in which Sike Society faces two interconnected
-- threats: the Spy Pigeons watching from the sky, and the Aliens whom
-- those pigeons inform.
worldUnderThreat :: World
worldUnderThreat =
  initialWorld
    { worldThreats = [spyPigeons, aliens]
    }

-- | Render the active threats of a world as a labelled section.
threatReport :: World -> String
threatReport w =
  unlines $
    [ "",
      "Active Threats:",
      ""
    ]
      ++ map (("  " ++) . describeThreat) (activeThreats w)

-- | A scenario heading, used to separate the two demonstrations.
scenarioHeader :: String -> String
scenarioHeader title =
  unlines
    [ "",
      "=========================================================",
      "  " ++ title,
      "=========================================================",
      ""
    ]

main :: IO ()
main = do
  putStrLn (scenarioHeader "The Society at Awakening")
  putStrLn (describeWorld initialWorld)

  putStrLn (scenarioHeader "The World Under Threat")
  putStrLn (describeWorld worldUnderThreat)
  putStrLn (threatReport worldUnderThreat)