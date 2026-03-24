import System.Environment (getArgs)
import System.Exit        (die)
main = do
  args <- getArgs
  case args of
    ["-h", _label, infile, outfile] -> process infile outfile
    _ -> die "Usage: typst-unlit -h <label> <source> <destination>"
process :: FilePath -> FilePath -> IO ()
process infile outfile = do
    ls <- lines <$> readFile infile
    writeFile outfile $ unlines $ removeComments ls
data State
  = OutsideCode
  | InHaskell
  | InHaskellTop
  deriving (Eq, Show)
withTag :: (String -> Bool) -> String -> Bool
withTag pred line = length ticks > 2 && pred tag
    where (ticks, tag) = span (== '`') line
isHaskell :: String -> Bool
isHaskell = withTag (== "haskell")
isHaskellTop = withTag (== "haskell-top")
isCodeEnd = withTag null
removeComments :: [String] -> [String]
removeComments ls = go OutsideCode ls [] []
go :: State -> [String] -> [String] -> [String] -> [String]
go _ [] top bot = reverse top ++ reverse bot
go OutsideCode (x : rest) top bot
  | isHaskellTop x = go InHaskellTop rest top ("" : bot)
  | isHaskell x = go InHaskell rest top ("" : bot)
  | otherwise = go OutsideCode rest top ("" : bot)
go InHaskell (x : rest) top bot
  | isCodeEnd x = go OutsideCode rest top ("" : bot)
  | otherwise = go InHaskell rest top (x : bot)
go InHaskellTop (x : rest) top bot
  | isCodeEnd x = go OutsideCode rest top ("" : bot)
  | otherwise = go InHaskellTop rest (x : top) bot
