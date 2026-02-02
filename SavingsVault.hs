
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ScopedTypeVariables #-}

module SavingsVault where

import PlutusTx
import PlutusTx.Prelude
import Ledger
import Ledger.Value

data VaultDatum = VaultDatum
  { owner  :: PubKeyHash
  , target :: Integer
  }

PlutusTx.unstableMakeIsData ''VaultDatum

data VaultRedeemer = Withdraw
PlutusTx.unstableMakeIsData ''VaultRedeemer

{-# INLINABLE mkValidator #-}
mkValidator :: VaultDatum -> VaultRedeemer -> ScriptContext -> Bool
mkValidator datum _ ctx =
    traceIfFalse "Not owner" signedByOwner &&
    traceIfFalse "Target not reached" targetReached
  where
    info = scriptContextTxInfo ctx

    signedByOwner =
        txSignedBy info (owner datum)

    targetReached =
        let paid = valuePaidTo info (owner datum)
        in lovelaceValueOf paid >= target datum

validator :: Validator
validator = mkValidatorScript $$(PlutusTx.compile [|| mkValidator ||])

vaultAddress :: Address
vaultAddress = scriptAddress validator
