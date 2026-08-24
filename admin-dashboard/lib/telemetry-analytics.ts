import {
  Student,
  QuestionAttempt,
  SkillMetric,
  StudentAnalyticsSummary,
} from "@/types";

/**
 * Skill dictionary mapping raw skillTags to user-friendly Sinhala and English titles.
 */
export const SKILL_LABELS: Record<string, { si: string; en: string }> = {
  place_value_identification: {
    si: "ස්ථානීය අගය හඳුනාගැනීම",
    en: "Place Value Identification",
  },
  place_value_comparison: {
    si: "ස්ථානීය අගය සංසන්දනය",
    en: "Place Value Comparison",
  },
  expanded_form: {
    si: "සංඛ්‍යා විහිදුවා ලිවීම",
    en: "Expanded Form Notation",
  },
  number_ordering: {
    si: "සංඛ්‍යා පටිපාටිගත කිරීම (ආරෝහණ/අවරෝහණ)",
    en: "Number Ordering (Ascending / Descending)",
  },
  digit_builder: {
    si: "ඉලක්කම් කාඩ්පත් මඟින් සංඛ්‍යා ගොඩනැගීම",
    en: "Digit Construction from Cards",
  },
  large_numbers_reading: {
    si: "100,000 දක්වා විශාල සංඛ්‍යා කියවීම",
    en: "Reading Large Numbers up to 100,000",
  },
  abacus_representation: {
    si: "ඇබකසයේ සංඛ්‍යා නිරූපණය",
    en: "Abacus Representation",
  },
  place_value_word_form: {
    si: "සංඛ්‍යා වචනයෙන් ලිවීම හා කියවීම",
    en: "Word Form to Standard Form",
  },
  train_concept: {
    si: "දුම්රිය මැදිරි සංසන්දනය",
    en: "Number Train Comparison",
  },
  math_concept: {
    si: "මූලික ගණිත සංකල්ප",
    en: "Foundational Place Value",
  },
};

/**
 * Format raw skill tag into readable Sinhala / English label
 */
export function getSkillLabel(tag: string): { si: string; en: string } {
  const normalized = (tag || "").toLowerCase().trim();
  if (SKILL_LABELS[normalized]) {
    return SKILL_LABELS[normalized];
  }

  // Fallback prettification
  const formattedEn = tag
    .replace(/_/g, " ")
    .replace(/\b\w/g, (l) => l.toUpperCase());

  return {
    si: formattedEn,
    en: formattedEn,
  };
}

/**
 * Analytics Engine:
 * Takes an array of QuestionAttempt objects and computes:
 * - Aggregated SkillMetrics per skillTag
 * - Strengths list (accuracy >= 80%)
 * - Focus Areas list (accuracy < 70% OR hintUsage >= 50%)
 * - Developing list (70% <= accuracy < 80%)
 * - Overall class-wide/student metrics
 */
export function calculateSkillMetrics(
  attempts: QuestionAttempt[]
): StudentAnalyticsSummary {
  if (!attempts || attempts.length === 0) {
    return {
      metrics: [],
      strengths: [],
      focusAreas: [],
      developing: [],
      overallAccuracy: 0,
      totalAttempts: 0,
      totalHintsUsed: 0,
      avgTimeTaken: 0,
    };
  }

  // Group attempts by skillTag
  const grouped = new Map<string, QuestionAttempt[]>();

  let totalCorrect = 0;
  let totalHints = 0;
  let totalTime = 0;

  for (const att of attempts) {
    const tag = att.skillTag || "math_concept";
    if (!grouped.has(tag)) {
      grouped.set(tag, []);
    }
    grouped.get(tag)!.push(att);

    if (att.isCorrect) totalCorrect++;
    if (att.hintUsed) totalHints++;
    if (typeof att.timeTaken === "number") totalTime += att.timeTaken;
  }

  const metrics: SkillMetric[] = [];
  const strengths: SkillMetric[] = [];
  const focusAreas: SkillMetric[] = [];
  const developing: SkillMetric[] = [];

  grouped.forEach((attList, skillTag) => {
    const total = attList.length;
    const correct = attList.filter((a) => a.isCorrect).length;
    const hints = attList.filter((a) => a.hintUsed).length;
    const accuracy = total > 0 ? Math.round((correct / total) * 100) : 0;
    const hintUsagePct = total > 0 ? Math.round((hints / total) * 100) : 0;

    const timeSum = attList.reduce(
      (acc, curr) => acc + (Number(curr.timeTaken) || 0),
      0
    );
    const avgTime = total > 0 ? Math.round(timeSum / total) : 0;

    const label = getSkillLabel(skillTag);

    let status: "strength" | "focus" | "developing" = "developing";
    if (accuracy >= 80 && hintUsagePct < 50) {
      status = "strength";
    } else if (accuracy < 70 || hintUsagePct >= 50) {
      status = "focus";
    } else {
      status = "developing";
    }

    const metric: SkillMetric = {
      skillTag,
      skillNameSi: label.si,
      skillNameEn: label.en,
      totalAttempts: total,
      correctAttempts: correct,
      accuracyPercentage: accuracy,
      hintsUsedCount: hints,
      hintUsagePercentage: hintUsagePct,
      avgTimeSeconds: avgTime,
      status,
    };

    metrics.push(metric);

    if (status === "strength") {
      strengths.push(metric);
    } else if (status === "focus") {
      focusAreas.push(metric);
    } else {
      developing.push(metric);
    }
  });

  // Sort: Focus areas first by lowest accuracy, Strengths by highest accuracy
  focusAreas.sort((a, b) => a.accuracyPercentage - b.accuracyPercentage);
  strengths.sort((a, b) => b.accuracyPercentage - a.accuracyPercentage);
  metrics.sort((a, b) => b.totalAttempts - a.totalAttempts);

  const overallAccuracy =
    attempts.length > 0 ? Math.round((totalCorrect / attempts.length) * 100) : 0;
  const avgTimeTaken =
    attempts.length > 0 ? Math.round(totalTime / attempts.length) : 0;

  return {
    metrics,
    strengths,
    focusAreas,
    developing,
    overallAccuracy,
    totalAttempts: attempts.length,
    totalHintsUsed: totalHints,
    avgTimeTaken,
  };
}

