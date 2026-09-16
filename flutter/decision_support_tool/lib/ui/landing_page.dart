import 'package:decision_support_tool/ui/site_footer.dart';
import 'package:decision_support_tool/ui/site_header.dart';
import 'package:decision_support_tool/ui/site_theme.dart';
import 'package:decision_support_tool/ui/site_widgets.dart';
import 'package:flutter/material.dart';

/// Landing page shown at the site root ('/'). '/instructions' shows the
/// jurisdiction-specific Instructions page; '/pst' shows the existing PST
/// tool ([AssessmentApp]) instead — see the routing in main.dart.
///
/// Content is reproduced from the verified PST/DST project pages
/// (https://pst.rtcsnv.com/intro/ and the UNLV DST Google Site). Nothing
/// here is invented; anything not yet confirmed by the PST team is marked
/// with a visible "[TODO: ...]" note in the relevant section below.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _openTool(BuildContext context) {
    Navigator.of(context).pushNamed('/pst');
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
                    _buildDescription(context),
                    _buildProcessDescription(context),
                    _buildHowItWorks(context),
                    _buildUsingTheTool(context),
                    _buildDisclaimer(context),
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
                      text: 'A Project Scoping Tool ',
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
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      color: SiteTheme.textMuted,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'The Decision Support Tool (DST)',
                        style: TextStyle(
                          color: SiteTheme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            ', this tool assists planning, public works, and transportation '
                            'professionals with the integration of public health and equity '
                            'into land use decisions to promote safe, walkable, bikeable, '
                            'and connected communities.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  FocusableButton(
                    label: 'Open Project Scoping Tool',
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
  // What This Tool Does
  // ---------------------------------------------------------------------

  Widget _buildDescription(BuildContext context) {
    return const SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiteSectionHeading('What This Tool Does'),
          SizedBox(height: 16),
          Text(
            'The Project Scoping Tool assists planning, public works, and transportation '
            'professionals with the integration of public health and equity into land use '
            'decisions, to promote safe, walkable, bikeable, and connected communities. It '
            'supports pedestrian and bicyclist safety assessment for a specific project area, '
            'and generates recommended infrastructure improvements based on that assessment.',
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
  // Description — three-step process
  // ---------------------------------------------------------------------

  Widget _buildProcessDescription(BuildContext context) {
    final narrow =
        MediaQuery.of(context).size.width < SiteTheme.narrowBreakpoint;

    final text = _buildProcessDescriptionText();
    const image = _RoadmapFigure(maxWidth: 380);

    return SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Description'),
          const SizedBox(height: 16),
          narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [text, const SizedBox(height: 28), image],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: text),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: image),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildProcessDescriptionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The Project Scoping Tool uses a three-step process to identify recommendations '
          'for a specific geographic area.',
          style: TextStyle(
            fontSize: 16,
            color: SiteTheme.textColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        _descriptionBullet(
          'Step 1: Existing Need',
          ' uses secondary data related to health, equity, active transport, crashes, '
              'land use features, and connectivity to assess an area’s existing needs.',
        ),
        _descriptionBullet(
          'Step 2: Existing Infrastructure',
          ' uses secondary data and built environment audits to assess an area’s '
              'existing walking and biking infrastructure.',
        ),
        _descriptionBullet(
          'Step 3: Select Proposed Infrastructure',
          ': the scores from Steps 1 and 2 yield recommendations for how to modify the '
              'area to promote walking and biking, including recommendations related to '
              'traffic calming, visibility, crosswalks and signalized intersections, '
              'bicycle and pedestrian connectivity, asset management, and aesthetics.',
        ),
        _descriptionBullet(
          null,
          'In general, the higher an area’s existing need and the less the area is '
          'conducive to walking and biking, the more the recommendations aim to '
          'promote active transport.',
        ),
      ],
    );
  }

  Widget _descriptionBullet(String? leadIn, String rest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 10),
            child: Text('•', style: TextStyle(color: SiteTheme.textColor)),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(color: SiteTheme.textColor, height: 1.6),
                children: [
                  if (leadIn != null)
                    TextSpan(
                      text: leadIn,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: SiteTheme.primary,
                      ),
                    ),
                  TextSpan(text: rest),
                ],
              ),
            ),
          ),
        ],
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
        'Uses secondary data and built-environment audits (walkability, roadway comfort, '
            'shade/tree canopy, and similar conditions) to assess the project area’s '
            'existing walking and biking infrastructure.',
      ),
      (
        '3',
        'Select Proposed Infrastructure',
        'Combines the results of Steps 1 and 2 to recommend infrastructure improvements '
            '— such as traffic calming, visibility, crosswalks and signalized '
            'intersections, bicycle and pedestrian connectivity, asset management, and '
            'aesthetics — for the project area.',
      ),
    ];

    return SiteSection(
      background: SiteTheme.bgAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('How It Works'),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Text(
              'The tool follows a three-step process. The greater an area’s existing need, '
              'and the less conducive it currently is to walking and biking, the more the '
              'resulting recommendations emphasize active transportation improvements. '
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
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final s in steps) ...[
                        Expanded(
                          child: _StepCard(
                            number: s.$1,
                            title: s.$2,
                            body: s.$3,
                          ),
                        ),
                        if (s != steps.last) const SizedBox(width: 20),
                      ],
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Using the Tool
  // ---------------------------------------------------------------------

  Widget _buildUsingTheTool(BuildContext context) {
    const items = [
      (
        'Before using this tool, please identify a specific geographic area for a land use project.',
        <String>[],
      ),
      (
        'Next, complete Steps 1 and 2, which involve gathering information through a series of questions.',
        <String>[],
      ),
      (
        'Step specific instructions:',
        ['Step 1 - Existing Need', 'Step 2 - Existing Infrastructure'],
      ),
      (
        'Finally, use the information collected through Steps 1 and 2 to select project recommendations in Step 3 that take health into account.',
        <String>[],
      ),
    ];

    const tips = [
      (
        'Steps 1 & 2 use many existing data sources available online.',
        [
          'Many of these websites are easiest to use by inputting a specific address. '
              'Select an address within the project area for this purpose. Selecting an '
              'address somewhere in the middle of the project area would be helpful.',
          'If a project encompasses more than one geographic unit of analysis '
              '(e.g. Census Tract or block group), answer questions for each involved '
              'unit independently. Then, average the answers to compute final points.',
        ],
      ),
      (
        'In Step 3, use the scores calculated in Steps 1 & 2 to determine whether '
            'the project should be designed and implemented using recommendations '
            'that are “good,” “better,” or “best” for promoting health.',
        <String>[],
      ),
      (
        'This tool recognizes that projects are unique. As a result, if choosing '
            'not to pursue the recommendation contained in the tool, briefly explain why.',
        <String>[],
      ),
    ];

    return SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Using the Tool'),
          const SizedBox(height: 16),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in items) ...[
                  _usingToolItem(item.$1),

                  for (final subItem in item.$2)
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: _usingToolItem(subItem, isStepLink: true),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: _TipsDisclosure(tips: tips),
          ),
        ],
      ),
    );
  }

  Widget _usingToolItem(String text, {bool isStepLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              isStepLink ? '▪' : '▪',
              style: const TextStyle(
                color: SiteTheme.textColor,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isStepLink ? SiteTheme.primary : SiteTheme.textColor,
                fontWeight: isStepLink ? FontWeight.w600 : FontWeight.normal,
                decoration: isStepLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: isStepLink ? SiteTheme.primary : null,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Disclaimer
  // ---------------------------------------------------------------------

  Widget _buildDisclaimer(BuildContext context) {
    return SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Disclaimer'),
          const SizedBox(height: 16),
          Semantics(
            container: true,
            label: 'Disclaimer',
            child: const Text(
              'This Project Scoping Tool relies on external sources of information, data, '
              'and analysis. The accuracy, recency, and availability of this information, '
              'data, and analysis depends on the organizations that maintain them. PST '
              'sources should be periodically verified and the PST updated to reflect any '
              'changes.',
              style: TextStyle(
                fontSize: 16,
                color: SiteTheme.textColor,
                height: 1.6,
              ),
            ),
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
// User Tips
// =====================================================================

class _TipsDisclosure extends StatefulWidget {
  const _TipsDisclosure({required this.tips});

  final List<(String, List<String>)> tips;

  @override
  State<_TipsDisclosure> createState() => _TipsDisclosureState();
}

class _TipsDisclosureState extends State<_TipsDisclosure> {
  bool _expanded = false;

  Widget _tipRow(String bullet, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              bullet,
              style: const TextStyle(color: SiteTheme.textColor, height: 1.5),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: SiteTheme.textColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SiteTheme.bgAlt,
        border: Border.all(color: SiteTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FocusableTapText(
              label: _expanded ? 'User Tips ▴' : 'User Tips ▾',
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: SiteTheme.primary,
              ),
            ),

            if (_expanded) ...[
              const SizedBox(height: 16),

              for (final tip in widget.tips) ...[
                _tipRow('•', tip.$1),

                for (final subTip in tip.$2)
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: _tipRow('▪', subTip),
                  ),

                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
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
