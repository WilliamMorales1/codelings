{-|
Module      : Haskellings.RunCommands
Description : Core wrapper functions for each command
License     : BSD3
Maintainer  : james@mondaymorninghaskell.me

The are the primary functions called for each command, including
'run', 'exec', 'hint', and 'list' (but not including 'watch').
-}

module Haskellings.RunCommands (
  -- * Running Exercises
  runExercise,
  execExercise,
  verifyExercises,
  nextExercise,
  resetExercise,
  runDoctor,
  -- * Listing Exercises
  listExercises,
  listExercises',
  -- * Helper Commands
  hintExercise,
  runHelp,
  runConfigure
) where

import           Control.Monad.Reader
import qualified Data.Map                          as M
import           Data.Yaml                         (encodeFile)
import           System.Directory
import           System.Exit                       (exitWith, ExitCode (..))
import           System.FilePath                   ((</>))

import           Haskellings.Constants
import           Haskellings.DirectoryUtils
import           Haskellings.Internal.ExerciseList
import           Haskellings.LoadConfig
import           Haskellings.Processor
import           Haskellings.Progress
import           Haskellings.TerminalUtils
import           Haskellings.Types

-- | Run the exercise given by the string (i.e. 'haskellings run')
runExercise :: String -> ReaderT ProgramConfig IO ()
runExercise exerciseName = case M.lookup exerciseName allExercisesMap of
  Nothing -> progPutStrLn $ "Could not find exercise: " ++ exerciseName ++ "!"
  Just exInfo -> compileAndRunExercise exInfo >>= recordResult exInfo

-- | Execute the exercise given by the string (i.e. 'haskellings exec')
--   Only used with executable exercises.
execExercise :: String -> ReaderT ProgramConfig IO ()
execExercise exerciseName = case M.lookup exerciseName allExercisesMap of
  Nothing -> progPutStrLn $ "Could not find exercise: " ++ exerciseName ++ "!"
  Just exInfo@(ExerciseInfo _ _ (Executable _ _) _) -> executeExercise exInfo
  _ -> progPutStrLn $ "Exercise " ++ exerciseName ++ " is not executable!"

-- | List all the exercises in Haskellings with their status (done/not done).
--   (i.e. 'haskellings list')
listExercises :: ReaderT ProgramConfig IO ()
listExercises = listExercises' allExercises

-- | Core logic function for listing. Separated for testing.
listExercises' :: [ExerciseInfo] -> ReaderT ProgramConfig IO ()
listExercises' [] = progPutStrLn "No exercises!"
listExercises' exercises = do
  config <- ask
  let maxNameSize = maximum (length . exerciseName <$> exercises)
  doneFlags <- forM exercises $ \exInfo -> do
    let name = exerciseName exInfo
    isNotDone <- not <$> isDone exInfo
    if isNotDone
      then withTerminalFailure $ progPutStr "PENDING"
      else withTerminalSuccess $ progPutStr "DONE   "
    link <- fileLink (exercisesExt config </> exerciseDirectory exInfo </> haskellFileName name)
    progPutStrLn $ "  " ++ name ++ replicate (maxNameSize - length name) ' ' ++ "  " ++ link
    return (not isNotDone)
  progPutStrLn ""
  progPutProgress (length (filter id doneFlags)) (length exercises)

-- | Check exercises in order and stop at the first one that fails or still has its marker.
--   (i.e. 'haskellings verify')
verifyExercises :: ReaderT ProgramConfig IO ()
verifyExercises = go (0 :: Int) allExercises
  where
    total = length allExercises
    go _ [] = do
      progPutProgress total total
      progPutStrLnSuccess $ "All " ++ show total ++ " exercises complete!"
    go i (exInfo : rest) = do
      done <- isDone exInfo
      if done
        then go (i + 1) rest
        else do
          progPutProgress i total
          result <- compileAndRunExercise exInfo
          recordResult exInfo result
          if result == RunSuccess
            then go (i + 1) rest
            else do
              progPutStrLn $ "Stuck? 'haskellings hint " ++ exerciseName exInfo ++ "'"
              lift $ exitWith (ExitFailure 1)

-- | The first exercise that has not passed since its last edit.
nextExercise :: ReaderT ProgramConfig IO (Maybe String)
nextExercise = do
  flags <- mapM (fmap not . isDone) allExercises
  return $ exerciseName . fst <$> lookupFirst (zip allExercises flags)
  where
    lookupFirst xs = case filter snd xs of
      (x : _) -> Just x
      []      -> Nothing

