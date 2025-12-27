{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Servant
import Network.Wai
import Network.Wai.Handler.Warp
import Data.Text

-- Simple API
type API =
       "status" :> Get '[JSON] Text
  :<|> "ping"   :> Get '[JSON] Text

server :: Server API
server =
       return "Backend running"
  :<|> return "pong"

api :: Proxy API
api = Proxy

app :: Application
app = serve api server

main :: IO ()
main = do
    putStrLn "Backend running on port 8080"
    run 8080 app
