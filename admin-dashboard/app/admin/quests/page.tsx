"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  fetchCollection,
  createDocument,
  setDocumentWithId,
  updateDocument,
  deleteDocument,
} from "@/lib/firestore-crud";
import { StoryQuest } from "@/types";
import { OFFICIAL_STORY_QUESTS } from "@/lib/official-story-quests";
import { useToast } from "@/components/Toast";
import DataTable, { ColumnDef } from "@/components/DataTable";
import QuestEditorModal from "@/components/quests/QuestEditorModal";
import DeleteConfirmDialog from "@/components/DeleteConfirmDialog";
import {
  Compass,
  Plus,
  Sparkles,
  BookOpen,
  MessageSquare,
  ShieldCheck,
  CheckCircle2,
  Clock,
  Trash2,
  AlertTriangle,
  Loader2,
  RefreshCw,
} from "lucide-react";

export default function StoryQuestsPage() {
  const { showToast } = useToast();

  // ─── DATA & UI STATES ─────────────────────────────────────────────────────
  const [rawQuests, setRawQuests] = useState<StoryQuest[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [syncing, setSyncing] = useState(false);
  const [purging, setPurging] = useState(false);

  // ─── FILTER STATES ────────────────────────────────────────────────────────
  const [statusFilter, setStatusFilter] = useState<"all" | "draft" | "published">("all");

  // ─── MODAL STATES ─────────────────────────────────────────────────────────
  const [editorOpen, setEditorOpen] = useState(false);
  const [editingQuest, setEditingQuest] = useState<StoryQuest | null>(null);

  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [questToDelete, setQuestToDelete] = useState<StoryQuest | null>(null);

  // ─── DATA FETCHING (Robust without missing-field omit) ─────────────────────
  const loadQuests = useCallback(async () => {
    setLoading(true);
    try {
      // Fetch all docs without strict orderBy so docs without chapterNumber are never excluded
      const data = await fetchCollection<StoryQuest>("story_quests");
      // Sort client-side
      data.sort((a, b) => (a.chapterNumber ?? 0) - (b.chapterNumber ?? 0));
      setRawQuests(data);
    } catch (error) {
      console.error("Error fetching story quests:", error);
      showToast("Error loading story quests from Firestore", "error");
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    loadQuests();
  }, [loadQuests]);

  // ─── DEDUPLICATION LOGIC ──────────────────────────────────────────────────
  const { uniqueQuests, duplicateDocs } = useMemo(() => {
    const seen = new Map<string, StoryQuest>();
    const duplicates: StoryQuest[] = [];

    for (const q of rawQuests) {
      const key = (q.conceptId || q.title || "").trim().toLowerCase();
      if (seen.has(key)) {
        duplicates.push(q);
      } else {
        seen.set(key, q);
      }
    }

    return {
      uniqueQuests: Array.from(seen.values()),
      duplicateDocs: duplicates,
    };
  }, [rawQuests]);

  // ─── SYNC OFFICIAL STORY QUESTS (10 CONCEPTS • 41 DIALOGUES) ─────────────
  const handleSyncOfficialQuests = async () => {
    setSyncing(true);
    try {
      // 1. Clean all existing placeholder / duplicate documents
      const currentDocs = await fetchCollection<StoryQuest>("story_quests");
      for (const q of currentDocs) {
        if (q.id) {
          await deleteDocument("story_quests", q.id);
        }
      }

      // 2. Set the 10 official concept story quests with deterministic IDs
      for (const official of OFFICIAL_STORY_QUESTS) {
        const { id, ...questPayload } = official;
        const docId = id || `quest_${official.conceptId}`;
        await setDocumentWithId("story_quests", docId, {
          ...questPayload,
          grade: 5,
        });
      }

      showToast("Official Story Quests Synced into Firestore! (10 Chapters • 41 Dialogues) 🚀", "success");
      await loadQuests();
    } catch (error) {
      console.error("Error syncing story quests:", error);
      showToast("Failed to sync story quests. Please ensure you are logged in as Admin.", "error");
    } finally {
      setSyncing(false);
    }
  };

  // ─── PURGE DUPLICATES FROM FIRESTORE ──────────────────────────────────────
  const handlePurgeDuplicates = async () => {
    setPurging(true);
    try {
      const currentDocs = await fetchCollection<StoryQuest>("story_quests");
      for (const dup of currentDocs) {
        if (dup.id) {
          await deleteDocument("story_quests", dup.id);
        }
      }

      for (const official of OFFICIAL_STORY_QUESTS) {
        const { id, ...questPayload } = official;
        const docId = id || `quest_${official.conceptId}`;
        await setDocumentWithId("story_quests", docId, {
          ...questPayload,
          grade: 5,
        });
      }

      showToast(`Cleaned duplicates and synced 10 official story quests! 🧹✨`, "success");
      await loadQuests();
    } catch (error) {
      console.error("Error purging duplicates:", error);
      showToast("Failed to remove duplicate story quests", "error");
    } finally {
      setPurging(false);
    }
  };

  // ─── SAVE QUEST HANDLER ───────────────────────────────────────────────────
  const handleSaveQuest = async (questData: Omit<StoryQuest, "id">) => {
    setActionLoading(true);
    try {
      if (editingQuest?.id) {
        await updateDocument("story_quests", editingQuest.id, questData);
        showToast("Story quest narrative updated! ✨", "success");
      } else {
        await createDocument("story_quests", questData);
        showToast("New story quest published to students! 🚀", "success");
      }
      setEditorOpen(false);
      setEditingQuest(null);
      await loadQuests();
    } catch (error) {
      console.error("Error saving quest:", error);
      showToast("Failed to save story quest", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── TOGGLE STATUS ────────────────────────────────────────────────────────
  const handleToggleStatus = async (quest: StoryQuest) => {
    if (!quest.id) return;
    const newStatus = quest.status === "published" ? "draft" : "published";
    try {
      await updateDocument("story_quests", quest.id, { status: newStatus });
      showToast(`Quest "${quest.title}" set to ${newStatus.toUpperCase()}`, "info");
      await loadQuests();
    } catch (error) {
      console.error("Error toggling status:", error);
      showToast("Failed to toggle status", "error");
    }
  };

  // ─── DELETE EXECUTION ─────────────────────────────────────────────────────
  const handleConfirmDelete = async () => {
    if (!questToDelete?.id) return;
    setActionLoading(true);
    try {
      await deleteDocument("story_quests", questToDelete.id);
      showToast(`Deleted "${questToDelete.title}" from Firestore`, "info");
      setDeleteDialogOpen(false);
      setQuestToDelete(null);
      await loadQuests();
    } catch (error) {
      console.error("Error deleting quest:", error);
      showToast("Failed to delete story quest", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── FILTERED QUESTS ──────────────────────────────────────────────────────
  const filteredQuests = useMemo(() => {
    return uniqueQuests.filter((q) => {
      if (statusFilter !== "all" && q.status !== statusFilter) return false;
      return true;
    });
  }, [uniqueQuests, statusFilter]);

  // ─── TABLE COLUMNS ────────────────────────────────────────────────────────
  const columns: ColumnDef<StoryQuest>[] = [
    {
      header: "Chapter / Story Quest",
      cell: (q) => (
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-purple-500/20 border border-purple-500/30 flex items-center justify-center font-bold text-xs text-purple-200 flex-shrink-0">
            Ch {q.chapterNumber || 1}
          </div>
          <div className="space-y-0.5 max-w-sm">
            <h4 className="font-bold text-white text-xs line-clamp-1">{q.title}</h4>
            <span className="text-[10px] font-mono text-purple-300">
              Concept: {q.conceptId || "General"}
            </span>
          </div>
        </div>
      ),
    },
    {
      header: "Narrative Beats",
      className: "w-40 hidden sm:table-cell",
      cell: (q) => {
        const count = q.storySequence?.length || 0;
        const gatesCount = q.storySequence?.filter((b) => b.hasInteractiveGate).length || 0;

        return (
          <div className="space-y-0.5">
            <span className="text-[11px] font-bold text-white flex items-center gap-1">
              <MessageSquare className="w-3 h-3 text-purple-400" />
              <span>{count} Dialogues</span>
            </span>
            {gatesCount > 0 && (
              <span className="text-[10px] text-emerald-400 font-semibold flex items-center gap-1">
                <ShieldCheck className="w-3 h-3" />
                <span>{gatesCount} Interactive Gates</span>
              </span>
            )}
          </div>
        );
      },
    },
    {
      header: "Grade",
      className: "w-24 text-center hidden md:table-cell",
      cell: () => (
        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-300 border border-emerald-500/30">
          Grade 5
        </span>
      ),
    },
    {
      header: "Status",
      className: "w-32 text-center",
      cell: (q) => (
        <button
          onClick={() => handleToggleStatus(q)}
          title="Click to toggle status"
          className={`inline-flex items-center gap-1.5 text-[10px] font-bold px-3 py-1 rounded-full border transition-all hover:scale-105 cursor-pointer ${
            q.status === "published"
              ? "bg-emerald-500/20 text-emerald-300 border-emerald-500/40 hover:bg-emerald-500/30 shadow-sm shadow-emerald-500/20"
              : "bg-slate-800 text-slate-400 border-slate-700 hover:bg-slate-700 hover:text-white"
          }`}
        >
          <span
            className={`w-2 h-2 rounded-full ${
              q.status === "published" ? "bg-emerald-400 animate-pulse" : "bg-slate-500"
            }`}
          />
          <span className="uppercase">{q.status || "published"}</span>
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
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-pink-500/20 text-pink-300 border border-pink-500/30">
              Phase 4 Active
            </span>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
              Firestore story_quests
            </span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight mt-1">
            Story Quests & Narrative CMS
          </h1>
          <p className="text-xs text-slate-400">
            Build conversational storyline chapters with Leo, Ella, Felix, and Guru Parrot
          </p>
        </div>

        <div className="flex items-center gap-2.5 flex-wrap">
          {/* New Story Quest */}
          <button
            onClick={() => {
              setEditingQuest(null);
              setEditorOpen(true);
            }}
            className="px-5 py-2.5 rounded-xl bg-gradient-to-r from-purple-600 via-indigo-600 to-pink-500 hover:from-purple-500 hover:to-pink-400 text-white font-bold text-xs shadow-lg shadow-purple-600/30 transition-all flex items-center gap-2 w-fit cursor-pointer"
          >
            <Plus className="w-4 h-4" />
            <span>New Story Quest</span>
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
                Found {duplicateDocs.length} Duplicate Quest Records in Database
              </h4>
              <p className="text-[11px] text-slate-400">
                The table below is automatically deduplicated to show the {uniqueQuests.length} unique story quests.
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
          All Quests ({uniqueQuests.length})
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
          <span>Published ({uniqueQuests.filter((q) => (q.status || "published") === "published").length})</span>
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
          <span>Drafts ({uniqueQuests.filter((q) => q.status === "draft").length})</span>
        </button>
      </div>

      {/* Main DataTable */}
      <DataTable<StoryQuest>
        data={filteredQuests}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search quests by title or concept ID..."
        searchFilter={(q, query) =>
          q.title.toLowerCase().includes(query) ||
          Boolean(q.conceptId && q.conceptId.toLowerCase().includes(query)) ||
          String(q.chapterNumber || "").includes(query)
        }
        addLabel="New Quest"
        onAdd={() => {
          setEditingQuest(null);
          setEditorOpen(true);
        }}
        onEdit={(q) => {
          setEditingQuest(q);
          setEditorOpen(true);
        }}
        onDelete={(q) => {
          setQuestToDelete(q);
          setDeleteDialogOpen(true);
        }}
        emptyTitle="No Story Quests Created"
        emptySubtitle="Click 'New Story Quest' to launch the narrative timeline sequence builder."
      />

      {/* Quest Editor Modal */}
      <QuestEditorModal
        isOpen={editorOpen}
        onClose={() => {
          setEditorOpen(false);
          setEditingQuest(null);
        }}
        onSave={handleSaveQuest}
        initialData={editingQuest}
        loading={actionLoading}
      />

      {/* Delete Confirmation Dialog */}
      <DeleteConfirmDialog
        isOpen={deleteDialogOpen}
        onClose={() => {
          setDeleteDialogOpen(false);
          setQuestToDelete(null);
        }}
        onConfirm={handleConfirmDelete}
        title="Delete Story Quest"
        itemName={questToDelete?.title || "Quest"}
        loading={actionLoading}
      />
    </div>
  );
}
