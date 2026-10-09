import 'package:decision_support_tool/config.dart';
import 'package:decision_support_tool/ui/site_footer.dart';
import 'package:decision_support_tool/ui/site_header.dart';
import 'package:decision_support_tool/ui/site_theme.dart';
import 'package:decision_support_tool/ui/site_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Landing page shown at the site root ('/'). '/instructions' shows the
/// jurisdiction-specific Instructions page; [toolExtension] shows the
/// existing PST tool ([AssessmentApp]) instead — see the routing in
/// main.dart and the flag/path in config.dart.
///
/// Body copy for the Purpose and Disclaimer / Attribution Statement /
/// Collaboration / Questions? sections is reproduced verbatim from the
/// PST team's approved "Proposed Language for PST Landing Page" document —
/// wording and meaning preserved exactly, only the presentation (layout,
/// typography, spacing) is this page's own.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _openTool(BuildContext context) {
    Navigator.of(context).pushNamed(toolExtension);
  }

  static const String _questionsEmail = 'vru@unlv.edu';

  Future<void> _emailQuestions() async {
    final uri = Uri(scheme: 'mailto', path: _questionsEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiteTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SiteHeader(currentRoute: '/'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(context),
                    _buildHowItWorks(context),
                    _buildPurposeAndDisclaimer(context),
                    _buildAttributionStatement(context),
                    _buildCollaboration(context),
                    _buildQuestions(context),
                    const SiteFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      color: SiteTheme.bgAlt,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: SiteWrap(
        alignment: CrossAxisAlignment.start,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Infrastructure for Healthy Living',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: SiteTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Project Scoping Tool ',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: SiteTheme.primary,
                        height: 1.15,
                      ),
                    ),
                    TextSpan(
                      text: '\nfor Nevada',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: SiteTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: const Text(
                  'A 3-step process to help create safer and healthier infrastructure '
                  'in the Las Vegas and Reno, Nevada metropolitan areas — integrating '
                  'health and equity into land use and infrastructure decisions to '
                  'promote safe, walkable, bikeable, and connected communities.',
                  style: TextStyle(
                    fontSize: 18,
                    color: SiteTheme.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  FocusableButton(
                    label: 'Launch the PST Tool',
                    onPressed: () => _openTool(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    fontSize: 16.5,
                  ),
                  FocusableButton(
                    label: 'View Instructions',
                    onPressed: () => goToSiteRoute(context, '/instructions'),
                    background: SiteTheme.bg,
                    hoverBackground: SiteTheme.bgAlt,
                    borderColor: SiteTheme.primary,
                    textColor: SiteTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    fontSize: 16.5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // How It Works
  // ---------------------------------------------------------------------

  Widget _buildHowItWorks(BuildContext context) {
    final narrow =
        MediaQuery.of(context).size.width < SiteTheme.narrowBreakpoint;

    final steps = [
      (
        '1',
        'Existing Need',
        'Uses secondary data related to health, equity, active transportation, crashes, '
            'land-use features, and connectivity to assess the project area’s existing need.',
      ),
      (
        '2',
        'Existing Infrastructure',
        'Uses secondary data and built-environment audits '
            'to assess the project area’s '
            'existing walking and biking infrastructure.',
      ),
      (
        '3',
        'Select Proposed Infrastructure',
        'Combines the results of Steps 1 and 2 to recommend infrastructure improvements '
            'for the project area.',
      ),
    ];

    return SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('How It Works'),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Text(
              'The PST follows a three-step process. In general, the higher an area’s '
              'existing need and the less conducive the area is to walking and biking, '
              'the more the recommendations aim to promote active transportation. '
              'Detailed, jurisdiction-specific instructions for Steps 1 and 2 are available '
              'on the Instructions page.',
              style: TextStyle(
                fontSize: 15,
                color: SiteTheme.textMuted,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          narrow
              ? Column(
                  children: [
                    for (final s in steps) ...[
                      _StepCard(number: s.$1, title: s.$2, body: s.$3),
                      const SizedBox(height: 16),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _howItWorksCards(steps)),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 2,
                      child: const _RoadmapFigure(maxWidth: 380),
                    ),
                  ],
                ),
          if (narrow) ...[
            const SizedBox(height: 24),
            const _RoadmapFigure(maxWidth: 380),
          ],
        ],
      ),
    );
  }

  Widget _howItWorksCards(List<(String, String, String)> steps) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final s in steps) ...[
            Expanded(
              child: _StepCard(number: s.$1, title: s.$2, body: s.$3),
            ),
            if (s != steps.last) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Purpose and Disclaimer
  // ---------------------------------------------------------------------

  Widget _buildPurposeAndDisclaimer(BuildContext context) {
    return SiteSection(
      background: SiteTheme.bgAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Purpose and Disclaimer'),
          const SizedBox(height: 20),
          const Text(
            'The Project Scoping Tool (PST) is a 3-step process to help create safer '
            'and healthier infrastructure in the Las Vegas and Reno, Nevada '
            'metropolitan areas by integrating health and equity into land use and '
            'infrastructure decisions to promote safe, walkable, bikeable, and '
            'connected communities.',
            style: TextStyle(
              fontSize: 16,
              color: SiteTheme.textColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'The PST makes actionable recommendations based on data, evidence, and '
            'community voices. It is intended to be used by planning, public works, '
            'design, and transportation professionals.',
            style: TextStyle(
              fontSize: 16,
              color: SiteTheme.textColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Its recommendations are intended to inform the decisions of these '
            'professionals and to supplement their expertise as they use their '
            'judgement and local project context to determine which recommendations '
            'are appropriate.',
            style: TextStyle(
              fontSize: 16,
              color: SiteTheme.textColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SiteTheme.disclaimerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SiteTheme.disclaimerBorder),
            ),
            child: Semantics(
              container: true,
              label: 'Disclaimer',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disclaimer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: SiteTheme.textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This PST relies on several external sources of information, data, '
                    'and analysis. The accuracy, recency, and availability of this '
                    'information, data, and analysis depends on the organizations that '
                    'maintain them. It cannot be guaranteed.',
                    style: TextStyle(
                      fontSize: 15,
                      color: SiteTheme.textColor,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'PST sources should be periodically verified and the PST updated to '
                    'reflect any changes.',
                    style: TextStyle(
                      fontSize: 15,
                      color: SiteTheme.textColor,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Attribution Statement
  // ---------------------------------------------------------------------

  Widget _buildAttributionStatement(BuildContext context) {
    return SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Attribution Statement'),
          const SizedBox(height: 20),
          const Text(
            'The Nevada Vulnerable Road User Safety Project, which updates the PST, '
            'was supported by TS-2025-UNLV-95, funded by the Nevada Office of Traffic '
            'Safety and the Nevada Department of Transportation.',
            style: TextStyle(
              fontSize: 16,
              color: SiteTheme.textColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'The original PST was supported by grant #NU58DP6578, funded by the '
            'Centers for Disease Control and Prevention and awarded to the Southern '
            'Nevada Health District. Its contents are solely the responsibility of '
            'the authors and do not necessarily represent the official views of the '
            'Centers for Disease Control and Prevention or the Department of Health '
            'and Human Services.',
            style: TextStyle(
              fontSize: 16,
              color: SiteTheme.textColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Collaboration
  // ---------------------------------------------------------------------

  Widget _buildCollaboration(BuildContext context) {
    const partners = [
      'UNLV School of Public Health',
      'Nevada Department of Public Safety – Office of Traffic Safety',
      'Nevada Department of Transportation',
      'Southern Nevada Health District',
      'Nevada Division of Public and Behavioral Health',
      'Nevada Office of Minority Health and Equity',
      'City of Las Vegas',
      'Regional Transportation Commission of Southern Nevada',
      'Regional Transportation Commission of Washoe County',
      'Clark County Office of Traffic Safety',
      'Nevada Community Health Coalition',
      'Howard R. Hughes College of Engineering',
      'Kirk Kerkorian School of Medicine at UNLV',
      'Safe Routes to School',
      'Southern Nevada Bicycle Coalition',
      'Make The Road Nevada',
      'Other Partners',
    ];

    return SiteSection(
      background: SiteTheme.bgAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Collaboration'),
          const SizedBox(height: 20),
          const Text(
            'The development and updates of the PST were made possible through '
            'collaboration among the following partners:',
            style: TextStyle(
              fontSize: 16,
              color: SiteTheme.textColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [for (final p in partners) _PartnerChip(p)],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Questions?
  // ---------------------------------------------------------------------

  Widget _buildQuestions(BuildContext context) {
    return SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Questions?'),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Contact ',
                style: TextStyle(
                  fontSize: 16,
                  color: SiteTheme.textColor,
                  height: 1.6,
                ),
              ),
              FocusableTapText(
                label: _questionsEmail,
                onTap: () => _emailQuestions(),
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: SiteTheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  height: 1.6,
                ),
              ),
              const Text(
                ' to get more information on the project.',
                style: TextStyle(
                  fontSize: 16,
                  color: SiteTheme.textColor,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Step Card
// =====================================================================

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: SiteTheme.bg,
        border: Border.all(color: SiteTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: SiteTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: SiteTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(color: SiteTheme.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Partner Chip
// =====================================================================

class _PartnerChip extends StatelessWidget {
  const _PartnerChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: SiteTheme.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SiteTheme.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: SiteTheme.textColor),
      ),
    );
  }
}

// =====================================================================
// Roadmap Figure
// =====================================================================

/// The project's existing "Roadmap" figure (Steps 1–3, and the matrix
/// combining Step 1/Step 2 results into a recommendation level), reused
/// as-is from the project's reference materials.
///
/// Asset:
/// assets/images/roadmap.png
class _RoadmapFigure extends StatelessWidget {
  const _RoadmapFigure({this.maxWidth = 480});

  final double maxWidth;

  // Intrinsic size of assets/images/roadmap.png (760x806).
  static const double _aspectRatio = 760 / 806;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Image.asset(
            'assets/images/roadmap.png',
            fit: BoxFit.contain,
            semanticLabel:
                'Roadmap diagram. Step 1: assess the area’s existing need. '
                'Step 2: assess existing infrastructure. '
                'Step 3: select proposed infrastructure. '
                'A matrix combines the area’s existing need '
                '(high, medium, or low) with its existing infrastructure '
                '(below average, average, or above average) to recommend '
                'a level of improvement: best, at least better, at least '
                'good, or minimal potential for benefit.',
          ),
        ),
      ),
    );
  }
}