/**
 * Generate targeted pedagogical recommendation for weak skills
 */
export function getRemediationAdvice(metric: SkillMetric): {
  actionSi: string;
  lessonRef: string;
} {
  switch (metric.skillTag) {
    case "expanded_form":
      return {
        actionSi: "ස්ථානීය අගය සංඛ්‍යා විහිදුවා ලියන ආකාරය (60,000 + 8,000 + ...) නැවත පුහුණු කරන්න.",
        lessonRef: "පාඩම 1 - සංකල්පය 5: නිධන් පෙට්ටිය විවෘත කිරීම",
      };
    case "place_value_comparison":
    case "train_concept":
      return {
        actionSi: "ඉහළම ස්ථානීය අගයේ (දසදහස්ස්ථානය) සිට සංසන්දනය කිරීමේ රීතිය සමාලෝචනය කරන්න.",
        lessonRef: "පාඩම 2 - සංකල්පය 1: පළමු නැවතුම – සංඛ්‍යා සසඳමු",
      };
    case "number_ordering":
      return {
        actionSi: "ආරෝහණ (කුඩා ➔ විශාල) සහ අවරෝහණ (විශාල ➔ කුඩා) පිළිවෙළ දුම්රිය මැදිරි මඟින් පැහැදිලි කරන්න.",
        lessonRef: "පාඩම 2 - සංකල්පය 2: දුම්රිය මැදිරි පේළිගත කිරීම",
      };
    case "digit_builder":
      return {
        actionSi: "විශාලම සංඛ්‍යාව සෑදීමට විශාලම ඉලක්කම් ඉහළම ස්ථානවලට තැබීමේ සංකල්පය පහදන්න.",
        lessonRef: "පාඩම 2 - සංකල්පය 3: ඉලක්කම් පත්‍ර දුම්රිය",
      };
    case "large_numbers_reading":
      return {
        actionSi: "10,000 සිට 100,000 දක්වා සංඛ්‍යාවල දහස් කාණ්ඩය එකවර කියවීමට හුරු කරන්න.",
        lessonRef: "පාඩම 1 - සංකල්පය 3: යෝධයාගේ දොරටුව",
      };
    case "abacus_representation":
      return {
        actionSi: "ඇබකසයේ කණුවල එක් එක් පබළුවකින් නිරූපණය වන ස්ථානීය අගයන් පුනරීක්ෂණය කරන්න.",
        lessonRef: "පාඩම 1 - සංකල්පය 2: පබළු ගඟ",
      };
    default:
      return {
        actionSi: "මූලික ස්ථානීය අගය සංකල්ප සහ පියවරෙන් පියවර විසඳුම් ක්‍රමය පරීක්ෂා කරන්න.",
        lessonRef: "පාඩම 1 - ස්ථානීය අගය හඳුනාගැනීම",
      };
  }
}

/**
 * 📊 Export Student Question Telemetry Attempts to CSV File
 */
export function exportStudentTelemetryToCsv(
  student: Student,
  attempts: QuestionAttempt[]
): void {
  if (typeof window === "undefined") return;

  const headers = [
    "Attempt #",
    "Student ID",
    "Student Name",
    "Grade",
    "District",
    "School",
    "Skill Category",
    "Skill Name (Sinhala)",
    "Result",
    "Hint Used",
    "Time Taken (seconds)",
    "Concept Reference",
    "Timestamp",
  ];

  const rows = attempts.map((att, idx) => {
    const skillSi = SKILL_LABELS[att.skillTag]?.si || att.skillTag;
    const timeStr =
      typeof att.timestamp === "object" && att.timestamp?.toDate
        ? att.timestamp.toDate().toISOString()
        : att.timestamp || new Date().toISOString();

    return [
      idx + 1,
      `"${student.id || ""}"`,
      `"${student.name.replace(/"/g, '""')}"`,
      student.grade || 5,
      `"${student.district || ""}"`,
      `"${(student.school || "").replace(/"/g, '""')}"`,
      `"${att.skillTag}"`,
      `"${skillSi}"`,
      att.isCorrect ? "Correct" : "Incorrect",
      att.hintUsed ? "Yes" : "No",
      att.timeTaken || 0,
      `"${att.conceptId || "Interactive Lesson"}"`,
      `"${timeStr}"`,
    ].join(",");
  });

  const csvContent =
    "data:text/csv;charset=utf-8,\uFEFF" + [headers.join(","), ...rows].join("\n");

  const encodedUri = encodeURI(csvContent);
  const link = document.createElement("a");
  const cleanName = student.name
    .replace(/[^a-zA-Z0-9_\u0D80-\u0DFF]/g, "_")
    .slice(0, 30);
  link.setAttribute("href", encodedUri);
  link.setAttribute(
    "download",
    `SisuPal_Telemetry_${cleanName}_G${student.grade || 5}.csv`
  );
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
