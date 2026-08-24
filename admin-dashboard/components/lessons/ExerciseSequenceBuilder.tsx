"use client";

import React, { useState } from "react";
import { ExerciseStep } from "@/types";
import ExerciseStepCard from "./ExerciseStepCard";
import {
  Plus,
  Sparkles,
  Layers,
  HelpCircle,
  Lightbulb,
  CheckCircle2,
} from "lucide-react";

interface ExerciseSequenceBuilderProps {
  exercises: ExerciseStep[];
  onChange: (updated: ExerciseStep[]) => void;
}

export default function ExerciseSequenceBuilder({
  exercises,
  onChange,
}: ExerciseSequenceBuilderProps) {
  const [activeStepPreviewIdx, setActiveStepPreviewIdx] = useState<number>(0);
  const [activeAttemptTab, setActiveAttemptTab] = useState<1 | 2 | 3>(1);

  const handleAddStep = () => {
    const newStep: ExerciseStep = {
      id: `ex_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      interactionType: "multipleChoice",
      questionText: "",
      options: ["10", "100", "1,000", "10,000"],
      correctAnswer: "1,000",
      hintLevel1: "",
      hintLevel2: "",
      workedSolution: "",
      xpReward: 10,
    };
    onChange([...exercises, newStep]);
  };

  const handleUpdateStep = (index: number, updated: ExerciseStep) => {
    const next = [...exercises];
    next[index] = updated;
    onChange(next);
  };

  const handleMoveUp = (index: number) => {
    if (index === 0) return;
    const next = [...exercises];
    const temp = next[index - 1];
    next[index - 1] = next[index];
    next[index] = temp;
    onChange(next);
  };

  const handleMoveDown = (index: number) => {
    if (index === exercises.length - 1) return;
    const next = [...exercises];
    const temp = next[index + 1];
    next[index + 1] = next[index];
    next[index] = temp;
    onChange(next);
  };

  const handleDuplicate = (index: number) => {
    const target = exercises[index];
    const clone: ExerciseStep = {
      ...target,
      id: `ex_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      questionText: `${target.questionText} (Copy)`,
    };
    const next = [...exercises];
    next.splice(index + 1, 0, clone);
    onChange(next);
  };

  const handleDelete = (index: number) => {
    if (exercises.length <= 1) return;
    onChange(exercises.filter((_, i) => i !== index));
  };

  const currentPreviewStep = exercises[activeStepPreviewIdx] || exercises[0];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3 pb-2">
        <div>
          <h3 className="text-xs font-bold text-white uppercase tracking-wider">
            Lesson Exercise Steps ({exercises.length} Exercises)
          </h3>
          <p className="text-[11px] text-slate-400">
            Each exercise includes adaptive 3-attempt scaffold feedback
          </p>
        </div>

        <button
          type="button"
          onClick={handleAddStep}
          className="px-3 py-1.5 rounded-xl bg-purple-600 hover:bg-purple-500 text-white text-xs font-bold transition-all flex items-center gap-1.5 shadow-md shadow-purple-600/30"
        >
          <Plus className="w-3.5 h-3.5" />
          <span>Add Exercise Step</span>
        </button>
      </div>

      {/* Ordered Steps List */}
      <div className="space-y-5">
        {exercises.map((step, idx) => (
          <ExerciseStepCard
            key={step.id || idx}
            step={step}
            index={idx}
            totalSteps={exercises.length}
            onUpdate={(updated) => handleUpdateStep(idx, updated)}
            onMoveUp={() => handleMoveUp(idx)}
            onMoveDown={() => handleMoveDown(idx)}
            onDuplicate={() => handleDuplicate(idx)}
            onDelete={() => handleDelete(idx)}
          />
        ))}
      </div>

      {/* Add Step Button */}
      <button
        type="button"
        onClick={handleAddStep}
        className="w-full py-3.5 rounded-2xl border border-dashed border-purple-500/40 hover:border-purple-400 bg-purple-500/5 hover:bg-purple-500/10 text-purple-300 hover:text-white font-bold text-xs transition-all flex items-center justify-center gap-2 cursor-pointer shadow-sm"
      >
        <Plus className="w-4 h-4" />
        <span>Append Next Exercise Step</span>
      </button>

      {/* 3-Attempt Adaptive Student Walkthrough Simulator */}
      {currentPreviewStep && (
        <div className="p-5 rounded-2xl bg-gradient-to-b from-[#15103A] to-[#0D0B26] border border-purple-500/30 space-y-4 shadow-xl">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-amber-400" />
              <h4 className="text-xs font-bold text-white">
                3-Attempt Adaptive Student Simulator
              </h4>
            </div>

            {/* Step Navigation */}
            <div className="flex items-center gap-2">
              <span className="text-[10px] text-slate-400 font-mono">
                Step {activeStepPreviewIdx + 1} of {exercises.length}
              </span>
              <div className="flex items-center gap-1">
                <button
                  type="button"
                  disabled={activeStepPreviewIdx === 0}
                  onClick={() => setActiveStepPreviewIdx((p) => Math.max(0, p - 1))}
                  className="px-2 py-0.5 rounded bg-slate-800 hover:bg-slate-700 text-xs text-white disabled:opacity-30"
                >
                  ◀
                </button>
                <button
                  type="button"
                  disabled={activeStepPreviewIdx >= exercises.length - 1}
                  onClick={() =>
                    setActiveStepPreviewIdx((p) => Math.min(exercises.length - 1, p + 1))
                  }
                  className="px-2 py-0.5 rounded bg-slate-800 hover:bg-slate-700 text-xs text-white disabled:opacity-30"
                >
                  ▶
                </button>
              </div>
            </div>
          </div>

          {/* Attempt Selector Tabs */}
          <div className="flex items-center gap-2 p-1 rounded-xl bg-black/40 border border-white/10 w-fit">
            <button
              type="button"
              onClick={() => setActiveAttemptTab(1)}
              className={`px-3 py-1 rounded-lg text-xs font-bold transition-all ${
                activeAttemptTab === 1
                  ? "bg-amber-500 text-black shadow"
                  : "text-slate-400 hover:text-white"
              }`}
            >
              1st Fail: Light Hint
            </button>
            <button
              type="button"
              onClick={() => setActiveAttemptTab(2)}
              className={`px-3 py-1 rounded-lg text-xs font-bold transition-all ${
                activeAttemptTab === 2
                  ? "bg-purple-600 text-white shadow"
                  : "text-slate-400 hover:text-white"
              }`}
            >
              2nd Fail: Guided Reasoning
            </button>
            <button
              type="button"
              onClick={() => setActiveAttemptTab(3)}
              className={`px-3 py-1 rounded-lg text-xs font-bold transition-all ${
                activeAttemptTab === 3
                  ? "bg-emerald-500 text-black shadow"
                  : "text-slate-400 hover:text-white"
              }`}
            >
              3rd Fail: Full Solution
            </button>
          </div>

          {/* Simulator Box */}
          <div className="p-4 rounded-xl bg-[#120E33] border border-slate-800 space-y-3">
            <div className="flex items-start justify-between gap-2">
              <p className="text-xs font-bold text-white leading-relaxed">
                {currentPreviewStep.questionText || "(No question text entered yet)"}
              </p>
              <span className="text-[10px] text-emerald-400 font-mono font-bold bg-emerald-950/40 px-2 py-0.5 rounded">
                +{currentPreviewStep.xpReward || 10} XP
              </span>
            </div>

            {/* Hint Box based on selected Attempt tab */}
            {activeAttemptTab === 1 && (
              <div className="p-3 rounded-lg bg-amber-500/10 border border-amber-500/30 flex items-start gap-2.5">
                <Lightbulb className="w-4 h-4 text-amber-400 flex-shrink-0 mt-0.5" />
                <div>
                  <span className="text-[10px] font-bold text-amber-300 uppercase block">
                    Hint 1 (Light Hint Triggered):
                  </span>
                  <p className="text-xs text-amber-100">
                    {currentPreviewStep.hintLevel1 || "No light hint provided."}
                  </p>
                </div>
              </div>
            )}

            {activeAttemptTab === 2 && (
              <div className="p-3 rounded-lg bg-purple-500/10 border border-purple-500/30 flex items-start gap-2.5">
                <Layers className="w-4 h-4 text-purple-400 flex-shrink-0 mt-0.5" />
                <div>
                  <span className="text-[10px] font-bold text-purple-300 uppercase block">
                    Hint 2 (Guided Reasoning Triggered):
                  </span>
                  <p className="text-xs text-purple-100">
                    {currentPreviewStep.hintLevel2 || "No guided reasoning provided."}
                  </p>
                </div>
              </div>
            )}

            {activeAttemptTab === 3 && (
              <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 flex-shrink-0 mt-0.5" />
                <div>
                  <span className="text-[10px] font-bold text-emerald-300 uppercase block">
                    Worked Solution (All Attempts Exhausted):
                  </span>
                  <p className="text-xs text-emerald-100">
                    {currentPreviewStep.workedSolution || "No worked solution provided."}
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
