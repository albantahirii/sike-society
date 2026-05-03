-- |
-- Module      : Main
-- Description : Narrative scenario engine for the Sike Society simulation.
module Main (main) where

import Prelude hiding (interact)

import Characters (describeWorld, initialMember, initialWorld)
import qualified Data.Map.Strict as Map
import Interaction (drLeytonHeals, terryListens, travisCollects)
import Threats (aliens, spyPigeons)
import Types

-- | A horizontal banner separating major sections of output.
banner :: String -> IO ()
banner title = do
  putStrLn ""
  putStrLn (replicate 60 '-')
  putStrLn ("  " ++ title)
  putStrLn (replicate 60 '-')
  putStrLn ""

-- | A narrated line, prefixed with a marker.
narrate :: String -> IO ()
narrate s = putStrLn ("> " ++ s)

-- | An indented detail line under a narration.
detail :: String -> IO ()
detail s = putStrLn ("  " ++ s)

-- | Event 1 — Terry100 hears whispers from the sky.
event1 :: World -> IO World
event1 w = do
  banner "EVENT 1: Distant Whispers"
  narrate "Terry100 listens to the wind..."
  detail "\"Spy Pigeons gather in the sky. They sell secrets to the Aliens.\""
  let w' = terryListens 25 w
  detail ("Intelligence: " ++ show (worldIntelligence w) ++ " -> " ++ show (worldIntelligence w'))
  return w'

-- | Event 2 — Sike commands Skye to engage the SpyPigeons.
event2 :: World -> IO World
event2 w = do
  banner "EVENT 2: The Sky Threat"
  narrate "Sike speaks: \"Skye, the sky is yours.\""
  let skye = initialMember Skye
  let (skye', pigeons') = interact skye spyPigeons
  detail ("Skye:       energy " ++ show (energy skye) ++ " -> " ++ show (energy skye'))
  detail ("SpyPigeons: energy " ++ show (threatEnergy spyPigeons) ++ " -> " ++ show (threatEnergy pigeons') ++ "  [NEUTRALIZED]")
  let updatedMembers = Map.insert Skye skye' (worldMembers w)
  return w { worldMembers = updatedMembers, worldThreats = [aliens] }

-- | Event 3 — The Aliens arrive, informed by the fallen pigeons.
event3 :: World -> IO World
event3 w = do
  banner "EVENT 3: The Invasion"
  narrate "But the Aliens have learned everything."
  narrate "Sike commands the full mobilization."
  let defenders = [Sike, Tobi, Leyton, Terry100]
  let (newMembers, alienAfter) = battleAll defenders aliens (worldMembers w)
  mapM_ (reportDefender (worldMembers w) newMembers) defenders
  detail ("Aliens:     energy " ++ show (threatEnergy aliens) ++ " -> " ++ show (threatEnergy alienAfter) ++ "  [NEUTRALIZED]")
  return w { worldMembers = newMembers, worldThreats = [] }
  where
    battleAll [] t ms = (ms, t)
    battleAll (mid : rest) t ms =
      let m = ms Map.! mid
          (m', t') = interact m t
       in battleAll rest t' (Map.insert mid m' ms)

    reportDefender oldMs newMs mid =
      let oldE = energy (oldMs Map.! mid)
          newE = energy (newMs Map.! mid)
       in detail (padRight 10 (show mid) ++ " energy " ++ show oldE ++ " -> " ++ show newE)

    padRight n s = s ++ replicate (max 1 (n - length s)) ' '

-- | Event 4 — DrLeyton walks among the wounded.
event4 :: World -> IO World
event4 w = do
  banner "EVENT 4: The Healer"
  narrate "DrLeyton walks among the wounded."
  let wounded = [Sike, Tobi, Leyton, Terry100]
  let healed = foldr (\mid acc -> drLeytonHeals mid 100 acc) w wounded
  mapM_ (reportHealing (worldMembers w) (worldMembers healed)) wounded
  return healed
  where
    reportHealing oldMs newMs mid =
      let oldE = energy (oldMs Map.! mid)
          newE = energy (newMs Map.! mid)
       in detail (padRight 10 (show mid) ++ " energy " ++ show oldE ++ " -> " ++ show newE)
    padRight n s = s ++ replicate (max 1 (n - length s)) ' '

-- | Event 5 — Travis returns from the deep with collected coin.
event5 :: World -> IO World
event5 w = do
  banner "EVENT 5: The Tide of Coin"
  narrate "Travis emerges from the deep."
  detail "ALERT: Puffer Fishes who own Bindila Lounge -- overdue payments"
  let w1 = travisCollects 50000 w
  detail ("Collected: 50,000 ocean coins")
  detail ("Treasury:  " ++ show (worldTreasury w) ++ " -> " ++ show (worldTreasury w1))
  putStrLn ""
  narrate "Travis returns to the depths."
  detail "ALERT: Octopus Cartel running illegal pearl mining"
  let w2 = travisCollects 150000 w1
  detail ("Collected: 150,000 ocean coins")
  detail ("Treasury:  " ++ show (worldTreasury w1) ++ " -> " ++ show (worldTreasury w2))
  return w2

main :: IO ()
main = do
  putStrLn ""
  putStrLn "============================================================"
  putStrLn "                    SIKE SOCIETY"
  putStrLn "                     The Awakening"
  putStrLn "============================================================"

  w1 <- event1 initialWorld
  w2 <- event2 w1
  w3 <- event3 w2
  w4 <- event4 w3
  w5 <- event5 w4

  banner "EPILOGUE"
  narrate "The threats are gone. The treasury grows."
  narrate "The seven rest, but their watch never ends."
  putStrLn ""
  putStrLn (describeWorld w5)
