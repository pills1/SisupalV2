"use client";

import React, { useState, useEffect } from "react";
import { LessonModule, ExerciseStep } from "@/types";
import ExerciseSequenceBuilder from "./ExerciseSequenceBuilder";
import LiveJsonPreviewer from "@/components/games/LiveJsonPreviewer";
import { X, Loader2, Sparkles, BookOpen, Layers } from "lucide-react";

interface LessonEditorModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (lesson: Omit<LessonModule, "id">) => Promise<void>;
  initialData?: LessonModule | null;
  loading?: boolean;
}

const DEFAULT_EXERCISES: ExerciseStep[] = [
  {
    id: "ex_1",
    interactionType: "multipleChoice",
    questionText: "5,420 සංඛ්‍යාවේ '4' ඉලක්කමේ ස්ථානීය අගය කුමක්ද?",
    options: ["4", "40", "400", "4,000"],
    correctAnswer: "400",
    hintLevel1: "'4' ඉලක්කම පිහිටා ඇත්තේ සියයේ (Hundreds) තීරුවේය.",
    hintLevel2: "සියයේ තීරුවේ ඇති බැවින්: 4 × 100 ගණනය කරන්න.",
    workedSolution: "නිවැරදි පිළිතුර 400 වේ (4 × 100 = 400).",
    xpReward: 10,
  },
  {
    id: "ex_2",
    interactionType: "numericInput",
    questionText: "78,510 සංඛ්‍යාවේ '7' ඉලක්කමේ ස්ථානීය අගය ලියන්න.",
    correctAnswer: "70000",
    hintLevel1: "'7' ඉලක්කම දස දහස් (Ten Thousands) තීරුවේ පිහිටා ඇත.",
    hintLevel2: "7 × 10,000 ගුණාකාරය ලියන්න.",
    workedSolution: "නිවැරදි අගය 70,000 (7 × 10,000) වේ.",
    xpReward: 15,
  },
];

export default function LessonEditorModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  loading = false,
}: LessonEditorModalProps) {
  const [title, setTitle] = useState("");
  const [conceptId, setConceptId] = useState("c1_place_value_expanded");
  const [status, setStatus] = useState<"draft" | "published">("published");
  const [exercises, setExercises] = useState<ExerciseStep[]>(DEFAULT_EXERCISES);

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setConceptId(initialData.conceptId || "c1_place_value_expanded");
      setStatus(initialData.status || "published");
      setExercises(
        initialData.exercises && initialData.exercises.length > 0
          ? initialData.exercises
          : DEFAULT_EXERCISES
      );
    } else {
      setTitle("පාඩම 1: ස්ථානීය අගය සහ විස්තාරිත ආකාරය (Place Value Mastery)");
      setConceptId("c1_place_value_expanded");
      setStatus("published");
      setExercises(DEFAULT_EXERCISES);
    }
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSave({
      title: title.trim(),
      conceptId: conceptId.trim(),
      status,
      grade: 5,
      exercises,
    });
  };

  const payloadForPreview = {
    title: title.trim(),
    conceptId: conceptId.trim(),
    status,
    grade: 5,
    exerciseCount: exercises.length,
    exercises,
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/80 backdrop-blur-md transition-opacity"
        onClick={() => !loading && onClose()}
      />

      {/* Modal Container */}
      <div className="relative w-full max-w-6xl bg-[#16123D] border border-purple-500/30 rounded-3xl shadow-2xl overflow-hidden z-10 my-6 max-h-[92vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-800 bg-[#120E33] flex-shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-purple-600/20 border border-purple-500/30 flex items-center justify-center text-xl">
              📖
            </div>
            <div>
              <h2 className="text-base font-bold text-white">
                {initialData ? "Edit Interactive Lesson Module" : "Create Interactive Lesson Module"}
              </h2>
              <p className="text-xs text-slate-400">
                Configure adaptive exercise steps and the 3-attempt scaffold feedback system
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            disabled={loading}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-colors disabled:opacity-50"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Scrollable Form Body */}
        <form onSubmit={handleSubmit} className="flex-1 flex flex-col overflow-hidden">
          <div className="flex-1 overflow-y-auto p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
            {/* Left Column: Form Controls & Exercise Steps (7 cols) */}
            <div className="lg:col-span-7 space-y-6">
              {/* Metadata Box */}
              <div className="p-5 rounded-2xl glass-card border border-slate-800 space-y-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <label className="text-xs font-bold text-white uppercase tracking-wider">
                    Lesson Module Metadata
                  </label>

                  {/* Status Switch */}
                  <div className="flex items-center gap-3 bg-[#120E33] p-1.5 rounded-xl border border-slate-800">
                    <span className="text-[11px] font-semibold text-slate-400">Status:</span>
                    <button
                      type="button"
                      onClick={() => setStatus(status === "published" ? "draft" : "published")}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        status === "published" ? "bg-emerald-500" : "bg-slate-700"
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          status === "published" ? "translate-x-6" : "translate-x-1"
                        }`}
                      />
                    </button>
                    <span
                      className={`text-[11px] font-bold uppercase tracking-tight ${
                        status === "published" ? "text-emerald-400" : "text-slate-400"
                      }`}
                    >
                      {status}
                    </span>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                    Lesson Title (පාඩම් මාතෘකාව)
                  </label>
                  <input
                    type="text"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    required
                    placeholder="e.g. පාඩම 1: ස්ථානීය අගය සහ විස්තාරිත ආකාරය"
                    className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                    Concept ID Identifier
                  </label>
                  <input
                    type="text"
                    value={conceptId}
                    onChange={(e) => setConceptId(e.target.value)}
                    required
                    placeholder="e.g. c1_place_value_expanded"
                    className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
                  />
                </div>
              </div>

              {/* Exercise Sequence Builder */}
              <div className="p-5 rounded-2xl glass-card border border-purple-500/20">
                <ExerciseSequenceBuilder
                  exercises={exercises}
                  onChange={setExercises}
                />
              </div>
            </div>

            {/* Right Column: Live JSON Payload Preview (5 cols) */}
            <div className="lg:col-span-5 flex flex-col space-y-4">
              <div className="sticky top-0">
                <LiveJsonPreviewer
                  data={payloadForPreview}
                  title="Firestore Live Payload (math_lessons)"
                />
              </div>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="flex items-center justify-between px-6 py-4 border-t border-slate-800 bg-[#120E33] flex-shrink-0">
            <div className="flex items-center gap-2 text-xs text-slate-400">
              <span className="w-2 h-2 rounded-full bg-purple-500 animate-pulse" />
              <span>Saves directly to Firestore collection: <code className="text-purple-300 font-mono">math_lessons</code></span>
            </div>

            <div className="flex items-center gap-3">
              <button
                type="button"
                onClick={onClose}
                disabled={loading}
                className="px-4 py-2 rounded-xl text-xs font-semibold text-slate-300 hover:text-white hover:bg-slate-800 transition-colors disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={loading}
                className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-purple-600/30 transition-all flex items-center gap-2 disabled:opacity-50 cursor-pointer"
              >
                {loading ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    <span>Saving Lesson...</span>
                  </>
                ) : (
                  <>
                    <Sparkles className="w-4 h-4" />
                    <span>{initialData ? "Update Lesson Module" : "Publish Lesson Module"}</span>
                  </>
                )}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}
