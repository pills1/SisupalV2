"use client";

import React, { useState, useEffect } from "react";
import { ExerciseStep, ExerciseInteractionType } from "@/types";
import { X, Loader2, Sparkles, Lightbulb, Layers, CheckCircle2, Award } from "lucide-react";

interface QuestionModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (question: ExerciseStep) => void;
  initialData?: ExerciseStep | null;
  conceptTitle?: string;
}

export default function QuestionModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  conceptTitle = "Concept",
}: QuestionModalProps) {
  const [questionText, setQuestionText] = useState("");
  const [interactionType, setInteractionType] = useState<ExerciseInteractionType>("multipleChoice");
  const [options, setOptions] = useState<string[]>(["Option A", "Option B", "Option C", "Option D"]);
  const [correctAnswer, setCorrectAnswer] = useState<string>("Option A");
  const [hintLevel1, setHintLevel1] = useState("");
  const [hintLevel2, setHintLevel2] = useState("");
  const [workedSolution, setWorkedSolution] = useState("");
  const [skillTag, setSkillTag] = useState("concept_practice");
  const [difficulty, setDifficulty] = useState<number>(1);
  const [xpReward, setXpReward] = useState<number>(10);

  useEffect(() => {
    if (initialData) {
      setQuestionText(initialData.questionText || "");
      setInteractionType(initialData.interactionType || "multipleChoice");
      setOptions(initialData.options || ["Option A", "Option B", "Option C", "Option D"]);
      setCorrectAnswer(String(initialData.correctAnswer || ""));
      setHintLevel1(initialData.hintLevel1 || "");
      setHintLevel2(initialData.hintLevel2 || "");
      setWorkedSolution(initialData.workedSolution || "");
      setSkillTag(initialData.skillTag || "concept_practice");
      setDifficulty(initialData.difficulty ?? 1);
      setXpReward(initialData.xpReward ?? 10);
    } else {
      setQuestionText("");
      setInteractionType("multipleChoice");
      setOptions(["Option A", "Option B", "Option C", "Option D"]);
      setCorrectAnswer("Option A");
      setHintLevel1("");
      setHintLevel2("");
      setWorkedSolution("");
      setSkillTag("concept_practice");
      setDifficulty(1);
      setXpReward(10);
    }
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      id: initialData?.id || `q_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      conceptId: initialData?.conceptId,
      questionText: questionText.trim(),
      interactionType,
      options:
        interactionType === "multipleChoice" || interactionType === "placeValuePicker"
          ? options
          : undefined,
      correctAnswer: correctAnswer.trim(),
      hintLevel1: hintLevel1.trim(),
      hintLevel2: hintLevel2.trim(),
      workedSolution: workedSolution.trim(),
      skillTag: skillTag.trim(),
      difficulty: Number(difficulty) || 1,
      xpReward: Number(xpReward) || 10,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      <div className="fixed inset-0 bg-black/80 backdrop-blur-md" onClick={onClose} />

      <div className="relative w-full max-w-3xl bg-[#16123D] border border-purple-500/30 rounded-3xl shadow-2xl overflow-hidden z-10 my-6 max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-800 bg-[#120E33]">
          <div>
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 border border-purple-500/30">
                {conceptTitle}
              </span>
            </div>
            <h2 className="text-base font-bold text-white mt-1">
              {initialData ? "Edit Question (3-Attempt Scaffold)" : "Add Concept Question"}
            </h2>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Scrollable Form Body */}
        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-5">
          {/* Question Prompt */}
          <div>
            <label className="block text-xs font-bold text-white uppercase tracking-wider mb-1.5">
              Question Prompt (ප්‍රශ්න ප්‍රකාශය)
            </label>
            <textarea
              value={questionText}
              onChange={(e) => setQuestionText(e.target.value)}
              required
              rows={2}
              placeholder="e.g. 5,420 සංඛ්‍යාවේ '4' ඉලක්කමේ ස්ථානීය අගය කුමක්ද?"
              className="w-full p-3 rounded-xl glass-input text-xs focus:outline-none"
            />
          </div>

          {/* Interaction Type, Difficulty, XP */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                Interaction Type
              </label>
              <select
                value={interactionType}
                onChange={(e) => setInteractionType(e.target.value as ExerciseInteractionType)}
                className="w-full p-2.5 rounded-xl glass-input text-xs bg-[#120E33] focus:outline-none"
              >
                <option value="multipleChoice">🔘 Multiple Choice (4 Choices)</option>
                <option value="numericInput">🔢 Direct Numeric Value</option>
                <option value="placeValuePicker">🎯 Place Value Tag Picker</option>
                <option value="abacusChallenge">🧮 Abacus Bead Challenge</option>
                <option value="digitBuilder">🎴 Digit Card Builder</option>
                <option value="expandedForm">🧩 Expanded Form Builder</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                Difficulty Level
              </label>
              <select
                value={difficulty}
                onChange={(e) => setDifficulty(Number(e.target.value))}
                className="w-full p-2.5 rounded-xl glass-input text-xs bg-[#120E33] focus:outline-none"
              >
                <option value={1}>Level 1: Easy</option>
                <option value={2}>Level 2: Medium</option>
                <option value={3}>Level 3: Advanced</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                XP Reward
              </label>
              <input
                type="number"
                value={xpReward}
                onChange={(e) => setXpReward(Number(e.target.value))}
                min={5}
                max={50}
                className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
              />
            </div>
          </div>

          {/* Choices or Direct Answer */}
          {(interactionType === "multipleChoice" || interactionType === "placeValuePicker") && (
            <div className="p-4 rounded-2xl bg-black/20 border border-white/10 space-y-3">
              <label className="block text-xs font-bold text-purple-200 uppercase tracking-wider">
                Answer Choices (Select Radio for Correct Answer)
              </label>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                {options.map((opt, idx) => (
                  <div
                    key={idx}
                    className={`flex items-center gap-2 p-2.5 rounded-xl border transition-all ${
                      correctAnswer === opt
                        ? "bg-emerald-500/20 border-emerald-500/50 shadow-sm"
                        : "bg-[#120E33] border-slate-800"
                    }`}
                  >
                    <input
                      type="radio"
                      name="modal-correct-choice"
                      checked={correctAnswer === opt}
                      onChange={() => setCorrectAnswer(opt)}
                      className="accent-emerald-400 cursor-pointer"
                    />
                    <input
                      type="text"
                      value={opt}
                      onChange={(e) => {
                        const newOpts = [...options];
                        newOpts[idx] = e.target.value;
                        if (correctAnswer === opt) setCorrectAnswer(e.target.value);
                        setOptions(newOpts);
                      }}
                      className="flex-1 bg-transparent text-xs text-white focus:outline-none"
                    />
                  </div>
                ))}
              </div>
            </div>
          )}

          {interactionType === "numericInput" && (
            <div className="p-4 rounded-2xl bg-emerald-950/20 border border-emerald-500/30 space-y-1.5">
              <label className="block text-xs font-bold text-emerald-300 uppercase tracking-wider">
                Correct Numerical Answer Value
              </label>
              <input
                type="text"
                value={correctAnswer}
                onChange={(e) => setCorrectAnswer(e.target.value)}
                required
                placeholder="e.g. 5000"
                className="w-full p-2.5 rounded-xl glass-input text-xs font-mono font-bold text-emerald-300 focus:outline-none"
              />
            </div>
          )}

          {/* 3-Attempt Progressive Scaffold Hints */}
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div className="flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-amber-400" />
              <h4 className="text-xs font-bold text-white uppercase tracking-wider">
                3-Attempt Progressive Hints
              </h4>
            </div>

            <div className="space-y-3">
              {/* Hint 1 */}
              <div className="p-3.5 rounded-xl bg-amber-950/20 border border-amber-500/30 space-y-1">
                <div className="flex items-center gap-1.5 text-amber-300 font-bold text-[10px] uppercase">
                  <Lightbulb className="w-3.5 h-3.5" />
                  <span>Attempt 1: Light Hint (Visual / Focus Nudge)</span>
                </div>
                <textarea
                  value={hintLevel1}
                  onChange={(e) => setHintLevel1(e.target.value)}
                  rows={2}
                  placeholder="e.g. '4' ඉලක්කම පිහිටා ඇත්තේ සියයේ (Hundreds) තීරුවේය."
                  className="w-full p-2 rounded-lg glass-input text-xs text-amber-100 placeholder-amber-400/40 focus:outline-none"
                />
              </div>

              {/* Hint 2 */}
              <div className="p-3.5 rounded-xl bg-purple-950/20 border border-purple-500/30 space-y-1">
                <div className="flex items-center gap-1.5 text-purple-300 font-bold text-[10px] uppercase">
                  <Layers className="w-3.5 h-3.5" />
                  <span>Attempt 2: Guided Reasoning (Step Breakdown)</span>
                </div>
                <textarea
                  value={hintLevel2}
                  onChange={(e) => setHintLevel2(e.target.value)}
                  rows={2}
                  placeholder="e.g. සියයේ තීරුවේ ඇති බැවින් 4 × 100 ගණනය කරන්න."
                  className="w-full p-2 rounded-lg glass-input text-xs text-purple-100 placeholder-purple-400/40 focus:outline-none"
                />
              </div>

              {/* Attempt 3 Worked Solution */}
              <div className="p-3.5 rounded-xl bg-emerald-950/20 border border-emerald-500/30 space-y-1">
                <div className="flex items-center gap-1.5 text-emerald-300 font-bold text-[10px] uppercase">
                  <CheckCircle2 className="w-3.5 h-3.5" />
                  <span>Attempt 3: Full Worked Solution</span>
                </div>
                <textarea
                  value={workedSolution}
                  onChange={(e) => setWorkedSolution(e.target.value)}
                  rows={2}
                  placeholder="e.g. නිවැරදි පිළිතුර 400 වේ (4 × 100 = 400)."
                  className="w-full p-2 rounded-lg glass-input text-xs text-emerald-100 placeholder-emerald-400/40 focus:outline-none"
                />
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-800">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-xl text-xs font-semibold text-slate-300 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-purple-600/30 cursor-pointer"
            >
              Save Question
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
