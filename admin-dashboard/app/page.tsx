"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { Loader2 } from "lucide-react";

export default function RootPage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading) {
      if (user) {
        router.replace("/admin");
      } else {
        router.replace("/login");
      }
    }
  }, [user, loading, router]);

  return (
    <div className="min-h-screen bg-[#0D0B26] flex flex-col items-center justify-center text-white">
      <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-purple-600 to-indigo-500 animate-pulse flex items-center justify-center shadow-lg shadow-purple-500/30 mb-4">
        <span className="text-2xl">🦁</span>
      </div>
      <div className="flex items-center gap-2 text-slate-400 text-sm">
        <Loader2 className="w-4 h-4 animate-spin text-purple-400" />
        <span>Loading SisuPal CMS...</span>
      </div>
    </div>
  );
}
