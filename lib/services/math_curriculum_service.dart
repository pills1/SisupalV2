import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maths/golden_mango_exercise_models.dart';
import '../models/maths/golden_mango_models.dart';
import '../models/maths/number_train_models.dart';
import '../data/maths/golden_mango_data.dart';
import '../data/maths/golden_mango_exercise_data.dart';
import '../data/maths/number_train_data.dart';

/// Service responsible for real-time Firestore synchronization and offline caching
/// for Grade 5 Interactive Math Lessons, Concepts, Questions, and Story Quests.
class MathCurriculumService {
  static final MathCurriculumService _instance =
      MathCurriculumService._internal();
  factory MathCurriculumService() => _instance;
  MathCurriculumService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cached memory data
  final Map<String, dynamic> _cachedLessons = {};
  final Map<String, dynamic> _cachedStoryQuests = {};

  bool _isInitialized = false;

  /// Initialize real-time streams to keep offline cache and memory up to date
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Listen to math_lessons in real-time
    _firestore.collection('math_lessons').snapshots().listen(
      (snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final id = doc.id;
          final conceptId = data['conceptId']?.toString() ?? id;
          _cachedLessons[id] = data;
          _cachedLessons[conceptId] = data;
        }
      },
      onError: (e) {
        debugPrint('MathCurriculumService math_lessons stream error: $e');
      },
    );

    // Listen to story_quests in real-time
    _firestore.collection('story_quests').snapshots().listen(
      (snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final id = doc.id;
          final conceptId = data['conceptId']?.toString() ?? id;
          _cachedStoryQuests[id] = data;
          _cachedStoryQuests[conceptId] = data;
        }
      },
      onError: (e) {
        debugPrint('MathCurriculumService story_quests stream error: $e');
      },
    );
  }

  /// Live Stream of math_lessons collection
  Stream<QuerySnapshot<Map<String, dynamic>>> getMathLessonsStream() {
    return _firestore.collection('math_lessons').snapshots();
  }

  /// Live Stream of story_quests collection
  Stream<QuerySnapshot<Map<String, dynamic>>> getStoryQuestsStream() {
    return _firestore.collection('story_quests').snapshots();
  }

  /// Check if a lesson is published
  bool isLessonPublished(String lessonId) {
    final lessonData = _cachedLessons[lessonId] ??
        _cachedLessons['lesson_1_golden_mango'] ??
        _cachedLessons['lesson_2_number_train'];
    if (lessonData == null) return true; // Default to published
    final status = lessonData['status']?.toString().toLowerCase();
    return status != 'draft';
  }

  // ─── GOLDEN MANGO QUESTIONS (LESSON 1) ─────────────────────────────────────

  /// Fetch 6 questions for a concept in Lesson 1 (Golden Mango)
  /// Checks live Firestore / cache first; falls back to bundled data.
  Future<List<GoldenMangoQuestion>> getGoldenMangoQuestions(
      String conceptId) async {
    try {
      // 1. Try fetching from Firestore collection 'math_lessons'
      final doc = await _firestore
          .collection('math_lessons')
          .doc('lesson_1_golden_mango')
          .get(const GetOptions(source: Source.cache));

      Map<String, dynamic>? data = doc.data();
      if (data == null) {
        final serverDoc = await _firestore
            .collection('math_lessons')
            .doc('lesson_1_golden_mango')
            .get();
        data = serverDoc.data();
      }

      if (data != null && data['concepts'] is List) {
        final concepts = data['concepts'] as List;
        final conceptMap = concepts.firstWhere(
          (c) =>
              c is Map &&
              (c['id'] == conceptId || c['conceptId'] == conceptId),
          orElse: () => null,
        );

        if (conceptMap != null && conceptMap['questions'] is List) {
          final questionsList = conceptMap['questions'] as List;
          if (questionsList.isNotEmpty) {
            final parsedQuestions = <GoldenMangoQuestion>[];

            for (final q in questionsList) {
              if (q is! Map) continue;
              final qMap = Map<String, dynamic>.from(q);

              // Map options
              final rawOptions = qMap['options'] as List? ?? [];
              final correctAnswer = qMap['correctAnswer']?.toString() ?? '';
              final options = rawOptions.map((opt) {
                final optStr = opt.toString();
                return ExerciseOption(
                  text: optStr,
                  isCorrect: optStr == correctAnswer,
                );
              }).toList();

              parsedQuestions.add(
                GoldenMangoQuestion(
                  id: qMap['id']?.toString() ?? 'q_${parsedQuestions.length}',
                  conceptId: conceptId,
                  questionType: _parseGoldenMangoQuestionType(
                      qMap['interactionType']?.toString()),
                  questionText: qMap['questionText']?.toString() ?? '',
                  options: options,
                  correctAnswer: correctAnswer,
                  skillTag: qMap['skillTag']?.toString() ?? 'math_concept',
                  difficulty: (qMap['difficulty'] as num?)?.toInt() ?? 1,
                  hintLevel1: qMap['hintLevel1']?.toString() ?? '',
                  hintLevel2: qMap['hintLevel2']?.toString() ?? '',
                  explanation: qMap['workedSolution']?.toString() ??
                      qMap['explanation']?.toString() ??
                      '',
                  extraData: qMap['extraData'] is Map
                      ? Map<String, dynamic>.from(qMap['extraData'])
                      : (qMap['digits'] != null
                          ? {'digits': qMap['digits'], 'targetAnswer': correctAnswer}
                          : null),
                ),
              );
            }

            if (parsedQuestions.isNotEmpty) {
              return parsedQuestions;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('MathCurriculumService: Reading GoldenMango fallback due to $e');
    }

    // Default Fallback to local data
    return GoldenMangoExerciseData.getQuestionsForConcept(conceptId);
  }

  // ─── NUMBER TRAIN CHALLENGES (LESSON 2) ───────────────────────────────────

  /// Fetch 6 challenges for a concept in Lesson 2 (Number Train)
  /// Checks live Firestore / cache first; falls back to bundled data.
  Future<List<NumberTrainChallengeModel>> getNumberTrainChallenges(
      String conceptId) async {
    try {
      final doc = await _firestore
          .collection('math_lessons')
          .doc('lesson_2_number_train')
          .get(const GetOptions(source: Source.cache));

      Map<String, dynamic>? data = doc.data();
      if (data == null) {
        final serverDoc = await _firestore
            .collection('math_lessons')
            .doc('lesson_2_number_train')
            .get();
        data = serverDoc.data();
      }

      if (data != null && data['concepts'] is List) {
        final concepts = data['concepts'] as List;
        final conceptMap = concepts.firstWhere(
          (c) =>
              c is Map &&
              (c['id'] == conceptId || c['conceptId'] == conceptId),
          orElse: () => null,
        );

        if (conceptMap != null && conceptMap['questions'] is List) {
          final questionsList = conceptMap['questions'] as List;
          if (questionsList.isNotEmpty) {
            final parsedChallenges = <NumberTrainChallengeModel>[];

            for (int i = 0; i < questionsList.length; i++) {
              final q = questionsList[i];
              if (q is! Map) continue;
              final qMap = Map<String, dynamic>.from(q);

              final rawOptions = qMap['options'] as List? ?? [];
              final optionsList = rawOptions.map((e) => e.toString()).toList();
              final correctAnswer = qMap['correctAnswer']?.toString() ?? '';

              parsedChallenges.add(
                NumberTrainChallengeModel(
                  id: qMap['id']?.toString() ?? 'c_q_$i',
                  conceptId: conceptId,
                  challengeNumber: i + 1,
                  interactionType: _parseNumberTrainInteractionType(
                      qMap['interactionType']?.toString(), i),
                  title: 'අභියෝගය ${i + 1}',
                  questionText: qMap['questionText']?.toString() ?? '',
                  numbers: optionsList.isNotEmpty ? optionsList : [correctAnswer],
                  correctAnswer: correctAnswer,
                  hintLevel1: qMap['hintLevel1']?.toString() ?? '',
                  hintLevel2: qMap['hintLevel2']?.toString() ?? '',
                  explanation: qMap['workedSolution']?.toString() ??
                      qMap['explanation']?.toString() ??
                      '',
                  skillTag: qMap['skillTag']?.toString() ?? 'train_concept',
                  difficulty: (qMap['difficulty'] as num?)?.toInt() ?? 1,
                ),
              );
            }

            if (parsedChallenges.isNotEmpty) {
              return parsedChallenges;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('MathCurriculumService: Reading NumberTrain fallback due to $e');
    }

    // Default Fallback to local data
    final localConcept = NumberTrainData.allConcepts.firstWhere(
      (c) => c.id == conceptId,
      orElse: () => NumberTrainData.concept1,
    );
    return localConcept.challenges;
  }

  // ─── STORY QUEST DIALOGUES (LESSON 1 & LESSON 2) ─────────────────────────

  /// Fetch story beats for Lesson 1 (Golden Mango) concept
  Future<List<StoryBeat>> getGoldenMangoStoryBeats(String conceptId) async {
    try {
      final docId = 'quest_$conceptId';
      final doc = await _firestore
          .collection('story_quests')
          .doc(docId)
          .get(const GetOptions(source: Source.cache));

      Map<String, dynamic>? data = doc.data();
      if (data == null) {
        final serverDoc =
            await _firestore.collection('story_quests').doc(docId).get();
        data = serverDoc.data();
      }

      if (data != null && data['storySequence'] is List) {
        final sequence = data['storySequence'] as List;
        if (sequence.isNotEmpty) {
          final beats = <StoryBeat>[];
          for (int i = 0; i < sequence.length; i++) {
            final item = sequence[i];
            if (item is! Map) continue;
            final itemMap = Map<String, dynamic>.from(item);

            final speakerStr = itemMap['speaker']?.toString().toLowerCase() ?? 'leo';
            StoryCharacter speaker = StoryCharacter.leo;
            if (speakerStr.contains('ella')) speaker = StoryCharacter.ella;
            if (speakerStr.contains('felix')) speaker = StoryCharacter.felix;

            beats.add(
              StoryBeat(
                speaker: speaker,
                text: itemMap['dialogueText']?.toString() ?? '',
                isFinal: i == sequence.length - 1,
              ),
            );
          }
          if (beats.isNotEmpty) {
            return beats;
          }
        }
      }
    } catch (e) {
      debugPrint('MathCurriculumService: StoryBeat fallback due to $e');
    }

    // Fallback to local story data
    final concept = GoldenMangoData.concepts.firstWhere(
      (c) => c.id == conceptId,
      orElse: () => GoldenMangoData.concepts.first,
    );
    return concept.beats;
  }

  /// Fetch story beats for Lesson 2 (Number Train) concept
  Future<List<NumberTrainStoryBeatModel>> getNumberTrainStoryBeats(
      String conceptId) async {
    try {
      final docId = 'quest_$conceptId';
      final doc = await _firestore
          .collection('story_quests')
          .doc(docId)
          .get(const GetOptions(source: Source.cache));

      Map<String, dynamic>? data = doc.data();
      if (data == null) {
        final serverDoc =
            await _firestore.collection('story_quests').doc(docId).get();
        data = serverDoc.data();
      }

      if (data != null && data['storySequence'] is List) {
        final sequence = data['storySequence'] as List;
        if (sequence.isNotEmpty) {
          final beats = <NumberTrainStoryBeatModel>[];
          for (final item in sequence) {
            if (item is! Map) continue;
            final itemMap = Map<String, dynamic>.from(item);

            final speakerStr = itemMap['speaker']?.toString().toLowerCase() ?? 'leo';
            TrainStorySpeaker speaker = TrainStorySpeaker.leo;
            String speakerNameSi = 'ලියෝ';
            if (speakerStr.contains('ella')) {
              speaker = TrainStorySpeaker.ella;
              speakerNameSi = 'එළි';
            } else if (speakerStr.contains('felix')) {
              speaker = TrainStorySpeaker.felix;
              speakerNameSi = 'ෆීලික්ස්';
            }

            final hasGate = itemMap['hasInteractiveGate'] == true;
            final gateOptions = itemMap['gateOptions'] as List? ?? [];
            final wrongOpt = gateOptions.isNotEmpty ? gateOptions[0]?.toString() : null;
            final correctOpt = gateOptions.length > 1 ? gateOptions[1]?.toString() : null;

            beats.add(
              NumberTrainStoryBeatModel(
                speaker: speaker,
                speakerNameSi: speakerNameSi,
                dialogueSi: itemMap['dialogueText']?.toString() ?? '',
                isInteractiveChoice: hasGate,
                choicePromptSi: itemMap['gateQuestion']?.toString(),
                wrongOptionText: wrongOpt,
                correctOptionText: correctOpt,
                wrongFeedbackSi: 'නැවත උත්සාහ කරමු!',
              ),
            );
          }
          if (beats.isNotEmpty) {
            return beats;
          }
        }
      }
    } catch (e) {
      debugPrint('MathCurriculumService: NumberTrain story fallback due to $e');
    }

    // Fallback to local number train story data
    final concept = NumberTrainData.allConcepts.firstWhere(
      (c) => c.id == conceptId,
      orElse: () => NumberTrainData.concept1,
    );
    return concept.storyBeats;
  }

  // ─── TYPE PARSING HELPERS ──────────────────────────────────────────────────

  GoldenMangoQuestionType _parseGoldenMangoQuestionType(String? typeStr) {
    switch (typeStr) {
      case 'multipleChoice':
        return GoldenMangoQuestionType.multipleChoice;
      case 'numericInput':
        return GoldenMangoQuestionType.numericInput;
      case 'placeValuePicker':
        return GoldenMangoQuestionType.placeValuePicker;
      case 'abacusChallenge':
      case 'abacusInteractive':
        return GoldenMangoQuestionType.abacusInteractive;
      case 'digitBuilder':
        return GoldenMangoQuestionType.digitBuilder;
      case 'expandedForm':
      case 'expandedFormBuilder':
        return GoldenMangoQuestionType.expandedFormBuilder;
      default:
        return GoldenMangoQuestionType.multipleChoice;
    }
  }

  NumberTrainInteractionType _parseNumberTrainInteractionType(
      String? typeStr, int challengeIndex) {
    switch (typeStr) {
      case 'digitBuilder':
        return NumberTrainInteractionType.digitBuilder;
      case 'ticketDrag':
        return NumberTrainInteractionType.ticketDrag;
      case 'carriageOrdering':
        return NumberTrainInteractionType.carriageOrdering;
      case 'guidedPlaceValue':
      case 'placeValuePicker':
        return NumberTrainInteractionType.guidedPlaceValue;
      case 'carriageSorting':
      case 'expandedForm':
        return NumberTrainInteractionType.carriageSorting;
      case 'masteryOrdering':
        return NumberTrainInteractionType.masteryOrdering;
      case 'tapSelection':
      case 'multipleChoice':
      case 'numericInput':
      default:
        // Default challenge map by challenge index
        switch (challengeIndex) {
          case 0:
            return NumberTrainInteractionType.tapSelection;
          case 1:
            return NumberTrainInteractionType.ticketDrag;
          case 2:
            return NumberTrainInteractionType.carriageOrdering;
          case 3:
            return NumberTrainInteractionType.guidedPlaceValue;
          case 4:
            return NumberTrainInteractionType.carriageSorting;
          case 5:
            return NumberTrainInteractionType.masteryOrdering;
          default:
            return NumberTrainInteractionType.tapSelection;
        }
    }
  }
}
