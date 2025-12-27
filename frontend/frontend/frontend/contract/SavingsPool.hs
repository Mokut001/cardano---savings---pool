{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module SavingsPool where

import Plutus.V2.Ledger.Api
import Plutus.V2.Ledger.Contexts
import PlutusTx
import PlutusTx.Prelude hiding (Semigroup(..), unless)
import qualified Prelude as H

-- DATUM
data PoolDatum = PoolDatum
    { owner    :: PubKeyHash
    , deadline :: POSIXTime
    } deriving H.Show

PlutusTx.unstableMakeIsData ''PoolDatum

-- REDEEMER
data PoolAction = Deposit | Withdraw
PlutusTx.unstableMakeIsData ''PoolAction

{-# INLINABLE mkValidator #-}
mkValidator :: PoolDatum -> PoolAction -> ScriptContext -> Bool
mkValidator dat act ctx =
    case act of
        Deposit -> True
        Withdraw ->
            traceIfFalse "Owner only" signedByOwner &&
            traceIfFalse "Deadline pending" deadlineReached
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    signedByOwner = txSignedBy info (owner dat)

    deadlineReached =
        contains (from $ deadline dat) (txInfoValidRange info)

{-# INLINABLE mkWrapped #-}
mkWrapped :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mkWrapped d r c =
    check (mkValidator
            (PlutusTx.unsafeFromBuiltinData d)
            (PlutusTx.unsafeFromBuiltinData r)
            (PlutusTx.unsafeFromBuiltinData c))

validator :: Validator
validator = mkValidatorScript $$(PlutusTx.compile [|| mkWrapped ||])
