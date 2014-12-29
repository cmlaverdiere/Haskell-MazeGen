-- Haskell Maze Generator

import DisjointSet
import System.Random
import Data.List

-- Settings
height = 10
width = 10
wallStr = "x"
emptyStr = " "

-- Maze dimensions
type Dims = (Int, Int)

-- An edge is also just a 2D int tuple, as the wall between two cells.
type Edge = (Int, Int)

-- Coordinate pairs readable by Python (PIL).
-- (x1, y1, x2, y2)
type CoordPair = (Int, Int, Int, Int)

-- A maze is just an arbitrary collection of walls.
type Maze = [Edge]

-- Cartesian distance between two coordinates.
dist :: Edge -> Edge -> Int
dist (px, py) (qx, qy) = abs (px - qx) + abs (py - qy)

-- Print simple text representation of maze.
-- mazeStr :: Maze -> Dims -> String
-- mazeStr xs (dx, dy) = concatMap sym coords
--   where
--     coords = [(x, y) | x <- [0..dx], y <- [0..dy]]
--     combs = concatMap (\((a,b),(c,d)) -> [(a,b),(c,d)]) xs
--     sym (x, y)
--       | (x, y) `elem` combs = wallStr ++ formatStr
--       | otherwise           = emptyStr ++ formatStr
--         where
--           formatStr = if x == dx then "\n" else ""

-- Return a list of edges for a maze with given dimensions.
-- Excludes boundary walls.
genEdges :: Dims -> [Edge]
genEdges d@(w, h) = filter (adjacent d) pairs
  where
    el = [0..(w*h)-1]
    pairs = perms2 el

-- Given edges and dimensions, return coordinate pairs for each edge.
genCoord :: Dims -> Edge -> CoordPair
genCoord (w, h) (p1, p2) =
  let p1d = (p1 `div` h)
      p2d = (p2 `div` h)
      p1m = (p1 `mod` w)
  in if p1d == p2d then (p1m, p1d, p1m+1, p1d)
                   else (p1m, p1d, p1m, p1d+1)

genBoundary :: Dims -> [CoordPair]
genBoundary (w, h) =
     [(x1,h1,x1+1,h1) | x1 <- [0..w-1], h1 <- [0, h]]
  ++ [(w1,y1,w1,y1+1) | y1 <- [0..h-1], w1 <- [0, w]]

-- Decide if two cells are adjacent.
adjacent :: Dims -> Dims -> Bool
adjacent (w, h) (x, y) = dh + dw == 1
  where
    dh = abs ((y `div` w) - (x `div` w))
    dw = abs ((y `mod` w) - (x `mod` w))

-- Unique 2-tuples
perms2 xs = concat $ zipWith (zip . repeat) xs $ tails xs

main = do
  -- putStrLn $ mazeStr maze (width, height)
  -- TODO use random union ordering instead.
  print $ inner_edges ++ outer_edges
  -- print $ inner_edges
    where
      cells = [0..(width*height)-1]
      edges = genEdges (width, height)
      sets = makeSet cells
      (m_edges, m_sets) = foldl nextUnion (edges, sets) edges
      inner_edges = map (genCoord (width, height)) m_edges
      outer_edges = genBoundary (width, height)
