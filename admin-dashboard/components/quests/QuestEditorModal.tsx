"use client";

import React, { useState, useEffect } from "react";
import { StoryQuest, StoryBeat } from "@/types";
import StorySequenceTimeline from "./StorySequenceTimeline";
import LiveJsonPreviewer from "@/components/games/LiveJsonPreviewer";
import { X, Loader2, Sparkles, BookOpen, Compass, CheckCircle2 } from "lucide-react";

interface QuestEditorModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (quest: Omit<StoryQuest, "id">) => Promise<void>;
  initialData?: StoryQuest | null;
  loading?: boolean;
}

const DEFAULT_STORY_BEATS: StoryBeat[] = [
  {
    id: "beat_1",
    speaker: "Parrot",
    dialogueText: "ආයුබෝවන් යාලුවනේ! අද අපි ගණිත වික්‍රමයේ 1 වන පරිච්ඡේදය ආරම්භ කරමු!",
    hasInteractiveGate: false,
  },
  {
    id: "beat_2",
    speaker: "Leo",
    dialogueText: "මම සූදානම් ගුරු පක්ෂිය තුමනි! අපිට අද හමුවන ප්‍රධාන අභියෝගය මොකක්ද?",
    hasInteractiveGate: false,
  },
  {
    id: "beat_3",
    speaker: "Ella",
    dialogueText: "අපිට දහස් සහ දස දහස් ස්ථානීය අගයන් නිවැරදිව හඳුනාගන්න වෙනවා.",
    hasInteractiveGate: true,
    gateQuestion: "1,000 සංඛ්‍යාවේ ශුන්‍ය (0) කීයක් තිබේද?",
    gateOptions: ["2 ක්", "3 ක්", "4 ක්", "5 ක්"],
    gateCorrectIndex: 1,
  },
];

export default function QuestEditorModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  loading = false,
}: QuestEditorModalProps) {
  const [title, setTitle] = useState("");
  const [conceptId, setConceptId] = useState("c1_place_value_intro");
  const [chapterNumber, setChapterNumber] = useState<number>(1);
  const [status, setStatus] = useState<"draft" | "published">("published");
  const [storySequence, setStorySequence] = useState<StoryBeat[]>(DEFAULT_STORY_BEATS);

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setConceptId(initialData.conceptId || "c1_place_value_intro");
      setChapterNumber(Number(initialData.chapterNumber) || 1);
      setStatus(initialData.status || "published");
      setStorySequence(
        initialData.storySequence && initialData.storySequence.length > 0
          ? initialData.storySequence
          : DEFAULT_STORY_BEATS
      );
    } else {
      setTitle("පරිච්ඡේදය 1: ස්ථානීය අගය රාජධානිය (Place Value Kingdom)");
      setConceptId("c1_place_value_intro");
      setChapterNumber(1);
      setStatus("published");
      setStorySequence(DEFAULT_STORY_BEATS);
    }
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSave({
      title: title.trim(),
      conceptId: conceptId.trim(),
      chapterNumber: Number(chapterNumber) || 1,
      status,
      grade: 5,
      storySequence,
    });
  };

  const payloadForPreview = {
    title: title.trim(),
    conceptId: conceptId.trim(),
    chapterNumber: Number(chapterNumber) || 1,
    status,
    grade: 5,
    beatsCount: storySequence.length,
    storySequence,
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
              🗺️
            </div>
            <div>
              <h2 className="text-base font-bold text-white">
                {initialData ? "Edit Story Quest Narrative" : "Create Story Quest Narrative"}
              </h2>
              <p className="text-xs text-slate-400">
                Design conversational story beats, character dialogues, and interactive gates
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
            {/* Left Column: Form Controls & Timeline (7 cols) */}
            <div className="lg:col-span-7 space-y-6">
              {/* Metadata Box */}
              <div className="p-5 rounded-2xl glass-card border border-slate-800 space-y-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <label className="text-xs font-bold text-white uppercase tracking-wider">
                    Story Quest Parameters
                  </label>

                  {/* Status Toggle Switch */}
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
                    Quest Title (පරිච්ඡේද නාමය)
                  </label>
                  <input
                    type="text"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    required
                    placeholder="e.g. පරිච්ඡේදය 1: ස්ථානීය අගය රාජධානිය"
                    className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                      Chapter Number
                    </label>
                    <input
                      type="number"
                      value={chapterNumber}
                      onChange={(e) => setChapterNumber(Number(e.target.value))}
                      min={1}
                      max={50}
                      className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
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
                      placeholder="e.g. c1_place_value_intro"
                      className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
                    />
                  </div>
                </div>
              </div>

              {/* Story Sequence Timeline */}
              <div className="p-5 rounded-2xl glass-card border border-purple-500/20">
                <StorySequenceTimeline
                  beats={storySequence}
                  onChange={setStorySequence}
                />
              </div>
            </div>

            {/* Right Column: Live JSON Payload Preview (5 cols) */}
            <div className="lg:col-span-5 flex flex-col space-y-4">
              <div className="sticky top-0">
                <LiveJsonPreviewer
                  data={payloadForPreview}
                  title="Firestore Live Payload (story_quests)"
                />
              </div>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="flex items-center justify-between px-6 py-4 border-t border-slate-800 bg-[#120E33] flex-shrink-0">
            <div className="flex items-center gap-2 text-xs text-slate-400">
              <span className="w-2 h-2 rounded-full bg-purple-500 animate-pulse" />
              <span>Saves directly to Firestore collection: <code className="text-purple-300 font-mono">story_quests</code></span>
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
                    <span>Saving Quest...</span>
                  </>
                ) : (
                  <>
                    <Sparkles className="w-4 h-4" />
                    <span>{initialData ? "Update Story Quest" : "Publish Story Quest"}</span>
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
