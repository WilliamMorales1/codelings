{-|
Module      : Haskellings.Progress
Description : Remembers which exercises have passed
License     : BSD3

An exercise is done once it passes. Passes are stored with the file's
modification time and size, so editing a solved exercise puts it back in
the queue.
-}

module Haskellings.Progress (
  isDone,
  recordResult
) where

import           Control.Monad.Reader
import           System.Directory
import           System.FilePath            ((</>))

import           Haskellings.DirectoryUtils
import           Haskellings.Types

progressFile :: ProgramConfig -> FilePath
progressFile config = projectRoot config </> ".haskellings-progress"

progressKey :: ExerciseInfo -> String
progressKey exInfo = exerciseDirectory exInfo </> exerciseName exInfo

stampOf :: FilePath -> IO String
stampOf fp = do
  exists <- doesFileExist fp
  if not exists
    then return "gone"
    else do
      t <- getModificationTime fp
      s <- getFileSize fp
      return (show t ++ "|" ++ show s)

loadProgress :: ProgramConfig -> IO [(String, String)]
loadProgress config = do
  let fp = progressFile config
  exists <- doesFileExist fp
  if not exists
    then return []
    else do
      contents <- readFile fp
      -- Force the whole file so it can be rewritten right after.
      length contents `seq` return [ (k, drop 1 v) | l <- lines contents, let (k, v) = break (== '\t') l ]

-- | True when the exercise passed and has not been edited since.
isDone :: ExerciseInfo -> ReaderT ProgramConfig IO Bool
isDone exInfo = do
  config <- ask
  lift $ do
    st <- stampOf (fullExerciseFp (projectRoot config) (exercisesExt config) exInfo)
    entries <- loadProgress config
    return $ lookup (progressKey exInfo) entries == Just st

-- | Remember a pass, or forget an earlier one when the exercise no longer passes.
recordResult :: ExerciseInfo -> RunResult -> ReaderT ProgramConfig IO ()
recordResult exInfo result = do
  config <- ask
  lift $ do
    st <- stampOf (fullExerciseFp (projectRoot config) (exercisesExt config) exInfo)
    entries <- loadProgress config
    let rest = filter ((/= progressKey exInfo) . fst) entries
        new = if result == RunSuccess then rest ++ [(progressKey exInfo, st)] else rest
    writeFile (progressFile config) (unlines [ k ++ "\t" ++ v | (k, v) <- new ])
