import 'package:decision_support_tool/ui/site_theme.dart';
import 'package:decision_support_tool/ui/site_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared footer for the site's own pages (landing page, Instructions
/// page). Deliberately minimal: the full attribution/collaboration
/// content now lives on the landing page itself (its own "Attribution
/// Statement" and "Collaboration" sections), so this footer only carries
/// the essentials that belong on every page — name, institution, contact,
/// copyright — not a second copy of the same material.
///
/// Uses a [Wrap] (rather than a fixed-breakpoint [Row]/[Column] split) for
/// the contact/copyright line so it reflows to a second line at any
/// viewport width instead of ever overflowing.
class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key, this.sectionKey});

  final Key? sectionKey;

  static const String _contactEmail = 'vru@unlv.edu';
  static const Color _onDarkText = Color(0xFFC9D2DC);
  static const Color _divider = Color(0x33FFFFFF);

  Future<void> _emailContact() async {
    final uri = Uri(scheme: 'mailto', path: _contactEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: SiteTheme.primaryDark,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: SiteWrap(
        alignment: CrossAxisAlignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _brand(),
            const SizedBox(height: 16),
            Container(height: 1, width: 48, color: _divider),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [_contact(), _copyright()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _brand() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Project Scoping Tool (PST)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'University of Nevada, Las Vegas',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: _onDarkText),
        ),
      ],
    );
  }

  Widget _contact() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Contact: ',
          style: TextStyle(fontSize: 12.5, color: _onDarkText),
        ),
        FocusableTapText(
          label: _contactEmail,
          onTap: () => _emailContact(),
          textStyle: const TextStyle(
            fontSize: 12.5,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: _onDarkText,
          ),
        ),
      ],
    );
  }

  Widget _copyright() {
    return const Text(
      '© 2026 All rights reserved.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11.5, color: _onDarkText),
    );
  }
}
