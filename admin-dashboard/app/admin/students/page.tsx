"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import { Student } from "@/types";
import { fetchCollection } from "@/lib/firestore-crud";
import { useToast } from "@/components/Toast";
import StudentDiagnosticModal from "@/components/students/StudentDiagnosticModal";
import SeederButton from "@/components/students/SeederButton";
import {
  Users,
  Trophy,
  Flame,
  Search,
  Filter,
  MapPin,
  GraduationCap,
  Sparkles,
  BarChart3,
  Loader2,
  ChevronRight,
  TrendingUp,
  School,
  Clock,
  ArrowUpDown,
} from "lucide-react";

// Pre-populated Sri Lankan Districts for Dropdown Filtering
const SRI_LANKAN_DISTRICTS = [
  "All Districts",
  "Colombo",
  "Gampaha",
  "Kalutara",
  "Kandy",
  "Matale",
  "Nuwara Eliya",
  "Galle",
  "Matara",
  "Hambantota",
  "Jaffna",
  "Kilinochchi",
  "Mannar",
  "Vavuniya",
  "Mullaitivu",
  "Batticaloa",
  "Ampara",
  "Trincomalee",
  "Kurunegala",
  "Puttalam",
  "Anuradhapura",
  "Polonnaruwa",
  "Badulla",
  "Monaragala",
  "Ratnapura",
  "Kegalle",
];

const GRADES = ["All Grades", "Grade 3", "Grade 4", "Grade 5"];

