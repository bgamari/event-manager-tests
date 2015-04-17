import Unsafe.Coerce
import GHC.Event
import Control.Monad (when)
import System.Posix.Types (Fd)
import System.Posix.Files
import Control.Concurrent.MVar
import System.Exit
import System.Posix.IO
import System.IO

assertRead :: String -> Fd -> IO ()
assertRead expected fd = do
    (a,_) <- fdRead fd (fromIntegral $ length expected)
    when (a /= expected) $ error "uh oh"

main = do
    fd <- openFd "test" ReadOnly Nothing defaultFileFlags
    Just mgr <- getSystemEventManager

    stageVar <- newMVar 0
    finishedVar <- newEmptyMVar
    let callback fdKey ev = do
            stage <- takeMVar stageVar
            putMVar stageVar (stage+1)
            case stage of
                0 -> assertRead "hello" fd
                1 -> assertRead " world" fd
                2 -> assertRead " this" fd
                3 -> assertRead " looks" fd
                4 -> assertRead " good" fd
                5 -> do
                    unregisterFd mgr fdKey
                    putMVar finishedVar ()

    registerFd mgr callback fd evtRead multiShot
    takeMVar finishedVar
    putStrLn "ok"

--multiShot = MultiShot
multiShot = unsafeCoerce True
