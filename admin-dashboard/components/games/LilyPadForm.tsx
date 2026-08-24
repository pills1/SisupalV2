"use client";

import React, { useState } from "react";
import { LilyPadLeapGameData } from "@/types";
import { Plus, X, Sparkles, CheckCircle2 } from "lucide-react";

interface LilyPadFormProps {
  data: Partial<LilyPadLeapGameData>;
  onChange: (updated: LilyPadLeapGameData) => void;
}

export default function LilyPadForm({ data, onChange }: LilyPadFormProps) {
  const sequence =
    data.sequence && data.sequence.length > 0
      ? data.sequence
      : [12, 24, null, 48, 60];
  const missingIndex = data.missingIndex ?? 2;
  const correctAnswer = data.correctAnswer ?? 36;
  const distractors =
    data.distractorOptions && data.distractorOptions.length > 0
      ? data.distractorOptions
      : [30, 32, 40];
  const ruleDescription =
    data.ruleDescription ?? "12 ගුණාකාර රටාව (+12 Multiples Step)";
  const timeLimit = data.timeLimitSeconds ?? 30;

  const [newDistractor, setNewDistractor] = useState("");

  const update = (overrides: Partial<LilyPadLeapGameData>) => {
    const nextSeq = overrides.sequence ?? sequence;
    const nextMissing = overrides.missingIndex ?? missingIndex;
    const cleanSeq = nextSeq.map((val, idx) => (idx === nextMissing ? null : val));

    onChange({
      sequence: cleanSeq,
      missingIndex: nextMissing,
      correctAnswer: Number(overrides.correctAnswer ?? correctAnswer) || 0,
      distractorOptions: overrides.distractorOptions ?? distractors,
      ruleDescription: overrides.ruleDescription ?? ruleDescription,
      timeLimitSeconds: Number(overrides.timeLimitSeconds ?? timeLimit) || 30,
    });
  };

  const handleSequenceValueChange = (index: number, val: string) => {
    const updated = [...sequence];
    if (index === missingIndex) {
      updated[index] = null;
    } else {
      updated[index] = val === "" ? 0 : Number(val);
    }
    update({ sequence: updated });
  };

  const handleSetMissingPad = (index: number) => {
    const updated = [...sequence];
    updated[index] = null;
    update({ sequence: updated, missingIndex: index });
  };

  const handleAddPad = () => {
    update({ sequence: [...sequence, 0] });
  };

  const handleRemovePad = (index: number) => {
    if (sequence.length <= 3) return;
    const updated = sequence.filter((_, i) => i !== index);
    const newMissing = missingIndex >= updated.length ? 0 : missingIndex;
    update({ sequence: updated, missingIndex: newMissing });
  };

  const handleAddDistractor = () => {
    if (newDistractor.trim() === "") return;
    const num = Number(newDistractor.trim());
    if (!isNaN(num) && !distractors.includes(num)) {
      update({ distractorOptions: [...distractors, num] });
      setNewDistractor("");
    }
  };

  const handleRemoveDistractor = (index: number) => {
    update({ distractorOptions: distractors.filter((_, i) => i !== index) });
  };

  return (
    <div className="space-y-6">
      {/* Rule Description & Time Limit */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="sm:col-span-2">
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Sequence Pattern Rule / Description
          </label>
          <input
            type="text"
            value={ruleDescription}
            onChange={(e) => update({ ruleDescription: e.target.value })}
            placeholder="e.g. 12 ගුණාකාර රටාව (+12)"
            className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>

        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Time Limit (Seconds)
          </label>
          <input
            type="number"
            value={timeLimit}
            onChange={(e) => update({ timeLimitSeconds: Number(e.target.value) })}
            min={10}
            max={120}
            className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
          />
        </div>
      </div>

      {/* Dynamic Lily Pad Sequence Builder */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider">
              Lily Pad Number Sequence ({sequence.length} Pads)
            </label>
            <p className="text-[10px] text-slate-400">
              Click &ldquo;Set As Missing&rdquo; on the slot that the frog needs to leap onto.
            </p>
          </div>

          <button
            type="button"
            onClick={handleAddPad}
            className="px-2.5 py-1 rounded-lg bg-emerald-600/30 hover:bg-emerald-600/50 border border-emerald-500/40 text-emerald-300 text-xs font-bold transition-colors flex items-center gap-1"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>Add Pad</span>
          </button>
        </div>

        {/* Sequence Pads Grid */}
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
          {sequence.map((item, idx) => {
            const isMissing = missingIndex === idx;

            return (
              <div
                key={idx}
                className={`p-3 rounded-2xl border transition-all relative ${
                  isMissing
                    ? "bg-amber-950/40 border-amber-500/60 shadow-lg shadow-amber-950/30"
                    : "bg-[#120E33] border-slate-800"
                }`}
              >
                {/* Pad Number Badge */}
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[10px] font-bold text-slate-400">Pad #{idx + 1}</span>
                  {sequence.length > 3 && (
                    <button
                      type="button"
                      onClick={() => handleRemovePad(idx)}
                      className="text-slate-500 hover:text-rose-400 transition-colors"
                    >
                      <X className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>

                {/* Pad Input Value or Missing Flag */}
                {isMissing ? (
                  <div className="py-2 text-center">
                    <span className="text-xl font-black text-amber-400 font-mono">?</span>
                    <span className="block text-[9px] font-bold text-amber-300 uppercase tracking-tight mt-0.5">
                      Missing Slot
                    </span>
                  </div>
                ) : (
                  <input
                    type="number"
                    value={item ?? 0}
                    onChange={(e) => handleSequenceValueChange(idx, e.target.value)}
                    className="w-full text-center py-1.5 rounded-lg glass-input text-base font-black text-white font-mono focus:outline-none"
                  />
                )}

                {/* Set as Missing Button */}
                <button
                  type="button"
                  onClick={() => handleSetMissingPad(idx)}
                  className={`w-full mt-2 py-1 rounded-lg text-[10px] font-bold transition-all ${
                    isMissing
                      ? "bg-amber-500 text-black shadow-sm font-black"
                      : "bg-slate-800 text-slate-400 hover:text-white hover:bg-slate-700"
                  }`}
                >
                  {isMissing ? "✓ Missing Target" : "Set As Missing"}
                </button>
              </div>
            );
          })}
        </div>
      </div>

      {/* Answers & Distractors Configuration */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {/* Correct Answer */}
        <div className="p-4 rounded-2xl bg-emerald-950/20 border border-emerald-500/30 space-y-2">
          <div className="flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-400" />
            <label className="text-xs font-bold text-white uppercase tracking-wider">
              Correct Answer (නිවැරදි පිළිතුර)
            </label>
          </div>
          <input
            type="number"
            value={correctAnswer}
            onChange={(e) => update({ correctAnswer: Number(e.target.value) })}
            required
            placeholder="36"
            className="w-full p-2.5 rounded-xl glass-input text-sm font-bold text-emerald-300 font-mono focus:outline-none"
          />
          <p className="text-[10px] text-slate-400">
            The numerical value that correctly fills the missing Pad #{missingIndex + 1}.
          </p>
        </div>

        {/* Distractor Choices */}
        <div className="p-4 rounded-2xl bg-[#120E33] border border-slate-800 space-y-2">
          <div className="flex items-center justify-between">
            <label className="text-xs font-bold text-white uppercase tracking-wider">
              Distractor Options ({distractors.length} Wrong Choices)
            </label>
            <span className="text-[10px] text-slate-400">Multiple Choice Pool</span>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            {distractors.map((d, idx) => (
              <div
                key={idx}
                className="flex items-center gap-1.5 px-3 py-1 rounded-lg bg-rose-500/10 border border-rose-500/30 text-xs font-mono font-bold text-rose-300"
              >
                <span>{d}</span>
                <button
                  type="button"
                  onClick={() => handleRemoveDistractor(idx)}
                  className="text-slate-400 hover:text-rose-400"
                >
                  <X className="w-3 h-3" />
                </button>
              </div>
            ))}

            <div className="flex items-center gap-1">
              <input
                type="number"
                value={newDistractor}
                onChange={(e) => setNewDistractor(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    handleAddDistractor();
                  }
                }}
                placeholder="Wrong choice..."
                className="px-2.5 py-1 rounded-lg glass-input text-xs w-28 font-mono focus:outline-none"
              />
              <button
                type="button"
                onClick={handleAddDistractor}
                className="p-1 rounded-lg bg-purple-600 hover:bg-purple-500 text-white text-xs transition-colors"
              >
                <Plus className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Visual Lily Pad Pond Simulator Preview */}
      <div className="p-4 rounded-2xl bg-gradient-to-b from-[#0e2730] to-[#0a1a24] border border-emerald-500/30 space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-emerald-400" />
            <h4 className="text-xs font-bold text-white">Interactive Lily Pond Game Simulator</h4>
          </div>
          <span className="text-[10px] text-emerald-300 font-medium">{ruleDescription}</span>
        </div>

        {/* Pond Surface Simulation */}
        <div className="flex items-center justify-between gap-2 p-4 rounded-xl bg-cyan-950/40 border border-cyan-800/40 overflow-x-auto">
          {sequence.map((item, idx) => {
            const isMissing = missingIndex === idx;
            return (
              <div key={idx} className="flex flex-col items-center gap-1 flex-shrink-0">
                <div
                  className={`w-14 h-14 rounded-full flex flex-col items-center justify-center border-2 transition-transform hover:scale-105 ${
                    isMissing
                      ? "bg-amber-500/20 border-amber-400 border-dashed animate-pulse"
                      : "bg-emerald-600/30 border-emerald-400 shadow-md shadow-emerald-900/30"
                  }`}
                >
                  <span className="text-lg">🪷</span>
                  <span
                    className={`text-xs font-black font-mono leading-none ${
                      isMissing ? "text-amber-300 font-bold" : "text-white"
                    }`}
                  >
                    {isMissing ? "?" : item}
                  </span>
                </div>
                <span className="text-[9px] font-bold text-slate-400">Pad {idx + 1}</span>
              </div>
            );
          })}
        </div>

        {/* Choice Bubbles Preview */}
        <div className="flex items-center justify-center gap-2 pt-1">
          <span className="text-[10px] text-slate-400 font-medium">Student Choice Options:</span>
          {[correctAnswer, ...distractors]
            .sort((a, b) => a - b)
            .map((val, idx) => (
              <span
                key={idx}
                className={`text-xs font-mono font-bold px-3 py-1 rounded-full border ${
                  val === correctAnswer
                    ? "bg-emerald-500/20 text-emerald-300 border-emerald-500/50 shadow-sm shadow-emerald-500/20"
                    : "bg-slate-800 text-slate-300 border-slate-700"
                }`}
              >
                {val}
              </span>
            ))}
        </div>
      </div>
    </div>
  );
}
