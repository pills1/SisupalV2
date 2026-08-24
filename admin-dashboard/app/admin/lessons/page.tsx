"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  fetchCollection,
  createDocument,
  setDocumentWithId,
  updateDocument,
  deleteDocument,
} from "@/lib/firestore-crud";
import { LessonModule, LessonConcept, ExerciseStep } from "@/types";
import { OFFICIAL_GRADE_5_LESSONS } from "@/lib/official-curriculum";
import { useToast } from "@/components/Toast";
import DataTable, { ColumnDef } from "@/components/DataTable";
import LessonHierarchyModal from "@/components/lessons/LessonHierarchyModal";
import QuestionModal from "@/components/lessons/QuestionModal";
import DeleteConfirmDialog from "@/components/DeleteConfirmDialog";
import {
  BookOpen,
  Plus,
  Sparkles,
  Layers,
  HelpCircle,
  Lightbulb,
  CheckCircle2,
  Clock,
  Award,
  Trash2,
  AlertTriangle,
  Loader2,
  ChevronDown,
  ChevronUp,
  RefreshCw,
  FolderOpen,
  Edit,
} from "lucide-react";

export default function InteractiveLessonsPage() {
  const { showToast } = useToast();

  // ─── DATA & UI STATES ─────────────────────────────────────────────────────
  const [rawLessons, setRawLessons] = useState<LessonModule[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [syncing, setSyncing] = useState(false);
  const [purging, setPurging] = useState(false);

  // ─── FILTER STATES ────────────────────────────────────────────────────────
  const [statusFilter, setStatusFilter] = useState<"all" | "draft" | "published">("all");
  const [expandedLessonId, setExpandedLessonId] = useState<string | null>(null);

  // ─── MODAL STATES ─────────────────────────────────────────────────────────
  const [editorOpen, setEditorOpen] = useState(false);
  const [editingLesson, setEditingLesson] = useState<LessonModule | null>(null);

  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [lessonToDelete, setLessonToDelete] = useState<LessonModule | null>(null);

  // ─── DATA FETCHING ────────────────────────────────────────────────────────
  const loadLessons = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchCollection<LessonModule>("math_lessons");
      // Sort by lessonNumber or title
      data.sort((a, b) => (a.lessonNumber ?? 0) - (b.lessonNumber ?? 0));
      setRawLessons(data);
    } catch (error) {
      console.error("Error fetching lessons:", error);
      showToast("Error loading interactive lessons from Firestore", "error");
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    loadLessons();
  }, [loadLessons]);

  // ─── DEDUPLICATION LOGIC ──────────────────────────────────────────────────
  const { uniqueLessons, duplicateDocs } = useMemo(() => {
    const seen = new Map<string, LessonModule>();
    const duplicates: LessonModule[] = [];

    for (const l of rawLessons) {
      const key = (l.conceptId || l.title || "").trim().toLowerCase();
      if (seen.has(key)) {
        duplicates.push(l);
      } else {
        seen.set(key, l);
      }
    }

    return {
      uniqueLessons: Array.from(seen.values()),
      duplicateDocs: duplicates,
    };
  }, [rawLessons]);

  // ─── SEED / SYNC OFFICIAL GRADE 5 CURRICULUM ──────────────────────────────
  const handleSyncOfficialCurriculum = async () => {
    setSyncing(true);
    try {
      // 1. Clean all existing old / duplicate documents to ensure a 100% clean state
      const currentDocs = await fetchCollection<LessonModule>("math_lessons");
      for (const l of currentDocs) {
        if (l.id) {
          await deleteDocument("math_lessons", l.id);
        }
      }

      // 2. Create the clean official Grade 5 Lessons with deterministic IDs (Lesson 1 & Lesson 2)
      for (const official of OFFICIAL_GRADE_5_LESSONS) {
        const { id, ...lessonPayload } = official;
        const docId = id || (official.lessonNumber === 1 ? "lesson_1_golden_mango" : "lesson_2_number_train");
        await setDocumentWithId("math_lessons", docId, {
          ...lessonPayload,
          grade: 5,
        });
      }

      showToast("Official SisuPal Grade 5 Curriculum Synced into Firestore! (2 Lessons • 10 Concepts • 60 Questions) 🚀", "success");
      await loadLessons();
    } catch (error) {
      console.error("Error syncing official curriculum into Firestore:", error);
      showToast("Failed to sync curriculum. Please ensure you are logged in as Admin.", "error");
    } finally {
      setSyncing(false);
    }
  };

  // ─── PURGE DUPLICATES FROM FIRESTORE ──────────────────────────────────────
  const handlePurgeDuplicates = async () => {
    setPurging(true);
    try {
      const currentDocs = await fetchCollection<LessonModule>("math_lessons");
      for (const docItem of currentDocs) {
        if (docItem.id) {
          await deleteDocument("math_lessons", docItem.id);
        }
      }

      for (const official of OFFICIAL_GRADE_5_LESSONS) {
        const { id, ...lessonPayload } = official;
        const docId = id || (official.lessonNumber === 1 ? "lesson_1_golden_mango" : "lesson_2_number_train");
        await setDocumentWithId("math_lessons", docId, {
          ...lessonPayload,
          grade: 5,
        });
      }

      showToast(`Cleaned legacy entries and synced 2 unique official lessons! 🧹✨`, "success");
      await loadLessons();
    } catch (error) {
      console.error("Error purging duplicate lessons:", error);
      showToast("Failed to remove duplicate lessons", "error");
    } finally {
      setPurging(false);
    }
  };

  // ─── SAVE LESSON HANDLER ──────────────────────────────────────────────────
  const handleSaveLesson = async (lessonData: Omit<LessonModule, "id">) => {
    setActionLoading(true);
    try {
      if (editingLesson?.id) {
        await updateDocument("math_lessons", editingLesson.id, lessonData);
        showToast("Lesson module and concept hierarchy updated! ✨", "success");
      } else {
        await createDocument("math_lessons", lessonData);
        showToast("New interactive lesson with concepts published! 🚀", "success");
      }
      setEditorOpen(false);
      setEditingLesson(null);
      await loadLessons();
    } catch (error) {
      console.error("Error saving lesson:", error);
      showToast("Failed to save lesson module", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── TOGGLE STATUS ────────────────────────────────────────────────────────
  const handleToggleStatus = async (lesson: LessonModule) => {
    if (!lesson.id) return;
    const newStatus = (lesson.status || "published") === "published" ? "draft" : "published";
    try {
      await updateDocument("math_lessons", lesson.id, { status: newStatus });
      showToast(`Lesson "${lesson.title}" set to ${newStatus.toUpperCase()}`, "info");
      await loadLessons();
    } catch (error) {
      console.error("Error toggling status:", error);
      showToast("Failed to toggle status", "error");
    }
  };

  // ─── DELETE EXECUTION ─────────────────────────────────────────────────────
  const handleConfirmDelete = async () => {
    if (!lessonToDelete?.id) return;
    setActionLoading(true);
    try {
      await deleteDocument("math_lessons", lessonToDelete.id);
      showToast(`Deleted "${lessonToDelete.title}" from Firestore`, "info");
      setDeleteDialogOpen(false);
      setLessonToDelete(null);
      await loadLessons();
    } catch (error) {
      console.error("Error deleting lesson:", error);
      showToast("Failed to delete lesson module", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── FILTERED LESSONS ─────────────────────────────────────────────────────
  const filteredLessons = useMemo(() => {
    return uniqueLessons.filter((l) => {
      if (statusFilter !== "all" && (l.status || "published") !== statusFilter) return false;
      return true;
    });
  }, [uniqueLessons, statusFilter]);

  // ─── TABLE COLUMNS ────────────────────────────────────────────────────────
  const columns: ColumnDef<LessonModule>[] = [
    {
      header: "Lesson & Curriculum Focus",
      cell: (l) => {
        const conceptsCount = l.concepts?.length || 0;
        const questionsCount =
          l.concepts?.reduce((s, c) => s + (c.questions?.length || 0), 0) ||
          l.exercises?.length ||
          0;

        return (
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-purple-500/20 border border-purple-500/30 flex items-center justify-center text-xl flex-shrink-0">
              📖
            </div>
            <div className="space-y-0.5 max-w-sm">
              <h4 className="font-bold text-white text-xs line-clamp-1">{l.title}</h4>
              <div className="flex items-center gap-2 text-[10px] text-slate-400">
                <span className="text-purple-300 font-bold">
                  {conceptsCount > 0 ? `${conceptsCount} Concepts` : "Standard Module"}
                </span>
                <span>•</span>
                <span className="text-emerald-300 font-bold">
                  {questionsCount} Questions (6 per concept)
                </span>
              </div>
            </div>
          </div>
        );
      },
    },
    {
      header: "Hierarchy Breakdown",
      className: "w-48 hidden sm:table-cell",
      cell: (l) => {
        const cCount = l.concepts?.length || 0;
        const qCount =
          l.concepts?.reduce((s, c) => s + (c.questions?.length || 0), 0) ||
          l.exercises?.length ||
          0;

        return (
          <div className="space-y-0.5">
            <span className="text-[11px] font-bold text-white flex items-center gap-1">
              <Layers className="w-3 h-3 text-purple-400" />
              <span>{cCount} Concept Modules</span>
            </span>
            <span className="text-[10px] text-emerald-400 font-semibold flex items-center gap-1">
              <CheckCircle2 className="w-3 h-3" />
              <span>{qCount} Scaffolds (3 Attempts)</span>
            </span>
          </div>
        );
      },
    },
    {
      header: "3-Attempt System",
      className: "w-36 text-center hidden md:table-cell",
      cell: () => (
        <span className="inline-flex items-center gap-1 text-[10px] font-bold px-2.5 py-1 rounded-full bg-amber-500/10 text-amber-300 border border-amber-500/30">
          <Lightbulb className="w-3 h-3" />
          <span>Active (3 Hints/Q)</span>
        </span>
      ),
    },
    {
      header: "Status",
      className: "w-32 text-center",
      cell: (l) => (
        <button
          onClick={() => handleToggleStatus(l)}
          title="Click to toggle status"
          className={`inline-flex items-center gap-1.5 text-[10px] font-bold px-3 py-1 rounded-full border transition-all hover:scale-105 cursor-pointer ${
            (l.status || "published") === "published"
              ? "bg-emerald-500/20 text-emerald-300 border-emerald-500/40 hover:bg-emerald-500/30 shadow-sm shadow-emerald-500/20"
              : "bg-slate-800 text-slate-400 border-slate-700 hover:bg-slate-700 hover:text-white"
          }`}
        >
          <span
            className={`w-2 h-2 rounded-full ${
              (l.status || "published") === "published" ? "bg-emerald-400 animate-pulse" : "bg-slate-500"
            }`}
          />
          <span className="uppercase">{l.status || "published"}</span>
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-800">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 border border-purple-500/30">
              Phase 4 Curriculum
            </span>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
              Lessons • Concepts • 6 Questions/Concept
            </span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight mt-1">
            Interactive Lessons & Concepts CMS
          </h1>
          <p className="text-xs text-slate-400">
            Manage Grade 5 mathematics lessons, 5/6 concepts per lesson, and 6 adaptive questions per concept
          </p>
        </div>

        <div className="flex items-center gap-2.5 flex-wrap">
          {/* Add New Lesson with Concepts */}
          <button
            onClick={() => {
              setEditingLesson(null);
              setEditorOpen(true);
            }}
            className="px-5 py-2.5 rounded-xl bg-gradient-to-r from-purple-600 via-indigo-600 to-amber-500 hover:from-purple-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-purple-600/30 transition-all flex items-center gap-2 w-fit cursor-pointer"
          >
            <Plus className="w-4 h-4" />
            <span>Add New Lesson</span>
          </button>
        </div>
      </div>

      {/* Duplicate Purge Banner */}
      {duplicateDocs.length > 0 && (
        <div className="p-4 rounded-2xl bg-gradient-to-r from-amber-950/40 to-rose-950/40 border border-amber-500/30 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-amber-500/20 text-amber-400 border border-amber-500/30">
              <AlertTriangle className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-bold text-white">
                Found {duplicateDocs.length} Duplicate Lesson Records in Database
              </h4>
              <p className="text-[11px] text-slate-400">
                The table below is automatically deduplicated to show the {uniqueLessons.length} unique interactive lessons.
              </p>
            </div>
          </div>

          <button
            onClick={handlePurgeDuplicates}
            disabled={purging}
            className="px-4 py-2 rounded-xl bg-rose-600/90 hover:bg-rose-500 text-white font-bold text-xs shadow-lg shadow-rose-600/20 transition-all flex items-center gap-2 flex-shrink-0 disabled:opacity-50 cursor-pointer"
          >
            {purging ? (
              <>
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
                <span>Removing {duplicateDocs.length} Duplicates...</span>
              </>
            ) : (
              <>
                <Trash2 className="w-3.5 h-3.5" />
                <span>Remove {duplicateDocs.length} Duplicate Entries</span>
              </>
            )}
          </button>
        </div>
      )}

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 p-1.5 rounded-2xl bg-[#120E33] border border-slate-800 w-fit">
        <button
          onClick={() => setStatusFilter("all")}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            statusFilter === "all"
              ? "bg-purple-600 text-white shadow-lg shadow-purple-600/30"
              : "text-slate-400 hover:text-white hover:bg-slate-800/40"
          }`}
        >
          All Lessons ({uniqueLessons.length})
        </button>
        <button
          onClick={() => setStatusFilter("published")}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 ${
            statusFilter === "published"
              ? "bg-emerald-600 text-white shadow-lg shadow-emerald-600/30"
              : "text-slate-400 hover:text-white hover:bg-slate-800/40"
          }`}
        >
          <CheckCircle2 className="w-3.5 h-3.5" />
          <span>Published ({uniqueLessons.filter((l) => (l.status || "published") === "published").length})</span>
        </button>
        <button
          onClick={() => setStatusFilter("draft")}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 ${
            statusFilter === "draft"
              ? "bg-amber-600 text-white shadow-lg shadow-amber-600/30"
              : "text-slate-400 hover:text-white hover:bg-slate-800/40"
          }`}
        >
          <Clock className="w-3.5 h-3.5" />
          <span>Drafts ({uniqueLessons.filter((l) => l.status === "draft").length})</span>
        </button>
      </div>

      {/* Main DataTable with Expandable Concept Hierarchy */}
      <DataTable<LessonModule>
        data={filteredLessons}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search lessons by title or concept ID..."
        searchFilter={(l, query) =>
          l.title.toLowerCase().includes(query) ||
          Boolean(l.conceptId && l.conceptId.toLowerCase().includes(query))
        }
        addLabel="New Lesson"
        onAdd={() => {
          setEditingLesson(null);
          setEditorOpen(true);
        }}
        onEdit={(l) => {
          setEditingLesson(l);
          setEditorOpen(true);
        }}
        onDelete={(l) => {
          setLessonToDelete(l);
          setDeleteDialogOpen(true);
        }}
        emptyTitle="No Lesson Modules Configured"
        emptySubtitle="Click 'Sync Official Curriculum' to load the full Grade 5 curriculum with 10 concepts and 60 questions."
      />

      {/* Comprehensive Lesson Hierarchy Editor Modal (Lesson -> Concepts -> 6 Questions) */}
      <LessonHierarchyModal
        isOpen={editorOpen}
        onClose={() => {
          setEditorOpen(false);
          setEditingLesson(null);
        }}
        onSave={handleSaveLesson}
        initialData={editingLesson}
        loading={actionLoading}
      />

      {/* Delete Confirmation Dialog */}
      <DeleteConfirmDialog
        isOpen={deleteDialogOpen}
        onClose={() => {
          setDeleteDialogOpen(false);
          setLessonToDelete(null);
        }}
        onConfirm={handleConfirmDelete}
        title="Delete Lesson Module"
        itemName={lessonToDelete?.title || "Lesson"}
        loading={actionLoading}
      />
    </div>
  );
}
