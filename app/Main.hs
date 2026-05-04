-- |
-- Module      : Main
-- Description : Narrative scenario engine for the Sike Society simulation.
module Main (main) where

import Prelude hiding (interact)

import Characters (describeWorld, initialMember, initialWorld)
import qualified Data.Map.Strict as Map
import Interaction (drLeytonHeals, terryListens, travisCollects)
import System.IO (hFlush, stdout)
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

-- | Show a prompt and read a line from the user.
prompt :: IO String
prompt = do
  putStr "> "
  hFlush stdout
  getLine

-- | Wait for the user to press Enter before continuing.
pause :: IO ()
pause = do
  putStrLn ""
  putStr "[Press Enter to continue...]"
  hFlush stdout
  _ <- getLine
  return ()

-- | Event 1 — Terry100 hears whispers from the sky.
event1 :: World -> IO World
event1 w = do
  banner "MISSION 1: Distant Whispers"
  narrate "Terry100 listens to the wind..."
  detail "\"Spy Pigeons gather in the sky. They sell secrets to the Aliens.\""
  let w' = terryListens 25 w
  detail ("Intelligence: " ++ show (worldIntelligence w) ++ " -> " ++ show (worldIntelligence w'))
  return w'

-- | Event 2 — Sike commands Skye to engage the SpyPigeons.
event2 :: World -> IO World
event2 w = do
  banner "MISSION 2: The Sky Threat"
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
  banner "MISSION 3: The Invasion"
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
  banner "MISSION 4: The Healer"
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
  banner "MISSION 5: The Tide of Coin"
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

-- | The automatic narrative mission, played step by step.
runMission :: IO ()
runMission = do
  putStrLn ""
  putStrLn "============================================================"
  putStrLn "                    SIKE SOCIETY"
  putStrLn "                     The Awakening"
  putStrLn "============================================================"

  pause
  w1 <- event1 initialWorld
  pause
  w2 <- event2 w1
  pause
  w3 <- event3 w2
  pause
  w4 <- event4 w3
  pause
  w5 <- event5 w4
  pause

  banner "EPILOGUE"
  narrate "The threats are gone. The treasury grows."
  narrate "The seven rest, but their watch never ends."
  putStrLn ""
  putStrLn (describeWorld w5)

-- | A user command in the interactive terminal.
data Command
  = Listen
  | Engage
  | Heal
  | Collect
  | ShowWorld
  | Back
  | Quit
  | Unknown

-- | Parse a raw user input into a 'Command'.
parseCommand :: String -> Command
parseCommand "1" = Listen
parseCommand "2" = Engage
parseCommand "3" = Heal
parseCommand "4" = Collect
parseCommand "5" = ShowWorld
parseCommand "b" = Back
parseCommand "q" = Quit
parseCommand _   = Unknown

-- | Print the command terminal menu.
showTerminalMenu :: IO ()
showTerminalMenu = do
  putStrLn ""
  putStrLn "============================================================"
  putStrLn "            SIKE SOCIETY - Command Terminal"
  putStrLn "============================================================"
  putStrLn ""
  putStrLn "  [1] Listen for threats         (Terry100)"
  putStrLn "  [2] Engage a threat            [coming soon]"
  putStrLn "  [3] Heal a wounded member      [coming soon]"
  putStrLn "  [4] Collect ocean coins        (Travis)"
  putStrLn "  [5] Show world status"
  putStrLn "  [b] Back to main menu"
  putStrLn "  [q] Exit"
  putStrLn ""

-- | The interactive terminal loop. Holds the World between commands.
runTerminal :: World -> IO ()
runTerminal w = do
  showTerminalMenu
  input <- prompt
  case parseCommand input of
    Listen    -> handleListen w >>= runTerminal
    ShowWorld -> handleShow w >> runTerminal w
    Engage    -> notImplemented >> runTerminal w
    Heal      -> notImplemented >> runTerminal w
    Collect   -> handleCollect w >>= runTerminal
    Back      -> mainMenu
    Quit      -> putStrLn "See you on the next mission."
    Unknown   -> putStrLn "Invalid command." >> runTerminal w

-- | Handler for [1] Listen: Terry100 gathers intelligence.
handleListen :: World -> IO World
handleListen w = do
  banner "Terry100 listens to the wind..."
  let w' = terryListens 25 w
  detail ("Intelligence: " ++ show (worldIntelligence w) ++ " -> " ++ show (worldIntelligence w'))
  return w'

-- | Handler for [5] Show: print the full world report.
handleShow :: World -> IO ()
handleShow w = do
  putStrLn ""
  putStrLn (describeWorld w)

-- | Handler for [4] Collect: Travis collects ocean coins from a chosen client.
handleCollect :: World -> IO World
handleCollect w = do
  banner "Travis emerges from the deep..."
  putStrLn "  Choose a target:"
  putStrLn "    [1] Puffer Fishes who own Bindila Lounge -- overdue payments"
  putStrLn "    [2] Octopus Cartel running illegal pearl mining"
  putStrLn "    [b] Cancel"
  putStrLn ""
  input <- prompt
  case input of
    "1" -> collectFrom "Puffer Fishes (Bindila Lounge)" 50000 w
    "2" -> collectFrom "Octopus Cartel (illegal pearl mining)" 150000 w
    "b" -> return w
    _   -> putStrLn "Invalid target." >> return w

-- | Helper: collect a given amount from a named client.
collectFrom :: String -> Int -> World -> IO World
collectFrom client amount w = do
  let w' = travisCollects amount w
  detail ("ALERT: " ++ client)
  detail ("Collected: " ++ show amount ++ " ocean coins")
  detail ("Treasury:  " ++ show (worldTreasury w) ++ " -> " ++ show (worldTreasury w'))
  return w'

-- | Placeholder for commands not yet implemented.
notImplemented :: IO ()
notImplemented = putStrLn "  [coming soon]"

-- | The top-level menu: choose between automatic scenario or terminal.
mainMenu :: IO ()
mainMenu = do
  putStrLn ""
  putStrLn "============================================================"
  putStrLn "                    SIKE SOCIETY"
  putStrLn "============================================================"
  putStrLn ""
  putStrLn "  [1] Run automatic mission"
  putStrLn "  [2] Enter command terminal"
  putStrLn "  [q] Exit"
  putStrLn ""
  input <- prompt
  case input of
    "1" -> runMission >> mainMenu
    "2" -> runTerminal initialWorld
    "q" -> putStrLn "See you on the next mission."
    _   -> putStrLn "Invalid choice." >> mainMenu

main :: IO ()
main = mainMenu