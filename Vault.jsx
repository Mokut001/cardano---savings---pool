
export default function Vault() {
  return (
    <div className="p-6 bg-slate-800 rounded-xl shadow">
      <h2 className="text-xl font-semibold mb-4">Your Vault</h2>
      <div className="mb-4">
        <label className="block text-sm mb-1">Target (ADA)</label>
        <input className="w-full p-2 rounded bg-slate-900 border border-slate-700" />
      </div>
      <button className="w-full py-3 bg-emerald-600 rounded hover:bg-emerald-700">
        Deposit ADA
      </button>
    </div>
  );
}
