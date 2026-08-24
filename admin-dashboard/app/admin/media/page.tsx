"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  fetchCollection,
  createDocument,
  updateDocument,
  deleteDocument,
} from "@/lib/firestore-crud";
import { Question, Video, Paper } from "@/types";
import { useToast } from "@/components/Toast";
import DataTable, { ColumnDef } from "@/components/DataTable";
import QuestionModal from "@/components/media/QuestionModal";
import VideoModal from "@/components/media/VideoModal";
import PaperModal from "@/components/media/PaperModal";
import DeleteConfirmDialog from "@/components/DeleteConfirmDialog";
import {
  Film,
  FileText,
  HelpCircle,
  Play,
  ExternalLink,
  Calendar,
  Trash2,
  AlertTriangle,
  Loader2,
  Sparkles,
} from "lucide-react";

type ActiveTab = "questions" | "videos" | "papers";

export default function MediaHubPage() {
  const [activeTab, setActiveTab] = useState<ActiveTab>("questions");
  const { showToast } = useToast();

  // ─── DATA STATES ──────────────────────────────────────────────────────────
  const [questions, setQuestions] = useState<Question[]>([]);
  const [videos, setVideos] = useState<Video[]>([]);
  const [papers, setPapers] = useState<Paper[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [purging, setPurging] = useState(false);

  // ─── MODAL STATES ─────────────────────────────────────────────────────────
  const [questionModalOpen, setQuestionModalOpen] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState<Question | null>(null);

  const [videoModalOpen, setVideoModalOpen] = useState(false);
  const [editingVideo, setEditingVideo] = useState<Video | null>(null);

  const [paperModalOpen, setPaperModalOpen] = useState(false);
  const [editingPaper, setEditingPaper] = useState<Paper | null>(null);

  // ─── DELETE DIALOG STATE ──────────────────────────────────────────────────
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [itemToDelete, setItemToDelete] = useState<{
    id: string;
    name: string;
    type: ActiveTab;
  } | null>(null);

  // ─── DATA FETCHING ────────────────────────────────────────────────────────
  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const [qData, vData, pData] = await Promise.allSettled([
        fetchCollection<Question>("questions", "createdAt", "desc"),
        fetchCollection<Video>("videos", "timestamp", "desc"),
        fetchCollection<Paper>("papers", "year", "desc"),
      ]);

      if (qData.status === "fulfilled") setQuestions(qData.value);
      if (vData.status === "fulfilled") setVideos(vData.value);
      if (pData.status === "fulfilled") setPapers(pData.value);
    } catch (error) {
      console.error("Error fetching media items:", error);
      showToast("Error loading media items", "error");
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // ─── GRADE 5 FILTERING LOGIC ──────────────────────────────────────────────
  const isLegacyGrade3or4 = useCallback((v: Video) => {
    const g = v.targetGrade as any;
    const title = v.title || "";
    const is3or4 =
      g === 3 ||
      g === 4 ||
      g === "3" ||
      g === "4" ||
      title.includes("Grade 3") ||
      title.includes("Grade 4") ||
      title.includes("3 ශ්‍රේණිය") ||
      title.includes("4 ශ්‍රේණිය");

    const isExplicitGrade5 =
      g === 5 ||
      g === "5" ||
      title.includes("Grade 5") ||
      title.includes("5 ශ්‍රේණිය") ||
      title.includes("Scholarship") ||
      title.includes("ශිෂ්‍යත්ව");

    return is3or4 && !isExplicitGrade5;
  }, []);

  const grade5Videos = useMemo(
    () => videos.filter((v) => !isLegacyGrade3or4(v)),
    [videos, isLegacyGrade3or4]
  );

  const legacyGrade3or4Videos = useMemo(
    () => videos.filter(isLegacyGrade3or4),
    [videos, isLegacyGrade3or4]
  );

  // ─── PURGE LEGACY VIDEOS HANDLER ──────────────────────────────────────────
  const handlePurgeLegacyVideos = async () => {
    if (legacyGrade3or4Videos.length === 0) return;
    setPurging(true);
    try {
      let count = 0;
      for (const v of legacyGrade3or4Videos) {
        if (v.id) {
          await deleteDocument("videos", v.id);
          count++;
        }
      }
      showToast(`Purged ${count} legacy Grade 3 & 4 videos from Firestore! ✨`, "success");
      await loadData();
    } catch (error) {
      console.error("Error purging legacy videos:", error);
      showToast("Failed to purge legacy videos. Please ensure you are logged in as Admin.", "error");
    } finally {
      setPurging(false);
    }
  };

  // ─── QUESTION HANDLERS ────────────────────────────────────────────────────
  const handleSaveQuestion = async (data: Omit<Question, "id">) => {
    setActionLoading(true);
    try {
      if (editingQuestion?.id) {
        await updateDocument("questions", editingQuestion.id, data);
        showToast("Question updated successfully! ✨", "success");
      } else {
        await createDocument("questions", data);
        showToast("Question added to bank! 🎯", "success");
      }
      setQuestionModalOpen(false);
      setEditingQuestion(null);
      await loadData();
    } catch (error) {
      console.error("Error saving question:", error);
      showToast("Failed to save question", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── VIDEO HANDLERS ───────────────────────────────────────────────────────
  const handleSaveVideo = async (data: Omit<Video, "id">) => {
    setActionLoading(true);
    try {
      if (editingVideo?.id) {
        await updateDocument("videos", editingVideo.id, data);
        showToast("Video lesson updated! 🎬", "success");
      } else {
        await createDocument("videos", data);
        showToast("Video lesson published to students! 🚀", "success");
      }
      setVideoModalOpen(false);
      setEditingVideo(null);
      await loadData();
    } catch (error) {
      console.error("Error saving video:", error);
      showToast("Failed to save video", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── PAPER HANDLERS ───────────────────────────────────────────────────────
  const handleSavePaper = async (data: Omit<Paper, "id">) => {
    setActionLoading(true);
    try {
      if (editingPaper?.id) {
        await updateDocument("papers", editingPaper.id, data);
        showToast("Past paper updated! 📄", "success");
      } else {
        await createDocument("papers", data);
        showToast("Past paper uploaded to archive! 📚", "success");
      }
      setPaperModalOpen(false);
      setEditingPaper(null);
      await loadData();
    } catch (error) {
      console.error("Error saving paper:", error);
      showToast("Failed to save past paper", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── DELETE EXECUTION ─────────────────────────────────────────────────────
  const handleConfirmDelete = async () => {
    if (!itemToDelete) return;
    setActionLoading(true);
    try {
      await deleteDocument(itemToDelete.type, itemToDelete.id);
      showToast(`Deleted ${itemToDelete.name} from Firestore`, "info");
      setDeleteDialogOpen(false);
      setItemToDelete(null);
      await loadData();
    } catch (error) {
      console.error("Error deleting document:", error);
      showToast("Failed to delete record", "error");
    } finally {
      setActionLoading(false);
    }
  };

  // ─── QUESTION COLUMNS ─────────────────────────────────────────────────────
  const questionColumns: ColumnDef<Question>[] = [
    {
      header: "Subject",
      className: "w-36",
      cell: (q) => {
        const subjectColors: Record<string, string> = {
          Mathematics: "bg-amber-500/10 text-amber-300 border-amber-500/30",
          Maths: "bg-amber-500/10 text-amber-300 border-amber-500/30",
          Sinhala: "bg-purple-500/10 text-purple-300 border-purple-500/30",
          Environment: "bg-emerald-500/10 text-emerald-300 border-emerald-500/30",
          English: "bg-blue-500/10 text-blue-300 border-blue-500/30",
        };

        const badgeClass =
          subjectColors[q.subject] ||
          "bg-amber-500/10 text-amber-300 border-amber-500/30";

        return (
          <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full border ${badgeClass}`}>
            {q.subject}
          </span>
        );
      },
    },
    {
      header: "Question Text",
      cell: (q) => (
        <div className="space-y-1">
          <p className="font-semibold text-white text-xs line-clamp-2">{q.questionText}</p>
          <div className="flex items-center gap-2 text-[10px] text-slate-400">
            <span className="text-emerald-400 font-bold">
              Answer ({String.fromCharCode(65 + (q.correctOptionIndex ?? 0))}):
            </span>
            <span className="text-slate-300">
              {q.options?.[q.correctOptionIndex ?? 0] || "None specified"}
            </span>
          </div>
        </div>
      ),
    },
    {
      header: "Options Summary",
      className: "w-56 hidden md:table-cell",
      cell: (q) => (
        <div className="flex flex-wrap gap-1">
          {q.options?.map((opt, idx) => (
            <span
              key={idx}
              className={`text-[9px] px-1.5 py-0.5 rounded ${
                q.correctOptionIndex === idx
                  ? "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 font-bold"
                  : "bg-slate-800 text-slate-400"
              }`}
            >
              {String.fromCharCode(65 + idx)}: {opt}
            </span>
          ))}
        </div>
      ),
    },
  ];

  // ─── VIDEO COLUMNS ────────────────────────────────────────────────────────
  const videoColumns: ColumnDef<Video>[] = [
    {
      header: "Video Lesson (Grade 5 Scholarship)",
      cell: (v) => (
        <div className="flex items-center gap-3">
          <div className="relative w-20 h-12 rounded-lg overflow-hidden bg-slate-900 border border-slate-700 flex-shrink-0 group">
            {v.thumbnailUrl ? (
              <img src={v.thumbnailUrl} alt={v.title} className="w-full h-full object-cover" />
            ) : (
              <div className="w-full h-full flex items-center justify-center bg-purple-950/40">
                <Film className="w-4 h-4 text-purple-400" />
              </div>
            )}
            <a
              href={v.videoUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <Play className="w-4 h-4 text-white fill-current" />
            </a>
          </div>

          <div className="space-y-0.5">
            <h4 className="font-bold text-white text-xs line-clamp-1">{v.title}</h4>
            <div className="flex items-center gap-2">
              <a
                href={v.videoUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[10px] text-purple-400 hover:text-purple-300 flex items-center gap-0.5 font-medium"
              >
                <span>Watch on YouTube</span>
                <ExternalLink className="w-2.5 h-2.5" />
              </a>
              {v.duration && (
                <span className="text-[10px] text-slate-400 font-mono">⏱ {v.duration}</span>
              )}
            </div>
          </div>
        </div>
      ),
    },
    {
      header: "Category",
      className: "w-36 hidden sm:table-cell",
      cell: (v) => (
        <span className="text-[10px] font-bold px-2.5 py-1 rounded-full bg-purple-500/10 text-purple-300 border border-purple-500/30 uppercase">
          {v.category || "mathematics"}
        </span>
      ),
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
  ];

  // ─── PAPER COLUMNS ────────────────────────────────────────────────────────
  const paperColumns: ColumnDef<Paper>[] = [
    {
      header: "Paper Details",
      cell: (p) => (
        <div className="space-y-0.5">
          <div className="flex items-center gap-2">
            <FileText className="w-4 h-4 text-emerald-400 flex-shrink-0" />
            <h4 className="font-bold text-white text-xs">{p.title}</h4>
          </div>
          <p className="text-[10px] text-slate-400">{p.subject || "Scholarship Examination"}</p>
        </div>
      ),
    },
    {
      header: "Year",
      className: "w-28 text-center",
      cell: (p) => (
        <span className="inline-flex items-center gap-1 text-[11px] font-bold px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-300 border border-emerald-500/30">
          <Calendar className="w-3 h-3" />
          <span>{p.year}</span>
        </span>
      ),
    },
    {
      header: "Document Link",
      className: "w-44 text-right",
      cell: (p) => (
        <a
          href={p.pdfUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="text-xs text-purple-400 hover:text-purple-300 font-semibold inline-flex items-center gap-1"
        >
          <span>Open PDF</span>
          <ExternalLink className="w-3 h-3" />
        </a>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Media Hub Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-800">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-pink-500/20 text-pink-300 border border-pink-500/30">
              Phase 2 Active
            </span>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
              Grade 5 Syllabus
            </span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight mt-1">Curriculum Media Hub</h1>
          <p className="text-xs text-slate-400">
            Manage Grade 5 scholarship question banks, video lessons, and past examination papers
          </p>
        </div>
      </div>

      {/* Tabs Switcher */}
      <div className="flex items-center gap-2 p-1.5 rounded-2xl bg-[#120E33] border border-slate-800 w-fit">
        <button
          onClick={() => setActiveTab("questions")}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === "questions"
              ? "bg-purple-600 text-white shadow-lg shadow-purple-600/30"
              : "text-slate-400 hover:text-white hover:bg-slate-800/40"
          }`}
        >
          <HelpCircle className="w-4 h-4" />
          <span>Question Bank</span>
          <span className="text-[10px] px-1.5 py-0.2 rounded-full bg-black/30 text-purple-200">
            {questions.length}
          </span>
        </button>

        <button
          onClick={() => setActiveTab("videos")}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === "videos"
              ? "bg-purple-600 text-white shadow-lg shadow-purple-600/30"
              : "text-slate-400 hover:text-white hover:bg-slate-800/40"
          }`}
        >
          <Film className="w-4 h-4" />
          <span>Video Classroom (Grade 5)</span>
          <span className="text-[10px] px-1.5 py-0.2 rounded-full bg-emerald-500/30 text-emerald-200 font-bold">
            {grade5Videos.length}
          </span>
        </button>

        <button
          onClick={() => setActiveTab("papers")}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === "papers"
              ? "bg-purple-600 text-white shadow-lg shadow-purple-600/30"
              : "text-slate-400 hover:text-white hover:bg-slate-800/40"
          }`}
        >
          <FileText className="w-4 h-4" />
          <span>Past Papers</span>
          <span className="text-[10px] px-1.5 py-0.2 rounded-full bg-black/30 text-purple-200">
            {papers.length}
          </span>
        </button>
      </div>

      {/* Tab Content 1: Question Bank */}
      {activeTab === "questions" && (
        <DataTable<Question>
          data={questions}
          columns={questionColumns}
          loading={loading}
          searchPlaceholder="Search questions by text or subject..."
          searchFilter={(q, query) =>
            q.questionText.toLowerCase().includes(query) ||
            q.subject.toLowerCase().includes(query) ||
            q.options.some((o) => o.toLowerCase().includes(query))
          }
          addLabel="Add Question"
          onAdd={() => {
            setEditingQuestion(null);
            setQuestionModalOpen(true);
          }}
          onEdit={(q) => {
            setEditingQuestion(q);
            setQuestionModalOpen(true);
          }}
          onDelete={(q) => {
            setItemToDelete({
              id: q.id!,
              name: `Question: "${q.questionText.substring(0, 30)}..."`,
              type: "questions",
            });
            setDeleteDialogOpen(true);
          }}
          emptyTitle="Question Bank is empty"
          emptySubtitle="Create practice questions with 4 options and answers."
        />
      )}

      {/* Tab Content 2: Video Lessons */}
      {activeTab === "videos" && (
        <div className="space-y-4">
          {/* Legacy Grade 3/4 Purge Banner if any exist in Firestore */}
          {legacyGrade3or4Videos.length > 0 && (
            <div className="p-4 rounded-2xl bg-gradient-to-r from-amber-950/40 to-rose-950/40 border border-amber-500/30 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className="p-2.5 rounded-xl bg-amber-500/20 text-amber-400 border border-amber-500/30">
                  <AlertTriangle className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white">
                    Found {legacyGrade3or4Videos.length} Legacy Grade 3 & 4 Videos in Database
                  </h4>
                  <p className="text-[11px] text-slate-400">
                    The table below is already filtered to only show the {grade5Videos.length} Grade 5 scholarship videos.
                  </p>
                </div>
              </div>

              <button
                onClick={handlePurgeLegacyVideos}
                disabled={purging}
                className="px-4 py-2 rounded-xl bg-rose-600/90 hover:bg-rose-500 text-white font-bold text-xs shadow-lg shadow-rose-600/20 transition-all flex items-center gap-2 flex-shrink-0 disabled:opacity-50"
              >
                {purging ? (
                  <>
                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                    <span>Purging {legacyGrade3or4Videos.length} Videos...</span>
                  </>
                ) : (
                  <>
                    <Trash2 className="w-3.5 h-3.5" />
                    <span>Purge {legacyGrade3or4Videos.length} Legacy Videos</span>
                  </>
                )}
              </button>
            </div>
          )}

          <DataTable<Video>
            data={grade5Videos}
            columns={videoColumns}
            loading={loading}
            searchPlaceholder="Search Grade 5 video lessons by title or category..."
            searchFilter={(v, query) =>
              v.title.toLowerCase().includes(query) ||
              v.category.toLowerCase().includes(query) ||
              v.description.toLowerCase().includes(query)
            }
            addLabel="Publish Grade 5 Video"
            onAdd={() => {
              setEditingVideo(null);
              setVideoModalOpen(true);
            }}
            onEdit={(v) => {
              setEditingVideo(v);
              setVideoModalOpen(true);
            }}
            onDelete={(v) => {
              setItemToDelete({
                id: v.id!,
                name: `Video: "${v.title}"`,
                type: "videos",
              });
              setDeleteDialogOpen(true);
            }}
            emptyTitle="No Grade 5 video lessons found"
            emptySubtitle="Paste YouTube links to publish Grade 5 scholarship video lessons."
          />
        </div>
      )}

      {/* Tab Content 3: Past Papers */}
      {activeTab === "papers" && (
        <DataTable<Paper>
          data={papers}
          columns={paperColumns}
          loading={loading}
          searchPlaceholder="Search past papers by title or year..."
          searchFilter={(p, query) =>
            p.title.toLowerCase().includes(query) ||
            String(p.year).includes(query) ||
            (p.subject ? p.subject.toLowerCase().includes(query) : false)
          }
          addLabel="Upload Past Paper"
          onAdd={() => {
            setEditingPaper(null);
            setPaperModalOpen(true);
          }}
          onEdit={(p) => {
            setEditingPaper(p);
            setPaperModalOpen(true);
          }}
          onDelete={(p) => {
            setItemToDelete({
              id: p.id!,
              name: `Paper: "${p.title}"`,
              type: "papers",
            });
            setDeleteDialogOpen(true);
          }}
          emptyTitle="Past papers archive is empty"
          emptySubtitle="Add official Grade 5 scholarship examination papers."
        />
      )}

      {/* Question Form Modal */}
      <QuestionModal
        isOpen={questionModalOpen}
        onClose={() => {
          setQuestionModalOpen(false);
          setEditingQuestion(null);
        }}
        onSave={handleSaveQuestion}
        initialData={editingQuestion}
        loading={actionLoading}
      />

      {/* Video Form Modal */}
      <VideoModal
        isOpen={videoModalOpen}
        onClose={() => {
          setVideoModalOpen(false);
          setEditingVideo(null);
        }}
        onSave={handleSaveVideo}
        initialData={editingVideo}
        loading={actionLoading}
      />

      {/* Paper Form Modal */}
      <PaperModal
        isOpen={paperModalOpen}
        onClose={() => {
          setPaperModalOpen(false);
          setEditingPaper(null);
        }}
        onSave={handleSavePaper}
        initialData={editingPaper}
        loading={actionLoading}
      />

      {/* Permanent Delete Confirmation Dialog */}
      <DeleteConfirmDialog
        isOpen={deleteDialogOpen}
        onClose={() => {
          setDeleteDialogOpen(false);
          setItemToDelete(null);
        }}
        onConfirm={handleConfirmDelete}
        title="Delete Item"
        itemName={itemToDelete?.name || "Record"}
        loading={actionLoading}
      />
    </div>
  );
}
