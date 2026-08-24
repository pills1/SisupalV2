"use client";

import React from "react";
import { useAuth } from "@/lib/auth-context";
import { Menu, LogOut, User, Bell, Sparkles } from "lucide-react";

interface NavbarProps {
  onToggleSidebar: () => void;
}

export default function Navbar({ onToggleSidebar }: NavbarProps) {
  const { user, adminProfile, signOutUser } = useAuth();

  return (
    <header className="h-16 border-b border-[#262057] bg-[#120E33]/90 backdrop-blur-md sticky top-0 z-30 px-4 lg:px-8 flex items-center justify-between">
      {/* Left: Mobile Menu Toggle */}
      <div className="flex items-center gap-3">
        <button
          onClick={onToggleSidebar}
          className="lg:hidden p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60 transition-colors"
        >
          <Menu className="w-5 h-5" />
        </button>
      </div>

      {/* Right: Admin Actions & Profile */}
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-3 pl-3 border-l border-slate-800">
          <div className="text-right hidden sm:block">
            <div className="text-xs font-bold text-white leading-tight">
              {adminProfile?.displayName || user?.email?.split("@")[0] || "Admin"}
            </div>
            <div className="text-[10px] text-purple-400 font-semibold">
              {adminProfile?.role || "Teacher / Admin"}
            </div>
          </div>

          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-purple-600 to-indigo-600 p-0.5 shadow-md shadow-purple-600/30 flex items-center justify-center text-white">
            <User className="w-4 h-4" />
          </div>

          <button
            onClick={() => signOutUser()}
            title="Sign Out"
            className="p-2 rounded-xl text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 border border-transparent hover:border-rose-500/30 transition-all ml-1"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </header>
  );
}
