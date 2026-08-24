"use client";

import React from "react";
import { StoryBeat, StoryCharacter } from "@/types";
import {
  ChevronUp,
  ChevronDown,
  Trash2,
  Copy,
  Sparkles,
  HelpCircle,
  MessageSquare,
  ShieldCheck,
  CheckCircle2,
  X,
  Plus,
} from "lucide-react";

interface StoryBeatCardProps {
  beat: StoryBeat;
  index: number;
  totalBeats: number;
  onUpdate: (updated: StoryBeat) => void;
  onMoveUp: () => void;
  onMoveDown: () => void;
  onDuplicate: () => void;
  onDelete: () => void;
}

export const CHARACTER_THEMES: Record<
  StoryCharacter,
  {
    name: string;
    emoji: string;
    role: string;
    cardBg: string;
    border: string;
    badgeBg: string;
    textColor: string;
    avatarBorder: string;
  }
> = {
  Leo: {
    name: "Leo the Brave Lion",
    emoji: "🦁",
    role: "Hero & Explorer",
    cardBg: "bg-gradient-to-r from-blue-950/60 to-indigo-950/40",
    border: "border-indigo-500/40 hover:border-indigo-400",
    badgeBg: "bg-indigo-500/20 text-indigo-300 border-indigo-500/40",
    textColor: "text-indigo-200",
    avatarBorder: "border-indigo-400",
  },
  Ella: {
    name: "Ella the Wise Elephant",
    emoji: "🐘",
    role: "Logic & Big Numbers",
    cardBg: "bg-gradient-to-r from-rose-950/60 to-pink-950/40",
    border: "border-pink-500/40 hover:border-pink-400",
    badgeBg: "bg-pink-500/20 text-pink-300 border-pink-500/40",
    textColor: "text-pink-200",
    avatarBorder: "border-pink-400",
  },
  Felix: {
    name: "Felix the Clever Fox",
    emoji: "🦊",
    role: "Tricks & Speed-Math",
    cardBg: "bg-gradient-to-r from-amber-950/60 to-orange-950/40",
    border: "border-amber-500/40 hover:border-amber-400",
    badgeBg: "bg-amber-500/20 text-amber-300 border-amber-500/40",
    textColor: "text-amber-200",
    avatarBorder: "border-amber-400",
  },
  Parrot: {
    name: "Guru Parrot Mentor",
    emoji: "🦜",
    role: "Teacher & Hint Guide",
    cardBg: "bg-gradient-to-r from-emerald-950/60 to-teal-950/40",
    border: "border-emerald-500/40 hover:border-emerald-400",
    badgeBg: "bg-emerald-500/20 text-emerald-300 border-emerald-500/40",
    textColor: "text-emerald-200",
    avatarBorder: "border-emerald-400",
  },
};

