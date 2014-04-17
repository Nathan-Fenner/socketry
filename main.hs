
import Network
import Control.Concurrent
import Control.Concurrent.MVar
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C8
import System.IO
import World
import WebSocket


data Void

main = do
	world <- worldStart
	listenOn (PortNumber 82) >>= loop world

loop :: MVar World -> Socket -> IO Void
loop mvar socket = do
	(handle,host,port) <- accept socket
	forkIO $ process mvar handle host port
	loop mvar socket

rn :: B.ByteString
rn = C8.pack "\r"

getHeader :: Handle -> IO [B.ByteString]
getHeader handle = fmap reverse $ getHeader' handle []
getHeader' handle list = do
	
	if not True then return list else do
	q <- B.hGetLine handle
	if rn == q
	then
		return list
	else
		getHeader' handle (q:list)



process mvar handle host port = do
	headers <- getHeader handle
	print headers
	respond mvar handle headers
	
getFrom :: B.ByteString -> [B.ByteString] -> B.ByteString
getFrom v list = getFrom' list
	where
	getFrom' [] = C8.pack ""
	getFrom' (a:z)
		|B.take (len+2) a == check = B.drop (len+2) a
		|otherwise = getFrom' z
	len = B.length v
	check = v `B.append` C8.pack ": "

sayAndClose handle given = do
	C8.hPutStr handle given
	hClose handle

respond :: MVar World -> Handle -> [B.ByteString] -> IO ()
respond mvar handle headers
	|null headers = sayAndClose handle $ C8.pack ""
	|firstLine == C8.pack "GET / HTTP/1.1\r" = indexPage >>= sayAndClose handle
	|B.take 15 firstLine == C8.pack "GET /resources/" = loadResource handle $ let r = B.drop 15 firstLine in B.take (B.length r - 10) r
	|firstLine == C8.pack "GET /favicon.ico HTTP/1.1\r" = sayAndClose handle $ C8.pack ""
	|getFrom (C8.pack "Upgrade") headers == C8.pack "websocket\r" = do
		putStrLn "Websocket request got."
		websocket mvar handle headers
	|otherwise = do
		putStrLn "HEADERS"
		mapM_ C8.putStrLn headers
		putStrLn "END"
		return $ () -- C8.pack ""
	where
	firstLine = head headers

loadResource handle loc = do
	let file = "resources/" ++ decode (C8.unpack loc)
	B.readFile file >>= sayAndClose handle
	
	where
	decode ('%':'2':'0':z) = ' ' : decode z
	decode (a:z) = a : decode z
	decode x = x

indexPage :: IO B.ByteString
indexPage = do
	file <- B.readFile "index.html"
	let len = B.length file
	return $ C8.pack "HTTP/1.1 200 OK\r\nContent-Length: " `B.append` C8.pack (show len) `B.append` C8.pack "\r\n\r\n" `B.append` file

websocket mvar handle headers = do
	putStrLn "websocket muse"
	let key = B.init $ getFrom (C8.pack "Sec-WebSocket-Key") headers
	putStr "key: "
	C8.putStrLn key
	let key' = magicResponse key
	putStr "reply: "
	C8.putStrLn key'
	let httpRespond = C8.pack "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: "
	let httpTail = C8.pack "\r\n\r\n"
	C8.hPutStr handle (httpRespond `B.append` key' `B.append` httpTail)
	putStrLn "Opened"
	worldLoop handle mvar
	putStrLn "Closed"