export default function StudentsPage() {
  const { showToast } = useToast();

  // ─── DATA & UI STATES ─────────────────────────────────────────────────────
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  // ─── FILTER STATES ────────────────────────────────────────────────────────
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [selectedDistrict, setSelectedDistrict] = useState<string>("All Districts");
  const [selectedGrade, setSelectedGrade] = useState<string>("All Grades");
  const [sortBy, setSortBy] = useState<"xp" | "streak" | "name" | "recent">("xp");

  // ─── MODAL STATES ─────────────────────────────────────────────────────────
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [diagnosticModalOpen, setDiagnosticModalOpen] = useState<boolean>(false);

  // ─── FETCH STUDENTS ───────────────────────────────────────────────────────
  const loadStudents = useCallback(async () => {
    setLoading(true);
    try {
      const users = await fetchCollection<any>("users");
      const data: Student[] = users
        .filter(
          (u) =>
            u.role === "student" ||
            u.isStudent === true ||
            (u.id && typeof u.id === "string" && u.id.startsWith("student_")) ||
            (u.grade !== undefined && u.role !== "admin")
        )
        .map((u) => ({
          id: u.id,
          name: u.name || u.displayName || "Unknown Student",
          grade: Number(u.grade) || 5,
          district: u.district || "Colombo",
          xp: Number(u.xp) || Number(u.points) || 0,
          streak: Number(u.streak) || Number(u.currentStreak) || 0,
          lastActiveDate: u.lastActiveDate || u.updatedAt || new Date(),
          avatarUrl: u.avatarUrl || u.photoURL,
          email: u.email,
          school: u.school,
          role: u.role || "student",
          questionAttempts: u.questionAttempts || [],
          totalQuestionsAttempted:
            u.totalQuestionsAttempted ||
            (u.questionAttempts ? u.questionAttempts.length : 0),
        }));

      setStudents(data);
    } catch (error) {
      console.error("Error loading students:", error);
      showToast("Error loading student roster from Firestore", "error");
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    loadStudents();
  }, [loadStudents]);

  // ─── FILTER & SORT LOGIC ──────────────────────────────────────────────────
  const filteredStudents = useMemo(() => {
    return students
      .filter((s) => {
        // Search Filter
        const query = searchQuery.toLowerCase().trim();
        const matchesSearch =
          !query ||
          s.name.toLowerCase().includes(query) ||
          (s.school && s.school.toLowerCase().includes(query)) ||
          (s.district && s.district.toLowerCase().includes(query));

        // District Filter
        const matchesDistrict =
          selectedDistrict === "All Districts" ||
          s.district.toLowerCase() === selectedDistrict.toLowerCase();

        // Grade Filter
        const matchesGrade =
          selectedGrade === "All Grades" ||
          `Grade ${s.grade}` === selectedGrade;

        return matchesSearch && matchesDistrict && matchesGrade;
      })
      .sort((a, b) => {
        if (sortBy === "xp") return (b.xp || 0) - (a.xp || 0);
        if (sortBy === "streak") return (b.streak || 0) - (a.streak || 0);
        if (sortBy === "name") return a.name.localeCompare(b.name);
        return 0;
      });
  }, [students, searchQuery, selectedDistrict, selectedGrade, sortBy]);

  // ─── SUMMARY KPI METRICS ──────────────────────────────────────────────────
  const stats = useMemo(() => {
    const total = students.length;
    const totalXp = students.reduce((acc, curr) => acc + (curr.xp || 0), 0);
    const avgXp = total > 0 ? Math.round(totalXp / total) : 0;
    const activeStreaks = students.filter((s) => (s.streak || 0) >= 3).length;
    const topPerformer = [...students].sort((a, b) => (b.xp || 0) - (a.xp || 0))[0];

    return {
      total,
      avgXp,
      activeStreaks,
      topPerformer,
    };
  }, [students]);

  const handleOpenDiagnostic = (student: Student) => {
    setSelectedStudent(student);
    setDiagnosticModalOpen(true);
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-800">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
              Phase 5 Active
            </span>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 border border-purple-500/30">
              Class-Wide Telemetry
            </span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight mt-1">
            Student Roster &amp; Diagnostic Telemetry
          </h1>
          <p className="text-xs text-slate-400">
            Monitor Grade 5 student progress, identify weak math skills, and track daily streaks across Sri Lankan districts
          </p>
        </div>

        <div className="flex items-center gap-3">
          {/* Developer Telemetry Seeder Button */}
          <SeederButton onSeeded={loadStudents} />
        </div>
      </div>

      {/* 4 Summary Stat Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-5 rounded-3xl bg-[#120E33] border border-slate-800 shadow-xl relative overflow-hidden group">
          <div className="flex items-center justify-between text-slate-400 mb-2">
            <span className="text-xs font-semibold">Total Students</span>
            <div className="p-2 rounded-xl bg-purple-500/10 text-purple-400 border border-purple-500/20">
              <Users className="w-4 h-4" />
            </div>
          </div>
          <div className="text-3xl font-black text-white">{stats.total}</div>
          <div className="text-[11px] text-slate-400 mt-1 flex items-center gap-1">
            <span className="text-emerald-400 font-bold">100%</span> Grade 5 Mathematics
          </div>
        </div>

        <div className="p-5 rounded-3xl bg-[#120E33] border border-slate-800 shadow-xl relative overflow-hidden group">
          <div className="flex items-center justify-between text-slate-400 mb-2">
            <span className="text-xs font-semibold">Average Class XP</span>
            <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20">
              <Trophy className="w-4 h-4" />
            </div>
          </div>
          <div className="text-3xl font-black text-amber-300">
            {stats.avgXp.toLocaleString()} <span className="text-xs font-bold text-slate-400">XP</span>
          </div>
          <div className="text-[11px] text-slate-400 mt-1">
            Per active learner
          </div>
        </div>

        <div className="p-5 rounded-3xl bg-[#120E33] border border-slate-800 shadow-xl relative overflow-hidden group">
          <div className="flex items-center justify-between text-slate-400 mb-2">
            <span className="text-xs font-semibold">Active Streaks (&ge;3d)</span>
            <div className="p-2 rounded-xl bg-orange-500/10 text-orange-400 border border-orange-500/20">
              <Flame className="w-4 h-4" />
            </div>
          </div>
          <div className="text-3xl font-black text-orange-400">
            {stats.activeStreaks}
          </div>
          <div className="text-[11px] text-orange-300/80 mt-1">
            Daily engagement consistency
          </div>
        </div>

        <div className="p-5 rounded-3xl bg-[#120E33] border border-slate-800 shadow-xl relative overflow-hidden group">
          <div className="flex items-center justify-between text-slate-400 mb-2">
            <span className="text-xs font-semibold">Top Mastery Performer</span>
            <div className="p-2 rounded-xl bg-pink-500/10 text-pink-400 border border-pink-500/20">
              <Sparkles className="w-4 h-4" />
            </div>
          </div>
          <div className="text-base font-black text-white truncate">
            {stats.topPerformer ? stats.topPerformer.name : "N/A"}
          </div>
          <div className="text-[11px] text-pink-300 mt-1">
            {stats.topPerformer ? `${stats.topPerformer.xp.toLocaleString()} XP • ${stats.topPerformer.district}` : "No student data"}
          </div>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="p-4 rounded-2xl bg-[#120E33] border border-slate-800 flex flex-col md:flex-row items-center justify-between gap-4">
        {/* Search Input */}
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search student by name, school, district..."
            className="w-full pl-10 pr-4 py-2 rounded-xl bg-slate-900/90 border border-slate-700 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-all"
          />
        </div>

        {/* Dropdowns */}
        <div className="flex items-center gap-3 w-full md:w-auto flex-wrap sm:flex-nowrap">
          {/* District Dropdown Filter */}
          <div className="flex items-center gap-1.5 w-full sm:w-auto">
            <MapPin className="w-3.5 h-3.5 text-blue-400 shrink-0" />
            <select
              value={selectedDistrict}
              onChange={(e) => setSelectedDistrict(e.target.value)}
              className="w-full sm:w-auto px-3 py-2 rounded-xl bg-slate-900/90 border border-slate-700 text-xs text-slate-200 focus:outline-none focus:border-purple-500 cursor-pointer"
            >
              {SRI_LANKAN_DISTRICTS.map((d) => (
                <option key={d} value={d} className="bg-slate-900 text-white">
                  {d}
                </option>
              ))}
            </select>
          </div>

          {/* Grade Dropdown Filter */}
          <div className="flex items-center gap-1.5 w-full sm:w-auto">
            <GraduationCap className="w-3.5 h-3.5 text-purple-400 shrink-0" />
            <select
              value={selectedGrade}
              onChange={(e) => setSelectedGrade(e.target.value)}
              className="w-full sm:w-auto px-3 py-2 rounded-xl bg-slate-900/90 border border-slate-700 text-xs text-slate-200 focus:outline-none focus:border-purple-500 cursor-pointer"
            >
              {GRADES.map((g) => (
                <option key={g} value={g} className="bg-slate-900 text-white">
                  {g}
                </option>
              ))}
            </select>
          </div>

          {/* Sort By Dropdown */}
          <div className="flex items-center gap-1.5 w-full sm:w-auto">
            <ArrowUpDown className="w-3.5 h-3.5 text-slate-400 shrink-0" />
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as any)}
              className="w-full sm:w-auto px-3 py-2 rounded-xl bg-slate-900/90 border border-slate-700 text-xs text-slate-200 focus:outline-none focus:border-purple-500 cursor-pointer"
            >
              <option value="xp" className="bg-slate-900 text-white">Sort by XP (Highest)</option>
              <option value="streak" className="bg-slate-900 text-white">Sort by Streak (Longest)</option>
              <option value="name" className="bg-slate-900 text-white">Sort by Name (A-Z)</option>
            </select>
          </div>
        </div>
      </div>

      {/* Student Roster Table */}
      <div className="rounded-3xl border border-slate-800 bg-[#120E33] shadow-2xl overflow-hidden">
        {loading ? (
          <div className="py-24 flex flex-col items-center justify-center gap-3">
            <Loader2 className="w-8 h-8 animate-spin text-purple-400" />
            <p className="text-xs text-slate-400">Loading student roster...</p>
          </div>
        ) : filteredStudents.length === 0 ? (
          <div className="py-20 text-center max-w-md mx-auto space-y-4">
            <div className="w-14 h-14 rounded-2xl bg-purple-500/20 text-purple-400 flex items-center justify-center mx-auto">
              <Users className="w-7 h-7" />
            </div>
            <h3 className="text-base font-bold text-white">No Students Found</h3>
            <p className="text-xs text-slate-400 leading-relaxed">
              {students.length === 0
                ? "No student records found in Firestore. Click the 'Seed Demo Telemetry' button in the top right to populate 5 mock Grade 5 students with itemized telemetry records."
                : "No students matched your search and filter criteria. Try resetting the district or search query."}
            </p>
            {students.length === 0 && (
              <div className="pt-2 flex justify-center">
                <SeederButton onSeeded={loadStudents} />
              </div>
            )}
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-[#0b0821] text-slate-400 border-b border-slate-800 text-[11px] font-bold uppercase tracking-wider">
                <tr>
                  <th className="py-4 px-6">Student Profile</th>
                  <th className="py-4 px-6">Grade &amp; District</th>
                  <th className="py-4 px-6">XP &amp; Progress</th>
                  <th className="py-4 px-6">Daily Streak</th>
                  <th className="py-4 px-6">Last Active</th>
                  <th className="py-4 px-6 text-right">Diagnostic Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/60 bg-[#120E33]/60">
                {filteredStudents.map((student, idx) => (
                  <tr
                    key={student.id || idx}
                    onClick={() => handleOpenDiagnostic(student)}
                    className="hover:bg-purple-950/20 transition-all cursor-pointer group"
                  >
                    {/* Student Profile Column */}
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3.5">
                        {student.avatarUrl ? (
                          // eslint-disable-next-line @next/next/no-img-element
                          <img
                            src={student.avatarUrl}
                            alt={student.name}
                            className="w-10 h-10 rounded-xl bg-purple-950/60 border border-purple-500/30 p-0.5 object-cover shrink-0"
                          />
                        ) : (
                          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-purple-600 to-pink-500 text-white font-bold text-sm flex items-center justify-center shadow shrink-0">
                            {student.name.charAt(0)}
                          </div>
                        )}
                        <div>
                          <div className="font-bold text-white text-sm group-hover:text-pink-300 transition-colors">
                            {student.name}
                          </div>
                          <div className="text-[11px] text-slate-400 flex items-center gap-1.5 mt-0.5">
                            {student.school ? (
                              <span className="flex items-center gap-1">
                                <School className="w-3 h-3 text-slate-500" />
                                {student.school}
                              </span>
                            ) : (
                              <span>{student.email || "Registered Student"}</span>
                            )}
                          </div>
                        </div>
                      </div>
                    </td>

                    {/* Grade & District Column */}
                    <td className="py-4 px-6">
                      <div className="flex flex-col gap-1.5">
                        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md bg-purple-500/10 text-purple-300 border border-purple-500/30 font-bold text-[11px] w-fit">
                          Grade {student.grade}
                        </span>
                        <span className="inline-flex items-center gap-1 text-[11px] text-slate-300">
                          <MapPin className="w-3 h-3 text-blue-400" />
                          {student.district}
                        </span>
                      </div>
                    </td>

                    {/* XP & Progress Column */}
                    <td className="py-4 px-6">
                      <div className="space-y-1.5 min-w-[130px]">
                        <div className="flex items-center justify-between text-xs">
                          <span className="font-black text-amber-300 flex items-center gap-1">
                            <Trophy className="w-3.5 h-3.5 text-amber-400" />
                            {student.xp.toLocaleString()} XP
                          </span>
                        </div>
                        <div className="w-full h-1.5 rounded-full bg-slate-800 overflow-hidden">
                          <div
                            className="h-full bg-gradient-to-r from-amber-500 to-yellow-400 rounded-full"
                            style={{
                              width: `${Math.min(100, Math.max(10, (student.xp / 2500) * 100))}%`,
                            }}
                          />
                        </div>
                      </div>
                    </td>

                    {/* Streak Column */}
                    <td className="py-4 px-6">
                      <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-orange-500/10 text-orange-300 border border-orange-500/30 font-bold text-xs">
                        <Flame className="w-4 h-4 text-orange-400 animate-pulse" />
                        <span>{student.streak} Days</span>
                      </div>
                    </td>

                    {/* Last Active Column */}
                    <td className="py-4 px-6 text-slate-400 text-xs">
                      <div className="flex items-center gap-1.5">
                        <Clock className="w-3.5 h-3.5 text-slate-500" />
                        <span>
                          {student.lastActiveDate
                            ? typeof student.lastActiveDate === "string"
                              ? student.lastActiveDate
                              : student.lastActiveDate.toDate
                              ? student.lastActiveDate.toDate().toLocaleDateString()
                              : new Date(student.lastActiveDate).toLocaleDateString()
                            : "Recently Active"}
                        </span>
                      </div>
                    </td>

                    {/* Diagnostic Action Column */}
                    <td className="py-4 px-6 text-right">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleOpenDiagnostic(student);
                        }}
                        className="px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-purple-600/80 to-pink-600/80 hover:from-purple-500 hover:to-pink-500 text-white font-bold text-xs shadow-md transition-all inline-flex items-center gap-1.5 cursor-pointer"
                      >
                        <BarChart3 className="w-3.5 h-3.5" />
                        <span>View Diagnostics</span>
                        <ChevronRight className="w-3.5 h-3.5" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Student Diagnostic Modal */}
      <StudentDiagnosticModal
        isOpen={diagnosticModalOpen}
        onClose={() => {
          setDiagnosticModalOpen(false);
          setSelectedStudent(null);
        }}
        student={selectedStudent}
      />
    </div>
  );
}
