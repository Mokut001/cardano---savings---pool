
export default function WalletConnect() {
  return (
    <div className="mb-8 p-6 bg-slate-800 rounded-xl shadow">
      <h2 className="text-xl font-semibold mb-4">Connect Wallet</h2>
      <div className="flex gap-3 flex-wrap">
        {["nami","lace","eternl","typhon"].map(w => (
          <button key={w}
            className="px-4 py-2 bg-indigo-600 rounded hover:bg-indigo-700">
            {w.toUpperCase()}
          </button>
        ))}
      </div>
    </div>
  );
}
