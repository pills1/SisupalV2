"use client";

import React, { useState, useEffect } from "react";
import { LessonConcept } from "@/types";
import { X, Sparkles, BookOpen, Layers } from "lucide-react";

interface ConceptEditorModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (concept: LessonConcept) => void;
  initialData?: LessonConcept | null;
  defaultOrder?: number;
}

export default function ConceptEditorModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  defaultOrder = 1,
}: ConceptEditorModalProps) {
  const [title, setTitle] = useState("");
  const [conceptId, setConceptId] = useState("");
  const [subtitle, setSubtitle] = useState("");
  const [learningObjective, setLearningObjective] = useState("");
  const [orderIndex, setOrderIndex] = useState<number>(defaultOrder);

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setConceptId(initialData.conceptId || "");
      setSubtitle(initialData.subtitle || "");
      setLearningObjective(initialData.learningObjective || "");
      setOrderIndex(initialData.orderIndex || defaultOrder);
    } else {
      setTitle(`සංකල්පය ${defaultOrder}: නව සංකල්පය`);
      setConceptId(`c${defaultOrder}_concept_tag`);
      setSubtitle("");
      setLearningObjective("");
      setOrderIndex(defaultOrder);
    }
  }, [initialData, defaultOrder, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      id: initialData?.id || `concept_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      conceptId: conceptId.trim(),
      title: title.trim(),
      subtitle: subtitle.trim(),
      learningObjective: learningObjective.trim(),
      orderIndex: Number(orderIndex) || defaultOrder,
      questions: initialData?.questions || [],
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      <div className="fixed inset-0 bg-black/80 backdrop-blur-md" onClick={onClose} />

      <div className="relative w-full max-w-2xl bg-[#16123D] border border-purple-500/30 rounded-3xl shadow-2xl overflow-hidden z-10 my-6 flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-800 bg-[#120E33]">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-purple-600/20 border border-purple-500/30 flex items-center justify-center text-xl">
              🎯
            </div>
            <div>
              <h2 className="text-base font-bold text-white">
                {initialData ? "Edit Curriculum Concept" : "Add New Concept to Lesson"}
              </h2>
              <p className="text-xs text-slate-400">
                Concepts group 6 progressive exercise questions and learning goals
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Concept Title (සංකල්ප නාමය)
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              placeholder="e.g. සංකල්පය 1: අංක කැලෑ සිතියම"
              className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                Concept ID Key (e.g. c1_jungle_map)
              </label>
              <input
                type="text"
                value={conceptId}
                onChange={(e) => setConceptId(e.target.value)}
                required
                placeholder="c1_concept_id"
                className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                Order Position (#)
              </label>
              <input
                type="number"
                value={orderIndex}
                onChange={(e) => setOrderIndex(Number(e.target.value))}
                min={1}
                max={20}
                className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Subtitle / Concept Focus
            </label>
            <input
              type="text"
              value={subtitle}
              onChange={(e) => setSubtitle(e.target.value)}
              placeholder="e.g. 9,999 දක්වා සංඛ්‍යා කියවීම හා ලිවීම"
              className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Learning Objective (ඉගෙනුම් ඵලය)
            </label>
            <textarea
              value={learningObjective}
              onChange={(e) => setLearningObjective(e.target.value)}
              rows={3}
              placeholder="e.g. 9,999 දක්වා සංඛ්‍යා නිවැරදිව කියවීම සහ ලිවීම හඳුනාගැනීම"
              className="w-full p-3 rounded-xl glass-input text-xs leading-relaxed focus:outline-none"
            />
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
              Save Concept
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
