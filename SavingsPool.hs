{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module SavingsPool where

import           PlutusTx                    (BuiltinData, compile, unstableMakeIsData)
import qualified PlutusTx
import           PlutusTx.Prelude            hiding (Semigroup(..), unless)
import           Plutus.V2.Ledger.Api        (Validator, Datum (..), ScriptContext (..),
                                              ValidatorHash, mkValidatorScript,
                                              unValidatorScript, scriptAddress,
                                              TxOutRef, POSIXTime,
                                              TxInfo, TxOutTx (..),
                                              adaToken, adaSymbol, Value)
import           Plutus.V2.Ledger.Contexts   (scriptContextTxInfo, txSignedBy,
                                              contains, from, txInfoValidRange)
import           Prelude                     (Show, String)
import qualified Prelude                     as H

data PoolDatum = PoolDatum
    { owner    :: PubKeyHash
    , deadline :: POSIXTime
    } deriving (Show, Generic)

data PoolAction = Fund | Withdraw
    deriving (Show, Generic)

PlutusTx.unstableMakeIsData ''PoolDatum
PlutusTx.unstableMakeIsData ''PoolAction

{-# INLINABLE mkPoolValidator #-}
mkPoolValidator :: PoolDatum -> PoolAction -> ScriptContext -> Bool
mkPoolValidator datum action ctx =
    case action of
        Fund -> True
        Withdraw ->
            traceIfFalse "Withdrawal: Not signed by owner" signedByOwner &&
            traceIfFalse "Withdrawal: Deadline not reached" deadlineReached
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    signedByOwner :: Bool
    signedByOwner = txSignedBy info (owner datum)

    deadlineReached :: Bool
    deadlineReached =
        contains (from $ deadline datum) (txInfoValidRange info)

{-# INLINABLE wrappedValidator #-}
wrappedValidator :: BuiltinData -> BuiltinData -> BuiltinData -> ()
wrappedValidator d r c =
    check $ mkPoolValidator
            (PlutusTx.unsafeFromBuiltinData d)
            (PlutusTx.unsafeFromBuiltinData r)
            (PlutusTx.unsafeFromBuiltinData c)

validator :: Validator
validator = mkValidatorScript $$(PlutusTx.compile [|| wrappedValidator ||])

validatorHash :: ValidatorHash
validatorHash = Scripts.validatorHash validator

scrAddress :: Ledger.Address
scrAddress = scriptAddress validator
