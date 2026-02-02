
module Endpoints where

import Plutus.Contract
import Ledger
import SavingsVault

type VaultSchema =
        Endpoint "createVault" Integer
    .\/ Endpoint "withdraw" ()

createVault :: Integer -> Contract () VaultSchema Text ()
createVault targetAmt = do
  pkh <- ownPubKeyHash
  let datum = VaultDatum pkh targetAmt
      tx = mustPayToOtherScript
            (validatorHash validator)
            (Datum $ PlutusTx.toBuiltinData datum)
            (lovelaceValueOf 2000000)
  submitTx tx

withdraw :: Contract () VaultSchema Text ()
withdraw = do
  utxos <- utxosAt vaultAddress
  let redeemer = Redeemer $ PlutusTx.toBuiltinData Withdraw
  submitTxConstraintsSpending validator utxos redeemer
