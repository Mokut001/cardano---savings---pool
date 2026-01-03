# Documentation
# 🛡️ Cardano Savings Pool Documentation

##  Project Overview
**Cardano Savings Pool** is a decentralized application (DApp) that allows users to securely lock ADA into a Plutus V2 smart contract. It functions as a non-custodial vault where funds are managed by on-chain logic rather than a central authority.

- **Live URL**: `https://cardano-savings-pool-ixj9.vercel.app/`
- **Network**: Cardano Mainnet
- **Contract Type**: Plutus V2

---

##  Key Features
- **Smart Contract Security**: Uses a Plutus V2 validator to ensure funds can only be withdrawn by the authorized beneficiary.
- **Mobile Optimized**: Designed specifically for the DApp browsers in **VESPR**, **Eternl**, and **Nami**.
- **Real-Time Balance**: Fetches the current vault status directly from the blockchain using Blockfrost.
- **Minimal UI**: High-performance, dark-mode interface built with Tailwind CSS.



## . How to Use the DApp 
### Depositing ADA
1. Open your wallet (e.g., VESPR) on your phone.
2. Go to the DApp Browser and enter your Vercel URL.
3. Enter the amount of ADA (Minimum 2 ADA).
4. Click **DEPOSIT FUNDS**.
5. Sign the transaction in your wallet.

### Withdrawing ADA
1. Click **WITHDRAW ALL**.
2. The DApp will scan the script address for available UTXOs.
3. Sign the transaction.
4. Funds will be returned to your wallet address
5. 

##  Troubleshooting
- **Balance Not Updating**: The blockchain takes about 20-60 seconds to confirm a transaction. Refresh the page after 1 minute.
- **Transaction Failed**: Ensure you have enough ADA in your wallet to cover the deposit amount plus ~0.2 ADA for fees.
