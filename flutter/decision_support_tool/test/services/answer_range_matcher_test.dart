// Covers the fix for "Could not match answer range: 9-16" in Q4/Q5:
// AnswerRangeMatcher replaces exact-string matching against a hardcoded
// (and, for pedestrian/bicycle crash, out-of-sync) service-side label
// with a direct read of the active question's own TOML-defined brackets.
import 'package:flutter_test/flutter_test.dart';
import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/services/answer_range_matcher.dart';

Answer _answer(String text, double points) => Answer(text: text, points: points);

void main() {
  group('AnswerRangeMatcher', () {
    // Mirrors assets/question_info/pedestrian-crash.toml exactly.
    final pedestrianCrashAnswers = [
      _answer('0-4.61', 1.0),
      _answer('>4.61-15.08', 2.0),
      _answer('>15.08-30.78', 3.0),
      _answer('>30.78-50.80', 4.0),
      _answer('>50.80-77.6', 5.0),
    ];

    // Mirrors assets/question_info/pedestrian-crash-washoe.toml, which has
    // genuinely different thresholds from the plain variant above -- this
    // is exactly the case a single hardcoded bucket table in the drawing
    // service could never satisfy for both jurisdictions at once.
    final pedestrianCrashWashoeAnswers = [
      _answer('0-3.38', 1.0),
      _answer('>3.38-12.00', 2.0),
      _answer('>12.00-26.78', 3.0),
      _answer('>26.78-50.80', 4.0),
      _answer('>50.80-81.6', 5.0),
    ];

    test(
      'reproduces the exact reported bug: a density that used to produce '
      'the orphan label "9-16" now resolves to a real TOML bracket',
      () {
        // Density 9.16 is squarely inside pedestrian-crash.toml's second
        // bracket ('>4.61-15.08'). Before the fix, the service's hardcoded
        // _getAnswerFromDensity(9) returned '9-16' -- a string that does
        // not exist anywhere in this TOML, causing the unmatched-answer
        // error irrespective of the drawing geometry used.
        final index = AnswerRangeMatcher.matchIndex(
          pedestrianCrashAnswers,
          9.16,
        );
        expect(index, 1);
        expect(pedestrianCrashAnswers[index].text, '>4.61-15.08');
      },
    );

    test('matches the first bracket at and below its upper bound', () {
      expect(AnswerRangeMatcher.matchIndex(pedestrianCrashAnswers, 0.0), 0);
      expect(AnswerRangeMatcher.matchIndex(pedestrianCrashAnswers, 4.61), 0);
    });

    test('a value just above a bound falls into the next bracket', () {
      expect(AnswerRangeMatcher.matchIndex(pedestrianCrashAnswers, 4.62), 1);
      expect(AnswerRangeMatcher.matchIndex(pedestrianCrashAnswers, 15.08), 1);
      expect(AnswerRangeMatcher.matchIndex(pedestrianCrashAnswers, 15.09), 2);
    });

    test(
      'the last bracket is open-ended: a value far beyond its displayed '
      'upper bound still matches it, rather than failing to match',
      () {
        expect(AnswerRangeMatcher.matchIndex(pedestrianCrashAnswers, 77.6), 4);
        expect(
          AnswerRangeMatcher.matchIndex(pedestrianCrashAnswers, 500.0),
          4,
        );
      },
    );

    test(
      'the exact same density matches different brackets under the '
      'Washoe-specific TOML -- proving the fix is jurisdiction-agnostic, '
      'unlike a hardcoded bucket table that could only ever match one '
      'TOML variant',
      () {
        final plainIndex = AnswerRangeMatcher.matchIndex(
          pedestrianCrashAnswers,
          13.0,
        );
        final washoeIndex = AnswerRangeMatcher.matchIndex(
          pedestrianCrashWashoeAnswers,
          13.0,
        );
        expect(plainIndex, 1); // '>4.61-15.08'
        expect(washoeIndex, 2); // '>12.00-26.78' -- different bracket!
        expect(pedestrianCrashAnswers[plainIndex].text, '>4.61-15.08');
        expect(pedestrianCrashWashoeAnswers[washoeIndex].text, '>12.00-26.78');
      },
    );

    test('an empty answer list returns -1', () {
      expect(AnswerRangeMatcher.matchIndex([], 5.0), -1);
    });

    test('bicycle-crash.toml-shaped brackets also match correctly', () {
      // Mirrors assets/question_info/bicycle-crash.toml.
      final bicycleCrashAnswers = [
        _answer('0-2.15', 1.0),
        _answer('>2.15-4.92', 2.0),
        _answer('>4.92-8.92', 3.0),
        _answer('>8.92-14.77', 4.0),
        _answer('>14.77-26.49', 5.0),
      ];
      expect(AnswerRangeMatcher.matchIndex(bicycleCrashAnswers, 2.0), 0);
      expect(AnswerRangeMatcher.matchIndex(bicycleCrashAnswers, 3.5), 1);
      expect(AnswerRangeMatcher.matchIndex(bicycleCrashAnswers, 100.0), 4);
    });
  });
}
