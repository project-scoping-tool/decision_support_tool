import 'package:decision_support_tool/data/static_data_models.dart';

/// Matches a computed numeric value (e.g. a density or rate) to the
/// TOML-defined answer bracket it falls into.
///
/// Several auto-fill drawing services (e.g. BikingRateDrawingService)
/// return an answer by bucketing their computed value into a label
/// string that's meant to exactly mirror the question's TOML
/// `answers[].text`. That only works as long as the service's hardcoded
/// buckets are kept in sync by hand with the TOML -- and with
/// jurisdiction-specific TOML variants (e.g. `pedestrian-crash-washoe
/// .toml` vs. `pedestrian-crash.toml`), a single hardcoded bucket table
/// can never match more than one variant at once. [matchIndex] instead
/// reads the brackets directly from whichever [answers] list is actually
/// active, so it's correct for every jurisdiction with no hardcoded
/// strings to keep in sync.
///
/// [answers] must be sorted ascending by `points` (guaranteed by
/// [QuestionInfo]'s own invariant), with `text` values of the form
/// `'0-X'`, `'>X-Y'`, ..., `'>W-Z'`. The upper bound of each bracket is
/// parsed from `text`, and [value] matches the first bracket whose upper
/// bound is `>= value`. The last answer is always treated as the
/// open-ended top bracket (matches whatever's left over), mirroring how
/// the app's other range-bucketed services already treat their final
/// bucket (their last `if`/`else` branch has no upper-bound check).
class AnswerRangeMatcher {
  /// Returns the matching index in [answers], or -1 if [answers] is
  /// empty or no bracket's upper bound could be parsed.
  static int matchIndex(List<Answer> answers, double value) {
    if (answers.isEmpty) return -1;
    var anyBoundParsed = false;
    for (var i = 0; i < answers.length - 1; i++) {
      final upper = _parseUpperBound(answers[i].text);
      if (upper == null) continue;
      anyBoundParsed = true;
      if (value <= upper) return i;
    }
    // Last bracket: open-ended, so it's the fallback for anything not
    // matched above -- but only if at least one bound elsewhere parsed
    // successfully (otherwise `answers` isn't actually a range list, and
    // blindly picking the last index would be wrong).
    if (anyBoundParsed || _parseUpperBound(answers.last.text) != null) {
      return answers.length - 1;
    }
    return -1;
  }

  static double? _parseUpperBound(String text) {
    final cleaned = text.replaceAll('>', '').replaceAll('%', '').trim();
    final dashIndex = cleaned.lastIndexOf('-');
    final numberPart = dashIndex == -1
        ? cleaned
        : cleaned.substring(dashIndex + 1).trim();
    return double.tryParse(numberPart);
  }
}
