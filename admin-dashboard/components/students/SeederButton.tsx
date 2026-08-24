"use client";

import React, { useState } from "react";
import { setDocumentWithId, setSubcollectionDocWithId } from "@/lib/firestore-crud";
import { Student, QuestionAttempt } from "@/types";
import { useToast } from "@/components/Toast";
import { Sparkles, Loader2, Database } from "lucide-react";

interface SeederButtonProps {
  onSeeded?: () => void;
}

const MOCK_STUDENTS: (Student & { id: string; attempts: Omit<QuestionAttempt, "id">[] })[] = [
  {
    id: "student_kasun_01",
    name: "කසුන් පෙරේරා (Kasun Perera)",
    grade: 5,
    district: "Colombo",
    xp: 1450,
    streak: 7,
    lastActiveDate: new Date(Date.now() - 1000 * 60 * 30), // 30 mins ago
    avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Kasun",
    email: "kasun.p@sisupal.lk",
    school: "Royal College, Colombo",
    totalQuestionsAttempted: 20,
    overallAccuracy: 80,
    attempts: [
      // 6 place_value_identification (5 correct -> 83%)
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date(Date.now() - 1000 * 60 * 30), questionId: "q_p1", conceptId: "c1_jungle_map" },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date(Date.now() - 1000 * 60 * 28), questionId: "q_p2", conceptId: "c1_jungle_map" },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date(Date.now() - 1000 * 60 * 25), questionId: "q_p3", conceptId: "c1_jungle_map" },
      { skillTag: "place_value_identification", isCorrect: false, hintUsed: true, timeTaken: 22, timestamp: new Date(Date.now() - 1000 * 60 * 22), questionId: "q_p4", conceptId: "c1_jungle_map" },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date(Date.now() - 1000 * 60 * 20), questionId: "q_p5", conceptId: "c1_jungle_map" },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date(Date.now() - 1000 * 60 * 18), questionId: "q_p6", conceptId: "c1_jungle_map" },
      // 5 place_value_comparison (4 correct -> 80%)
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date(Date.now() - 1000 * 60 * 16), questionId: "q_c1", conceptId: "c1_number_train_station" },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 15, timestamp: new Date(Date.now() - 1000 * 60 * 14), questionId: "q_c2", conceptId: "c1_number_train_station" },
      { skillTag: "place_value_comparison", isCorrect: false, hintUsed: true, timeTaken: 25, timestamp: new Date(Date.now() - 1000 * 60 * 12), questionId: "q_c3", conceptId: "c1_number_train_station" },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date(Date.now() - 1000 * 60 * 10), questionId: "q_c4", conceptId: "c1_number_train_station" },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date(Date.now() - 1000 * 60 * 8), questionId: "q_c5", conceptId: "c1_number_train_station" },
      // 5 expanded_form (2 correct -> 40% - Weak Focus Area)
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 30, timestamp: new Date(Date.now() - 1000 * 60 * 6), questionId: "q_e1", conceptId: "c5_unlocking_chest" },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 18, timestamp: new Date(Date.now() - 1000 * 60 * 5), questionId: "q_e2", conceptId: "c5_unlocking_chest" },
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 28, timestamp: new Date(Date.now() - 1000 * 60 * 4), questionId: "q_e3", conceptId: "c5_unlocking_chest" },
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 35, timestamp: new Date(Date.now() - 1000 * 60 * 3), questionId: "q_e4", conceptId: "c5_unlocking_chest" },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 16, timestamp: new Date(Date.now() - 1000 * 60 * 2), questionId: "q_e5", conceptId: "c5_unlocking_chest" },
      // 4 number_ordering (3 correct -> 75% - Developing)
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date(Date.now() - 1000 * 60 * 2), questionId: "q_o1", conceptId: "c2_number_train_ordering" },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date(Date.now() - 1000 * 60 * 1), questionId: "q_o2", conceptId: "c2_number_train_ordering" },
      { skillTag: "number_ordering", isCorrect: false, hintUsed: false, timeTaken: 19, timestamp: new Date(Date.now() - 1000 * 45), questionId: "q_o3", conceptId: "c2_number_train_ordering" },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date(Date.now() - 1000 * 20), questionId: "q_o4", conceptId: "c2_number_train_ordering" },
    ],
  },
  {
    id: "student_dinithi_02",
    name: "දිනිති සිල්වා (Dinithi Silva)",
    grade: 5,
    district: "Gampaha",
    xp: 2120,
    streak: 14,
    lastActiveDate: new Date(Date.now() - 1000 * 60 * 5), // 5 mins ago
    avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Dinithi",
    email: "dinithi.s@sisupal.lk",
    school: "Holy Cross College, Gampaha",
    totalQuestionsAttempted: 20,
    overallAccuracy: 95,
    attempts: [
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 6, timestamp: new Date(), questionId: "q_d1" },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 7, timestamp: new Date(), questionId: "q_d2" },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 5, timestamp: new Date(), questionId: "q_d3" },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date(), questionId: "q_d4" },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date(), questionId: "q_d5" },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 7, timestamp: new Date(), questionId: "q_d6" },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date(), questionId: "q_d7" },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date(), questionId: "q_d8" },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date(), questionId: "q_d9" },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date(), questionId: "q_d10" },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date(), questionId: "q_d11" },
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 20, timestamp: new Date(), questionId: "q_d12" },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date(), questionId: "q_d13" },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date(), questionId: "q_d14" },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date(), questionId: "q_d15" },
      { skillTag: "digit_builder", isCorrect: true, hintUsed: false, timeTaken: 13, timestamp: new Date(), questionId: "q_d16" },
      { skillTag: "digit_builder", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date(), questionId: "q_d17" },
      { skillTag: "large_numbers_reading", isCorrect: true, hintUsed: false, timeTaken: 7, timestamp: new Date(), questionId: "q_d18" },
      { skillTag: "large_numbers_reading", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date(), questionId: "q_d19" },
      { skillTag: "large_numbers_reading", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date(), questionId: "q_d20" },
    ],
  },
  {
    id: "student_thinura_03",
    name: "තිනුර ජයවර්ධන (Thinura Jayawardena)",
    grade: 5,
    district: "Kandy",
    xp: 890,
    streak: 3,
    lastActiveDate: new Date(Date.now() - 1000 * 60 * 60 * 2), // 2 hours ago
    avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Thinura",
    email: "thinura.j@sisupal.lk",
    school: "Kingswood College, Kandy",
    totalQuestionsAttempted: 20,
    overallAccuracy: 60,
    attempts: [
      // 5 abacus_representation (4 correct -> 80% Strength)
      { skillTag: "abacus_representation", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date() },
      { skillTag: "abacus_representation", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date() },
      { skillTag: "abacus_representation", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date() },
      { skillTag: "abacus_representation", isCorrect: false, hintUsed: false, timeTaken: 15, timestamp: new Date() },
      { skillTag: "abacus_representation", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date() },
      // 6 number_ordering (2 correct -> 33% Focus Area)
      { skillTag: "number_ordering", isCorrect: false, hintUsed: true, timeTaken: 25, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: false, hintUsed: true, timeTaken: 30, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 16, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: false, hintUsed: true, timeTaken: 28, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: false, hintUsed: true, timeTaken: 32, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 18, timestamp: new Date() },
      // 5 large_numbers_reading (2 correct -> 40% Focus Area)
      { skillTag: "large_numbers_reading", isCorrect: false, hintUsed: true, timeTaken: 22, timestamp: new Date() },
      { skillTag: "large_numbers_reading", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date() },
      { skillTag: "large_numbers_reading", isCorrect: false, hintUsed: true, timeTaken: 26, timestamp: new Date() },
      { skillTag: "large_numbers_reading", isCorrect: false, hintUsed: false, timeTaken: 19, timestamp: new Date() },
      { skillTag: "large_numbers_reading", isCorrect: true, hintUsed: false, timeTaken: 15, timestamp: new Date() },
      // 4 place_value_comparison (4 correct -> 100% Strength)
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date() },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date() },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date() },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 7, timestamp: new Date() },
    ],
  },
  {
    id: "student_oshadhi_04",
    name: "ඕෂදී ප්‍රනාන්දු (Oshadhi Fernando)",
    grade: 5,
    district: "Galle",
    xp: 1780,
    streak: 9,
    lastActiveDate: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
    avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Oshadhi",
    email: "oshadhi.f@sisupal.lk",
    school: "Southlands College, Galle",
    totalQuestionsAttempted: 20,
    overallAccuracy: 75,
    attempts: [
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date() },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date() },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date() },
      { skillTag: "place_value_comparison", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date() },
      { skillTag: "digit_builder", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date() },
      { skillTag: "digit_builder", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date() },
      { skillTag: "digit_builder", isCorrect: true, hintUsed: false, timeTaken: 15, timestamp: new Date() },
      { skillTag: "digit_builder", isCorrect: false, hintUsed: true, timeTaken: 22, timestamp: new Date() },
      { skillTag: "digit_builder", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date() },
      // place_value_word_form (2 correct / 5 -> 40% Focus)
      { skillTag: "place_value_word_form", isCorrect: false, hintUsed: true, timeTaken: 25, timestamp: new Date() },
      { skillTag: "place_value_word_form", isCorrect: true, hintUsed: false, timeTaken: 13, timestamp: new Date() },
      { skillTag: "place_value_word_form", isCorrect: false, hintUsed: true, timeTaken: 28, timestamp: new Date() },
      { skillTag: "place_value_word_form", isCorrect: false, hintUsed: false, timeTaken: 18, timestamp: new Date() },
      { skillTag: "place_value_word_form", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date() },
      // expanded_form (4 correct / 6 -> 67% Focus/Developing)
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 24, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 26, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date() },
    ],
  },
  {
    id: "student_kaveen_05",
    name: "කවීන් වික්‍රමසිංහ (Kaveen Wickramasinghe)",
    grade: 5,
    district: "Jaffna",
    xp: 1220,
    streak: 5,
    lastActiveDate: new Date(Date.now() - 1000 * 60 * 60 * 5), // 5 hours ago
    avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=Kaveen",
    email: "kaveen.w@sisupal.lk",
    school: "St. John's College, Jaffna",
    totalQuestionsAttempted: 20,
    overallAccuracy: 70,
    attempts: [
      { skillTag: "train_concept", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date() },
      { skillTag: "train_concept", isCorrect: true, hintUsed: false, timeTaken: 9, timestamp: new Date() },
      { skillTag: "train_concept", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date() },
      { skillTag: "train_concept", isCorrect: true, hintUsed: false, timeTaken: 8, timestamp: new Date() },
      { skillTag: "train_concept", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date() },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date() },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date() },
      { skillTag: "place_value_identification", isCorrect: false, hintUsed: false, timeTaken: 16, timestamp: new Date() },
      { skillTag: "place_value_identification", isCorrect: true, hintUsed: false, timeTaken: 11, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 15, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 25, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: false, hintUsed: true, timeTaken: 28, timestamp: new Date() },
      { skillTag: "expanded_form", isCorrect: true, hintUsed: false, timeTaken: 13, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: false, hintUsed: true, timeTaken: 22, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 14, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: false, hintUsed: true, timeTaken: 24, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 12, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: false, hintUsed: false, timeTaken: 18, timestamp: new Date() },
      { skillTag: "number_ordering", isCorrect: true, hintUsed: false, timeTaken: 10, timestamp: new Date() },
    ],
  },
];

