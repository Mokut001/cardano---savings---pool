async function cardanoConnect() {
    if (!window.cardano || !window.cardano.nami) {
        alert("CIP-30 wallet not detected.");
        return null;
    }

    const api = await window.cardano.nami.enable();
    const usedAddresses = await api.getUsedAddresses();

    return {
        api,
        address: usedAddresses[0]
    };
}

async function cardanoSign(txCborHex) {
    const api = await window.cardano.nami.enable();
    const signedTx = await api.signTx(txCborHex, true);
    return signedTx;
}
