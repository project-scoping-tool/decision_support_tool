import 'package:decision_support_tool/ui/site_theme.dart';
import 'package:flutter/material.dart';

/// Centers content and caps it at [maxWidth], like a CSS `.wrap` container.
/// Shared by every site-shell page (landing, instructions, ...).
class SiteWrap extends StatelessWidget {
  const SiteWrap({
    super.key,
    this.maxWidth = SiteTheme.maxContentWidth,
    required this.child,
    this.alignment = CrossAxisAlignment.center,
  });

  final double maxWidth;
  final Widget child;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(crossAxisAlignment: alignment, children: [child]),
      ),
    );
  }
}

/// A page/section heading in the site's shared style.
class SiteSectionHeading extends StatelessWidget {
  const SiteSectionHeading(this.text, {super.key, this.fontSize = 26});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: SiteTheme.primary,
      ),
    );
  }
}

/// A full-bleed section container with the site's standard vertical padding
/// and content width cap.
class SiteSection extends StatelessWidget {
  const SiteSection({
    super.key,
    this.sectionKey,
    required this.background,
    required this.child,
  });

  final Key? sectionKey;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: SiteWrap(alignment: CrossAxisAlignment.start, child: child),
    );
  }
}

/// A focusable, tappable text link with a visible focus outline for
/// keyboard navigation (used for nav links and similar inline actions).
class FocusableTapText extends StatefulWidget {
  const FocusableTapText({
    super.key,
    required this.label,
    required this.onTap,
    this.focusColor = SiteTheme.focusColor,
    this.textStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      color: SiteTheme.textColor,
    ),
  });

  final String label;
  final VoidCallback onTap;
  final Color focusColor;
  final TextStyle textStyle;

  @override
  State<FocusableTapText> createState() => _FocusableTapTextState();
}

class _FocusableTapTextState extends State<FocusableTapText> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _hasFocus = v),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: _hasFocus
              ? BoxDecoration(
                  border: Border.all(color: widget.focusColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Text(widget.label, style: widget.textStyle),
        ),
      ),
    );
  }
}

/// A button with hover + visible keyboard-focus styling, matching the
/// site's `.cta-button` / `.nav-cta` treatment.
class FocusableButton extends StatefulWidget {
  const FocusableButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = SiteTheme.primary,
    this.hoverBackground = SiteTheme.primaryDark,
    this.borderColor,
    this.textColor = Colors.white,
    this.focusColor = SiteTheme.focusColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize = 14,
  });

  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color hoverBackground;

  /// Border color when not focused; defaults to [background] (a solid-fill
  /// look). Pass a visible color (e.g. [SiteTheme.primary]) for an outlined
  /// button on a light/white background.
  final Color? borderColor;
  final Color textColor;
  final Color focusColor;
  final EdgeInsets padding;
  final double fontSize;

  @override
  State<FocusableButton> createState() => _FocusableButtonState();
}

class _FocusableButtonState extends State<FocusableButton> {
  bool _hovering = false;
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: Focus(
        onFocusChange: (v) => setState(() => _hasFocus = v),
        child: Semantics(
          button: true,
          label: widget.label,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: _hovering ? widget.hoverBackground : widget.background,
                borderRadius: BorderRadius.circular(8),
                border: _hasFocus
                    ? Border.all(color: widget.focusColor, width: 3)
                    : Border.all(color: widget.borderColor ?? widget.background),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
