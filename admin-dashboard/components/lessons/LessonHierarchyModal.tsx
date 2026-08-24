"use client";

import React, { useState, useEffect } from "react";
import { LessonModule, LessonConcept, ExerciseStep } from "@/types";
import ConceptEditorModal from "./ConceptEditorModal";
import QuestionModal from "./QuestionModal";
import {
  X,
  Loader2,
  Sparkles,
  BookOpen,
  Layers,
  Plus,
  Trash2,
  Edit2,
  HelpCircle,
  Lightbulb,
  CheckCircle2,
  ChevronDown,
  ChevronUp,
} from "lucide-react";

interface LessonHierarchyModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (lesson: Omit<LessonModule, "id">) => Promise<void>;
  initialData?: LessonModule | null;
  loading?: boolean;
}

export default function LessonHierarchyModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  loading = false,
}: LessonHierarchyModalProps) {
  const [title, setTitle] = useState("");
  const [lessonNumber, setLessonNumber] = useState<number>(1);
  const [description, setDescription] = useState("");
  const [conceptId, setConceptId] = useState("");
  const [status, setStatus] = useState<"draft" | "published">("published");
  const [concepts, setConcepts] = useState<LessonConcept[]>([]);

  // Concept Modal State
  const [conceptModalOpen, setConceptModalOpen] = useState(false);
  const [editingConceptIdx, setEditingConceptIdx] = useState<number | null>(null);

  // Question Modal State
  const [questionModalOpen, setQuestionModalOpen] = useState(false);
  const [targetConceptIdx, setTargetConceptIdx] = useState<number | null>(null);
  const [editingQuestionIdx, setEditingQuestionIdx] = useState<number | null>(null);

  // Expanded Concept in UI
  const [expandedConceptIdx, setExpandedConceptIdx] = useState<number | null>(0);

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setLessonNumber(initialData.lessonNumber || 1);
      setDescription(initialData.description || "");
      setConceptId(initialData.conceptId || "");
      setStatus(initialData.status || "published");
      setConcepts(initialData.concepts || []);
    } else {
      setTitle("පාඩම: නව ගණිත පාඩම");
      setLessonNumber(3);
      setDescription("Grade 5 Scholarship curriculum interactive lesson module");
      setConceptId("lesson_concept_id");
      setStatus("published");
      setConcepts([]);
    }
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSave({
      title: title.trim(),
      lessonNumber: Number(lessonNumber) || 1,
      description: description.trim(),
      conceptId: conceptId.trim(),
      status,
      grade: 5,
      concepts,
    });
  };

  // ─── CONCEPT HANDLERS ─────────────────────────────────────────────────────
  const handleSaveConcept = (saved: LessonConcept) => {
    if (editingConceptIdx !== null) {
      const updated = [...concepts];
      updated[editingConceptIdx] = saved;
      setConcepts(updated);
    } else {
      setConcepts([...concepts, saved]);
    }
    setEditingConceptIdx(null);
  };

  const handleDeleteConcept = (index: number) => {
    setConcepts(concepts.filter((_, i) => i !== index));
    if (expandedConceptIdx === index) setExpandedConceptIdx(null);
  };

  // ─── QUESTION HANDLERS ────────────────────────────────────────────────────
  const handleSaveQuestion = (savedQuestion: ExerciseStep) => {
    if (targetConceptIdx === null) return;
    const updatedConcepts = [...concepts];
    const concept = { ...updatedConcepts[targetConceptIdx] };
    const questions = [...(concept.questions || [])];

    if (editingQuestionIdx !== null) {
      questions[editingQuestionIdx] = savedQuestion;
    } else {
      questions.push(savedQuestion);
    }

    concept.questions = questions;
    updatedConcepts[targetConceptIdx] = concept;
    setConcepts(updatedConcepts);

    setTargetConceptIdx(null);
    setEditingQuestionIdx(null);
  };

  const handleDeleteQuestion = (cIdx: number, qIdx: number) => {
    const updatedConcepts = [...concepts];
    const concept = { ...updatedConcepts[cIdx] };
    concept.questions = concept.questions.filter((_, i) => i !== qIdx);
    updatedConcepts[cIdx] = concept;
    setConcepts(updatedConcepts);
  };

  const totalQuestionsInLesson = concepts.reduce(
    (sum, c) => sum + (c.questions?.length || 0),
    0
  );

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      <div className="fixed inset-0 bg-black/80 backdrop-blur-md" onClick={() => !loading && onClose()} />

      <div className="relative w-full max-w-5xl bg-[#16123D] border border-purple-500/30 rounded-3xl shadow-2xl overflow-hidden z-10 my-6 max-h-[92vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-800 bg-[#120E33] flex-shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-purple-600/20 border border-purple-500/30 flex items-center justify-center text-xl">
              📚
            </div>
            <div>
              <h2 className="text-base font-bold text-white">
                {initialData ? "Edit Lesson & Concepts Hierarchy" : "Create New Lesson with Concepts"}
              </h2>
              <p className="text-xs text-slate-400">
                Each lesson contains 5 to 6 concepts with 6 questions per concept (3-attempt hints)
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

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-6">
          {/* Metadata Section */}
          <div className="p-5 rounded-2xl glass-card border border-slate-800 space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <label className="text-xs font-bold text-white uppercase tracking-wider">
                Lesson Overview
              </label>

              {/* Status Switch */}
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

            <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
              <div className="sm:col-span-3">
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                  Lesson Title (පාඩම් මාතෘකාව)
                </label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                  placeholder="e.g. පාඩම 1: රන් අඹ ගෙඩිය සොයා ගමන"
                  className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                  Lesson #
                </label>
                <input
                  type="number"
                  value={lessonNumber}
                  onChange={(e) => setLessonNumber(Number(e.target.value))}
                  min={1}
                  max={50}
                  className="w-full p-2.5 rounded-xl glass-input text-xs font-mono focus:outline-none"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                Description & Syllabus Scope
              </label>
              <input
                type="text"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="e.g. 99,999 දක්වා සංඛ්‍යා කියවීම, ලිවීම, ස්ථානීය අගය සහ විස්තාරිත ආකාරය"
                className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
              />
            </div>
          </div>

          {/* Concepts & Questions Hierarchy Section */}
          <div className="space-y-4">
            <div className="flex flex-wrap items-center justify-between gap-3 pb-2 border-b border-slate-800">
              <div>
                <h3 className="text-xs font-bold text-white uppercase tracking-wider">
                  Concepts in this Lesson ({concepts.length} Concepts • {totalQuestionsInLesson} Questions)
                </h3>
                <p className="text-[11px] text-slate-400">
                  Each concept contains learning goals and 6 interactive questions with 3-attempt hints
                </p>
              </div>

              <button
                type="button"
                onClick={() => {
                  setEditingConceptIdx(null);
                  setConceptModalOpen(true);
                }}
                className="px-3.5 py-1.5 rounded-xl bg-purple-600 hover:bg-purple-500 text-white font-bold text-xs transition-all flex items-center gap-1.5 shadow-md shadow-purple-600/30 cursor-pointer"
              >
                <Plus className="w-4 h-4" />
                <span>Add Concept</span>
              </button>
            </div>

            {/* Concepts Accordion List */}
            {concepts.length === 0 ? (
              <div className="p-8 rounded-2xl bg-black/20 border border-dashed border-purple-500/30 text-center space-y-2">
                <Layers className="w-8 h-8 text-purple-400 mx-auto opacity-60" />
                <h4 className="text-xs font-bold text-white">No Concepts Added Yet</h4>
                <p className="text-[11px] text-slate-400 max-w-sm mx-auto">
                  Click &ldquo;Add Concept&rdquo; above to structure this lesson with 5/6 concepts and their 6 questions.
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {concepts.map((concept, cIdx) => {
                  const isExpanded = expandedConceptIdx === cIdx;
                  const qCount = concept.questions?.length || 0;

                  return (
                    <div
                      key={concept.id || cIdx}
                      className="rounded-2xl border border-purple-500/20 bg-[#120E33] overflow-hidden shadow-lg"
                    >
                      {/* Concept Header Row */}
                      <div className="p-4 flex items-center justify-between gap-3 bg-white/[0.02]">
                        <div
                          className="flex items-center gap-3 flex-1 cursor-pointer"
                          onClick={() => setExpandedConceptIdx(isExpanded ? null : cIdx)}
                        >
                          <div className="w-7 h-7 rounded-lg bg-purple-500/20 border border-purple-500/40 flex items-center justify-center text-xs font-bold text-purple-300 font-mono">
                            C{cIdx + 1}
                          </div>
                          <div>
                            <div className="flex items-center gap-2">
                              <h4 className="text-xs font-bold text-white">{concept.title}</h4>
                              <span className="text-[10px] px-2 py-0.2 rounded bg-purple-950/60 text-purple-300 border border-purple-500/30 font-bold">
                                {qCount} / 6 Questions
                              </span>
                            </div>
                            <p className="text-[10px] text-slate-400 line-clamp-1 mt-0.5">
                              {concept.learningObjective || concept.subtitle}
                            </p>
                          </div>
                        </div>

                        {/* Concept Action Controls */}
                        <div className="flex items-center gap-1.5">
                          <button
                            type="button"
                            onClick={() => {
                              setEditingConceptIdx(cIdx);
                              setConceptModalOpen(true);
                            }}
                            className="p-1.5 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white transition-colors"
                          >
                            <Edit2 className="w-3.5 h-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() => handleDeleteConcept(cIdx)}
                            className="p-1.5 rounded-lg bg-rose-500/20 hover:bg-rose-500/40 text-rose-300 transition-colors"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() => setExpandedConceptIdx(isExpanded ? null : cIdx)}
                            className="p-1.5 rounded-lg bg-slate-800 text-slate-400 hover:text-white"
                          >
                            {isExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                          </button>
                        </div>
                      </div>

                      {/* Expanded Questions View for this Concept */}
                      {isExpanded && (
                        <div className="p-4 border-t border-slate-800 bg-black/20 space-y-3">
                          <div className="flex items-center justify-between pb-1">
                            <span className="text-[11px] font-bold text-purple-200">
                              Questions in {concept.title}:
                            </span>

                            <button
                              type="button"
                              onClick={() => {
                                setTargetConceptIdx(cIdx);
                                setEditingQuestionIdx(null);
                                setQuestionModalOpen(true);
                              }}
                              className="px-2.5 py-1 rounded-lg bg-emerald-600/30 hover:bg-emerald-600/50 border border-emerald-500/40 text-emerald-300 text-xs font-bold transition-all flex items-center gap-1"
                            >
                              <Plus className="w-3.5 h-3.5" />
                              <span>Add Question</span>
                            </button>
                          </div>

                          {/* Question Cards List */}
                          {(!concept.questions || concept.questions.length === 0) ? (
                            <p className="text-[11px] text-slate-500 italic p-3 text-center">
                              No questions configured yet for this concept. Click &ldquo;Add Question&rdquo; to add up to 6 questions with 3-attempt hints.
                            </p>
                          ) : (
                            <div className="space-y-2">
                              {concept.questions.map((q, qIdx) => (
                                <div
                                  key={q.id || qIdx}
                                  className="p-3 rounded-xl bg-[#16123D] border border-purple-500/20 flex items-start justify-between gap-3 shadow"
                                >
                                  <div className="flex items-start gap-2.5">
                                    <span className="text-[10px] font-mono font-bold px-1.5 py-0.5 rounded bg-purple-950 text-purple-300 border border-purple-500/30 mt-0.5">
                                      Q{qIdx + 1}
                                    </span>
                                    <div className="space-y-0.5">
                                      <p className="text-xs font-semibold text-white leading-tight">
                                        {q.questionText}
                                      </p>
                                      <div className="flex items-center gap-2 text-[10px] text-slate-400">
                                        <span className="text-emerald-400 font-bold">
                                          Answer: {String(q.correctAnswer)}
                                        </span>
                                        {q.hintLevel1 && (
                                          <span className="text-amber-300">💡 3-Attempt Hints Set</span>
                                        )}
                                      </div>
                                    </div>
                                  </div>

                                  <div className="flex items-center gap-1">
                                    <button
                                      type="button"
                                      onClick={() => {
                                        setTargetConceptIdx(cIdx);
                                        setEditingQuestionIdx(qIdx);
                                        setQuestionModalOpen(true);
                                      }}
                                      className="p-1 rounded-lg bg-black/30 hover:bg-black/50 text-slate-300 hover:text-white"
                                    >
                                      <Edit2 className="w-3 h-3" />
                                    </button>
                                    <button
                                      type="button"
                                      onClick={() => handleDeleteQuestion(cIdx, qIdx)}
                                      className="p-1 rounded-lg bg-rose-500/20 hover:bg-rose-500/40 text-rose-300"
                                    >
                                      <Trash2 className="w-3 h-3" />
                                    </button>
                                  </div>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Footer Actions */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-800">
            <button
              type="button"
              onClick={onClose}
              disabled={loading}
              className="px-4 py-2 rounded-xl text-xs font-semibold text-slate-300 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-purple-600 via-indigo-600 to-emerald-500 hover:from-purple-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-purple-600/30 transition-all flex items-center gap-2 cursor-pointer disabled:opacity-50"
            >
              {loading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  <span>Saving Lesson...</span>
                </>
              ) : (
                <>
                  <Sparkles className="w-4 h-4" />
                  <span>{initialData ? "Update Complete Lesson" : "Publish Lesson Module"}</span>
                </>
              )}
            </button>
          </div>
        </form>
      </div>

      {/* Sub-Modal: Concept Editor */}
      <ConceptEditorModal
        isOpen={conceptModalOpen}
        onClose={() => {
          setConceptModalOpen(false);
          setEditingConceptIdx(null);
        }}
        onSave={handleSaveConcept}
        initialData={editingConceptIdx !== null ? concepts[editingConceptIdx] : null}
        defaultOrder={editingConceptIdx !== null ? editingConceptIdx + 1 : concepts.length + 1}
      />

      {/* Sub-Modal: Question Editor */}
      <QuestionModal
        isOpen={questionModalOpen}
        onClose={() => {
          setQuestionModalOpen(false);
          setTargetConceptIdx(null);
          setEditingQuestionIdx(null);
        }}
        onSave={handleSaveQuestion}
        initialData={
          targetConceptIdx !== null && editingQuestionIdx !== null
            ? concepts[targetConceptIdx]?.questions?.[editingQuestionIdx]
            : null
        }
        conceptTitle={targetConceptIdx !== null ? concepts[targetConceptIdx]?.title : "Concept"}
      />
    </div>
  );
}
