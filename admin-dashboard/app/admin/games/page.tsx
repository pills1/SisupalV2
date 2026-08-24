"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  fetchCollection,
  createDocument,
  updateDocument,
  deleteDocument,
} from "@/lib/firestore-crud";
import { MathGameBase, GameTemplateType, GameTemplateStatus } from "@/types";
import { useToast } from "@/components/Toast";
import DataTable, { ColumnDef } from "@/components/DataTable";
import GameEditorModal from "@/components/games/GameEditorModal";
import DeleteConfirmDialog from "@/components/DeleteConfirmDialog";
import {
  Gamepad2,
  Plus,
  Sparkles,
  Layers,
  CheckCircle2,
  Clock,
  Trash2,
  AlertTriangle,
  Loader2,
} from "lucide-react";

const TEMPLATE_META: Record<
  GameTemplateType,
  { label: string; emoji: string; color: string }
> = {
  abacus: {
    label: "Abacus Match",
    emoji: "🧮",
    color: "bg-amber-500/10 text-amber-300 border-amber-500/30",
  },
  lily_pad_leap: {
    label: "Lily Pad Leap",
    emoji: "🐸",
    color: "bg-emerald-500/10 text-emerald-300 border-emerald-500/30",
  },
  place_value: {
    label: "Place Value",
    emoji: "🎯",
    color: "bg-blue-500/10 text-blue-300 border-blue-500/30",
  },
  number_archery: {
    label: "Number Archery",
    emoji: "🏹",
    color: "bg-rose-500/10 text-rose-300 border-rose-500/30",
  },
  digit_builder: {
    label: "Digit Builder",
    emoji: "🧩",
    color: "bg-purple-500/10 text-purple-300 border-purple-500/30",
  },
  expanded_form: {
    label: "Expanded Form",
    emoji: "📐",
    color: "bg-cyan-500/10 text-cyan-300 border-cyan-500/30",
  },
  rapid_fire: {
    label: "Rapid Fire",
    emoji: "⚡",
    color: "bg-yellow-500/10 text-yellow-300 border-yellow-500/30",
  },
};

