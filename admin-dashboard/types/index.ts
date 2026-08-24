export interface AdminUser {
  uid: string;
  email: string | null;
  displayName: string | null;
  role: "Admin" | "Teacher" | "Student";
  photoURL?: string | null;
}

export interface NavItem {
  name: string;
  href: string;
  iconName: string;
  badge?: string;
  description?: string;
}

export interface DashboardMetric {
  title: string;
  value: number | string;
  iconName: string;
  change?: string;
  isPositive?: boolean;
  color: string;
}

export interface ToastMessage {
  id: string;
  title: string;
  description?: string;
  type: "success" | "error" | "info" | "warning";
}

// ─── PHASE 2: MEDIA & QUESTION BANK TYPES ────────────────────────────────────

export type SubjectType = "Mathematics" | "Maths" | "Sinhala" | "Environment" | "English";

export interface Question {
  id?: string;
  questionText: string;
  subject: SubjectType;
  grade?: number;
  options: string[]; // exactly 4 items
  correctOptionIndex?: number; // 0 to 3
  correctAnswer?: string;
  explanation?: string;
  explanationSi?: string;
  difficulty?: number;
  skillTag?: string;
  createdAt?: any;
  updatedAt?: any;
}

export type VideoCategory =
  | "mathematics"
  | "sinhala"
  | "english"
  | "environment"
  | "past_papers";

export interface Video {
  id?: string;
  title: string;
  videoUrl: string;
  thumbnailUrl: string;
  category: VideoCategory;
  targetGrade: number;
  duration: string;
  description: string;
  timestamp?: any;
  createdAt?: any;
  updatedAt?: any;
}

export interface Paper {
  id?: string;
  title: string;
  year: number;
  pdfUrl: string;
  subject?: string;
  timestamp?: any;
  createdAt?: any;
  updatedAt?: any;
}

// ─── PHASE 3: GAME TEMPLATES CMS TYPES ───────────────────────────────────────

export type GameTemplateStatus = "draft" | "published";

export type GameTemplateType =
  | "abacus"
  | "lily_pad_leap"
  | "number_archery"
  | "digit_builder"
  | "place_value"
  | "expanded_form"
  | "rapid_fire";

export interface AbacusGameData {
  targetNumber: number;
  placeValues: string[]; // e.g. ["දහස්", "සිය", "දහය", "එකක"]
  instruction?: string;
  maxBeadsPerRod?: number;
  allowDragDrop?: boolean;
}

export interface LilyPadLeapGameData {
  sequence: (number | null)[]; // e.g. [12, 24, null, 48, 60]
  missingIndex: number; // e.g. 2
  correctAnswer: number; // e.g. 36
  distractorOptions: number[]; // e.g. [30, 32, 40]
  ruleDescription?: string; // e.g. "Add 12 pattern (+12)"
  timeLimitSeconds?: number;
}

export interface NumberArcheryGameData {
  targetEquation: string;
  targetResult: number;
  availableArrows: number[];
  hitZoneCount?: number;
}

export interface DigitBuilderGameData {
  targetValue: number;
  allowedDigits: number[];
  constraintDescription?: string;
}

export interface PlaceValueGameData {
  number: number;
  highlightedDigitIndex: number;
  correctPlaceValueName: string;
  options: string[];
}

export interface ExpandedFormGameData {
  standardNumber: number;
  expandedParts: string[];
  missingPartIndex: number;
  correctPart: string;
  distractors: string[];
}

export interface RapidFireGameData {
  timePerQuestionSeconds: number;
  totalQuestions: number;
  operationType: "addition" | "subtraction" | "multiplication" | "mixed";
  maxNumberRange: number;
}

export type MathGameData =
  | AbacusGameData
  | LilyPadLeapGameData
  | NumberArcheryGameData
  | DigitBuilderGameData
  | PlaceValueGameData
  | ExpandedFormGameData
  | RapidFireGameData
  | Record<string, any>;

