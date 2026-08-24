"use client";

import React, { useState } from "react";
import { StoryBeat, StoryCharacter } from "@/types";
import StoryBeatCard, { CHARACTER_THEMES } from "./StoryBeatCard";
import { Plus, Sparkles, Play, MessageSquare, ShieldCheck } from "lucide-react";

interface StorySequenceTimelineProps {
  beats: StoryBeat[];
  onChange: (updatedBeats: StoryBeat[]) => void;
}

export default function StorySequenceTimeline({
  beats,
  onChange,
}: StorySequenceTimelineProps) {
  const [activePreviewIdx, setActivePreviewIdx] = useState<number>(0);

  const handleAddBeat = (speaker: StoryCharacter = "Parrot") => {
    const newBeat: StoryBeat = {
      id: `beat_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      speaker,
      dialogueText: "",
      hasInteractiveGate: false,
    };
    onChange([...beats, newBeat]);
  };

  const handleUpdateBeat = (index: number, updated: StoryBeat) => {
    const next = [...beats];
    next[index] = updated;
    onChange(next);
  };

  const handleMoveUp = (index: number) => {
    if (index === 0) return;
    const next = [...beats];
    const temp = next[index - 1];
    next[index - 1] = next[index];
    next[index] = temp;
    onChange(next);
  };

  const handleMoveDown = (index: number) => {
    if (index === beats.length - 1) return;
    const next = [...beats];
    const temp = next[index + 1];
    next[index + 1] = next[index];
    next[index] = temp;
    onChange(next);
  };

  const handleDuplicate = (index: number) => {
    const target = beats[index];
    const clone: StoryBeat = {
      ...target,
      id: `beat_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      dialogueText: `${target.dialogueText} (Copy)`,
    };
    const next = [...beats];
    next.splice(index + 1, 0, clone);
    onChange(next);
  };

  const handleDelete = (index: number) => {
    if (beats.length <= 1) return;
    onChange(beats.filter((_, i) => i !== index));
  };

  return (
    <div className="space-y-6">
      {/* Action Header */}
      <div className="flex flex-wrap items-center justify-between gap-3 pb-2">
        <div>
          <h3 className="text-xs font-bold text-white uppercase tracking-wider">
            Story Narrative Timeline ({beats.length} Dialogue Beats)
          </h3>
          <p className="text-[11px] text-slate-400">
            Ordered sequence of conversational beats played before or during the quest
          </p>
        </div>

        {/* Quick Add Character Buttons */}
        <div className="flex items-center gap-1.5 flex-wrap">
          <span className="text-[10px] text-slate-400 font-semibold mr-1">Add:</span>
          {(["Leo", "Ella", "Felix", "Parrot"] as StoryCharacter[]).map((char) => {
            const theme = CHARACTER_THEMES[char];
            return (
              <button
                key={char}
                type="button"
                onClick={() => handleAddBeat(char)}
                className={`px-2.5 py-1 rounded-xl text-xs font-bold border transition-all flex items-center gap-1 hover:scale-105 ${theme.badgeBg}`}
              >
                <span>{theme.emoji}</span>
                <span>{char}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Timeline Ordered Cards */}
      <div className="space-y-4 relative">
        {beats.map((beat, idx) => (
          <div key={beat.id || idx} className="relative group">
            {/* Timeline Connecting Line */}
            {idx < beats.length - 1 && (
              <div className="absolute left-8 top-full h-4 w-0.5 bg-gradient-to-b from-purple-500/50 to-transparent z-0" />
            )}

            <StoryBeatCard
              beat={beat}
              index={idx}
              totalBeats={beats.length}
              onUpdate={(updated) => handleUpdateBeat(idx, updated)}
              onMoveUp={() => handleMoveUp(idx)}
              onMoveDown={() => handleMoveDown(idx)}
              onDuplicate={() => handleDuplicate(idx)}
              onDelete={() => handleDelete(idx)}
            />
          </div>
        ))}
      </div>

      {/* Append New Beat Button */}
      <button
        type="button"
        onClick={() => handleAddBeat("Parrot")}
        className="w-full py-3.5 rounded-2xl border border-dashed border-purple-500/40 hover:border-purple-400 bg-purple-500/5 hover:bg-purple-500/10 text-purple-300 hover:text-white font-bold text-xs transition-all flex items-center justify-center gap-2 cursor-pointer shadow-sm"
      >
        <Plus className="w-4 h-4" />
        <span>Append Next Dialogue Beat</span>
      </button>

      {/* Live Narrative Dialogue Playback Simulator */}
      {beats.length > 0 && (
        <div className="p-5 rounded-2xl bg-gradient-to-b from-[#15103A] to-[#0D0B26] border border-purple-500/30 space-y-4 shadow-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-amber-400" />
              <h4 className="text-xs font-bold text-white">Live Story Dialogue Simulator</h4>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-[10px] text-slate-400 font-mono">
                Beat {activePreviewIdx + 1} of {beats.length}
              </span>
              <div className="flex items-center gap-1">
                <button
                  type="button"
                  disabled={activePreviewIdx === 0}
                  onClick={() => setActivePreviewIdx((p) => Math.max(0, p - 1))}
                  className="px-2 py-0.5 rounded bg-slate-800 hover:bg-slate-700 text-xs text-white disabled:opacity-30"
                >
                  ◀
                </button>
                <button
                  type="button"
                  disabled={activePreviewIdx >= beats.length - 1}
                  onClick={() => setActivePreviewIdx((p) => Math.min(beats.length - 1, p + 1))}
                  className="px-2 py-0.5 rounded bg-slate-800 hover:bg-slate-700 text-xs text-white disabled:opacity-30"
                >
                  ▶
                </button>
              </div>
            </div>
          </div>

          {/* Active Dialogue Bubble Presentation */}
          {beats[activePreviewIdx] && (
            (() => {
              const current = beats[activePreviewIdx];
              const theme = CHARACTER_THEMES[current.speaker] || CHARACTER_THEMES.Parrot;

              return (
                <div className="p-4 rounded-2xl bg-black/40 border border-white/10 flex items-start gap-4">
                  {/* Speaker Avatar Circle */}
                  <div
                    className={`w-12 h-12 rounded-2xl flex items-center justify-center text-2xl border-2 flex-shrink-0 shadow-lg ${theme.cardBg} ${theme.avatarBorder}`}
                  >
                    {theme.emoji}
                  </div>

                  {/* Speech Bubble */}
                  <div className="flex-1 space-y-1.5">
                    <div className="flex items-center gap-2">
                      <span className={`text-xs font-bold ${theme.textColor}`}>
                        {theme.name}
                      </span>
                      {current.hasInteractiveGate && (
                        <span className="text-[9px] font-bold px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 flex items-center gap-1">
                          <ShieldCheck className="w-2.5 h-2.5" />
                          <span>Interactive Checkpoint</span>
                        </span>
                      )}
                    </div>

                    <p className="text-xs text-white leading-relaxed font-sans bg-[#120E33] p-3 rounded-xl border border-slate-800 shadow-inner">
                      {current.dialogueText || (
                        <span className="italic text-slate-500">
                          (No dialogue typed yet for this beat...)
                        </span>
                      )}
                    </p>

                    {/* Gate Question Preview */}
                    {current.hasInteractiveGate && current.gateQuestion && (
                      <div className="mt-2 p-2.5 rounded-lg bg-emerald-950/40 border border-emerald-500/30 text-[11px] space-y-1">
                        <span className="font-bold text-emerald-300 block">
                          🔒 Gate Question: {current.gateQuestion}
                        </span>
                        <div className="flex flex-wrap gap-1.5 pt-1">
                          {current.gateOptions?.map((opt, oIdx) => (
                            <span
                              key={oIdx}
                              className={`text-[10px] px-2 py-0.5 rounded ${
                                current.gateCorrectIndex === oIdx
                                  ? "bg-emerald-500 text-black font-bold"
                                  : "bg-slate-800 text-slate-300"
                              }`}
                            >
                              {opt}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              );
            })()
          )}
        </div>
      )}
    </div>
  );
}
