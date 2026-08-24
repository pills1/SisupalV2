"use client";

import React, { useState, useEffect } from "react";
import ItemModal from "@/components/ItemModal";
import { Question, SubjectType } from "@/types";
import { CheckCircle2, HelpCircle } from "lucide-react";

interface QuestionModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (question: Omit<Question, "id">) => Promise<void>;
  initialData?: Question | null;
  loading?: boolean;
}

const SUBJECTS: SubjectType[] = ["Mathematics", "Sinhala", "Environment", "English"];

export default function QuestionModal({
  isOpen,
  onClose,
  onSave,
  initialData,
  loading = false,
}: QuestionModalProps) {
  const [subject, setSubject] = useState<SubjectType>("Mathematics");
  const [questionText, setQuestionText] = useState("");
  const [options, setOptions] = useState<string[]>(["", "", "", ""]);
  const [correctOptionIndex, setCorrectOptionIndex] = useState<number>(0);
  const [explanation, setExplanation] = useState("");

  useEffect(() => {
    if (initialData) {
      setSubject(initialData.subject || "Mathematics");
      setQuestionText(initialData.questionText || "");
      const opts = initialData.options && initialData.options.length === 4
        ? [...initialData.options]
        : ["", "", "", ""];
      setOptions(opts);
      setCorrectOptionIndex(initialData.correctOptionIndex ?? 0);
      setExplanation(initialData.explanation || "");
    } else {
      setSubject("Mathematics");
      setQuestionText("");
      setOptions(["", "", "", ""]);
      setCorrectOptionIndex(0);
      setExplanation("");
    }
  }, [initialData, isOpen]);

  const handleOptionChange = (index: number, val: string) => {
    const updated = [...options];
    updated[index] = val;
    setOptions(updated);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSave({
      subject,
      questionText: questionText.trim(),
      options: options.map((o) => o.trim()),
      correctOptionIndex,
      explanation: explanation.trim(),
    });
  };

  return (
    <ItemModal
      isOpen={isOpen}
      onClose={onClose}
      title={initialData ? "Edit Practice Question" : "Create Practice Question"}
      subtitle="Multi-subject Question Bank item for student practice exams"
      onSubmit={handleSubmit}
      submitLabel={initialData ? "Update Question" : "Create Question"}
      loading={loading}
    >
      <div className="space-y-4">
        {/* Subject Dropdown */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Curriculum Subject
          </label>
          <select
            value={subject}
            onChange={(e) => setSubject(e.target.value as SubjectType)}
            className="w-full py-2.5 px-3 rounded-xl glass-input text-xs focus:outline-none bg-[#120E33]"
          >
            {SUBJECTS.map((sub) => (
              <option key={sub} value={sub} className="bg-[#16123D] text-white">
                {sub}
              </option>
            ))}
          </select>
        </div>

        {/* Question Text */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Question Text (Sinhala or English)
          </label>
          <textarea
            value={questionText}
            onChange={(e) => setQuestionText(e.target.value)}
            rows={3}
            required
            placeholder="e.g. 5,421 හි 4 ඉලක්කමේ ස්ථානීය අගය කුමක්ද?"
            className="w-full p-3 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>

        {/* 4 Options with Correct Answer Selector */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider">
              Answer Options (Select the correct option)
            </label>
            <span className="text-[10px] text-purple-300">Option {String.fromCharCode(65 + correctOptionIndex)} is marked correct</span>
          </div>

          <div className="space-y-2.5">
            {options.map((opt, idx) => {
              const isSelected = correctOptionIndex === idx;
              const letter = String.fromCharCode(65 + idx);

              return (
                <div
                  key={idx}
                  onClick={() => setCorrectOptionIndex(idx)}
                  className={`flex items-center gap-3 p-2.5 rounded-xl border transition-all cursor-pointer ${
                    isSelected
                      ? "bg-purple-950/40 border-purple-500/60 shadow-md shadow-purple-900/20"
                      : "bg-[#120E33]/60 border-slate-800 hover:border-slate-700"
                  }`}
                >
                  <div
                    className={`w-6 h-6 rounded-lg flex items-center justify-center font-bold text-xs flex-shrink-0 transition-colors ${
                      isSelected
                        ? "bg-purple-600 text-white shadow-sm shadow-purple-600/50"
                        : "bg-slate-800 text-slate-400"
                    }`}
                  >
                    {letter}
                  </div>

                  <input
                    type="text"
                    value={opt}
                    onChange={(e) => handleOptionChange(idx, e.target.value)}
                    placeholder={`Option ${letter} text...`}
                    required
                    className="flex-1 bg-transparent border-none text-xs text-white focus:outline-none placeholder:text-slate-600"
                  />

                  <div className="flex-shrink-0">
                    <CheckCircle2
                      className={`w-4 h-4 transition-colors ${
                        isSelected ? "text-purple-400" : "text-slate-700"
                      }`}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Worked Explanation */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
            Worked Explanation (Optional)
          </label>
          <textarea
            value={explanation}
            onChange={(e) => setExplanation(e.target.value)}
            rows={2}
            placeholder="Step-by-step reasoning shown to students after answering..."
            className="w-full p-3 rounded-xl glass-input text-xs focus:outline-none"
          />
        </div>
      </div>
    </ItemModal>
  );
}
