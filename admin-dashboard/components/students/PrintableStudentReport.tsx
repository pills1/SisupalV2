"use client";

import React from "react";
import { Student, QuestionAttempt, SkillMetric } from "@/types";
import {
  calculateSkillMetrics,
  getRemediationAdvice,
} from "@/lib/telemetry-analytics";
import {
  Printer,
  X,
  Trophy,
  Flame,
  CheckCircle2,
  AlertTriangle,
  Lightbulb,
  ShieldCheck,
  Target,
  School,
  MapPin,
  Calendar,
  Sparkles,
  BookOpen,
} from "lucide-react";

interface PrintableStudentReportProps {
  isOpen: boolean;
  onClose: () => void;
  student: Student | null;
  attempts: QuestionAttempt[];
}

export default function PrintableStudentReport({
  isOpen,
  onClose,
  student,
  attempts,
}: PrintableStudentReportProps) {
  if (!isOpen || !student) return null;

  const analytics = calculateSkillMetrics(attempts);
  const reportDate = new Date().toLocaleDateString("en-GB", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });

  const handlePrint = () => {
    if (typeof window !== "undefined") {
      window.print();
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-2 sm:p-4 overflow-y-auto bg-slate-950/85 backdrop-blur-md">
      {/* Action Toolbar (Hidden during print) */}
      <div className="fixed top-4 right-4 z-50 flex items-center gap-3 print:hidden">
        <button
          onClick={handlePrint}
          className="px-4 py-2.5 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold text-xs shadow-xl transition-all flex items-center gap-2 cursor-pointer"
        >
          <Printer className="w-4 h-4" />
          <span>Print / Save as PDF</span>
        </button>

        <button
          onClick={onClose}
          className="p-2.5 rounded-xl bg-slate-800/90 hover:bg-slate-700 text-slate-300 hover:text-white transition-all shadow-xl cursor-pointer"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      {/* Printable Sheet (A4 format styled) */}
      <div className="relative w-full max-w-4xl bg-white text-slate-900 rounded-2xl shadow-2xl p-8 sm:p-12 my-8 print:my-0 print:p-6 print:shadow-none print:w-full print:max-w-none print:rounded-none overflow-hidden">
        {/* Top Header & Crest */}
        <div className="border-b-2 border-slate-900 pb-6 mb-6">
          <div className="flex items-start justify-between gap-4">
            <div>
              <div className="flex items-center gap-2 mb-1">
                <span className="px-2.5 py-0.5 rounded bg-purple-900 text-white text-[11px] font-black tracking-wider uppercase">
                  SisuPal Educational Platform
                </span>
                <span className="text-[11px] font-semibold text-slate-600">
                  Primary Mathematics Division
                </span>
              </div>
              <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
                ශිෂ්‍ය නිපුණතා හා ඇගයීම් වාර්තාව
              </h1>
              <p className="text-xs sm:text-sm font-semibold text-purple-900">
                Grade 5 Mathematics Diagnostic Mastery &amp; Progress Report
              </p>
            </div>

            <div className="text-right shrink-0">
              <div className="w-12 h-12 rounded-xl bg-gradient-to-tr from-purple-700 to-indigo-600 text-white font-black text-xl flex items-center justify-center shadow ml-auto mb-1">
                SP
              </div>
              <div className="text-[10px] font-mono text-slate-500">
                REF: {student.id || "SP-2026-MATH"}
              </div>
              <div className="text-[10px] text-slate-500 flex items-center justify-end gap-1 mt-0.5">
                <Calendar className="w-3 h-3 text-slate-400" />
                <span>{reportDate}</span>
              </div>
            </div>
          </div>

          {/* Student Profile Card in Header */}
          <div className="mt-5 grid grid-cols-2 sm:grid-cols-4 gap-3 p-4 rounded-xl bg-slate-100 border border-slate-200 text-xs">
            <div>
              <div className="text-[10px] text-slate-500 font-semibold uppercase">
                Student Name
              </div>
              <div className="font-bold text-slate-900 text-sm mt-0.5">
                {student.name}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-slate-500 font-semibold uppercase">
                Grade &amp; Subject
              </div>
              <div className="font-bold text-purple-900 mt-0.5">
                Grade {student.grade || 5} • ගණිතය (Maths)
              </div>
            </div>

            <div>
              <div className="text-[10px] text-slate-500 font-semibold uppercase">
                District / School
              </div>
              <div className="font-semibold text-slate-800 mt-0.5 truncate">
                {student.district} {student.school ? `• ${student.school}` : ""}
              </div>
            </div>

            <div>
              <div className="text-[10px] text-slate-500 font-semibold uppercase">
                Total XP / Streak
              </div>
              <div className="font-bold text-amber-700 mt-0.5">
                ⚡ {(student.xp || 0).toLocaleString()} XP • 🔥 {student.streak || 0} Days
              </div>
            </div>
          </div>
        </div>

        {/* 4 Performance KPI Metric Boxes */}
        <div className="grid grid-cols-4 gap-3 mb-6">
          <div className="p-3.5 rounded-xl bg-purple-50 border border-purple-200 text-center">
            <div className="text-[10px] font-bold text-purple-800 uppercase tracking-wide">
              Overall Accuracy
            </div>
            <div className="text-2xl font-black text-purple-950 mt-0.5">
              {analytics.overallAccuracy}%
            </div>
            <div className="text-[9px] text-purple-700 font-medium mt-0.5">
              {analytics.totalAttempts} Solved Questions
            </div>
          </div>

          <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-center">
            <div className="text-[10px] font-bold text-emerald-800 uppercase tracking-wide">
              Demonstrated Strengths
            </div>
            <div className="text-2xl font-black text-emerald-900 mt-0.5">
              {analytics.strengths.length}
            </div>
            <div className="text-[9px] text-emerald-700 font-medium mt-0.5">
              &ge; 80% Mastery Skills
            </div>
          </div>

          <div className="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-center">
            <div className="text-[10px] font-bold text-rose-800 uppercase tracking-wide">
              Focus Areas
            </div>
            <div className="text-2xl font-black text-rose-900 mt-0.5">
              {analytics.focusAreas.length}
            </div>
            <div className="text-[9px] text-rose-700 font-medium mt-0.5">
              Needs Teacher Attention
            </div>
          </div>

          <div className="p-3.5 rounded-xl bg-amber-50 border border-amber-200 text-center">
            <div className="text-[10px] font-bold text-amber-800 uppercase tracking-wide">
              Scaffolding Hints Used
            </div>
            <div className="text-2xl font-black text-amber-900 mt-0.5">
              {analytics.totalHintsUsed}
            </div>
            <div className="text-[9px] text-amber-700 font-medium mt-0.5">
              Avg Speed: {analytics.avgTimeTaken}s / Q
            </div>
          </div>
        </div>

        {/* Diagnostic Sections: Strengths vs Focus Areas */}
        <div className="space-y-5 mb-6">
          {/* 🟢 STRENGTHS & MASTERY */}
          <div className="p-4 rounded-xl bg-emerald-50/60 border border-emerald-300">
            <div className="flex items-center gap-2 mb-3 pb-2 border-b border-emerald-200">
              <ShieldCheck className="w-5 h-5 text-emerald-700" />
              <h3 className="font-bold text-emerald-950 text-sm">
                🟢 විශිෂ්ට නිපුණතා (Demonstrated Strengths &amp; Mastery &ge; 80%)
              </h3>
            </div>

            {analytics.strengths.length === 0 ? (
              <p className="text-xs text-slate-500 italic">
                No skills reached 80% threshold yet. Continue regular practice.
              </p>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 text-xs">
                {analytics.strengths.map((metric) => (
                  <div
                    key={metric.skillTag}
                    className="p-2.5 rounded-lg bg-white border border-emerald-200 flex items-center justify-between"
                  >
                    <div>
                      <div className="font-bold text-slate-900">
                        {metric.skillNameSi}
                      </div>
                      <div className="text-[10px] text-slate-500">
                        {metric.skillNameEn} • {metric.correctAttempts}/{metric.totalAttempts} Correct
                      </div>
                    </div>
                    <span className="px-2 py-1 rounded bg-emerald-100 text-emerald-900 font-black text-xs">
                      {metric.accuracyPercentage}%
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* 🔴 FOCUS AREAS & TEACHER GUIDANCE */}
          <div className="p-4 rounded-xl bg-rose-50/60 border border-rose-300">
            <div className="flex items-center gap-2 mb-3 pb-2 border-b border-rose-200">
              <AlertTriangle className="w-5 h-5 text-rose-700" />
              <h3 className="font-bold text-rose-950 text-sm">
                🔴 අවධානය යොමු කළ යුතු කරුණු හා ගුරු උපදෙස් (Focus Areas &amp; Action Plan)
              </h3>
            </div>

            {analytics.focusAreas.length === 0 ? (
              <p className="text-xs text-emerald-800 font-semibold">
                🎉 No weak skill areas identified. Student is performing at full mastery level across all tested concepts.
              </p>
            ) : (
              <div className="space-y-2.5 text-xs">
                {analytics.focusAreas.map((metric) => {
                  const advice = getRemediationAdvice(metric);
                  return (
                    <div
                      key={metric.skillTag}
                      className="p-3 rounded-lg bg-white border border-rose-200 space-y-1.5"
                    >
                      <div className="flex items-center justify-between">
                        <div className="font-bold text-slate-900">
                          {metric.skillNameSi} ({metric.skillNameEn})
                        </div>
                        <span className="px-2 py-0.5 rounded bg-rose-100 text-rose-900 font-black text-xs">
                          {metric.accuracyPercentage}% Accuracy
                        </span>
                      </div>

                      <div className="text-[11px] text-slate-700 flex items-start gap-1.5 bg-rose-50/80 p-2 rounded">
                        <Lightbulb className="w-3.5 h-3.5 text-amber-600 shrink-0 mt-0.5" />
                        <div>
                          <span className="font-bold text-rose-950">ගුරු උපදෙස: </span>
                          <span>{advice.actionSi}</span>
                          <div className="text-[10px] text-purple-900 font-semibold mt-0.5">
                            📚 නිර්දේශිත පාඩම: {advice.lessonRef}
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        {/* Footer & Teacher Signature Area */}
        <div className="pt-6 border-t-2 border-slate-900 flex flex-col sm:flex-row items-center justify-between gap-6 text-xs text-slate-700">
          <div className="space-y-1 text-center sm:text-left">
            <div className="font-bold text-slate-900">
              SisuPal Intelligent Telemetry Evaluation
            </div>
            <div className="text-[10px] text-slate-500">
              This report is electronically compiled from real-time question attempts, hint tracking, and speed telemetry.
            </div>
          </div>

          <div className="flex items-center gap-8 text-center">
            <div className="border-t border-slate-400 pt-1 w-36">
              <div className="font-bold text-slate-900 text-[11px]">ගුරු භවතාගේ අත්සන</div>
              <div className="text-[9px] text-slate-500">(Teacher Signature)</div>
            </div>

            <div className="border-t border-slate-400 pt-1 w-36">
              <div className="font-bold text-slate-900 text-[11px]">දෙමව්පිය අත්සන</div>
              <div className="text-[9px] text-slate-500">(Parent Acknowledgment)</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