export default function StoryBeatCard({
  beat,
  index,
  totalBeats,
  onUpdate,
  onMoveUp,
  onMoveDown,
  onDuplicate,
  onDelete,
}: StoryBeatCardProps) {
  const theme = CHARACTER_THEMES[beat.speaker] || CHARACTER_THEMES.Leo;

  const handleSpeakerChange = (newSpeaker: StoryCharacter) => {
    onUpdate({ ...beat, speaker: newSpeaker });
  };

  const handleDialogueChange = (text: string) => {
    onUpdate({ ...beat, dialogueText: text });
  };

  const handleToggleGate = () => {
    const nextGate = !beat.hasInteractiveGate;
    onUpdate({
      ...beat,
      hasInteractiveGate: nextGate,
      gateQuestion: nextGate ? beat.gateQuestion || "නිවැරදි පිළිතුර තෝරන්න:" : undefined,
      gateOptions: nextGate ? beat.gateOptions || ["10", "100", "1,000", "10,000"] : undefined,
      gateCorrectIndex: nextGate ? beat.gateCorrectIndex ?? 0 : undefined,
    });
  };

  return (
    <div
      className={`rounded-2xl p-4 sm:p-5 border transition-all ${theme.cardBg} ${theme.border} shadow-lg relative`}
    >
      {/* Header Bar */}
      <div className="flex flex-wrap items-center justify-between gap-3 pb-3 border-b border-white/10">
        {/* Step Index & Character Badge */}
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-xl bg-black/40 border border-white/20 flex items-center justify-center font-mono text-xs font-bold text-white shadow-inner">
            #{index + 1}
          </div>

          {/* Character Selector Dropdown */}
          <div className="relative">
            <select
              value={beat.speaker}
              onChange={(e) => handleSpeakerChange(e.target.value as StoryCharacter)}
              className={`text-xs font-bold py-1.5 px-3 rounded-xl border focus:outline-none cursor-pointer ${theme.badgeBg} bg-[#120E33]`}
            >
              <option value="Leo">🦁 Leo (Lion Hero)</option>
              <option value="Ella">🐘 Ella (Elephant Logic)</option>
              <option value="Felix">🦊 Felix (Fox Tricks)</option>
              <option value="Parrot">🦜 Parrot (Mentor Guide)</option>
            </select>
          </div>

          <span className="text-[10px] text-slate-400 hidden sm:inline-block">
            {theme.role}
          </span>
        </div>

        {/* Action Controls: Move Up/Down, Duplicate, Delete */}
        <div className="flex items-center gap-1">
          <button
            type="button"
            onClick={onMoveUp}
            disabled={index === 0}
            title="Move Beat Up"
            className="p-1.5 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white disabled:opacity-30 transition-colors"
          >
            <ChevronUp className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={onMoveDown}
            disabled={index === totalBeats - 1}
            title="Move Beat Down"
            className="p-1.5 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white disabled:opacity-30 transition-colors"
          >
            <ChevronDown className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={onDuplicate}
            title="Duplicate Beat"
            className="p-1.5 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white transition-colors"
          >
            <Copy className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={onDelete}
            title="Delete Beat"
            className="p-1.5 rounded-lg bg-rose-500/20 hover:bg-rose-500/40 text-rose-300 hover:text-rose-100 transition-colors ml-1"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Dialogue Input Body */}
      <div className="pt-4 space-y-3">
        <div>
          <label className="block text-[11px] font-semibold text-slate-300 uppercase tracking-wider mb-1.5 flex items-center justify-between">
            <span>Character Speech Dialogue (Sinhala / English)</span>
            <span className="text-[10px] text-slate-400 font-mono">
              {beat.dialogueText.length} chars
            </span>
          </label>
          <textarea
            value={beat.dialogueText}
            onChange={(e) => handleDialogueChange(e.target.value)}
            rows={3}
            placeholder={`e.g. ${theme.name}: "යාලුවනේ, අද අපි දහස් සහ දස දහස් ස්ථානීය අගයන් ගවේෂණය කරමු!"`}
            className="w-full p-3 rounded-xl glass-input text-xs leading-relaxed focus:outline-none resize-y"
          />
        </div>

        {/* Interactive Gate Checkpoint Toggle */}
        <div className="pt-1">
          <div className="flex items-center justify-between p-3 rounded-xl bg-black/20 border border-white/10">
            <div className="flex items-center gap-2">
              <ShieldCheck
                className={`w-4 h-4 ${
                  beat.hasInteractiveGate ? "text-emerald-400" : "text-slate-500"
                }`}
              />
              <div>
                <span className="text-xs font-bold text-white">Interactive Gate Checkpoint</span>
                <p className="text-[10px] text-slate-400">
                  Pause dialogue until student answers a quick concept question
                </p>
              </div>
            </div>

            <button
              type="button"
              onClick={handleToggleGate}
              className={`px-3 py-1 rounded-xl text-[10px] font-bold uppercase transition-all ${
                beat.hasInteractiveGate
                  ? "bg-emerald-500 text-black shadow-md shadow-emerald-500/30"
                  : "bg-slate-800 text-slate-400 hover:bg-slate-700"
              }`}
            >
              {beat.hasInteractiveGate ? "Gate Enabled ✓" : "No Gate"}
            </button>
          </div>

          {/* Expanded Gate Question Configuration */}
          {beat.hasInteractiveGate && (
            <div className="mt-3 p-4 rounded-xl bg-emerald-950/20 border border-emerald-500/30 space-y-3">
              <div>
                <label className="block text-[10px] font-bold text-emerald-300 uppercase tracking-wider mb-1">
                  Gate Prompt Question
                </label>
                <input
                  type="text"
                  value={beat.gateQuestion || ""}
                  onChange={(e) => onUpdate({ ...beat, gateQuestion: e.target.value })}
                  placeholder="e.g. 5,420 සංඛ්‍යාවේ '4' ඉලක්කමේ ස්ථානීය අගය කුමක්ද?"
                  className="w-full p-2 rounded-lg glass-input text-xs focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-[10px] font-bold text-emerald-300 uppercase tracking-wider mb-1">
                  Answer Choices (Select Radio for Correct Option)
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  {(beat.gateOptions || ["10", "100", "1,000", "10,000"]).map(
                    (opt, optIdx) => (
                      <div
                        key={optIdx}
                        className={`flex items-center gap-2 p-2 rounded-lg border transition-all ${
                          beat.gateCorrectIndex === optIdx
                            ? "bg-emerald-500/20 border-emerald-500/50"
                            : "bg-[#120E33] border-slate-800"
                        }`}
                      >
                        <input
                          type="radio"
                          name={`gate-correct-${beat.id}`}
                          checked={beat.gateCorrectIndex === optIdx}
                          onChange={() => onUpdate({ ...beat, gateCorrectIndex: optIdx })}
                          className="accent-emerald-400"
                        />
                        <input
                          type="text"
                          value={opt}
                          onChange={(e) => {
                            const newOpts = [...(beat.gateOptions || [])];
                            newOpts[optIdx] = e.target.value;
                            onUpdate({ ...beat, gateOptions: newOpts });
                          }}
                          className="flex-1 bg-transparent text-xs text-white focus:outline-none"
                        />
                      </div>
                    )
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
