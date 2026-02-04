import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/data/form_data_models.dart';

final testAssessmentInfo = AssessmentInfo(
  state: "Test State",
  jurisdiction: "Test Jurisdiction",
  questionInfoIds: [
    [
      "test-question-info-id-0-0",
      "test-question-info-id-0-1",
      "test-question-info-id-0-2",
    ],
    ["test-question-info-id-0-0", "test-question-info-id-0-1"],
  ],
  recommendationsInfoId: 'test-recommendations-info-id',
);

final testStaticData1 = StaticData(
  assessmentInfoMap: {
    'ai1': AssessmentInfo(
      state: 's1',
      jurisdiction: 'j1',
      questionInfoIds: [
        ['qi1', 'qi2', 'qi3'],
        ['qi1', 'qi2'],
      ],
      recommendationsInfoId: 'ri1',
    ),
    'ai2': AssessmentInfo(
      state: 's2',
      jurisdiction: 'j2',
      questionInfoIds: [
        ['qi3', 'qi2'],
        ['qi3', 'qi2', 'qi1'],
      ],
      recommendationsInfoId: 'ri2',
    ),
  },
  questionInfoMap: {
    'qi1': QuestionInfo(
      questionText: 'questionText1',
      useUrl: '',
      url: '',
      answers: [Answer(text: 'a1', points: 1.0)],
      answerLeadingHeader: '',
      domain: '',
      instructionsMarkdown: '',
      videoId: '',
      hint: '',
    ),
    'qi2': QuestionInfo(
      questionText: 'questionText2',
      useUrl: '',
      url: '',
      answers: [
        Answer(text: 'a1', points: 1.0),
        Answer(text: 'a2', points: 2.0),
      ],
      answerLeadingHeader: '',
      domain: '',
      instructionsMarkdown: '',
      videoId: '',
      hint: '',
    ),
    'qi3': QuestionInfo(
      questionText: 'questionText3',
      useUrl: '',
      url: '',
      answers: [
        Answer(text: 'a1', points: 1.0),
        Answer(text: 'a2', points: 2.0),
        Answer(text: 'a3', points: 3.0),
      ],
      answerLeadingHeader: '',
      domain: '',
      instructionsMarkdown: '',
      videoId: '',
      hint: '',
    ),
  },
  recommendationsInfoMap: {
    'ri1': RecommendationsInfo(
      s3_categories: [
        RecommendationCategory(
          categoryTitle: 'cat1',
          goodHealth: ['good1'],
          betterHealth: ['better1', 'better2'],
          bestHealth: ['best1', 'best2', 'best3'],
        ),
        RecommendationCategory(
          categoryTitle: 'cat2',
          goodHealth: ['good1', 'good2', 'good3'],
          betterHealth: ['better1', 'better2'],
          bestHealth: ['best1'],
        ),
      ],
    ),
    'ri2': RecommendationsInfo(
      s3_categories: [
        RecommendationCategory(
          categoryTitle: 'cat1',
          goodHealth: ['good1'],
          betterHealth: ['better1', 'better2'],
          bestHealth: ['best1'],
        ),
        RecommendationCategory(
          categoryTitle: 'cat2',
          goodHealth: ['good1'],
          betterHealth: ['better1', 'better2'],
          bestHealth: ['best1'],
        ),
        RecommendationCategory(
          categoryTitle: 'cat3',
          goodHealth: ['good1'],
          betterHealth: ['better1'],
          bestHealth: ['best1'],
        ),
      ],
    ),
  },
);

final testFormData1 = FormData(
  assessmentInfoId: 'ai1',
  selectedAnswerIndices: [
    [0, 1, 2],
    [0, null],
  ],
  selectedRecommendationIndices: [
    [0, 1, 2],
    [2, 1, 0],
  ],
  justifications: ['j1', 'j2'],
);
final testFormData2 = FormData(
  assessmentInfoId: 'ai2',
  selectedAnswerIndices: [
    [2, 1],
    [2, 1, 0],
  ],
  selectedRecommendationIndices: [
    [0, 1],
    [0, 1],
    [0],
  ],
  justifications: ['j1', 'j2', 'j3'],
);