export default function GamesCMSPage() {
  const { showToast } = useToast();

  // ─── DATA & UI STATES ─────────────────────────────────────────────────────
  const [rawGames, setRawGames] = useState<MathGameBase[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [purging, setPurging] = useState(false);

  // ─── FILTER STATES ────────────────────────────────────────────────────────
  const [statusFilter, setStatusFilter] = useState<"all" | GameTemplateStatus>("all");
  const [typeFilter, setTypeFilter] = useState<"all" | GameTemplateType>("all");

  // ─── MODAL STATES ─────────────────────────────────────────────────────────
  const [editorOpen, setEditorOpen] = useState(false);
  const [editingGame, setEditingGame] = useState<MathGameBase | null>(null);

  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [gameToDelete, setGameToDelete] = useState<MathGameBase | null>(null);

  // ─── DATA FETCHING ────────────────────────────────────────────────────────
  const loadGames = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchCollection<MathGameBase>("math_games", "createdAt", "desc");
      setRawGames(data);
    } catch (error) {
      console.error("Error fetching math games:", error);
      showToast("Error loading math mini-games from Firestore", "error");
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    loadGames();
  }, [loadGames]);

  // ─── DEDUPLICATION LOGIC ──────────────────────────────────────────────────
  const { uniqueGames, duplicateDocs } = useMemo(() => {
    const seen = new Map<string, MathGameBase>();
    const duplicates: MathGameBase[] = [];

    for (const g of rawGames) {
      const key = g.templateType || g.title?.trim().toLowerCase();
      if (seen.has(key)) {
        duplicates.push(g);
      } else {
        seen.set(key, g);
      }
    }

    return {
      uniqueGames: Array.from(seen.values()),
      duplicateDocs: duplicates,
    };
  }, [rawGames]);

  // ─── PURGE DUPLICATES FROM FIRESTORE ──────────────────────────────────────
  const handlePurgeDuplicates = async () => {
    if (duplicateDocs.length === 0) return;
    setPurging(true);
    try {
      let count = 0;
      for (const dup of duplicateDocs) {
        if (dup.id) {
          await deleteDocument("math_games", dup.id);
          count++;
        }
      }
      showToast(`Removed ${count} duplicate game entries from Firestore! 🧹`, "success");
      await loadGames();
    } catch (error) {
      console.error("Error purging duplicate games:", error);
      showToast("Failed to remove duplicate games", "error");
    } finally {
      setPurging(false);
    }
  };

  // ─── SAVE GAME HANDLER ────────────────────────────────────────────────────
  const handleSaveGame = async (gameData: Omit<MathGameBase, "id">) => {
    setActionLoading(true);
    try {
      if (editingGame?.id) {
        await updateDocument("math_games", editingGame.id, gameData);
        showToast("Mini-game configuration updated! ✨", "success");
      } else {
        await createDocument("math_games", gameData);
        showToast("New math mini-game published! 🚀", "success");
      }
      setEditorOpen(false);
      setEditingGame(null);
      await loadGames();
    } catch (error) {
      console.error("Error saving game:", error);
      showToast("Failed to save mini-game configuration", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── TOGGLE STATUS ────────────────────────────────────────────────────────
  const handleToggleStatus = async (game: MathGameBase) => {
    if (!game.id) return;
    const newStatus: GameTemplateStatus =
      game.status === "published" ? "draft" : "published";
    try {
      await updateDocument("math_games", game.id, { status: newStatus });
      showToast(`Game "${game.title}" set to ${newStatus.toUpperCase()}`, "info");
      await loadGames();
    } catch (error) {
      console.error("Error updating status:", error);
      showToast("Failed to toggle game status", "error");
    }
  };

  // ─── DELETE EXECUTION ─────────────────────────────────────────────────────
  const handleConfirmDelete = async () => {
    if (!gameToDelete?.id) return;
    setActionLoading(true);
    try {
      await deleteDocument("math_games", gameToDelete.id);
      showToast(`Deleted "${gameToDelete.title}" from Firestore`, "info");
      setDeleteDialogOpen(false);
      setGameToDelete(null);
      await loadGames();
    } catch (error) {
      console.error("Error deleting game:", error);
      showToast("Failed to delete game record", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── FILTERED GAMES LIST ──────────────────────────────────────────────────
  const filteredGames = useMemo(() => {
    return uniqueGames.filter((g) => {
      if (statusFilter !== "all" && g.status !== statusFilter) return false;
      if (typeFilter !== "all" && g.templateType !== typeFilter) return false;
      return true;
    });
  }, [uniqueGames, statusFilter, typeFilter]);

  // ─── TABLE COLUMNS ────────────────────────────────────────────────────────
  const columns: ColumnDef<MathGameBase>[] = [
    {
      header: "Mini-Game Title",
      cell: (g) => (
        <div className="space-y-0.5 max-w-sm">
          <div className="flex items-center gap-2">
            <span className="text-base">
              {TEMPLATE_META[g.templateType]?.emoji || "🎮"}
            </span>
            <h4 className="font-bold text-white text-xs line-clamp-1">{g.title}</h4>
          </div>
          <p className="text-[10px] text-slate-400 line-clamp-1">
            {g.description || "Interactive Grade 5 mathematics learning activity"}
          </p>
        </div>
      ),
    },
    {
      header: "Game Engine",
      className: "w-36",
      cell: (g) => {
        const meta = TEMPLATE_META[g.templateType] || {
          label: g.templateType,
          emoji: "🎮",
          color: "bg-purple-500/10 text-purple-300 border-purple-500/30",
        };
        return (
          <span
            className={`inline-flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-1 rounded-full border ${meta.color}`}
          >
            <span>{meta.emoji}</span>
            <span>{meta.label}</span>
          </span>
        );
      },
    },
    {
      header: "Configuration Summary",
      className: "w-44 hidden md:table-cell",
      cell: (g) => {
        const data = (g.gameData || {}) as any;
        if (g.templateType === "abacus") {
          return (
            <div className="text-[10px] space-y-0.5">
              <span className="font-mono text-amber-300 font-bold block">
                Target: {data.targetNumber ?? "None"}
              </span>
              <span className="text-slate-400">
                {data.placeValues?.length || 4} Place Rods
              </span>
            </div>
          );
        }
        if (g.templateType === "lily_pad_leap") {
          return (
            <div className="text-[10px] space-y-0.5">
              <span className="font-mono text-emerald-300 font-bold block">
                Ans: {data.correctAnswer} (Pad #{Number(data.missingIndex ?? 0) + 1})
              </span>
              <span className="text-slate-400 truncate block">
                {data.ruleDescription || "Step pattern"}
              </span>
            </div>
          );
        }
        return (
          <span className="text-[10px] text-slate-400 font-mono">
            {Object.keys(data).length} parameters
          </span>
        );
      },
    },
    {
      header: "Status (Click to toggle)",
      className: "w-32 text-center",
      cell: (g) => (
        <button
          onClick={() => handleToggleStatus(g)}
          title={`Click to set as ${g.status === "published" ? "DRAFT (hidden from students)" : "PUBLISHED (visible to students)"}`}
          className={`inline-flex items-center gap-1.5 text-[10px] font-bold px-3 py-1 rounded-full border transition-all hover:scale-105 cursor-pointer ${
            g.status === "published"
              ? "bg-emerald-500/20 text-emerald-300 border-emerald-500/40 hover:bg-emerald-500/30 shadow-sm shadow-emerald-500/20"
              : "bg-slate-800 text-slate-400 border-slate-700 hover:bg-slate-700 hover:text-white"
          }`}
        >
          <span
            className={`w-2 h-2 rounded-full ${
              g.status === "published" ? "bg-emerald-400 animate-pulse" : "bg-slate-500"
            }`}
          />
          <span className="uppercase">{g.status}</span>
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* CMS Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-800">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 border border-purple-500/30">
              Phase 3 Active
            </span>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
              Live Student Sync
            </span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight mt-1">Game Templates CMS</h1>
          <p className="text-xs text-slate-400">
            Design, configure, and publish interactive Grade 5 math mini-games with live JSON preview
          </p>
        </div>

        <button
          onClick={() => {
            setEditingGame(null);
            setEditorOpen(true);
          }}
          className="px-5 py-2.5 rounded-xl bg-gradient-to-r from-purple-600 via-indigo-600 to-amber-500 hover:from-purple-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-purple-600/30 transition-all flex items-center gap-2 w-fit cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Create Mini-Game</span>
        </button>
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
                Found {duplicateDocs.length} Duplicate Game Records in Database
              </h4>
              <p className="text-[11px] text-slate-400">
                The table below is automatically deduplicated to show the {uniqueGames.length} unique math games.
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

      {/* Status Tabs & Template Filters */}
      <div className="space-y-3">
        {/* Status Switcher Tabs */}
        <div className="flex items-center gap-2 p-1.5 rounded-2xl bg-[#120E33] border border-slate-800 w-fit">
          <button
            onClick={() => setStatusFilter("all")}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              statusFilter === "all"
                ? "bg-purple-600 text-white shadow-lg shadow-purple-600/30"
                : "text-slate-400 hover:text-white hover:bg-slate-800/40"
            }`}
          >
            All Games ({uniqueGames.length})
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
            <span>Published ({uniqueGames.filter((g) => g.status === "published").length})</span>
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
            <span>Drafts ({uniqueGames.filter((g) => g.status === "draft").length})</span>
          </button>
        </div>

        {/* Template Type Pill Filter Bar */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 scrollbar-none">
          <button
            onClick={() => setTypeFilter("all")}
            className={`text-[11px] font-semibold px-3 py-1.5 rounded-xl border transition-all whitespace-nowrap ${
              typeFilter === "all"
                ? "bg-purple-500/20 text-purple-200 border-purple-500/50 shadow-sm"
                : "bg-[#120E33]/60 text-slate-400 border-slate-800 hover:border-slate-700"
            }`}
          >
            All Engines
          </button>
          {(Object.keys(TEMPLATE_META) as GameTemplateType[]).map((key) => {
            const meta = TEMPLATE_META[key];
            const isSelected = typeFilter === key;
            return (
              <button
                key={key}
                onClick={() => setTypeFilter(key)}
                className={`text-[11px] font-semibold px-3 py-1.5 rounded-xl border transition-all flex items-center gap-1.5 whitespace-nowrap ${
                  isSelected
                    ? "bg-purple-500/20 text-purple-200 border-purple-500/50 shadow-sm"
                    : "bg-[#120E33]/60 text-slate-400 border-slate-800 hover:border-slate-700"
                }`}
              >
                <span>{meta.emoji}</span>
                <span>{meta.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Main Games DataTable */}
      <DataTable<MathGameBase>
        data={filteredGames}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search games by title, description or template..."
        searchFilter={(g, query) =>
          g.title.toLowerCase().includes(query) ||
          (g.description && g.description.toLowerCase().includes(query)) ||
          g.templateType.toLowerCase().includes(query) ||
          false
        }
        addLabel="New Game"
        onAdd={() => {
          setEditingGame(null);
          setEditorOpen(true);
        }}
        onEdit={(g) => {
          setEditingGame(g);
          setEditorOpen(true);
        }}
        onDelete={(g) => {
          setGameToDelete(g);
          setDeleteDialogOpen(true);
        }}
        emptyTitle="No Math Mini-Games Configured"
        emptySubtitle="Click 'Create Mini-Game' to launch the interactive Game Builder wizard."
      />

      {/* Game Builder Editor Modal */}
      <GameEditorModal
        isOpen={editorOpen}
        onClose={() => {
          setEditorOpen(false);
          setEditingGame(null);
        }}
        onSave={handleSaveGame}
        initialData={editingGame}
        loading={actionLoading}
      />

      {/* Delete Confirmation Dialog */}
      <DeleteConfirmDialog
        isOpen={deleteDialogOpen}
        onClose={() => {
          setDeleteDialogOpen(false);
          setGameToDelete(null);
        }}
        onConfirm={handleConfirmDelete}
        title="Delete Mini-Game"
        itemName={gameToDelete?.title || "Game"}
        loading={actionLoading}
      />
    </div>
  );
}
