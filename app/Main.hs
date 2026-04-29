-- |
-- Module      : Main
-- Description : Entry point for Sike Society demonstrations.
--
-- This module exists at the boundary between the pure simulation core
-- and the impure outside world. All I/O happens here. Every other
-- module in the project remains pure: deterministic, referentially
-- transparent, free of side effects.
module Main (main) where

import Characters (describeWorld, initialWorld)

main :: IO ()
main = do
  putStrLn ""
  putStrLn (describeWorld initialWorld)
  putStrLn ""