"use client";

import React, { useState } from "react";
import { GameTemplateType } from "@/types";
import { Target, Binary, Award, Zap, Compass } from "lucide-react";

interface PlaceholderGameFormProps {
  templateType: GameTemplateType;
  data: any;
  onChange: (updated: any) => void;
}

export default function PlaceholderGameForm({
  templateType,
  data,
  onChange,
}: PlaceholderGameFormProps) {
  const instruction = data.instruction ?? "ගැළපෙන අගය තෝරා ක්‍රීඩාව සම්පූර්ණ කරන්න.";
  const difficulty = data.difficulty ?? 1;
  const [customParams, setCustomParams] = useState<string>(
    JSON.stringify(
      data.customConfig || {
        targetRange: [1, 100],
        timeLimitSeconds: 45,
        scoringMultiplier: 1.5,
      },
      null,
      2
    )
  );

  const update = (overrides: { instruction?: string; difficulty?: number; customConfig?: any }) => {
    let parsed = overrides.customConfig;
    if (parsed === undefined) {
      try {
        parsed = JSON.parse(customParams);
      } catch {
        parsed = { raw: customParams };
      }
    }

    onChange({
      instruction: overrides.instruction ?? instruction,
      difficulty: Number(overrides.difficulty ?? difficulty) || 1,
      customConfig: parsed,
    });
  };

  const handleJsonChange = (raw: string) => {
    setCustomParams(raw);
    try {
      const parsed = JSON.parse(raw);
      update({ customConfig: parsed });
    } catch {
      update({ customConfig: { raw } });
    }
  };

  const TEMPLATE_META: Record<string, { title: string; icon: any; desc: string }> = {
    number_archery: {
      title: "Number Archery (ඊතල විදීමේ ක්‍රීඩාව)",
      icon: Target,
      desc: "Shoot mathematical operation arrows to strike the target number.",
    },
    digit_builder: {
      title: "Digit Builder (ඉලක්කම් ගොඩනැගීම)",
      icon: Binary,
      desc: "Assemble highest or lowest numbers using restricted digit cards.",
    },
    place_value: {
      title: "Place Value Hunter (ස්ථානීය අගය)",
      icon: Award,
      desc: "Identify place values of underlined digits in 5-digit numbers.",
    },
    expanded_form: {
      title: "Expanded Form Puzzle (විස්තාරිත ආකාරය)",
      icon: Compass,
      desc: "Match numbers to their expanded standard polynomial sums.",
    },
    rapid_fire: {
      title: "Rapid Fire Math Blitz (ක්ෂණික ගණිතය)",
      icon: Zap,
      desc: "High-speed mental math arithmetic countdown challenge.",
    },
  };

  const templateInfo = TEMPLATE_META[templateType] || {
    title: "Mini-Game Template",
    icon: Target,
    desc: "Configure interactive math mini-game parameters.",
  };

  const Icon = templateInfo.icon;

  return (
    <div className="space-y-4">
      {/* Template Header Notice */}
      <div className="p-4 rounded-2xl bg-[#120E33] border border-slate-800 flex items-start gap-3">
        <div className="p-2.5 rounded-xl bg-purple-500/20 text-purple-300 border border-purple-500/30">
          <Icon className="w-5 h-5" />
        </div>
        <div>
          <h4 className="text-xs font-bold text-white">{templateInfo.title}</h4>
          <p className="text-[11px] text-slate-400 mt-0.5">{templateInfo.desc}</p>
        </div>
      </div>

      {/* Instruction */}
      <div>
        <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
          Student Gameplay Prompt
        </label>
        <input
          type="text"
          value={instruction}
          onChange={(e) => update({ instruction: e.target.value })}
          className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
        />
      </div>

      {/* Difficulty */}
      <div>
        <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
          Difficulty Level (1 - Easy, 2 - Medium, 3 - Scholarship Advanced)
        </label>
        <select
          value={difficulty}
          onChange={(e) => update({ difficulty: Number(e.target.value) })}
          className="w-full py-2.5 px-3 rounded-xl glass-input text-xs focus:outline-none bg-[#120E33]"
        >
          <option value={1}>Level 1: Easy Basics</option>
          <option value={2}>Level 2: Standard Grade 5</option>
          <option value={3}>Level 3: Scholarship Challenge</option>
        </select>
      </div>

      {/* Custom Configuration JSON */}
      <div>
        <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
          Game Configuration Parameters (JSON)
        </label>
        <textarea
          value={customParams}
          onChange={(e) => handleJsonChange(e.target.value)}
          rows={5}
          className="w-full p-3 rounded-xl glass-input text-xs font-mono focus:outline-none"
        />
      </div>
    </div>
  );
}
