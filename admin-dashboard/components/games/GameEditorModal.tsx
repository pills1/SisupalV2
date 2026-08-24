"use client";

import React, { useState, useEffect } from "react";
import {
  MathGameBase,
  GameTemplateType,
  GameTemplateStatus,
  MathGameData,
} from "@/types";
import AbacusForm from "./AbacusForm";
import LilyPadForm from "./LilyPadForm";
import PlaceholderGameForm from "./PlaceholderGameForm";
import LiveJsonPreviewer from "./LiveJsonPreviewer";
import {
  X,
  Loader2,
  Gamepad2,
  Sparkles,
  Layers,
  CheckCircle2,
  Binary,
  Target,
  Award,
  Compass,
  Zap,
} from "lucide-react";

interface GameEditorModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (game: Omit<MathGameBase, "id">) => Promise<void>;
  initialData?: MathGameBase | null;
  loading?: boolean;
}

const TEMPLATE_TYPES: {
  id: GameTemplateType;
  title: string;
  emoji: string;
  badge: string;
  desc: string;
}[] = [
  {
    id: "abacus",
    title: "Abacus Bead Match",
    emoji: "🧮",
    badge: "Fully Configurable",
    desc: "4 or 5-digit rod place value counter challenge",
  },
  {
    id: "lily_pad_leap",
    title: "Lily Pad Leap",
    emoji: "🐸",
    badge: "Fully Configurable",
    desc: "Frog jumping pattern & sequence puzzle",
  },
  {
    id: "place_value",
    title: "Place Value Hunter",
    emoji: "🎯",
    badge: "Template Ready",
    desc: "Find value of underlined digits in large numbers",
  },
  {
    id: "number_archery",
    title: "Number Archery",
    emoji: "🏹",
    badge: "Template Ready",
    desc: "Hit targets using mathematical equation arrows",
  },
  {
    id: "digit_builder",
    title: "Digit Builder",
    emoji: "🧩",
    badge: "Template Ready",
    desc: "Form highest or lowest numbers with digit cards",
  },
  {
    id: "expanded_form",
    title: "Expanded Form",
    emoji: "📐",
    badge: "Template Ready",
    desc: "Deconstruct numbers into standard expanded parts",
  },
  {
    id: "rapid_fire",
    title: "Rapid Fire Blitz",
    emoji: "⚡",
    badge: "Template Ready",
    desc: "Speed-math arithmetic timer challenge",
  },
];

