{-|
Module      : Haskellings.Watcher
Description : Functionality for the 'watch' command
License     : BSD3
Maintainer  : james@mondaymorninghaskell.me

Core logic for the 'watch' command, which automatically re-runs
exercises when the user makes changes.
-}

module Haskellings.Watcher (
  -- * Watch Functions
  watchExercises,
  runExerciseWatch
) where

import           Control.Concurrent
import           Control.Monad.Reader
import           System.FilePath                   (takeFileName, (</>))
import           System.FSNotify
import           System.IO                         (hIsEOF)

import           Haskellings.DirectoryUtils
import           Haskellings.Internal.ExerciseList
import           Haskellings.Processor
import           Haskellings.Progress
import           Haskellings.TerminalUtils
import           Haskellings.Types

-- | Runs the Watcher on the default set of Haskellings exercises
watchExercises :: ReaderT ProgramConfig IO ()
watchExercises = runExerciseWatch allExercises

-- | Run the Watcher on the given set of exercises, proceding to the next exercise
--   when the current one compiles and passes the tests. Works recursively.
runExerciseWatch :: [ExerciseInfo] -> ReaderT ProgramConfig IO ()
runExerciseWatch [] = progPutStrLn "Congratulations, you've completed all the exercises!"
runExerciseWatch exs@(firstEx : restExs) = do
  config <- ask
  let total = length allExercises
  progPutProgress (max 0 (total - length exs)) total
  let fullFp = fullExerciseFp (projectRoot config) (exercisesExt config) firstEx
  alreadyDone <- isDone firstEx
  runResult <- if alreadyDone
    then return RunSuccess
    else withFileLock fullFp $ do
      result <- compileAndRunExercise firstEx
      recordResult firstEx result
      return result
  if runResult == RunSuccess
    then runExerciseWatch restExs
    else do
      let conf = defaultConfig { confDebounce = Debounce 1 }
      liftIO $ withManagerConf conf $ \mgr -> do
        signalMVar <- newEmptyMVar
        stopAction <- watchTree mgr (projectRoot config </> exercisesExt config) (shouldCheckFile firstEx)
          (\event -> runReaderT (processEvent firstEx signalMVar event) config)
        userInputThread <- forkIO $ forever (watchForUserInput config firstEx)
        takeMVar signalMVar
        stopAction
        forkIO $ killThread userInputThread
      runExerciseWatch restExs

---------- PRIVATE FUNCTIONS ----------
shouldCheckFile :: ExerciseInfo -> Event -> Bool
shouldCheckFile (ExerciseInfo exName _ _ _) (Added fp _ _) = takeFileName fp == haskellFileName exName
shouldCheckFile (ExerciseInfo exName _ _ _) (Modified fp _ _) = takeFileName fp == haskellFileName exName
shouldCheckFile _ _ = False

-- This event should be a modification of one of our exercise files
processEvent :: ExerciseInfo -> MVar () -> Event -> ReaderT ProgramConfig IO ()
processEvent exerciseInfo signalMVar _ = do
  config <- ask
  let fullFp = fullExerciseFp (projectRoot config) (exercisesExt config) exerciseInfo
  progPutStrLn $ "Running exercise: " ++ exerciseName exerciseInfo
  withFileLock fullFp $ do
    runResult <- compileAndRunExercise exerciseInfo
    recordResult exerciseInfo runResult
    when (runResult == RunSuccess) $ lift $ putMVar signalMVar ()

-- Must be IO because it is called through forkIO
watchForUserInput :: ProgramConfig -> ExerciseInfo -> IO ()
watchForUserInput config exInfo = do
  inIsEnd <- hIsEOF (inHandle config)
  if inIsEnd
    then void (threadDelay 1000000)
    else flip runReaderT config $ do
      userInput <- progReadLine
      when (userInput == "hint") $
        progPutStrLn (exerciseHint exInfo)
