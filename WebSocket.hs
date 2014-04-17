module WebSocket where
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C8
import Data.Bits
import Crypto.Hash.SHA1(hash)
import Data.ByteString.Base64(encode)

magicResponse ::B.ByteString -> B.ByteString
magicResponse key = encode . hash . appendMagic $ key
	where
	appendMagic x = B.append x $ C8.pack "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

-- this function performs the transformation required by the standard to accept a websocket

encodeWebSocketValue string
	|len <= 125 = B.pack [toEnum 129,toEnum len] `B.append` string
	|len <= 65535 = B.pack [toEnum 129,toEnum 126,toEnum (div len 256),toEnum (mod len 256) ] `B.append` string
	|otherwise = C8.pack "" -- why would you want to send more than 65k over a websocket? 
	where
	len = B.length string

webSocketListen handle = do
	B.hGet handle 1 -- always should be 129 for text
	f2 <- fmap ((\x -> x - 128) . fromEnum . head . B.unpack) $ B.hGet handle 1
	nGet f2
	where
	nGet n
		|n <= 125 = do
			mask <- fmap (cycle . B.unpack) $ B.hGet handle 4
			rest <- fmap B.unpack $ B.hGet handle n
			return $ B.pack $ zipWith xor rest mask
		|n == 126 = do
			[a,b] <- fmap (map fromEnum . B.unpack) $ B.hGet handle 2
			mask <- fmap (cycle . B.unpack) $ B.hGet handle 4
			rest <- fmap B.unpack $ B.hGet handle (256 * a + b)
			return $ B.pack $ zipWith xor rest mask

webSocketSend handle msg = B.hPutStr handle $ encodeWebSocketValue msg