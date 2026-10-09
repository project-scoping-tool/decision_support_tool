/// Contains config for assets

/// Whether the site has a separate landing page at `/`.
///
/// - `true`: `/` shows the landing page ([LandingPage]); the PST tool is
///   reached at [toolExtension] instead.
/// - `false`: `/` opens the PST tool directly — no landing page route
///   exists, and there's no need to visit [toolExtension] first.
///
/// See the routing in `main.dart`, which is the only other place this is
/// read.
const bool landingPageEnabled = true;

/// URL path the PST tool is served at when [landingPageEnabled] is `true`
/// (and, in addition to `/`, when it's `false`).
///
/// Must start with `/` and have no trailing slash (e.g. `/pst`, `/tool`,
/// `/decision-support`). Change this instead of hardcoding a path anywhere
/// else in the app — `main.dart`, `landing_page.dart`, and
/// `site_header.dart` all read this constant rather than a literal string.
const String toolExtension = '/pst';

abstract class Assets {
  static const assessmentInfoDir = 'assets/assessment_info/';
  static const questionInfoDir = 'assets/question_info/';
  static const recommendationsInfoDir = 'assets/recommendations_info/';
}

/// Master switch for the project address input and per-question auto-fill
/// buttons on the assessment page.
///
/// - `true`: both are shown, and each question's auto-fill button still
///   follows its own `autoFillEnabled` setting from its question_info toml
///   (unchanged).
/// - `false`: both are hidden everywhere, regardless of any question's
///   `autoFillEnabled` setting.
///
/// Flip this instead of commenting out `_buildProjectAddressInput()` /
/// `_buildWidgetAutoFillButton()` in question_section_page.dart.
const bool enableAutoFillFeatures = false;
