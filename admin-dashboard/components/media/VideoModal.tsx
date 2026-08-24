"use client";

import React, { useState, useEffect } from "react";
import ItemModal from "@/components/ItemModal";
import { Video, VideoCategory } from "@/types";
import { extractYoutubeId, getYoutubeThumbnail } from "@/lib/firestore-crud";
import { Film, Play, Image as ImageIcon } from "lucide-react";

interface VideoModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (video: Omit<Video, "id">) => Promise<void>;
  initialData?: Video | null;
  loading?: boolean;
}

const CATEGORIES: { id: VideoCategory; label: string }[] = [
  { id: "mathematics", label: "Mathematics (ගණිතය)" },
  { id: "sinhala", label: "Sinhala (සිංහල)" },
  { id: "environment", label: "Environment (පරිසරය)" },
  { id: "english", label: "English (ඉංග්‍රීසි)" },
  { id: "past_papers", label: "Past Paper Discussions" },
];

export default function VideoModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  loading = false,
}: VideoModalProps) {
  const [title, setTitle] = useState("");
  const [videoUrl, setVideoUrl] = useState("");
  const [thumbnailUrl, setThumbnailUrl] = useState("");
  const [category, setCategory] = useState<VideoCategory>("mathematics");
  const [targetGrade, setTargetGrade] = useState<number>(5);
  const [duration, setDuration] = useState("10:00");
  const [description, setDescription] = useState("");

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setVideoUrl(initialData.videoUrl || "");
      setThumbnailUrl(initialData.thumbnailUrl || getYoutubeThumbnail(initialData.videoUrl || ""));
      setCategory(initialData.category || "mathematics");
      setTargetGrade(initialData.targetGrade || 5);
      setDuration(initialData.duration || "10:00");
      setDescription(initialData.description || "");
    } else {
      setTitle("");
      setVideoUrl("");
      setThumbnailUrl("");
      setCategory("mathematics");
      setTargetGrade(5);
      setDuration("10:00");
      setDescription("");
    }
  }, [initialData, isOpen]);

  // Handle YouTube URL change and auto-extract HQ thumbnail
  const handleUrlChange = (url: string) => {
    setVideoUrl(url);
    const thumb = getYoutubeThumbnail(url);
    if (thumb) {
      setThumbnailUrl(thumb);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const finalThumb = thumbnailUrl || getYoutubeThumbnail(videoUrl);

    await onSave({
      title: title.trim(),
      videoUrl: videoUrl.trim(),
      thumbnailUrl: finalThumb,
      category,
      targetGrade: Number(targetGrade) || 5,
      duration: duration.trim() || "10:00",
      description: description.trim(),
    });
  };

  const yId = extractYoutubeId(videoUrl);

  return (
    <ItemModal
      isOpen={isOpen}
      onClose={onClose}
      title={initialData ? "Edit Video Lesson" : "Add Video Lesson"}
      subtitle="Curated scholarship video tutorial for student video classroom"
      onSubmit={handleSubmit}
      submitLabel={initialData ? "Update Video" : "Publish Video"}
      loading={loading}
    >
      <div className="space-y-4">
        {/* Title */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Lesson Title
          </label>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
            placeholder="e.g. 5 ශ්‍රේණිය ගණිතය — ස්ථානීය අගය සහ සංඛ්‍යා රටා"
            className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>

        {/* YouTube Video URL */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            YouTube Video URL
          </label>
          <input
            type="url"
            value={videoUrl}
            onChange={(e) => handleUrlChange(e.target.value)}
            required
            placeholder="https://www.youtube.com/watch?v=5V3bA_O2o5U"
            className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
          />
          {yId && (
            <p className="text-[10px] text-emerald-400 mt-1 flex items-center gap-1">
              <span>✓ Detected YouTube Video ID:</span>
              <code className="font-mono bg-emerald-950/40 px-1 py-0.2 rounded border border-emerald-500/30">
                {yId}
              </code>
            </p>
          )}
        </div>

        {/* Live Thumbnail Preview */}
        {thumbnailUrl && (
          <div className="p-3 rounded-xl bg-[#120E33] border border-slate-800 flex items-center gap-3">
            <div className="relative w-24 h-14 rounded-lg overflow-hidden flex-shrink-0 bg-slate-900 border border-slate-700">
              <img
                src={thumbnailUrl}
                alt="Video Thumbnail Preview"
                className="w-full h-full object-cover"
                onError={(e) => {
                  (e.target as HTMLElement).style.display = "none";
                }}
              />
              <div className="absolute inset-0 bg-black/30 flex items-center justify-center">
                <Play className="w-4 h-4 text-white fill-current opacity-80" />
              </div>
            </div>
            <div className="flex-1 text-xs">
              <span className="font-bold text-white block">Auto-Generated Thumbnail</span>
              <span className="text-[10px] text-slate-400 font-mono break-all">{thumbnailUrl}</span>
            </div>
          </div>
        )}

        {/* Category & Grade */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Subject / Category
            </label>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value as VideoCategory)}
              className="w-full py-2.5 px-3 rounded-xl glass-input text-xs focus:outline-none bg-[#120E33]"
            >
              {CATEGORIES.map((c) => (
                <option key={c.id} value={c.id} className="bg-[#16123D] text-white">
                  {c.label}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Target Grade
            </label>
            <select
              value={targetGrade}
              onChange={(e) => setTargetGrade(Number(e.target.value))}
              className="w-full py-2.5 px-3 rounded-xl glass-input text-xs focus:outline-none bg-[#120E33]"
            >
              <option value={5} className="bg-[#16123D] text-white">
                Grade 5 (Scholarship Exam)
              </option>
            </select>
          </div>
        </div>

        {/* Duration */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Video Duration (MM:SS)
          </label>
          <input
            type="text"
            value={duration}
            onChange={(e) => setDuration(e.target.value)}
            placeholder="14:20"
            className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>

        {/* Description */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Lesson Description
          </label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={2}
            placeholder="Summary of learning outcomes covered in this video tutorial..."
            className="w-full p-3 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>
      </div>
    </ItemModal>
  );
}
