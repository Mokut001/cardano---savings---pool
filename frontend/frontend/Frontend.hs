{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module Main where

import Miso
import Miso.String

data Model = Model
    { walletConnected :: Bool
    , statusMessage   :: MisoString
    }

data Action
    = ConnectWallet
    | Deposit
    | Withdraw
    | NoOp

main :: IO ()
main = startApp App {..}
  where
    initialAction = NoOp
    model  = Model False "Welcome to Cardano Savings Pool"
    update = updateModel
    view   = viewModel
    events = defaultEvents
    subs   = []
    mountPoint = Nothing
    logLevel = Off

updateModel :: Action -> Model -> Effect Action Model
updateModel ConnectWallet m =
    m <# do doConnect >> pure NoOp

updateModel Deposit m =
    noEff m { statusMessage = "Deposit sent to wallet" }

updateModel Withdraw m =
    noEff m { statusMessage = "Withdraw request sent" }

updateModel _ m = noEff m

-- wallet bridge
doConnect :: IO ()
doConnect = do
    putStrLn "Connecting wallet via CIP-30 JS bridge…"

viewModel :: Model -> View Action
viewModel Model{..} =
    div_ []
      [ h2_ [] [ text "Cardano Savings Pool (DeFi Thrift)" ]
      , button_ [onClick ConnectWallet] [text "Connect Wallet"]
      , button_ [onClick Deposit] [text "Deposit ADA"]
      , button_ [onClick Withdraw] [text "Withdraw (Owner Only)"]
      , p_ [] [ text statusMessage ]
      ]
