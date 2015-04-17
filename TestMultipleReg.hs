import Control.Concurrent.MVar
import Control.Monad (void)
import Unsafe.Coerce
import GHC.Event
import Network.Socket
import System.Posix.IO
import System.Posix.Types (Fd(Fd))

main = do
    AddrInfo {addrAddress=addr}:_ <- getAddrInfo Nothing (Just "localhost") (Just "7777")

    sock <- socket AF_INET Stream defaultProtocol
    connect sock addr
    let fd = Fd $ fdSocket sock

    Just mgr <- getSystemEventManager
    doneVar <- newEmptyMVar
    let readCallback fdKey ev = fdRead fd 5 >>= print >> putMVar doneVar ()
        writeCallback fdKey ev = void $ fdWrite fd "write callback\n"
    registerFd mgr readCallback fd evtRead oneShot
    registerFd mgr writeCallback fd evtWrite oneShot
    takeMVar doneVar


--oneShot = OneShot
oneShot = unsafeCoerce False
