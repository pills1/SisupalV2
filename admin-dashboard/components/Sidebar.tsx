"use client";

import React from "react";
import { usePathname } from "next/navigation";
import Link from "next/link";
import {
  LayoutDashboard,
  Gamepad2,
  BookOpen,
  Compass,
  Film,
  Users,
  ShieldCheck,
  Zap,
} from "lucide-react";

interface SidebarProps {
  isOpen: boolean;
  setIsOpen: (open: boolean) => void;
}

export default function Sidebar({ isOpen, setIsOpen }: SidebarProps) {
  const pathname = usePathname();

  const navigation = [
    {
      name: "Dashboard Home",
      href: "/admin",
      icon: LayoutDashboard,
    },
    {
      name: "Game Templates",
      href: "/admin/games",
      icon: Gamepad2,
    },
    {
      name: "Interactive Lessons",
      href: "/admin/lessons",
      icon: BookOpen,
    },
    {
      name: "Story Quests",
      href: "/admin/quests",
      icon: Compass,
    },
    {
      name: "Media Hub",
      href: "/admin/media",
      icon: Film,
    },
    {
      name: "Student Analytics",
      href: "/admin/students",
      icon: Users,
    },
  ];

  return (
    <>
      {/* Mobile backdrop overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/60 backdrop-blur-sm lg:hidden"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Sidebar container */}
      <aside
        className={`fixed top-0 left-0 z-50 h-screen w-64 bg-[#0C0A24] border-r border-[#1E1A4A] flex flex-col transition-transform duration-300 ease-in-out lg:translate-x-0 ${isOpen ? "translate-x-0" : "-translate-x-full"
          }`}
      >
        {/* Brand Header */}
        <div className="h-16 flex items-center justify-between px-5 border-b border-[#1E1A4A]">
          <Link href="/admin" className="flex items-center gap-3 group">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 via-purple-500 to-amber-400 p-[2px] shadow-lg shadow-indigo-500/30 group-hover:shadow-indigo-400/40 group-hover:scale-105 transition-all duration-300">
              <div className="w-full h-full bg-[#0C0A24] rounded-[10px] flex items-center justify-center">
                <Zap className="w-5 h-5 text-amber-400" />
              </div>
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <span className="font-extrabold text-white text-base tracking-tight">SisuPal</span>
                <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-md bg-gradient-to-r from-indigo-500/20 to-purple-500/20 text-indigo-300 border border-indigo-500/30">
                  CMS
                </span>
              </div>
              <p className="text-[11px] text-slate-500 font-medium">Admin & Teacher Portal</p>
            </div>
          </Link>
        </div>

        {/* Navigation List */}
        <div className="flex-1 overflow-y-auto px-3 py-5 space-y-1">
          <div className="px-3 pb-3 text-[10px] font-bold uppercase tracking-widest text-slate-600">
            Management
          </div>

          {navigation.map((item) => {
            const isActive =
              item.href === "/admin"
                ? pathname === "/admin"
                : pathname.startsWith(item.href);
            const Icon = item.icon;

            return (
              <Link
                key={item.name}
                href={item.href}
                onClick={() => setIsOpen(false)}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13px] font-semibold transition-all duration-200 group ${isActive
                    ? "bg-gradient-to-r from-indigo-600/25 to-purple-600/15 text-white border border-indigo-500/30 shadow-lg shadow-indigo-900/20"
                    : "text-slate-400 hover:text-slate-200 hover:bg-white/[0.04] border border-transparent"
                  }`}
              >
                <div
                  className={`p-1.5 rounded-lg transition-all duration-200 ${isActive
                      ? "bg-indigo-500 text-white shadow-md shadow-indigo-500/40"
                      : "bg-slate-800/50 text-slate-500 group-hover:text-indigo-400 group-hover:bg-slate-800"
                    }`}
                >
                  <Icon className="w-4 h-4" />
                </div>
                <span>{item.name}</span>
              </Link>
            );
          })}
        </div>

        {/* System Status Footer Card */}
        <div className="p-3 border-t border-[#1E1A4A]">
          <div className="p-3 rounded-xl bg-gradient-to-br from-indigo-950/50 to-slate-950/80 border border-indigo-500/15">
            <div className="flex items-center gap-2 mb-1.5">
              <ShieldCheck className="w-4 h-4 text-emerald-400" />
              <span className="text-[11px] font-bold text-white">Firestore Connected</span>
              <span className="ml-auto w-2 h-2 rounded-full bg-emerald-400 shadow-sm shadow-emerald-400/60 animate-pulse" />
            </div>
            <p className="text-[10px] text-slate-500 leading-relaxed">
              Syncing with <code className="text-indigo-400 font-mono">sisupal-782d3</code>
            </p>
          </div>
        </div>
      </aside>
    </>
  );
}
