module Tree(Tree,insert,delete,search,serial,pretty,prune,leaf) where

data Tree a b = Leaf | Branch a b (Tree a b) (Tree a b) deriving Show

top :: Tree a b -> (a,b)
top (Branch a b _ _) = (a,b)

leftOf :: Tree a b -> Tree a b
leftOf (Branch _ _ x _) = x

rightOf :: Tree a b -> Tree a b
rightOf (Branch _ _ _ x) = x

search :: Ord a => a -> Tree a b -> Maybe b
search _ Leaf = Nothing
search k' (Branch k v left right)
	|k' == k = Just v
	|k' < k = search k' left
	|otherwise = search k' right

insert :: Ord a => a -> b -> Tree a b -> Tree a b
insert k v Leaf = Branch k v Leaf Leaf
insert k v (Branch k' v' left right)
	|k' == k = Branch k v left right
	|k' > k = Branch k' v' (insert k v left) right
	|otherwise = Branch k' v' left (insert k v right)

leftMost :: Tree a b -> (a,b)
leftMost (Branch a b Leaf _) = (a,b)
leftMost (Branch _ _ left _) = leftMost left

-- delete :: Ord a => a -> Tree a b -> Tree a b
delete _ Leaf = Leaf
delete k tree@(Branch k' v' Leaf Leaf)
	|k' == k = Leaf
	|otherwise = tree
delete k tree@(Branch k' v' Leaf right)
	|k == k' = right
	|k < k' = tree
	|otherwise = Branch k' v' Leaf (delete k right)
delete k tree@(Branch k' v' left Leaf)
	|k == k' = left
	|k > k' = tree
	|otherwise = Branch k' v' (delete k left) Leaf
delete k (Branch k' v' left right)
	|k < k' = Branch k' v' (delete k left) right
	|k > k' = Branch k' v' left (delete k right)
	|otherwise = Branch k'' v'' (delete k'' left) right
	-- find leftmost descendant, swap with them, then delete it again
	-- this node is special because it must be a leaf or have only one child
	where
	(k'',v'') = leftMost left

serial :: Tree a b -> [(a,b)]
serial Leaf = []
serial (Branch a b left right) = serial left ++ [(a,b)] ++ serial right

pad :: Int -> String -> String
pad n s = s ++ take (n - length s) (repeat ' ')

tab :: Int -> String
tab n = take n $ repeat ' '

fill :: Int -> [String] -> [String]
fill n s = s ++ (take (n - length s) $ repeat "")


width :: Show a => Tree a b -> Int
width Leaf = 0
width (Branch a _ left right) = length (show a) + width left + width right + 3

pretty' Leaf = []
pretty' tree@(Branch a b left right) = zipWith (++) pLeft $ zipWith (++) centralColumn pRight
	where
	showA = show a
	centralRow = "" ++ showA ++ " "

	pLeft' = pretty' left
	pRight' = pretty' right -- post condition: every row has same length

	longer = max (length pLeft') (length pRight')

	lLeft = lengthOf pLeft'
	lRight = lengthOf pRight'

	pLeft = tab lLeft : map (pad lLeft) (fill longer pLeft')
	pRight = tab lRight : map (pad lRight) (fill longer pRight')

	centralColumn = map (pad (length centralRow)) $ fill (longer+1) [centralRow]

	lengthOf [] = 0
	lengthOf (a:_) = length a

pretty tree = tail' $ concat $ map ('\n':) $ pretty' tree
	where
	tail' [] = []
	tail' x = tail x

prune :: Ord a => (a -> b -> Bool) -> Tree a b -> Tree a b
prune f Leaf = Leaf
prune f tree@(Branch a b left right)
	|f a b = Branch a b (prune f left) (prune f right)
	|otherwise = prune f $ delete a tree

-- nice = putStrLn . pretty

example = delete 6 $ insert 19 1 $ insert 20 1 $ insert 10 1 $ insert 1 1 $ insert 5 1 $ insert 6 1 $ insert 3 1 $ Leaf

display tree = putStrLn $ pretty tree

leaf = Leaf