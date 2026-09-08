module Main where

import qualified Data.ByteString as BS
import Data.Bits (testBit)
import Data.Char (chr, isSpace)
import System.Environment (getArgs)
import Text.Read (readMaybe)

data PBM = PBM
  { width :: Int
  , height :: Int
  , bytesPerRow :: Int
  , raster :: BS.ByteString
  }

main :: IO ()
main = do
  args <- getArgs
  let file = case args of
        (x:_) -> x
        []    -> "../curva_binaria_P4.pbm"

  content <- BS.readFile file
  case parsePBM content of
    Left err -> putStrLn ("Error: " ++ err)
    Right image -> do
      let m = heights image
          area = sum m

      putStrLn "=============================================="
      putStrLn " PRACTICE I - FROM PIXELS TO THE INTEGRAL"
      putStrLn " HASKELL"
      putStrLn "=============================================="
      putStrLn $ "Dimensions: " ++ show (width image) ++ " x " ++ show (height image)
      putStrLn $ "Bytes per row: " ++ show (bytesPerRow image)

      putStrLn "\n1. Compact visualization of the PBM image"
      drawImage image 100 35

      putStrLn "\n2. Height function M[x] = f(x)"
      drawHeights m 100 25

      putStrLn "\n3. Sample values"
      showSamples m 10

      putStrLn "\n4. Riemann sum"
      putStrLn $ "Area = sum(M) = " ++ show area ++ " square pixels"

-- PBM P4 parser -------------------------------------------------------------

parsePBM :: BS.ByteString -> Either String PBM
parsePBM bs =
  case readToken bs of
    Just ("P4", rest1) ->
      case readToken rest1 of
        Just (wText, rest2) ->
          case readToken rest2 of
            Just (hText, rest3) ->
              case (readMaybe wText, readMaybe hText) of
                (Just w, Just h)
                  | w > 0 && h > 0 ->
                      let bpr = (w + 7) `div` 8
                          needed = bpr * h
                      in if BS.length rest3 < needed
                         then Left "Incomplete raster data."
                         else Right $ PBM w h bpr (BS.take needed rest3)
                _ -> Left "Invalid dimensions."
            Nothing -> Left "Missing height."
        Nothing -> Left "Missing width."
    _ -> Left "The file is not a PBM P4 file."

readToken :: BS.ByteString -> Maybe (String, BS.ByteString)
readToken bs0 =
  let bs = skipSpacesAndComments bs0
  in if BS.null bs
     then Nothing
     else
       let (tok, rest) = BS.span (\b -> not (isSpace (chr (fromIntegral b))) && b /= 35) bs
       in Just (map (chr . fromIntegral) (BS.unpack tok), skipOneWhitespace rest)

skipSpacesAndComments :: BS.ByteString -> BS.ByteString
skipSpacesAndComments bs
  | BS.null bs = bs
  | otherwise =
      case BS.head bs of
        35 -> skipSpacesAndComments (dropComment bs)
        b | isSpace (chr (fromIntegral b)) -> skipSpacesAndComments (BS.tail bs)
        _ -> bs

dropComment :: BS.ByteString -> BS.ByteString
dropComment bs =
  case BS.elemIndex 10 bs of
    Just i  -> BS.drop (i + 1) bs
    Nothing -> BS.empty

-- IMPORTANT:
-- After the height token, exactly one whitespace separator belongs to the
-- header. We remove only that separator so raster bytes that happen to have
-- whitespace values are never discarded.
skipOneWhitespace :: BS.ByteString -> BS.ByteString
skipOneWhitespace bs
  | BS.null bs = bs
  | isSpace (chr (fromIntegral (BS.head bs))) = BS.tail bs
  | otherwise = bs

-- Pixel access ---------------------------------------------------------------

pixel :: PBM -> Int -> Int -> Int
pixel img x y
  | x < 0 || x >= width img || y < 0 || y >= height img = 0
  | otherwise =
      let index = y * bytesPerRow img + x `div` 8
          bit = 7 - (x `mod` 8)
          byte = BS.index (raster img) index
      in if testBit byte bit then 1 else 0

-- f(x): consecutive black pixels from the bottom ---------------------------

f :: PBM -> Int -> Int
f img x = length $ takeWhile (== 1) [pixel img x y | y <- [height img - 1, height img - 2 .. 0]]

-- M = map f [0 .. width-1]
heights :: PBM -> [Int]
heights img = map (f img) [0 .. width img - 1]

-- Console visualizations -----------------------------------------------------

samplePositions :: Int -> Int -> [Int]
samplePositions total target =
  let step = max 1 ((total + target - 1) `div` target)
  in take target [0, step .. total - 1]

drawImage :: PBM -> Int -> Int -> IO ()
drawImage img maxW maxH = do
  let sx = max 1 ((width img + maxW - 1) `div` maxW)
      sy = max 1 ((height img + maxH - 1) `div` maxH)
      xs = [0, sx .. width img - 1]
      ys = [0, sy .. height img - 1]
      block x y =
        let xEnd = min (width img - 1) (x + sx - 1)
            yEnd = min (height img - 1) (y + sy - 1)
            black = any (== 1) [pixel img px py | px <- [x..xEnd], py <- [y..yEnd]]
        in if black then '█' else ' '
  mapM_ (\y -> putStrLn [block x y | x <- xs]) ys

drawHeights :: [Int] -> Int -> Int -> IO ()
drawHeights m maxW maxH = do
  let n = length m
      sx = max 1 ((n + maxW - 1) `div` maxW)
      groups = [take sx (drop i m) | i <- [0, sx .. n - 1]]
      compact = map maximum groups
      maxValue = maximum (1 : compact)
      scaled = map (\v -> (v * maxH + maxValue - 1) `div` maxValue) compact
  mapM_ (\row -> putStrLn [if v >= row then '█' else ' ' | v <- scaled]) [maxH, maxH-1 .. 1]
  putStrLn $ replicate (length compact) '─'

showSamples :: [Int] -> Int -> IO ()
showSamples m count =
  mapM_ (\x -> putStrLn $ "x = " ++ show x ++ " -> f(x) = " ++ show (m !! x) ++ " pixels")
        (samplePositions (length m) count)
