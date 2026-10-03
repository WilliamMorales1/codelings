module Main where

import           Control.Monad.Reader
import           Data.Map                  (empty)
import           Data.Tuple.Extra          (uncurry3)
import           System.Environment
import           System.IO

import           Haskellings.Constants
import           Haskellings.LoadConfig
import           Haskellings.RunCommands
import           Haskellings.TerminalUtils
import           Haskellings.Types
import           Haskellings.Watcher

main :: IO ()
main = do
  args <- getArgs
  if not (null args) && head args `elem` ["help", "-h", "--help"]
    then runHelp
    else if args == ["configure"]
      then runConfigure
    else if args == ["doctor"]
      then runDoctor
      else do
        loadResult <- loadBaseConfigPaths
        case loadResult of
          Left NoProjectRootError -> putStrLn "Couldn't find project root!"
          Left NoGhcError -> putStrLn $ "Couldn't find " ++ ghcVersion
          Left NoStackPackageDbError -> putStrLn "Couldn't find an appropriate stack package DB!"
          Right paths -> do
            let config = uncurry3 ProgramConfig paths mainProjectExercisesDir stdin stdout stderr empty
            let (command, rest) = if null args then ("verify", []) else (head args, tail args)
            runReaderT (runCommand rest command) config

runCommand :: [String] -> String -> ReaderT ProgramConfig IO ()
runCommand restArgs command = case command of
  "verify" -> verifyExercises
  "run" -> if null restArgs
    then nextExercise >>= maybe (progPutStrLn "Every exercise is done!") runExercise
    else runExercise (head restArgs)
  "reset" -> if null restArgs
    then progPutStrLn "Reset command requires an exercise name!"
    else resetExercise (head restArgs)
  "watch" -> watchExercises
  "exec" -> if null restArgs
    then progPutStrLn "Exec command requires an exercise name!"
    else execExercise (head restArgs)
  "version" -> progPutStrLn haskellingsVersion
  "list" -> listExercises
  "hint" -> if null restArgs
    then nextExercise >>= maybe (progPutStrLn "Every exercise is done!") hintExercise
    else hintExercise (head restArgs)
  _ -> lift runHelp
