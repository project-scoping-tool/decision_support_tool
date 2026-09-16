import 'package:flutter/material.dart';

/// Shared design tokens for the unified Flutter site's own pages (landing
/// page, Instructions page, and any future site-shell pages). Unrelated to
/// the PST/AssessmentApp's own styling.
abstract class SiteTheme {
  static const Color primary = Color(0xFF1D3557);
  static const Color primaryDark = Color(0xFF14263F);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgAlt = Color(0xFFF4F6F8);
  static const Color textColor = Color(0xFF1B2430);
  static const Color textMuted = Color(0xFF48525E);
  static const Color border = Color(0xFFD9DFE4);
  static const Color focusColor = Color(0xFFE9A319);
  static const Color disclaimerBg = Color(0xFFFFF8E6);
  static const Color disclaimerBorder = Color(0xFFE0B34C);

  static const double maxContentWidth = 1080;
  static const double narrowBreakpoint = 760;
}
