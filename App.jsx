
import WalletConnect from "./components/WalletConnect";
import Vault from "./components/Vault";

export default function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-900 to-slate-900 text-white">
      <div className="max-w-5xl mx-auto p-8">
        <h1 className="text-4xl font-bold mb-6">Savings Vault</h1>
        <p className="text-gray-300 mb-8">
          Lock ADA securely until your savings target is reached.
        </p>
        <WalletConnect />
        <Vault />
      </div>
    </div>
  );
}
