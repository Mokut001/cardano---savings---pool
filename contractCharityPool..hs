import React, { useState, useEffect } from "react";
import {
  Lucid,
  Address,
  Blockfrost,
  fromText,
} from "lucid-cardano";

export default function SavingsPoolUI() {
  // --------------------------
  // STATE MANAGEMENT
  // --------------------------
  const [lucid, setLucid] = useState(null);
  const [walletConnected, setWalletConnected] = useState(false);
  const [walletAddress, setWalletAddress] = useState("");
  const [balance, setBalance] = useState("0");
  const [bech32, setBech32] = useState("");
  const [pkh, setPkh] = useState("");
  const [error, setError] = useState("");

  // --------------------------
  // CONFIGURATION
  // --------------------------
  const blockfrostKey = "preprodYjRkHfcazNkL0xxG9C2RdUbUoTrG7wip"; // Preprod
  const scriptAddress =
    "addr1qya0lz7unvjaxdgfjpfcwkkrcg45xw2v4jfds0k09h4yc85pn7m0dhrm2746hu9mqrujjlyqz4l0el8awwugzrfgfe9q6kjdcy";

  // --------------------------
  // INITIALIZE LUCID
  // --------------------------
  const initLucid = async () => {
    try {
      const lucidInstance = await Lucid.new(
        new Blockfrost("https://cardano-preprod.blockfrost.io/api/v0", blockfrostKey),
        "Preprod"
      );
      setLucid(lucidInstance);
    } catch (err) {
      console.log(err);
    }
  };

  useEffect(() => {
    initLucid();
  }, []);

  // --------------------------
  // CONNECT WALLET
  // --------------------------
  const connectWallet = async () => {
    try {
      if (!window.cardano.nami && !window.cardano.eternl) {
        alert("No Cardano wallet found. Install Nami or Eternl.");
        return;
      }

      const api = await window.cardano.nami.enable();
      lucid.selectWallet(api);

      const addr = await lucid.wallet.address();
      setWalletAddress(addr);

      const bal = await lucid.wallet.getUtxos();
      setBalance((await lucid.wallet.getBalance()).toString());

      setWalletConnected(true);
    } catch (err) {
      console.log(err);
    }
  };

  // --------------------------
  // DEPOSIT ADA
  // --------------------------
  const depositAda = async (amountAda) => {
    try {
      if (!walletConnected) return alert("Connect wallet first.");

      const tx = await lucid
        .newTx()
        .payToAddress(scriptAddress, { lovelace: BigInt(amountAda) * 1_000_000n })
        .complete();

      const signed = await tx.sign().complete();
      const hash = await signed.submit();

      alert("Deposit submitted: " + hash);
    } catch (err) {
      console.log(err);
      alert("Deposit failed.");
    }
  };

  // --------------------------
  // WITHDRAW ADA (OWNER ONLY)
  // --------------------------
  const withdraw = async () => {
    alert("Withdrawal logic requires your Plutus redeemer + script UTxO. I will generate this when your contract compilation is ready.");
  };

  // --------------------------
  // ADDRESS → PKH CONVERTER
  // --------------------------
  const convertAddress = () => {
    try {
      setError("");
      setPkh("");

      if (!bech32 || bech32.length < 15) {
        setError("Invalid Cardano address.");
        return;
      }

      const addr = Address.fromBech32(bech32);
      const paymentCred = addr.paymentCredential;

      if (!paymentCred || paymentCred.type !== "Key") {
        setError("Address has no payment key hash.");
        return;
      }

      setPkh(paymentCred.hash);
    } catch (err) {
      setError("Invalid bech32 address.");
    }
  };

  // --------------------------
  // UI
  // --------------------------
  return (
    <div style={{ maxWidth: "450px", margin: "auto", padding: "20px", fontFamily: "system-ui" }}>
      <h2 style={{ textAlign: "center" }}>Cardano Savings Pool</h2>

      {/* Connect Wallet */}
      {!walletConnected ? (
        <button
          onClick={connectWallet}
          style={{
            width: "100%",
            padding: "12px",
            background: "#4e73df",
            color: "white",
            border: "none",
            borderRadius: "8px",
            fontWeight: "bold",
            marginTop: "12px"
          }}
        >
          Connect Wallet
        </button>
      ) : (
        <div style={{ marginTop: "12px" }}>
          <p><b>Wallet:</b> {walletAddress}</p>
          <p><b>Balance:</b> {balance} lovelace</p>
        </div>
      )}

      {/* Deposit Box */}
      <div
        style={{
          marginTop: "20px",
          padding: "15px",
          background: "#f7f7f7",
          borderRadius: "10px",
          boxShadow: "0px 1px 5px rgba(0,0,0,0.1)"
        }}
      >
        <h3>Deposit ADA</h3>
        <input
          type="number"
          placeholder="Amount (ADA)"
          id="dep"
          style={{
            width: "100%",
            padding: "10px",
            marginTop: "8px",
            borderRadius: "6px",
            border: "1px solid #ccc"
          }}
        />
        <button
          onClick={() => depositAda(document.getElementById("dep").value)}
          style={{
            width: "100%",
            marginTop: "10px",
            padding: "12px",
            background: "#2ecc71",
            border: "none",
            color: "white",
            borderRadius: "8px",
            fontWeight: "bold"
          }}
        >
          Deposit
        </button>
      </div>

      {/* Withdraw */}
      <button
        onClick={withdraw}
        style={{
          width: "100%",
          marginTop: "20px",
          padding: "12px",
          background: "#e74c3c",
          color: "white",
          border: "none",
          borderRadius: "8px",
          fontWeight: "bold"
        }}
      >
        Withdraw (Owner Only)
      </button>

      {/* PKH Converter */}
      <div
        style={{
          marginTop: "25px",
          padding: "15px",
          background: "#fafafa",
          borderRadius: "10px",
          border: "1px solid #eee"
        }}
      >
        <h3>Bech32 → PKH Converter</h3>
        <input
          type="text"
          placeholder="Enter bech32 address"
          value={bech32}
          onChange={(e) => setBech32(e.target.value)}
          style={{
            width: "100%",
            padding: "10px",
            marginTop: "8px",
            borderRadius: "6px",
            border: "1px solid #ccc"
          }}
        />

        <button
          onClick={convertAddress}
          style={{
            width: "100%",
            marginTop: "10px",
            padding: "12px",
            background: "#34495e",
            color: "white",
            border: "none",
            borderRadius: "8px",
            fontWeight: "bold"
          }}
        >
          Convert
        </button>

        {error && <p style={{ color: "red", marginTop: "10px" }}>{error}</p>}

        {pkh && (
          <div
            style={{
              marginTop: "12px",
              padding: "10px",
              background: "white",
              borderRadius: "8px",
              border: "1px solid #ccc",
              wordBreak: "break-all"
            }}
          >
            <b>Payment Key Hash:</b>
            <br />
            {pkh}
          </div>
        )}
      </div>

      {/* Script Address */}
      <div
        style={{
          marginTop: "25px",
          padding: "12px",
          borderRadius: "8px",
          background: "#eef2ff",
          border: "1px solid #d0d6ff",
          wordBreak: "break-all"
        }}
      >
        <b>Smart Contract Address</b>
        <br />
        {scriptAddress}
      </div>
    </div>
  );
}