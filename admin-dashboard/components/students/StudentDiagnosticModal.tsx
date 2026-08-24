import React, { useState, useEffect } from "react";
import { Student, QuestionAttempt, SkillMetric } from "@/types";
import { fetchSubcollection, updateDocument } from "@/lib/firestore-crud";
import {
  calculateSkillMetrics,
  getRemediationAdvice,
  exportStudentTelemetryToCsv,
} from "@/lib/telemetry-analytics";
import { useToast } from "@/components/Toast";
import PrintableStudentReport from "@/components/students/PrintableStudentReport";
import {
  X,
  Loader2,
  Trophy,
  Flame,
  Clock,
  MapPin,
  School,
  CheckCircle2,
  AlertTriangle,
  Lightbulb,
  ShieldCheck,
  Target,
  Sparkles,
  TrendingUp,
  HelpCircle,
  BarChart3,
  BookOpen,
  Printer,
  Download,
  Share2,
  Send,
} from "lucide-react";

interface StudentDiagnosticModalProps {
  isOpen: boolean;
  onClose: () => void;
  student: Student | null;
}

export default function StudentDiagnosticModal({
  isOpen,
  onClose,
  student,
}: StudentDiagnosticModalProps) {
  const { showToast } = useToast();
  const [attempts, setAttempts] = useState<QuestionAttempt[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [activeTab, setActiveTab] = useState<"diagnostics" | "attempts">("diagnostics");
  const [printModalOpen, setPrintModalOpen] = useState<boolean>(false);
  const [sharingWithParent, setSharingWithParent] = useState<boolean>(false);

  useEffect(() => {
    if (!isOpen || !student?.id) return;

    async function loadTelemetry() {
      setLoading(true);
      try {
        // 1. Check embedded questionAttempts array from student document
        if (student?.questionAttempts && student.questionAttempts.length > 0) {
          setAttempts(student.questionAttempts);
          setLoading(false);
          return;
        }

        // 2. Fallback to subcollection
        let data = await fetchSubcollection<QuestionAttempt>(
          "users",
          student!.id!,
          "question_attempts",
          "timestamp",
          "desc"
        );

        setAttempts(data);
      } catch (error) {
        console.error("Error loading student question attempts:", error);
      } finally {
        setLoading(false);
      }
    }

    loadTelemetry();
  }, [isOpen, student]);

  if (!isOpen || !student) return null;

  const analytics = calculateSkillMetrics(attempts);

  const handleShareWithParent = async () => {
    if (!student?.id) return;
    setSharingWithParent(true);
    try {
      const reportSummary = {
        title: "ශිෂ්‍ය ගණිත ඇගයීම් වාර්තාව (Maths Diagnostic Report)",
        message: `${student.name} ගේ නවතම ගණිත ඇගයීම් වාර්තාව සූදානම්. නිපුණතා මට්ටම: ${analytics.overallAccuracy}%.`,
        accuracy: analytics.overallAccuracy,
        strengthsCount: analytics.strengths.length,
        focusAreasCount: analytics.focusAreas.length,
        updatedAt: new Date().toISOString(),
      };

      await updateDocument("users", student.id, {
        latestParentReport: reportSummary,
        parentNotificationCount: 1,
      });

      showToast(
        `Diagnostic report card shared directly to Parent Dashboard for ${student.name}! 📲✨`,
        "success"
      );
    } catch (error) {
      console.error("Error sharing report with parent:", error);
      showToast("Failed to share report to Parent Dashboard.", "error");
    } finally {
      setSharingWithParent(false);
    }
  };

  return (
    <>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-6 overflow-y-auto">
        {/* Backdrop */}
        <div
          className="fixed inset-0 bg-slate-950/80 backdrop-blur-md transition-opacity"
          onClick={onClose}
        />

        {/* Modal Container */}
        <div className="relative w-full max-w-5xl max-h-[92vh] bg-[#0c0a21] border border-slate-800 rounded-3xl shadow-2xl flex flex-col overflow-hidden text-slate-200 z-10">
          {/* Modal Header */}
          <div className="p-6 pb-5 border-b border-slate-800/80 bg-gradient-to-r from-slate-900/90 via-[#130f30] to-purple-950/40 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="relative">
                {student.avatarUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={student.avatarUrl}
                    alt={student.name}
                    className="w-16 h-16 rounded-2xl bg-purple-950/50 p-1 border border-purple-500/40 shadow-lg object-cover"
                  />
                ) : (
                  <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-purple-600 to-pink-500 text-white font-black text-2xl flex items-center justify-center shadow-lg">
                    {student.name.charAt(0)}
                  </div>
                )}
                <span className="absolute -bottom-1 -right-1 px-1.5 py-0.5 rounded-full bg-emerald-500 text-[10px] font-bold text-white border-2 border-[#0c0a21]">
                  G{student.grade}
                </span>
              </div>

              <div>
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 border border-purple-500/30">
                    Grade {student.grade} Mathematics
                  </span>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-500/20 text-blue-300 border border-blue-500/30 flex items-center gap-1">
                    <MapPin className="w-2.5 h-2.5" />
                    {student.district}
                  </span>
                  {student.school && (
                    <span className="text-[10px] text-slate-400 flex items-center gap-1">
                      <School className="w-2.5 h-2.5 text-slate-500" />
                      {student.school}
                    </span>
                  )}
                </div>

                <h2 className="text-xl font-bold text-white tracking-tight mt-1">
                  {student.name}
                </h2>

                <p className="text-xs text-slate-400">
                  Diagnostic Mastery Profile & Question Attempt Telemetry
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2.5 flex-wrap sm:flex-nowrap">
              {/* XP Badge */}
              <div className="px-3 py-1.5 rounded-xl bg-amber-500/10 border border-amber-500/30 text-amber-300 flex items-center gap-1.5 shadow">
                <Trophy className="w-4 h-4 text-amber-400" />
                <span className="text-xs font-black">{student.xp.toLocaleString()} XP</span>
              </div>

              {/* Streak Badge */}
              <div className="px-3 py-1.5 rounded-xl bg-orange-500/10 border border-orange-500/30 text-orange-300 flex items-center gap-1.5 shadow">
                <Flame className="w-4 h-4 text-orange-400" />
                <span className="text-xs font-black">{student.streak} Days</span>
              </div>

              {/* Close Button */}
              <button
                onClick={onClose}
                className="p-2 rounded-xl bg-slate-800/80 hover:bg-slate-700 text-slate-400 hover:text-white transition-all cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Tab & Action Bar */}
          <div className="px-6 pt-3 border-b border-slate-800 bg-slate-900/40 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div className="flex items-center gap-2">
              <button
                onClick={() => setActiveTab("diagnostics")}
                className={`px-4 py-2.5 text-xs font-bold rounded-t-xl transition-all border-b-2 flex items-center gap-2 cursor-pointer ${
                  activeTab === "diagnostics"
                    ? "border-pink-500 text-pink-400 bg-pink-500/10"
                    : "border-transparent text-slate-400 hover:text-slate-200"
                }`}
              >
                <BarChart3 className="w-4 h-4" />
                <span>Skill Diagnostics & Heatmap</span>
              </button>
              <button
                onClick={() => setActiveTab("attempts")}
                className={`px-4 py-2.5 text-xs font-bold rounded-t-xl transition-all border-b-2 flex items-center gap-2 cursor-pointer ${
                  activeTab === "attempts"
                    ? "border-purple-500 text-purple-400 bg-purple-500/10"
                    : "border-transparent text-slate-400 hover:text-slate-200"
                }`}
              >
                <Clock className="w-4 h-4" />
                <span>Question Attempt Logs ({attempts.length})</span>
              </button>
            </div>

            {/* Action Buttons: Print PDF, Export CSV, Share with Parent */}
            <div className="flex items-center gap-2 pb-2 sm:pb-0">
              <button
                onClick={() => setPrintModalOpen(true)}
                className="px-3 py-1.5 rounded-xl bg-purple-600/20 hover:bg-purple-600/30 border border-purple-500/30 hover:border-purple-500 text-purple-300 hover:text-white text-xs font-bold shadow transition-all flex items-center gap-1.5 cursor-pointer"
                title="Print or Save Official PDF Report Card"
              >
                <Printer className="w-3.5 h-3.5" />
                <span>PDF Report Card</span>
              </button>

              <button
                onClick={() => exportStudentTelemetryToCsv(student, attempts)}
                className="px-3 py-1.5 rounded-xl bg-slate-800/80 hover:bg-slate-700 border border-slate-700 hover:border-slate-600 text-slate-300 hover:text-white text-xs font-semibold shadow transition-all flex items-center gap-1.5 cursor-pointer"
                title="Download full question telemetry as CSV file"
              >
                <Download className="w-3.5 h-3.5" />
                <span>Export CSV</span>
              </button>

              <button
                onClick={handleShareWithParent}
                disabled={sharingWithParent}
                className="px-3 py-1.5 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white text-xs font-bold shadow transition-all flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
                title="Share this diagnostic assessment directly to the Parent Dashboard"
              >
                {sharingWithParent ? (
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                ) : (
                  <Send className="w-3.5 h-3.5" />
                )}
                <span>Share with Parent</span>
              </button>
            </div>
          </div>

          {/* Modal Body */}
          <div className="p-6 overflow-y-auto space-y-6 flex-1 custom-scrollbar">
            {loading ? (
              <div className="py-20 flex flex-col items-center justify-center gap-3">
                <Loader2 className="w-8 h-8 animate-spin text-purple-400" />
                <p className="text-xs text-slate-400">Loading student telemetry data...</p>
              </div>
            ) : attempts.length === 0 ? (
              <div className="py-16 text-center max-w-md mx-auto space-y-3">
                <div className="w-12 h-12 rounded-2xl bg-purple-500/20 text-purple-400 flex items-center justify-center mx-auto">
                  <HelpCircle className="w-6 h-6" />
                </div>
                <h4 className="text-base font-bold text-white">No Telemetry Recorded Yet</h4>
                <p className="text-xs text-slate-400 leading-relaxed">
                  This student has not yet attempted any interactive lesson exercises. Once they play through the Quest for the Golden Mango or Number Train, their question attempts will populate automatically.
                </p>
              </div>
            ) : (
              <>
                {/* 4 Top KPI Cards */}
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  <div className="p-4 rounded-2xl bg-gradient-to-br from-slate-900/90 to-purple-950/30 border border-slate-800">
                    <div className="flex items-center justify-between text-slate-400 mb-1">
                      <span className="text-[11px] font-medium">Overall Accuracy</span>
                      <Target className="w-4 h-4 text-purple-400" />
                    </div>
                    <div className="text-2xl font-black text-white">
                      {analytics.overallAccuracy}%
                    </div>
                    <div className="text-[10px] text-slate-400 mt-1">
                      Across {analytics.totalAttempts} total attempts
                    </div>
                  </div>

                  <div className="p-4 rounded-2xl bg-gradient-to-br from-slate-900/90 to-emerald-950/30 border border-slate-800">
                    <div className="flex items-center justify-between text-slate-400 mb-1">
                      <span className="text-[11px] font-medium">Strengths Identified</span>
                      <ShieldCheck className="w-4 h-4 text-emerald-400" />
                    </div>
                    <div className="text-2xl font-black text-emerald-400">
                      {analytics.strengths.length}
                    </div>
                    <div className="text-[10px] text-emerald-400/80 mt-1">
                      Skills with &ge; 80% accuracy
                    </div>
                  </div>

                  <div className="p-4 rounded-2xl bg-gradient-to-br from-slate-900/90 to-rose-950/30 border border-slate-800">
                    <div className="flex items-center justify-between text-slate-400 mb-1">
                      <span className="text-[11px] font-medium">Focus Areas</span>
                      <AlertTriangle className="w-4 h-4 text-rose-400" />
                    </div>
                    <div className="text-2xl font-black text-rose-400">
                      {analytics.focusAreas.length}
                    </div>
                    <div className="text-[10px] text-rose-400/80 mt-1">
                      Needs pedagogical remediation
                    </div>
                  </div>

                  <div className="p-4 rounded-2xl bg-gradient-to-br from-slate-900/90 to-amber-950/30 border border-slate-800">
                    <div className="flex items-center justify-between text-slate-400 mb-1">
                      <span className="text-[11px] font-medium">Hint Usage</span>
                      <Lightbulb className="w-4 h-4 text-amber-400" />
                    </div>
                    <div className="text-2xl font-black text-amber-400">
                      {analytics.totalHintsUsed}
                    </div>
                    <div className="text-[10px] text-amber-400/80 mt-1">
                      Avg speed: {analytics.avgTimeTaken}s / question
                    </div>
                  </div>
                </div>

                {activeTab === "diagnostics" ? (
                  /* ─── DIAGNOSTIC HEATMAP TAB ─── */
                  <div className="space-y-6">
                    {/* Two distinct lists: Strengths vs Focus Areas */}
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                      {/* 🟢 STRENGTHS LIST (>= 80%) */}
                      <div className="p-5 rounded-2xl bg-gradient-to-b from-emerald-950/20 to-slate-900/60 border border-emerald-500/30 space-y-4">
                        <div className="flex items-center justify-between pb-3 border-b border-emerald-500/20">
                          <div className="flex items-center gap-2.5">
                            <div className="p-2 rounded-xl bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
                              <ShieldCheck className="w-5 h-5" />
                            </div>
                            <div>
                              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                                🟢 Strengths &amp; Mastery
                                <span className="px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 text-[10px] font-bold">
                                  {analytics.strengths.length} Skills
                                </span>
                              </h3>
                              <p className="text-[11px] text-slate-400">
                                Concepts with 80% or higher accuracy
                              </p>
                            </div>
                          </div>
                        </div>

                        {analytics.strengths.length === 0 ? (
                          <div className="py-8 text-center text-xs text-slate-400">
                            No mastery-level strengths detected yet (&ge; 80%).
                          </div>
                        ) : (
                          <div className="space-y-3">
                            {analytics.strengths.map((metric) => (
                              <div
                                key={metric.skillTag}
                                className="p-3.5 rounded-xl bg-slate-900/80 border border-emerald-500/20 space-y-2"
                              >
                                <div className="flex items-start justify-between gap-2">
                                  <div>
                                    <h4 className="text-xs font-bold text-white">
                                      {metric.skillNameSi}
                                    </h4>
                                    <p className="text-[10px] text-slate-400">
                                      {metric.skillNameEn}
                                    </p>
                                  </div>
                                  <span className="px-2.5 py-1 rounded-lg bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-xs font-black">
                                    {metric.accuracyPercentage}%
                                  </span>
                                </div>

                                {/* Progress bar */}
                                <div className="w-full h-1.5 rounded-full bg-slate-800 overflow-hidden">
                                  <div
                                    className="h-full bg-gradient-to-r from-emerald-500 to-teal-400 rounded-full transition-all"
                                    style={{ width: `${metric.accuracyPercentage}%` }}
                                  />
                                </div>

                                <div className="flex items-center justify-between text-[10px] text-slate-400 pt-0.5">
                                  <span>
                                    {metric.correctAttempts} of {metric.totalAttempts} correct
                                  </span>
                                  <span>
                                    💡 {metric.hintsUsedCount} hints used • ⏱️ {metric.avgTimeSeconds}s avg
                                  </span>
                                </div>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>

                      {/* 🔴 FOCUS AREAS LIST (< 70% or high hints) */}
                      <div className="p-5 rounded-2xl bg-gradient-to-b from-rose-950/20 to-slate-900/60 border border-rose-500/30 space-y-4">
                        <div className="flex items-center justify-between pb-3 border-b border-rose-500/20">
                          <div className="flex items-center gap-2.5">
                            <div className="p-2 rounded-xl bg-rose-500/20 text-rose-400 border border-rose-500/30">
                              <AlertTriangle className="w-5 h-5" />
                            </div>
                            <div>
                              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                                🔴 Focus Areas &amp; Weak Points
                                <span className="px-2 py-0.5 rounded-full bg-rose-500/20 text-rose-300 text-[10px] font-bold">
                                  {analytics.focusAreas.length} Needs Attention
                                </span>
                              </h3>
                              <p className="text-[11px] text-slate-400">
                                Accuracy under 70% or high hint reliance
                              </p>
                            </div>
                          </div>
                        </div>

                        {analytics.focusAreas.length === 0 ? (
                          <div className="py-8 text-center text-xs text-emerald-400/90 font-medium">
                            🎉 Excellent! No weak areas or high hint usage detected for this student.
                          </div>
                        ) : (
                          <div className="space-y-3">
                            {analytics.focusAreas.map((metric) => {
                              const advice = getRemediationAdvice(metric);
                              return (
                                <div
                                  key={metric.skillTag}
                                  className="p-3.5 rounded-xl bg-slate-900/80 border border-rose-500/30 space-y-2.5"
                                >
                                  <div className="flex items-start justify-between gap-2">
                                    <div>
                                      <h4 className="text-xs font-bold text-white">
                                        {metric.skillNameSi}
                                      </h4>
                                      <p className="text-[10px] text-slate-400">
                                        {metric.skillNameEn}
                                      </p>
                                    </div>
                                    <div className="flex flex-col items-end">
                                      <span className="px-2.5 py-1 rounded-lg bg-rose-500/20 text-rose-300 border border-rose-500/30 text-xs font-black">
                                        {metric.accuracyPercentage}%
                                      </span>
                                      {metric.hintUsagePercentage >= 50 && (
                                        <span className="text-[9px] text-amber-400 mt-0.5">
                                          ⚠️ High Hint Rate ({metric.hintUsagePercentage}%)
                                        </span>
                                      )}
                                    </div>
                                  </div>

                                  {/* Progress bar */}
                                  <div className="w-full h-1.5 rounded-full bg-slate-800 overflow-hidden">
                                    <div
                                      className="h-full bg-gradient-to-r from-rose-500 to-amber-500 rounded-full transition-all"
                                      style={{ width: `${metric.accuracyPercentage}%` }}
                                    />
                                  </div>

                                  {/* Pedagogical Advice Box */}
                                  <div className="p-2.5 rounded-lg bg-rose-950/30 border border-rose-500/20 text-[11px] space-y-1">
                                    <div className="text-rose-300 font-bold flex items-center gap-1.5">
                                      <Lightbulb className="w-3 h-3 text-rose-400" />
                                      <span>ගුරු උපදෙස් (Teacher Guidance):</span>
                                    </div>
                                    <p className="text-slate-300 text-[10px] leading-relaxed">
                                      {advice.actionSi}
                                    </p>
                                    <div className="text-[10px] text-purple-300 font-semibold pt-0.5 flex items-center gap-1">
                                      <BookOpen className="w-3 h-3" />
                                      <span>නිර්දේශිත පාඩම: {advice.lessonRef}</span>
                                    </div>
                                  </div>
                                </div>
                              );
                            })}
                          </div>
                        )}
                      </div>
                    </div>

                    {/* 🟡 DEVELOPING SKILLS (70% - 79%) */}
                    {analytics.developing.length > 0 && (
                      <div className="p-4 rounded-2xl bg-slate-900/60 border border-amber-500/20 space-y-3">
                        <div className="flex items-center gap-2">
                          <TrendingUp className="w-4 h-4 text-amber-400" />
                          <h4 className="text-xs font-bold text-white">
                            🟡 Developing Skills ({analytics.developing.length})
                          </h4>
                          <span className="text-[10px] text-slate-400">
                            (70% to 79% accuracy - close to mastery)
                          </span>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {analytics.developing.map((metric) => (
                            <div
                              key={metric.skillTag}
                              className="p-3 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-between"
                            >
                              <div>
                                <div className="text-xs font-bold text-slate-200">
                                  {metric.skillNameSi}
                                </div>
                                <div className="text-[10px] text-slate-400">
                                  {metric.correctAttempts}/{metric.totalAttempts} correct • 💡 {metric.hintsUsedCount} hints
                                </div>
                              </div>
                              <span className="px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 font-bold text-xs">
                                {metric.accuracyPercentage}%
                              </span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                ) : (
                  /* ─── RAW QUESTION ATTEMPTS LOG TAB ─── */
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <h4 className="text-xs font-bold text-white">
                        Itemized Question Attempt Stream ({attempts.length} records)
                      </h4>
                      <span className="text-[10px] text-slate-400">
                        Sorted by most recent
                      </span>
                    </div>

                    <div className="rounded-2xl border border-slate-800 overflow-hidden">
                      <table className="w-full text-left text-xs">
                        <thead className="bg-slate-900/90 text-slate-400 border-b border-slate-800 text-[11px] font-bold">
                          <tr>
                            <th className="py-3 px-4">#</th>
                            <th className="py-3 px-4">Skill Category</th>
                            <th className="py-3 px-4">Result</th>
                            <th className="py-3 px-4">Hints</th>
                            <th className="py-3 px-4">Time Taken</th>
                            <th className="py-3 px-4">Concept Reference</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-800/60 bg-slate-950/40">
                          {attempts.map((att, idx) => (
                            <tr key={att.id || idx} className="hover:bg-slate-800/30">
                              <td className="py-2.5 px-4 font-mono text-slate-500 text-[11px]">
                                {idx + 1}
                              </td>
                              <td className="py-2.5 px-4 font-medium text-white">
                                {att.skillTag}
                              </td>
                              <td className="py-2.5 px-4">
                                {att.isCorrect ? (
                                  <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-[10px] font-bold">
                                    <CheckCircle2 className="w-3 h-3" /> Correct
                                  </span>
                                ) : (
                                  <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded bg-rose-500/20 text-rose-300 border border-rose-500/30 text-[10px] font-bold">
                                    <X className="w-3 h-3" /> Incorrect
                                  </span>
                                )}
                              </td>
                              <td className="py-2.5 px-4">
                                {att.hintUsed ? (
                                  <span className="inline-flex items-center gap-1 text-amber-300 text-[11px] font-semibold">
                                    <Lightbulb className="w-3 h-3 text-amber-400" />
                                    Hint Used
                                  </span>
                                ) : (
                                  <span className="text-slate-500 text-[11px]">No Hint</span>
                                )}
                              </td>
                              <td className="py-2.5 px-4 font-mono text-slate-300 text-[11px]">
                                ⏱️ {att.timeTaken || 0}s
                              </td>
                              <td className="py-2.5 px-4 text-slate-400 text-[11px]">
                                {att.conceptId || "Interactive Lesson"}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                )}
              </>
            )}
          </div>

          {/* Modal Footer */}
          <div className="p-4 px-6 border-t border-slate-800 bg-slate-950/60 flex items-center justify-between text-xs text-slate-400">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span>Class Diagnostic Engine v2.0 Active</span>
            </div>

            <button
              onClick={onClose}
              className="px-5 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-white font-bold text-xs transition-all cursor-pointer"
            >
              Close Diagnostics
            </button>
          </div>
        </div>
      </div>

      {/* Printable Report Card Modal */}
      <PrintableStudentReport
        isOpen={printModalOpen}
        onClose={() => setPrintModalOpen(false)}
        student={student}
        attempts={attempts}
      />
    </>
  );
}
