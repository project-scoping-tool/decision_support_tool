import 'package:decision_support_tool/config.dart';
import 'package:decision_support_tool/ui/site_theme.dart';
import 'package:decision_support_tool/ui/site_widgets.dart';
import 'package:flutter/material.dart';

/// Navigates to a top-level site route, avoiding a redundant push if
/// already on that route, and preferring popping back to '/' (over pushing
/// a new landing-page instance) when that's possible.
void goToSiteRoute(BuildContext context, String routeName) {
  final current = ModalRoute.of(context)?.settings.name;
  if (current == routeName) return;
  if (routeName == '/' && Navigator.canPop(context)) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }
  Navigator.of(context).pushNamed(routeName);
}

/// Shared top navigation bar for the site's own pages (landing page,
/// Instructions page, ...) — NOT used inside the PST tool itself, which has
/// its own existing UI. Shows "Home", "Instructions", and "Open Tool",
/// consistent across every page that uses it.
class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key, required this.currentRoute});

  /// The route name of the page this header is displayed on (e.g. '/' or
  /// '/instructions'), used only to lightly highlight the active nav item.
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < SiteTheme.narrowBreakpoint;
    return Container(
      decoration: const BoxDecoration(
        color: SiteTheme.bg,
        border: Border(bottom: BorderSide(color: SiteTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: SiteWrap(
        child: narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _brand(context),
                  const SizedBox(height: 10),
                  _navLinks(context),
                  const SizedBox(height: 10),
                  _openToolButton(context),
                ],
              )
            : Row(
                children: [
                  _brand(context),
                  const Spacer(),
                  _navLinks(context),
                  const SizedBox(width: 20),
                  _openToolButton(context),
                ],
              ),
      ),
    );
  }

  Widget _brand(BuildContext context) {
    return InkWell(
      onTap: () => goToSiteRoute(context, '/'),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Project Scoping Tool',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: SiteTheme.primary,
            ),
          ),
          Text(
            'University of Nevada, Las Vegas',
            style: TextStyle(fontSize: 13, color: SiteTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _navLinks(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 6,
      children: [
        _navLink(context, 'Home', '/'),
        _navLink(context, 'Instructions', '/instructions'),
      ],
    );
  }

  Widget _navLink(BuildContext context, String label, String routeName) {
    final active = currentRoute == routeName;
    return FocusableTapText(
      label: label,
      onTap: () => goToSiteRoute(context, routeName),
      textStyle: TextStyle(
        fontWeight: active ? FontWeight.bold : FontWeight.w500,
        color: active ? SiteTheme.primary : SiteTheme.textColor,
        decoration: active ? TextDecoration.underline : TextDecoration.none,
        decorationColor: SiteTheme.primary,
      ),
    );
  }

  Widget _openToolButton(BuildContext context) {
    return FocusableButton(
      label: 'Open Tool',
      onPressed: () => goToSiteRoute(context, toolExtension),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      fontSize: 14,
    );
  }
}
