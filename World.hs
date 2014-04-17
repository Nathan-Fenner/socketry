module World(worldStart,worldLoop,World) where
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C8
import WebSocket
import System.IO
import Data.Time.Clock
import Control.Concurrent.MVar
import Tree

type Time = UTCTime
type ByteString = B.ByteString

data Event = Event ByteString Int Time -- value, queue number, time of creation
data EventQueue = Queue [Event]

data World = World
	EventQueue -- queue of events
	Int -- queue size
	(Tree ByteString (ByteString,Time)) -- tree of states

worldStart = newMVar $ World (Queue []) 0 leaf

transmit handle (World eventQueue queueSize stateTree) = webSocketSend handle $
	B.intercalate (C8.pack "|") $
		messageQueue eventQueue ++ messageState (serial stateTree)
	-- transmitQueue handle eventQueue >> transmitState handle (serial stateTree)

messageQueue (Queue es) = map (\(Event msg count time) -> C8.pack "!" `B.append` C8.pack (show count) `B.append` C8.pack ":" `B.append` msg) es
messageState list = map (\(state,(val,_)) -> state `B.append` val) list

transmitQueue handle (Queue []) = return ()
transmitQueue handle (Queue (Event b i t:z)) = do
	webSocketSend handle $ C8.pack "!" `B.append` C8.pack (show i) `B.append` C8.pack ":" `B.append` b
	transmitQueue handle (Queue z)

transmitState handle ((key,(value,time)) : z) = do
	webSocketSend handle $ key `B.append` value
	transmitState handle z
transmitState _ _ = return ()

clearWorld now (World (Queue queue) count tree) = World (Queue $ clearQueue now queue) count (clearTree now tree)
clearQueue now  (e@(Event b i t) : z)
	|diffUTCTime now t > 10 = []
	|otherwise = e : clearQueue now z
clearQueue now x = x

clearTree now tree = prune (\_ (_,t) -> diffUTCTime now t < 600) tree

timeout :: Handle -> Int -> IO a -> IO a -> IO a
timeout handle time m o = do
	q' <- hIsEOF handle
	if q' then putStrLn "is eof" >> o else do
	ready <- hWaitForInput handle time
	if ready then m else o

require :: Bool -> IO () -> IO ()
require b m = if b then m else return ()

setState key val (World queue count tree) now = World queue count $ insert key (val,now) tree

addEvent event (World (Queue queue) count state) now = World (Queue (Event event count now : queue)) (count+1) state

respond handle msg mvar
	|msg == C8.pack "ask" = do
		r <- readMVar mvar
		transmit handle r
	|B.null msg = putStrLn "empty"
	|B.take 1 msg == C8.pack "=" = let (key,val) = B.span (/= 58) msg -- state response
		in do
			world <- takeMVar mvar
			now <- getCurrentTime
			putMVar mvar $ setState key val world now
	|B.take 1 msg == C8.pack "!" = do
		world <- takeMVar mvar
		now <- getCurrentTime
		putMVar mvar $ addEvent (B.tail msg) world now
	|otherwise = putStrLn "?" >> return ()

worldLoop handle mvar = timeout handle 1000 (do
	msg <- webSocketListen handle
	respond handle msg mvar
	now <- getCurrentTime
	r <- takeMVar mvar
	putMVar mvar $ clearWorld now r
	worldLoop handle mvar)
	(putStrLn "timeoutd")