export default function SeederButton({ onSeeded }: SeederButtonProps) {
  const [seeding, setSeeding] = useState(false);
  const { showToast } = useToast();

  const handleSeed = async () => {
    setSeeding(true);
    try {
      let studentCount = 0;
      let attemptCount = 0;

      for (const student of MOCK_STUDENTS) {
        const { id, attempts, ...studentData } = student;

        const formattedAttempts = attempts.map((att, idx) => ({
          ...att,
          id: `att_${id}_${idx + 1}`,
          timestamp:
            typeof att.timestamp === "object"
              ? (att.timestamp as Date).toISOString()
              : att.timestamp,
        }));

        // Save directly to "users" collection (which has full write permission)
        await setDocumentWithId("users", id, {
          ...studentData,
          role: "student",
          isStudent: true,
          lastActiveDate:
            typeof studentData.lastActiveDate === "object"
              ? (studentData.lastActiveDate as Date).toISOString()
              : studentData.lastActiveDate,
          questionAttempts: formattedAttempts,
          totalQuestionsAttempted: formattedAttempts.length,
        });

        studentCount++;
        attemptCount += formattedAttempts.length;
      }

      showToast(
        `Seeded ${studentCount} students & ${attemptCount} question attempts into Firestore! 🧪✨`,
        "success"
      );

      if (onSeeded) {
        onSeeded();
      }
    } catch (error: any) {
      console.error("Error seeding telemetry data:", error);
      showToast(
        error?.message || "Failed to seed mock telemetry data.",
        "error"
      );
    } finally {
      setSeeding(false);
    }
  };

  return (
    <button
      onClick={handleSeed}
      disabled={seeding}
      className="px-3.5 py-2 rounded-xl bg-slate-900/80 hover:bg-slate-800 border border-slate-700 hover:border-emerald-500/40 text-slate-300 hover:text-emerald-300 text-xs font-semibold shadow transition-all flex items-center gap-2 cursor-pointer disabled:opacity-50"
      title="Seed 5 Demo Students with 20 Telemetry Question Attempts each"
    >
      {seeding ? (
        <>
          <Loader2 className="w-3.5 h-3.5 animate-spin text-emerald-400" />
          <span>Seeding Telemetry...</span>
        </>
      ) : (
        <>
          <Database className="w-3.5 h-3.5 text-emerald-400" />
          <span>Seed Demo Telemetry</span>
        </>
      )}
    </button>
  );
}
