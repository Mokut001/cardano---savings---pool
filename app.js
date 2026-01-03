const PROJECT_ID = "61c2c5d8c94c7d5a8f8f5a1d4e3c2b1a0f9e8d7c6";
const BF_KEY = PROJECT_ID.startsWith("mainnet") ? PROJECT_ID : "mainnet" + PROJECT_ID;
const SCRIPT_HEX = "5909245909210100003232323232323232222533300300114a0244646174756d004c636f6e7472696275746f72000000024b000000024d00000002494801b779fb5ad1dd0ed13aaf76138dbc60d73f5bcaabff122b3e961a8c5b0001";

let lucid;

async function init() {
    const status = document.getElementById("status");
    try {
        status.innerText = "Connecting to Cardano...";
        lucid = await Lucid.new(
            new Blockfrost("https://cardano-mainnet.blockfrost.io/api/v0", BF_KEY),
            "Mainnet"
        );

        const wallet = window.cardano.vespr || window.cardano.eternl || window.cardano.nami || window.cardano.lace;
        if (!wallet) throw new Error("Open in Wallet DApp Browser.");

        const api = await wallet.enable();
        lucid.selectWallet(api);

        const addr = await lucid.wallet.address();
        const scriptAddr = lucid.utils.validatorToAddress({ type: "PlutusV2", script: SCRIPT_HEX });
        
        document.getElementById("wallet-addr").innerText = addr.substring(0, 12) + "...";
        status.innerText = "Connected";
        checkBalance(scriptAddr);
    } catch (e) {
        status.innerText = "Error: " + e.message;
    }
}

async function checkBalance(scriptAddr) {
    try {
        const utxos = await lucid.utxosAt(scriptAddr);
        const totalLovelace = utxos.reduce((acc, utxo) => acc + utxo.assets.lovelace, 0n);
        document.getElementById("vault-bal").innerText = (Number(totalLovelace) / 1000000).toFixed(2) + " ADA";
    } catch (e) { console.error(e); }
}

async function deposit() {
    const status = document.getElementById("status");
    try {
        if (!lucid) await init();
        const amount = document.getElementById("amt").value;
        if (amount < 2) throw new Error("Min 2 ADA");

        status.innerText = "Signing...";
        const scriptAddr = lucid.utils.validatorToAddress({ type: "PlutusV2", script: SCRIPT_HEX });

        const tx = await lucid.newTx()
            .payToContract(scriptAddr, { inline: "d87980" }, { lovelace: BigInt(amount * 1000000) })
            .complete();

        const signed = await tx.sign().complete();
        const hash = await signed.submit();
        status.innerText = "Tx Sent!";
        alert("Hash: " + hash);
    } catch (e) {
        status.innerText = "Error: " + e.message;
    }
}

async function withdraw() {
    const status = document.getElementById("status");
    try {
        if (!lucid) await init();
        status.innerText = "Searching...";

        const script = { type: "PlutusV2", script: SCRIPT_HEX };
        const scriptAddr = lucid.utils.validatorToAddress(script);
        const utxos = await lucid.utxosAt(scriptAddr);

        if (utxos.length === 0) throw new Error("Empty");

        const tx = await lucid.newTx()
            .collectFrom(utxos, "d87980")
            .attachSpendingValidator(script)
            .addSigner(await lucid.wallet.address())
            .complete();

        const signed = await tx.sign().complete();
        const hash = await signed.submit();
        status.innerText = "Success!";
        alert("Hash: " + hash);
    } catch (e) {
        status.innerText = "Error: " + e.message;
    }
}

window.addEventListener('load', init);