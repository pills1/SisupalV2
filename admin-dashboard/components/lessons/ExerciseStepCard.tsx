"use client";

import React from "react";
import { ExerciseStep, ExerciseInteractionType } from "@/types";
import {
  ChevronUp,
  ChevronDown,
  Trash2,
  Copy,
  Lightbulb,
  BookOpen,
  CheckCircle2,
  Layers,
  Sparkles,
  HelpCircle,
  Award,
} from "lucide-react";

interface ExerciseStepCardProps {
  step: ExerciseStep;
  index: number;
  totalSteps: number;
  onUpdate: (updated: ExerciseStep) => void;
  onMoveUp: () => void;
  onMoveDown: () => void;
  onDuplicate: () => void;
  onDelete: () => void;
}

export default function ExerciseStepCard({
  step,
  index,
  totalSteps,
  onUpdate,
  onMoveUp,
  onMoveDown,
  onDuplicate,
  onDelete,
}: ExerciseStepCardProps) {
  const handleTypeChange = (newType: ExerciseInteractionType) => {
    onUpdate({
      ...step,
      interactionType: newType,
      options:
        newType === "multipleChoice" || newType === "placeValuePicker"
          ? step.options || ["10", "100", "1,000", "10,000"]
          : undefined,
    });
  };

  const handleOptionTextChange = (optIdx: number, val: string) => {
    const nextOpts = [...(step.options || [])];
    nextOpts[optIdx] = val;
    onUpdate({ ...step, options: nextOpts });
  };

  return (
    <div className="rounded-2xl p-5 border border-purple-500/30 bg-[#15103A] shadow-xl space-y-5 relative">
      {/* Header Bar */}
      <div className="flex flex-wrap items-center justify-between gap-3 pb-3 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl bg-purple-600/30 border border-purple-400/40 flex items-center justify-center font-mono text-xs font-bold text-white shadow-inner">
            #{index + 1}
          </div>

          {/* Interaction Type Selector */}
          <div className="relative">
            <select
              value={step.interactionType}
              onChange={(e) =>
                handleTypeChange(e.target.value as ExerciseInteractionType)
              }
              className="text-xs font-bold py-1.5 px-3 rounded-xl border border-purple-500/40 bg-[#120E33] text-purple-200 focus:outline-none cursor-pointer"
            >
              <option value="multipleChoice">🔘 Multiple Choice (4 Options)</option>
              <option value="numericInput">🔢 Direct Numeric Input</option>
              <option value="placeValuePicker">🎯 Place Value Tag Picker</option>
            </select>
          </div>

          <span className="text-[10px] text-emerald-400 font-bold px-2 py-0.5 rounded bg-emerald-950/40 border border-emerald-500/30 hidden sm:inline-block">
            + {step.xpReward || 10} XP
          </span>
        </div>

        {/* Action Controls */}
        <div className="flex items-center gap-1">
          <button
            type="button"
            onClick={onMoveUp}
            disabled={index === 0}
            title="Move Step Up"
            className="p-1.5 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white disabled:opacity-30 transition-colors"
          >
            <ChevronUp className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={onMoveDown}
            disabled={index === totalSteps - 1}
            title="Move Step Down"
            className="p-1.5 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white disabled:opacity-30 transition-colors"
          >
            <ChevronDown className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={onDuplicate}
            title="Duplicate Step"
            className="p-1.5 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white transition-colors"
          >
            <Copy className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={onDelete}
            title="Delete Step"
            className="p-1.5 rounded-lg bg-rose-500/20 hover:bg-rose-500/40 text-rose-300 hover:text-rose-100 transition-colors ml-1"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Main Question & Answer */}
      <div className="space-y-4">
        <div>
          <label className="block text-[11px] font-bold text-white uppercase tracking-wider mb-1.5 flex items-center justify-between">
            <span>Main Exercise Question Prompt</span>
            <span className="text-[10px] text-purple-300 font-mono">Step #{index + 1}</span>
          </label>
          <textarea
            value={step.questionText}
            onChange={(e) => onUpdate({ ...step, questionText: e.target.value })}
            rows={2}
            placeholder="e.g. 45,621 සංඛ්‍යාවේ '5' ඉලක්කමේ ස්ථානීය අගය කුමක්ද?"
            className="w-full p-3 rounded-xl glass-input text-xs leading-relaxed focus:outline-none"
          />
        </div>

        {/* Options for Multiple Choice or Place Value Picker */}
        {(step.interactionType === "multipleChoice" ||
          step.interactionType === "placeValuePicker") && (
          <div className="space-y-2 p-3.5 rounded-xl bg-black/20 border border-white/10">
            <label className="block text-[10px] font-bold text-purple-200 uppercase tracking-wider">
              Answer Choices (Select the Radio for Correct Answer)
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
              {(step.options || ["10", "100", "1,000", "10,000"]).map(
                (opt, optIdx) => (
                  <div
                    key={optIdx}
                    className={`flex items-center gap-2 p-2 rounded-xl border transition-all ${
                      String(step.correctAnswer) === String(opt)
                        ? "bg-emerald-500/20 border-emerald-500/50 shadow-sm"
                        : "bg-[#120E33] border-slate-800"
                    }`}
                  >
                    <input
                      type="radio"
                      name={`correct-choice-${step.id}`}
                      checked={String(step.correctAnswer) === String(opt)}
                      onChange={() => onUpdate({ ...step, correctAnswer: opt })}
                      className="accent-emerald-400"
                    />
                    <input
                      type="text"
                      value={opt}
                      onChange={(e) => handleOptionTextChange(optIdx, e.target.value)}
                      placeholder={`Option ${optIdx + 1}`}
                      className="flex-1 bg-transparent text-xs text-white focus:outline-none"
                    />
                  </div>
                )
              )}
            </div>
          </div>
        )}

        {/* Direct Numeric Input Answer */}
        {step.interactionType === "numericInput" && (
          <div className="p-3.5 rounded-xl bg-emerald-950/20 border border-emerald-500/30 space-y-1">
            <label className="block text-[10px] font-bold text-emerald-300 uppercase tracking-wider">
              Exact Correct Numeric Value
            </label>
            <input
              type="text"
              value={step.correctAnswer}
              onChange={(e) => onUpdate({ ...step, correctAnswer: e.target.value })}
              placeholder="e.g. 5000"
              className="w-full p-2 rounded-lg glass-input text-xs font-mono font-bold text-emerald-300 focus:outline-none"
            />
          </div>
        )}
      </div>

      {/* ─── 3-ATTEMPT HINT SYSTEM SECTION ─────────────────────────────────── */}
      <div className="space-y-3 pt-2">
        <div className="flex items-center gap-2 pb-1 border-b border-white/10">
          <Sparkles className="w-4 h-4 text-amber-400" />
          <h4 className="text-xs font-bold text-white uppercase tracking-wider">
            3-Attempt Adaptive Scaffold System
          </h4>
          <span className="text-[10px] text-slate-400">
            (Progressive assistance triggered when student fails attempts)
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          {/* Attempt 1 Fail: Light Hint */}
          <div className="p-3.5 rounded-2xl bg-amber-950/20 border border-amber-500/30 space-y-1.5 flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-1.5 text-amber-300 font-bold text-[10px] uppercase tracking-tight">
                <Lightbulb className="w-3.5 h-3.5" />
                <span>Attempt 1: Light Hint</span>
              </div>
              <p className="text-[9px] text-amber-200/70">
                Gentle nudge or visual focus reminder
              </p>
            </div>
            <textarea
              value={step.hintLevel1}
              onChange={(e) => onUpdate({ ...step, hintLevel1: e.target.value })}
              rows={3}
              placeholder="e.g. '5' ඉලක්කම පිහිටා ඇති ස්ථානීය තීරුව කුමක්දැයි බලන්න."
              className="w-full p-2.5 rounded-xl glass-input text-[11px] leading-relaxed text-amber-100 placeholder-amber-400/40 focus:outline-none"
            />
          </div>

          {/* Attempt 2 Fail: Guided Reasoning */}
          <div className="p-3.5 rounded-2xl bg-purple-950/20 border border-purple-500/30 space-y-1.5 flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-1.5 text-purple-300 font-bold text-[10px] uppercase tracking-tight">
                <Layers className="w-3.5 h-3.5" />
                <span>Attempt 2: Guided Reasoning</span>
              </div>
              <p className="text-[9px] text-purple-200/70">
                Step-by-step logic breakdown
              </p>
            </div>
            <textarea
              value={step.hintLevel2}
              onChange={(e) => onUpdate({ ...step, hintLevel2: e.target.value })}
              rows={3}
              placeholder="e.g. දකුණේ සිට: 1-එකක, 2-දහය, 6-සිය, 5-දහස්. එබැවින් 5 × 1,000 වේ."
              className="w-full p-2.5 rounded-xl glass-input text-[11px] leading-relaxed text-purple-100 placeholder-purple-400/40 focus:outline-none"
            />
          </div>

          {/* Attempt 3 Fail: Final Worked Solution */}
          <div className="p-3.5 rounded-2xl bg-emerald-950/20 border border-emerald-500/30 space-y-1.5 flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-1.5 text-emerald-300 font-bold text-[10px] uppercase tracking-tight">
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>Attempt 3: Worked Solution</span>
              </div>
              <p className="text-[9px] text-emerald-200/70">
                Full solution & concept summary
              </p>
            </div>
            <textarea
              value={step.workedSolution}
              onChange={(e) => onUpdate({ ...step, workedSolution: e.target.value })}
              rows={3}
              placeholder="e.g. නිවැරදි පිළිතුර 5,000 වේ (5 × 1,000 = 5,000)."
              className="w-full p-2.5 rounded-xl glass-input text-[11px] leading-relaxed text-emerald-100 placeholder-emerald-400/40 focus:outline-none"
            />
          </div>
        </div>
      </div>
    </div>
  );
}
