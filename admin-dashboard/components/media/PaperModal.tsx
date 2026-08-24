"use client";

import React, { useState, useEffect } from "react";
import ItemModal from "@/components/ItemModal";
import { Paper } from "@/types";
import { FileText, ExternalLink } from "lucide-react";

interface PaperModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (paper: Omit<Paper, "id">) => Promise<void>;
  initialData?: Paper | null;
  loading?: boolean;
}

export default function PaperModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  loading = false,
}: PaperModalProps) {
  const [title, setTitle] = useState("");
  const [year, setYear] = useState<number>(new Date().getFullYear());
  const [pdfUrl, setPdfUrl] = useState("");
  const [subject, setSubject] = useState("Scholarship Examination");

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || "");
      setYear(Number(initialData.year) || new Date().getFullYear());
      setPdfUrl(initialData.pdfUrl || "");
      setSubject(initialData.subject || "Scholarship Examination");
    } else {
      setTitle("");
      setYear(new Date().getFullYear());
      setPdfUrl("");
      setSubject("Scholarship Examination");
    }
  }, [initialData, isOpen]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSave({
      title: title.trim(),
      year: Number(year) || new Date().getFullYear(),
      pdfUrl: pdfUrl.trim(),
      subject: subject.trim(),
    });
  };

  const years = Array.from({ length: 15 }, (_, i) => new Date().getFullYear() - i);

  return (
    <ItemModal
      isOpen={isOpen}
      onClose={onClose}
      title={initialData ? "Edit Past Examination Paper" : "Upload Past Paper"}
      subtitle="Grade 5 Scholarship official paper or model exam PDF"
      onSubmit={handleSubmit}
      submitLabel={initialData ? "Update Paper" : "Save Paper"}
      loading={loading}
    >
      <div className="space-y-4">
        {/* Title */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Paper Title
          </label>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
            placeholder="e.g. 2023 5 ශ්‍රේණිය ශිෂ්‍යත්ව විභාග ප්‍රශ්න පත්‍රය (රජයේ)"
            className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>

        {/* Year & Subject Category */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Examination Year
            </label>
            <select
              value={year}
              onChange={(e) => setYear(Number(e.target.value))}
              className="w-full py-2.5 px-3 rounded-xl glass-input text-xs focus:outline-none bg-[#120E33]"
            >
              {years.map((y) => (
                <option key={y} value={y} className="bg-[#16123D] text-white">
                  {y}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Subject Classification
            </label>
            <input
              type="text"
              value={subject}
              onChange={(e) => setSubject(e.target.value)}
              placeholder="e.g. Mathematics, General Paper"
              className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
            />
          </div>
        </div>

        {/* PDF File URL */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            PDF Download / Document URL
          </label>
          <input
            type="url"
            value={pdfUrl}
            onChange={(e) => setPdfUrl(e.target.value)}
            required
            placeholder="https://firebasestorage.googleapis.com/.../exam_2023.pdf"
            className="w-full p-2.5 rounded-xl glass-input text-xs focus:outline-none"
          />
          {pdfUrl && (
            <div className="mt-2 flex items-center gap-2">
              <a
                href={pdfUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[11px] text-purple-400 hover:text-purple-300 font-semibold inline-flex items-center gap-1"
              >
                <span>Test Open PDF</span>
                <ExternalLink className="w-3 h-3" />
              </a>
            </div>
          )}
        </div>
      </div>
    </ItemModal>
  );
}
