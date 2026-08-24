"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import { collection, getDocs, query, where } from "firebase/firestore";
import { db } from "@/lib/firebase";
import {
  Gamepad2,
  BookOpen,
  Compass,
  Film,
  FileText,
  Users,
  Sparkles,
  ArrowRight,
  ShieldCheck,
  CheckCircle2,
  Zap,
  TrendingUp,
  Activity,
} from "lucide-react";

export default function AdminHomePage() {
  const { adminProfile, user } = useAuth();
  const [stats, setStats] = useState({
    students: 0,
    questions: 0,
    videos: 0,
    papers: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let isMounted = true;
    const fetchCounts = async () => {
      try {
        const studentQ = query(collection(db, "users"), where("role", "==", "Student"));
        const results = await Promise.allSettled([
          getDocs(studentQ),
          getDocs(collection(db, "questions")),
          getDocs(collection(db, "videos")),
          getDocs(collection(db, "papers")),
        ]);

        if (isMounted) {
          setStats({
            students: results[0].status === "fulfilled" ? results[0].value.size : 0,
            questions: results[1].status === "fulfilled" ? results[1].value.size : 0,
            videos: results[2].status === "fulfilled" ? results[2].value.size : 0,
            papers: results[3].status === "fulfilled" ? results[3].value.size : 0,
          });
          setLoading(false);
        }
      } catch (err) {
        console.warn("Could not fetch counts:", err);
        if (isMounted) setLoading(false);
      }
    };

    fetchCounts();
    return () => {
      isMounted = false;
    };
  }, []);

  const metricCards = [
    {
      title: "Active Students",
      value: stats.students,
      icon: Users,
      color: "from-blue-600/20 to-indigo-600/20 border-blue-500/30 text-blue-400",
      href: "/admin/students",
      description: "Registered Grade 5 students",
      accent: "bg-blue-500",
    },
    {
      title: "Question Bank",
      value: stats.questions,
      icon: BookOpen,
      color: "from-amber-600/20 to-orange-600/20 border-amber-500/30 text-amber-400",
      href: "/admin/media",
      description: "Exam practice questions",
      accent: "bg-amber-500",
    },
    {
      title: "Video Lessons",
      value: stats.videos,
      icon: Film,
      color: "from-purple-600/20 to-pink-600/20 border-purple-500/30 text-purple-400",
      href: "/admin/media",
      description: "Curated YouTube classroom",
      accent: "bg-purple-500",
    },
    {
      title: "Past Papers",
      value: stats.papers,
      icon: FileText,
      color: "from-emerald-600/20 to-teal-600/20 border-emerald-500/30 text-emerald-400",
      href: "/admin/media",
      description: "PDF examination repository",
      accent: "bg-emerald-500",
    },
  ];

  const modules = [
    {
      title: "Game Templates CMS",
      description: "Create & configure 7 interactive game engines — Abacus, Lily Pad Leap, Number Archery, Digit Builder, and more.",
      icon: Gamepad2,
      href: "/admin/games",
      iconColor: "text-purple-400 bg-purple-500/10 border-purple-500/20",
      hoverColor: "group-hover:border-purple-500/40",
    },
    {
      title: "Interactive Lessons & Quests",
      description: "Author step-by-step curriculum lessons, Leo & Ella story beats, and adaptive 3-attempt hint exercises.",
      icon: Compass,
      href: "/admin/lessons",
      iconColor: "text-indigo-400 bg-indigo-500/10 border-indigo-500/20",
      hoverColor: "group-hover:border-indigo-500/40",
    },
    {
      title: "Story Quests Manager",
      description: "Build immersive story-driven learning adventures with branching narratives and character progression.",
      icon: Sparkles,
      href: "/admin/quests",
      iconColor: "text-amber-400 bg-amber-500/10 border-amber-500/20",
      hoverColor: "group-hover:border-amber-500/40",
    },
    {
      title: "Media Hub & Questions",
      description: "Manage video lessons, past papers PDFs, and multi-subject question bank entries across all grades.",
      icon: Film,
      href: "/admin/media",
      iconColor: "text-pink-400 bg-pink-500/10 border-pink-500/20",
      hoverColor: "group-hover:border-pink-500/40",
    },
    {
      title: "Student Analytics & Roster",
      description: "Inspect real-time telemetry, 25-district roster, XP leaderboard, and weak skill diagnostics.",
      icon: Users,
      href: "/admin/students",
      iconColor: "text-emerald-400 bg-emerald-500/10 border-emerald-500/20",
      hoverColor: "group-hover:border-emerald-500/40",
    },
  ];

  return (
    <div className="space-y-8">
      {/* Welcome Banner */}
      <div className="relative rounded-3xl p-6 sm:p-8 overflow-hidden border border-indigo-500/20 shadow-2xl shadow-indigo-900/10">
        {/* Background gradient layers */}
        <div className="absolute inset-0 bg-gradient-to-br from-indigo-950/80 via-[#16123D] to-purple-950/60" />
        <div className="absolute top-0 right-0 w-96 h-96 bg-gradient-to-bl from-indigo-500/10 via-transparent to-transparent rounded-full blur-3xl" />
        <div className="absolute bottom-0 left-0 w-64 h-64 bg-gradient-to-tr from-purple-500/10 via-transparent to-transparent rounded-full blur-3xl" />

        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-xl bg-gradient-to-br from-indigo-500/20 to-purple-500/20 border border-indigo-500/30">
                <Zap className="w-5 h-5 text-amber-400" />
              </div>
              <span className="text-xs font-bold uppercase tracking-wider text-indigo-300">
                Admin Control Center
              </span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
              Welcome back, {adminProfile?.displayName || user?.email?.split("@")[0] || "Administrator"}
            </h1>
            <p className="text-xs sm:text-sm text-slate-400 max-w-2xl leading-relaxed">
              SisuPal CMS is live and connected. Configure curriculum, manage interactive lessons, create games, and monitor student mastery in real time.
            </p>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <div className="px-4 py-3 rounded-2xl bg-slate-900/60 backdrop-blur-sm border border-emerald-500/25 flex items-center gap-3">
              <div className="relative">
                <div className="w-2.5 h-2.5 rounded-full bg-emerald-400" />
                <div className="absolute inset-0 w-2.5 h-2.5 rounded-full bg-emerald-400 animate-ping opacity-40" />
              </div>
              <div>
                <div className="text-[11px] font-bold text-white">Firestore Database</div>
                <div className="text-[10px] text-emerald-400 font-mono">Connected & Synced</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {metricCards.map((card) => {
          const Icon = card.icon;
          return (
            <Link
              key={card.title}
              href={card.href}
              className={`group p-5 rounded-2xl bg-gradient-to-br ${card.color} border glass-card-hover flex flex-col justify-between transition-all duration-300 hover:scale-[1.02] hover:shadow-lg`}
            >
              <div className="flex items-center justify-between mb-4">
                <span className="text-xs font-semibold text-slate-300">{card.title}</span>
                <div className="p-2 rounded-xl bg-slate-900/60 border border-slate-800 group-hover:border-slate-600 transition-colors">
                  <Icon className="w-4 h-4" />
                </div>
              </div>
              <div>
                <div className="text-3xl font-extrabold text-white tracking-tight">
                  {loading ? (
                    <div className="h-8 w-12 rounded-lg bg-slate-800 animate-pulse" />
                  ) : (
                    card.value
                  )}
                </div>
                <p className="text-[10px] text-slate-400 mt-1.5">{card.description}</p>
              </div>
            </Link>
          );
        })}
      </div>

      {/* Management Modules */}
      <div>
        <div className="flex items-center justify-between mb-5">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-lg bg-indigo-500/10 border border-indigo-500/20">
              <Activity className="w-4 h-4 text-indigo-400" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-white">Management Modules</h2>
              <p className="text-xs text-slate-500">Curriculum authoring and content management tools</p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {modules.map((mod) => {
            const Icon = mod.icon;
            return (
              <Link
                key={mod.title}
                href={mod.href}
                className={`p-5 rounded-2xl bg-slate-900/40 backdrop-blur-sm border border-slate-800/80 ${mod.hoverColor} flex items-start justify-between group transition-all duration-300 hover:bg-slate-800/30`}
              >
                <div className="flex items-start gap-4">
                  <div className={`p-3 rounded-xl border ${mod.iconColor} group-hover:scale-110 transition-transform duration-300`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-white group-hover:text-indigo-300 transition-colors mb-1.5">
                      {mod.title}
                    </h3>
                    <p className="text-xs text-slate-500 leading-relaxed max-w-md">
                      {mod.description}
                    </p>
                  </div>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-600 group-hover:text-indigo-400 group-hover:translate-x-1 transition-all mt-3 shrink-0" />
              </Link>
            );
          })}
        </div>
      </div>
    </div>
  );
}