export interface MathGameBase {
  id?: string;
  title: string;
  description?: string;
  templateType: GameTemplateType;
  status: GameTemplateStatus;
  grade?: number;
  conceptId?: string;
  gameData: MathGameData;
  createdAt?: any;
  updatedAt?: any;
}

// ─── PHASE 4: LESSONS & STORY QUESTS CMS TYPES ───────────────────────────────

export type StoryCharacter = "Leo" | "Ella" | "Felix" | "Parrot";

export interface StoryBeat {
  id: string;
  speaker: StoryCharacter;
  dialogueText: string;
  hasInteractiveGate: boolean;
  gateQuestion?: string;
  gateOptions?: string[];
  gateCorrectIndex?: number;
}

export interface StoryQuest {
  id?: string;
  title: string;
  conceptId: string;
  chapterNumber?: number;
  status: "draft" | "published";
  grade: number;
  storySequence: StoryBeat[];
  createdAt?: any;
  updatedAt?: any;
}

export type ExerciseInteractionType =
  | "multipleChoice"
  | "numericInput"
  | "placeValuePicker"
  | "abacusChallenge"
  | "digitBuilder"
  | "expandedForm";

export interface ExerciseStep {
  id: string;
  conceptId?: string;
  interactionType: ExerciseInteractionType;
  questionText: string;
  options?: string[]; // for multipleChoice or placeValuePicker
  correctAnswer: string | number;
  hintLevel1: string; // Attempt 1: Light Hint
  hintLevel2: string; // Attempt 2: Guided Reasoning
  workedSolution: string; // Attempt 3: Full Worked Solution
  skillTag?: string;
  difficulty?: number;
  xpReward?: number;
}

export interface LessonConcept {
  id: string;
  conceptId: string; // e.g. c1_jungle_map
  title: string;
  subtitle?: string;
  learningObjective: string;
  orderIndex: number;
  questions: ExerciseStep[]; // 6 questions per concept
}

export interface LessonModule {
  id?: string;
  title: string;
  lessonNumber?: number;
  description?: string;
  conceptId?: string;
  status: "draft" | "published";
  grade: number;
  concepts?: LessonConcept[]; // 5 to 6 concepts per lesson
  exercises?: ExerciseStep[]; // fallback flat exercises
  storySequence?: StoryBeat[];
  createdAt?: any;
  updatedAt?: any;
}

// ─── PHASE 5: STUDENT ROSTER & CLASS-WIDE TELEMETRY ─────────────────────────

export interface Student {
  id?: string;
  name: string;
  grade: number;
  district: string;
  xp: number;
  streak: number;
  lastActiveDate: string | Date | any;
  avatarUrl?: string;
  email?: string;
  school?: string;
  role?: string;
  isStudent?: boolean;
  totalQuestionsAttempted?: number;
  overallAccuracy?: number;
  questionAttempts?: QuestionAttempt[];
  createdAt?: any;
  updatedAt?: any;
}

export interface QuestionAttempt {
  id?: string;
  skillTag: string;
  isCorrect: boolean;
  hintUsed: boolean;
  timeTaken: number; // in seconds
  timestamp: any;
  questionId?: string;
  conceptId?: string;
  lessonId?: string;
  attemptNumber?: number;
  answerGiven?: string;
  correctAnswer?: string;
}

export interface SkillMetric {
  skillTag: string;
  skillNameSi: string;
  skillNameEn: string;
  totalAttempts: number;
  correctAttempts: number;
  accuracyPercentage: number;
  hintsUsedCount: number;
  hintUsagePercentage: number;
  avgTimeSeconds: number;
  status: "strength" | "focus" | "developing";
}

export interface StudentAnalyticsSummary {
  metrics: SkillMetric[];
  strengths: SkillMetric[];
  focusAreas: SkillMetric[];
  developing: SkillMetric[];
  overallAccuracy: number;
  totalAttempts: number;
  totalHintsUsed: number;
  avgTimeTaken: number;
}
