"use client";

import React, { useState } from "react";
import { AbacusGameData } from "@/types";
import { Plus, X, Sparkles } from "lucide-react";

interface AbacusFormProps {
  data: Partial<AbacusGameData>;
  onChange: (updated: AbacusGameData) => void;
}

const PRESETS = [
  { label: "Grade 5 (4-Digit: දහස්, සිය, දහය, එකක)", values: ["දහස්", "සිය", "දහය", "එකක"] },
  { label: "Grade 5 (5-Digit: දස දහස්, දහස්, සිය, දහය, එකක)", values: ["දස දහස්", "දහස්", "සිය", "දහය", "එකක"] },
  { label: "English (Thousands, Hundreds, Tens, Ones)", values: ["Thousands", "Hundreds", "Tens", "Ones"] },
];

export default function AbacusForm({ data, onChange }: AbacusFormProps) {
  const targetNumber = data.targetNumber ?? 5421;
  const placeValues =
    data.placeValues && data.placeValues.length > 0
      ? data.placeValues
      : ["දහස්", "සිය", "දහය", "එකක"];
  const instruction =
    data.instruction ?? "අබාකස් රාමුවේ පබළු ගණනය කර නිවැරදි සංඛ්‍යාව සාදන්න.";

  const [newPlaceValue, setNewPlaceValue] = useState("");

  const update = (overrides: Partial<AbacusGameData>) => {
    onChange({
      targetNumber: Number(overrides.targetNumber ?? targetNumber) || 0,
      placeValues: overrides.placeValues ?? placeValues,
      instruction: overrides.instruction ?? instruction,
      maxBeadsPerRod: 9,
      allowDragDrop: true,
    });
  };

  const handleAddPlaceValue = () => {
    if (!newPlaceValue.trim()) return;
    update({ placeValues: [...placeValues, newPlaceValue.trim()] });
    setNewPlaceValue("");
  };

  const handleRemovePlaceValue = (index: number) => {
    if (placeValues.length <= 1) return;
    update({ placeValues: placeValues.filter((_, i) => i !== index) });
  };

  const applyPreset = (preset: string[]) => {
    update({ placeValues: [...preset] });
  };

  // Convert target number to digits aligned with rods
  const targetStr = String(targetNumber).padStart(placeValues.length, "0");
  const digits = targetStr.slice(-placeValues.length).split("").map(Number);

  return (
    <div className="space-y-6">
      {/* Target Number & Instruction */}
      <div className="space-y-4">
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Target Number (ඉලක්ක සංඛ්‍යාව)
          </label>
          <input
            type="number"
            value={targetNumber}
            onChange={(e) => update({ targetNumber: Number(e.target.value) })}
            required
            min={0}
            max={999999}
            placeholder="5421"
            className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
          />
          <p className="text-[10px] text-slate-400 mt-1">
            The target integer students must assemble by placing beads on the abacus rods.
          </p>
        </div>

        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Student Instruction Prompt
          </label>
          <input
            type="text"
            value={instruction}
            onChange={(e) => update({ instruction: e.target.value })}
            placeholder="අබාකස් රාමුවේ පබළු ගණනය කර නිවැරදි සංඛ්‍යාව සාදන්න."
            className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>
      </div>

      {/* Place Value Column Rods */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider">
            Place Value Rods ({placeValues.length} Columns)
          </label>
          <span className="text-[10px] text-purple-300">Left to Right Order</span>
        </div>

        {/* Quick Preset Buttons */}
        <div className="flex flex-wrap gap-2">
          {PRESETS.map((p, idx) => (
            <button
              key={idx}
              type="button"
              onClick={() => applyPreset(p.values)}
              className="text-[10px] px-2.5 py-1 rounded-lg bg-[#120E33] border border-slate-800 hover:border-purple-500/50 text-slate-300 hover:text-white transition-colors"
            >
              {p.label}
            </button>
          ))}
        </div>

        {/* Dynamic Tags */}
        <div className="flex flex-wrap items-center gap-2 p-3 rounded-xl bg-[#120E33]/70 border border-slate-800">
          {placeValues.map((pv, idx) => (
            <div
              key={idx}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-purple-500/10 border border-purple-500/30 text-xs font-bold text-purple-200 shadow-sm"
            >
              <span>{pv}</span>
              <button
                type="button"
                onClick={() => handleRemovePlaceValue(idx)}
                className="text-slate-400 hover:text-rose-400 transition-colors"
              >
                <X className="w-3 h-3" />
              </button>
            </div>
          ))}

          <div className="flex items-center gap-1.5">
            <input
              type="text"
              value={newPlaceValue}
              onChange={(e) => setNewPlaceValue(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter") {
                  e.preventDefault();
                  handleAddPlaceValue();
                }
              }}
              placeholder="Add rod label..."
              className="px-2.5 py-1 rounded-lg glass-input text-xs w-32 focus:outline-none"
            />
            <button
              type="button"
              onClick={handleAddPlaceValue}
              className="p-1 rounded-lg bg-purple-600 hover:bg-purple-500 text-white text-xs transition-colors"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Visual Live Abacus Rods Simulation Preview */}
      <div className="p-4 rounded-2xl bg-gradient-to-b from-[#16123D] to-[#0D0B26] border border-purple-500/30 space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-amber-400" />
            <h4 className="text-xs font-bold text-white">Visual Abacus Simulator Preview</h4>
          </div>
          <span className="text-[10px] font-mono text-emerald-400 font-bold bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-500/30">
            Target = {targetNumber}
          </span>
        </div>

        {/* Rods Grid */}
        <div className="grid grid-cols-4 sm:grid-cols-4 md:grid-cols-5 gap-3 pt-2">
          {placeValues.map((pv, idx) => {
            const beadCount = digits[idx] ?? 0;
            return (
              <div
                key={idx}
                className="flex flex-col items-center p-3 rounded-xl bg-[#120E33] border border-slate-800 text-center"
              >
                <span className="text-[10px] font-bold text-purple-300 uppercase tracking-tight truncate w-full">
                  {pv}
                </span>

                {/* Rod with Beads */}
                <div className="relative w-full h-28 flex flex-col-reverse items-center justify-start my-2 py-1 bg-slate-900/60 rounded-lg border border-slate-800/80">
                  {/* Vertical Wire Rod Line */}
                  <div className="absolute inset-y-1 w-1 bg-gradient-to-b from-slate-500 to-slate-700 rounded-full" />

                  {/* Beads */}
                  {Array.from({ length: beadCount }).map((_, bIdx) => (
                    <div
                      key={bIdx}
                      className="relative z-10 w-8 h-4 my-0.5 rounded-full bg-gradient-to-r from-amber-400 to-orange-500 shadow-md shadow-amber-500/30 border border-amber-300"
                    />
                  ))}

                  {beadCount === 0 && (
                    <span className="relative z-10 text-[10px] text-slate-600 my-auto">
                      Empty
                    </span>
                  )}
                </div>

                <span className="text-xs font-black text-white font-mono bg-purple-950/60 px-2 py-0.5 rounded border border-purple-500/30">
                  {beadCount}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