export default function GameEditorModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  loading = false,
}: GameEditorModalProps) {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [templateType, setTemplateType] = useState<GameTemplateType>("abacus");
  const [status, setStatus] = useState<GameTemplateStatus>("published");
  const [gameData, setGameData] = useState<MathGameData>({});

  // Reset or populate state when opening modal
  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setDescription(initialData.description || "");
      setTemplateType(initialData.templateType || "abacus");
      setStatus(initialData.status || "published");
      setGameData(initialData.gameData || {});
    } else {
      setTitle("5 ශ්‍රේණිය අබාකස් ස්ථානීය අගය පුහුණුව");
      setDescription("ස්ථානීය අගය හඳුනාගැනීම සඳහා අබාකස් රාමුව භාවිතයෙන් සංඛ්‍යා සෑදීම.");
      setTemplateType("abacus");
      setStatus("published");
      setGameData({
        targetNumber: 5421,
        placeValues: ["දහස්", "සිය", "දහය", "එකක"],
        instruction: "අබාකස් රාමුවේ පබළු ගණනය කර නිවැරදි සංඛ්‍යාව සාදන්න.",
        maxBeadsPerRod: 9,
        allowDragDrop: true,
      });
    }
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSave({
      title: title.trim(),
      description: description.trim(),
      templateType,
      status,
      grade: 5,
      gameData,
    });
  };

  const payloadForPreview = {
    title: title.trim(),
    description: description.trim(),
    templateType,
    status,
    grade: 5,
    gameData,
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/80 backdrop-blur-md transition-opacity"
        onClick={() => !loading && onClose()}
      />

      {/* Modal Dialog */}
      <div className="relative w-full max-w-6xl bg-[#16123D] border border-purple-500/30 rounded-3xl shadow-2xl overflow-hidden z-10 my-6 max-h-[92vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-800 bg-[#120E33] flex-shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-purple-600/20 border border-purple-500/30 flex items-center justify-center text-xl">
              🎮
            </div>
            <div>
              <h2 className="text-base font-bold text-white">
                {initialData ? "Edit Mini-Game Configuration" : "Create Math Mini-Game"}
              </h2>
              <p className="text-xs text-slate-400">
                Configure game mechanics, target rules, and live payload for SisuPal student app
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

        {/* Scrollable Form Body with Split Layout */}
        <form onSubmit={handleSubmit} className="flex-1 flex flex-col overflow-hidden">
          <div className="flex-1 overflow-y-auto p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
            {/* Left Column: Form Controls (7 cols) */}
            <div className="lg:col-span-7 space-y-6">
              {/* Game Title & Status Switch */}
              <div className="space-y-4 p-5 rounded-2xl glass-card border border-slate-800">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <label className="text-xs font-bold text-white uppercase tracking-wider">
                    Basic Game Metadata
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
                    Game Title
                  </label>
                  <input
                    type="text"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    required
                    placeholder="e.g. 5 ශ්‍රේණිය අබාකස් ස්ථානීය අගය පුහුණුව"
                    className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                    Description / Learning Objective
                  </label>
                  <input
                    type="text"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="e.g. ස්ථානීය අගය හඳුනාගැනීම සඳහා අබාකස් රාමුව භාවිතයෙන් සංඛ්‍යා සෑදීම."
                    className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
                  />
                </div>
              </div>

              {/* Template Type Selector */}
              <div className="space-y-3">
                <label className="block text-xs font-bold text-white uppercase tracking-wider">
                  Select Game Engine Template ({TEMPLATE_TYPES.length} Engines)
                </label>

                <div className="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
                  {TEMPLATE_TYPES.map((t) => {
                    const isSelected = templateType === t.id;
                    return (
                      <button
                        key={t.id}
                        type="button"
                        onClick={() => {
                          setTemplateType(t.id);
                          // Initialize default data structure for selected template
                          if (t.id === "abacus") {
                            setGameData({
                              targetNumber: 5421,
                              placeValues: ["දහස්", "සිය", "දහය", "එකක"],
                              instruction: "අබාකස් රාමුවේ පබළු ගණනය කර නිවැරදි සංඛ්‍යාව සාදන්න.",
                            });
                          } else if (t.id === "lily_pad_leap") {
                            setGameData({
                              sequence: [12, 24, null, 48, 60],
                              missingIndex: 2,
                              correctAnswer: 36,
                              distractorOptions: [30, 32, 40],
                              ruleDescription: "12 ගුණාකාර රටාව (+12)",
                              timeLimitSeconds: 30,
                            });
                          }
                        }}
                        className={`p-3 rounded-2xl border text-left transition-all relative ${
                          isSelected
                            ? "bg-gradient-to-tr from-purple-600/40 to-indigo-600/30 border-purple-500 shadow-lg shadow-purple-900/30 scale-[1.02]"
                            : "bg-[#120E33] border-slate-800 hover:border-slate-700"
                        }`}
                      >
                        <div className="flex items-center justify-between mb-1">
                          <span className="text-xl">{t.emoji}</span>
                          {isSelected && (
                            <CheckCircle2 className="w-4 h-4 text-purple-400" />
                          )}
                        </div>
                        <h4 className="text-xs font-bold text-white">{t.title}</h4>
                        <p className="text-[10px] text-slate-400 line-clamp-1 mt-0.5">{t.desc}</p>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Dynamic Game Form Section */}
              <div className="p-5 rounded-2xl glass-card border border-purple-500/20 space-y-4">
                <div className="flex items-center justify-between pb-3 border-b border-slate-800">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-white">Engine Configuration:</span>
                    <span className="text-xs font-mono text-purple-300 font-semibold uppercase">
                      {templateType}
                    </span>
                  </div>
                  <span className="text-[10px] text-emerald-400 font-bold bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-500/30">
                    Grade 5 Scholarship
                  </span>
                </div>

                {templateType === "abacus" && (
                  <AbacusForm data={gameData as any} onChange={setGameData} />
                )}

                {templateType === "lily_pad_leap" && (
                  <LilyPadForm data={gameData as any} onChange={setGameData} />
                )}

                {templateType !== "abacus" && templateType !== "lily_pad_leap" && (
                  <PlaceholderGameForm
                    templateType={templateType}
                    data={gameData}
                    onChange={setGameData}
                  />
                )}
              </div>
            </div>

            {/* Right Column: Live JSON Payload Preview (5 cols) */}
            <div className="lg:col-span-5 flex flex-col space-y-4">
              <div className="sticky top-0">
                <LiveJsonPreviewer
                  data={payloadForPreview}
                  title="Firestore Live Payload (math_games)"
                />
              </div>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="flex items-center justify-between px-6 py-4 border-t border-slate-800 bg-[#120E33] flex-shrink-0">
            <div className="flex items-center gap-2 text-xs text-slate-400">
              <span className="w-2 h-2 rounded-full bg-purple-500 animate-pulse" />
              <span>Saves directly to Firestore collection: <code className="text-purple-300 font-mono">math_games</code></span>
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
                    <span>Saving Game...</span>
                  </>
                ) : (
                  <>
                    <Sparkles className="w-4 h-4" />
                    <span>{initialData ? "Update Game Config" : "Publish Mini-Game"}</span>
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