-- | Restore an exercise from the pristine copy in .templates/ (i.e. 'haskellings reset')
resetExercise :: String -> ReaderT ProgramConfig IO ()
resetExercise exerciseName = case M.lookup exerciseName allExercisesMap of
  Nothing -> progPutStrLn $ "Could not find exercise: " ++ exerciseName ++ "!"
  Just exInfo -> do
    config <- ask
    let rel = exerciseDirectory exInfo </> haskellFileName exerciseName
        template = projectRoot config </> ".templates" </> rel
    exists <- lift $ doesFileExist template
    if exists
      then do
        lift $ copyFile template (fullExerciseFp (projectRoot config) (exercisesExt config) exInfo)
        progPutStrLn $ "Reset " ++ exerciseName ++ " to its original state"
      else progPutStrLnFailure $ "No pristine copy at " ++ template

-- | Report the tools haskellings needs and how to install the missing ones (i.e. 'haskellings doctor')
runDoctor :: IO ()
runDoctor = do
  stack <- findExecutable "stack"
  report "stack" stack "install stack, e.g. with ghcup: https://www.haskell.org/ghcup/"
  loadResult <- loadBaseConfigPaths
  case loadResult of
    Left NoProjectRootError -> missing "project" "run haskellings from inside the haskellings repository"
    Left NoGhcError -> missing ghcVersion $ "run `stack build` in the repository so stack installs " ++ ghcVersion ++ ", or point `haskellings configure` at it"
    Left NoStackPackageDbError -> missing "packages" "run `stack build` in the repository to install the snapshot packages the exercises import"
    Right (root, ghc, db) -> do
      ok "project" root
      ok ghcVersion ghc
      ok "packages" db
  where
    report name found install = maybe (missing name install) (ok name) found
    ok name path = withTerminalSuccess (putStr "ok     ") >> putStrLn (" " ++ pad name ++ path)
    missing name install = withTerminalFailure (putStr "missing") >> putStrLn (" " ++ pad name ++ install)
    pad s = s ++ replicate (12 - length s) ' ' 

-- | Give a hint for the given exercise (i.e. 'haskellings hint')
hintExercise :: String -> ReaderT ProgramConfig IO ()
hintExercise exerciseName = case M.lookup exerciseName allExercisesMap of
  Nothing -> progPutStrLn $ "Could not find exercise: " ++ exerciseName ++ "!"
  Just exInfo -> progPutStrLn (exerciseHint exInfo)

-- | List available commands (i.e. 'haskellings help')
runHelp :: IO ()
runHelp = mapM_ putStrLn
  [ "Available commands:"
  , "  haskellings verify            -- Check exercises in order, stopping at the first unsolved one (default)."
  , "  haskellings watch             -- Run the Watcher for continuous exercise checking."
  , "  haskellings run [exercise]    -- Run an individual exercise (default: the next unsolved one)."
  , "  haskellings exec {exercise}   -- Run an 'executable' exercise with custom input."
  , "  haskellings hint [exercise]   -- Display a hint for the exercise (default: the next unsolved one)."
  , "  haskellings list              -- List all exercises and their status."
  , "  haskellings reset {exercise}  -- Restore an exercise to its original, unsolved state."
  , "  haskellings doctor            -- Show which tools are installed and how to get the rest."
  , "  haskellings configure         -- Set custom GHC and Stack package DB paths."
  , "  haskellings version           -- Display the current version of the program."
  , "  haskellings help (-h, --help) -- Display this help message."
  ]

-- | Configure the project. Allows the user to set the GHC path and
--   the Stack package path, saving them in a config file.
runConfigure :: IO ()
runConfigure = do
  projectRoot' <- findProjectRoot
  case projectRoot' of
    Nothing -> putStrLn "Could not find project root. Please move the repository so that it is somewhere within the 'home' directory on your system."
    Just projectRoot -> runConfigureWithProjectRoot projectRoot

---------- PRIVATE FUNCTIONS ----------

runConfigureWithProjectRoot :: FilePath -> IO ()
runConfigureWithProjectRoot projectRoot = do
  putStrLn "Please enter GHC Path (or leave blank for default): "
  ghc <- getLine
  putStrLn "Please enter Stack package DB path (or leave blank): "
  stackPath <- getLine
  let configPath = projectRoot </> configFileName
  alreadyExists <- doesFileExist configPath
  when alreadyExists $ removeFile configPath
  let config = BaseConfig
                 (if null ghc then Nothing else Just ghc)
                 (if null stackPath then Nothing else Just stackPath)
  if null ghc && null stackPath
    then putStrLn "No configuration information given, will rely on defaults."
    else encodeFile configPath config >> putStrLn ("Saved configuration to " ++ configPath)
