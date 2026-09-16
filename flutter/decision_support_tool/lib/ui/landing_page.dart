import 'package:flutter/material.dart';

/// Landing page shown at the site root ('/'). '/pst' shows the existing PST
/// tool ([AssessmentApp]) instead — see the routing in main.dart.
///
/// Content is reproduced from the verified PST/DST project pages
/// (https://pst.rtcsnv.com/intro/ and the UNLV DST Google Site). Nothing
/// here is invented; anything not yet confirmed by the PST team is marked
/// with a visible "[TODO: ...]" note in the relevant section below.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
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

  final _descriptionKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _usingTheToolKey = GlobalKey();
  final _partnersKey = GlobalKey();

  bool _tipsExpanded = false;

  void _openTool() {
    Navigator.of(context).pushNamed('/pst');
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(context),
                    _buildDescription(context),
                    _buildHowItWorks(context),
                    _buildUsingTheTool(context),
                    _buildDisclaimer(context),
                    _buildFooter(context),
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
  // Header / nav
  // ---------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < narrowBreakpoint;
    return Container(
      decoration: const BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: _Wrap(
        maxWidth: maxContentWidth,
        child: narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _brand(),
                  const SizedBox(height: 10),
                  _navLinks(),
                  const SizedBox(height: 10),
                  _openToolButton(),
                ],
              )
            : Row(
                children: [
                  _brand(),
                  const Spacer(),
                  _navLinks(),
                  const SizedBox(width: 20),
                  _openToolButton(),
                ],
              ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'Project Scoping Tool',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primary),
        ),
        Text(
          'University of Nevada, Las Vegas',
          style: TextStyle(fontSize: 13, color: textMuted),
        ),
      ],
    );
  }

  Widget _navLinks() {
    return Wrap(
      spacing: 24,
      runSpacing: 6,
      children: [
        _navLink('Description', _descriptionKey),
        _navLink('How It Works', _howItWorksKey),
        _navLink('Using the Tool', _usingTheToolKey),
        _navLink('About/Partners', _partnersKey),
      ],
    );
  }

  Widget _navLink(String label, GlobalKey key) {
    return _FocusableTapText(
      label: label,
      onTap: () => _scrollTo(key),
      focusColor: focusColor,
      textStyle: const TextStyle(fontWeight: FontWeight.w500, color: textColor),
    );
  }

  Widget _openToolButton() {
    return _FocusableButton(
      label: 'Open Tool',
      onPressed: _openTool,
      background: primary,
      hoverBackground: primaryDark,
      focusColor: focusColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      fontSize: 14,
    );
  }

  // ---------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bgAlt,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: _Wrap(
        maxWidth: maxContentWidth,
        alignment: CrossAxisAlignment.start,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Infrastructure for Healthy Living',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textMuted),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'A Project Scoping Tool ',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: primary,
                        height: 1.15,
                      ),
                    ),
                    const TextSpan(
                      text: '\nfor Southern Nevada',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
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
                    style: TextStyle(fontSize: 18, color: textMuted, height: 1.5),
                    children: [
                      TextSpan(text: 'Also known as the '),
                      TextSpan(
                        text: 'Pedestrian Safety Tool (PST)',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ', this tool assists planning, public works, and transportation '
                            'professionals with the integration of public health and equity '
                            'into land use decisions — to promote safe, walkable, bikeable, '
                            'and connected communities.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _FocusableButton(
                label: 'Open Project Scoping Tool',
                onPressed: _openTool,
                background: primary,
                hoverBackground: primaryDark,
                focusColor: focusColor,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                fontSize: 16.5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Description
  // ---------------------------------------------------------------------

  Widget _buildDescription(BuildContext context) {
    return _section(
      key: _descriptionKey,
      background: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeading('What This Tool Does'),
          SizedBox(height: 16),
          Text(
            'The Project Scoping Tool assists planning, public works, and transportation '
            'professionals with the integration of public health and equity into land use '
            'decisions, to promote safe, walkable, bikeable, and connected communities. It '
            'supports pedestrian and bicyclist safety assessment for a specific project area, '
            'and generates recommended infrastructure improvements based on that assessment.',
            style: TextStyle(fontSize: 16, color: textColor, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // How It Works
  // ---------------------------------------------------------------------

  Widget _buildHowItWorks(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < narrowBreakpoint;
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

    return _section(
      key: _howItWorksKey,
      background: bgAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading('How It Works'),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Text(
              'The tool follows a three-step process. The greater an area’s existing need, '
              'and the less conducive it currently is to walking and biking, the more the '
              'resulting recommendations emphasize active transportation improvements.',
              style: TextStyle(fontSize: 15, color: textMuted, height: 1.5),
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
                        Expanded(child: _StepCard(number: s.$1, title: s.$2, body: s.$3)),
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
      'Identify a specific geographic/project area before you begin.',
      'Complete Step 1 and Step 2 by answering the provided questions — using the '
          'auto-fill tools where available, or the step-by-step instructions for each question.',
      'Use your Step 1 and Step 2 results in Step 3 to review the recommended infrastructure '
          'and select the features you plan to include.',
      'Generate and print/save a PDF summarizing your selected recommendations.',
    ];
    const tips = [
      'Steps 1 and 2 rely on existing external data sources maintained by federal, municipal, '
          'and university organizations — their accuracy depends on those organizations '
          'keeping them up to date.',
      'Each question includes a link to the relevant resource and instructions for finding an '
          'answer.',
      'For a project area that isn’t a single point, an address near the center of the '
          'area may work best for some resources.',
      'Projects that cover multiple geographic units may need to be evaluated one unit at a '
          'time.',
      'Step 3 recommendation levels are based on your Step 1 and Step 2 scores; if a specific '
          'recommendation doesn’t fit your project, you can choose a different option and '
          'briefly explain why.',
    ];

    return _section(
      key: _usingTheToolKey,
      background: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading('Using the Tool'),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++) _orderedItem(i + 1, items[i]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _TipsDisclosure(
              expanded: _tipsExpanded,
              focusColor: focusColor,
              onToggle: () => setState(() => _tipsExpanded = !_tipsExpanded),
              tips: tips,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderedItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text('$index.', style: const TextStyle(color: textColor, height: 1.5)),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(color: textColor, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Disclaimer
  // ---------------------------------------------------------------------

  Widget _buildDisclaimer(BuildContext context) {
    return _section(
      background: bgAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading('Disclaimer'),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Semantics(
              container: true,
              label: 'Disclaimer',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: disclaimerBg,
                  border: Border.all(color: disclaimerBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'This Project Scoping Tool relies on external sources of information, data, '
                  'and analysis. The accuracy, recency, and availability of this information, '
                  'data, and analysis depends on the organizations that maintain them. PST '
                  'sources should be periodically verified and the PST updated to reflect any '
                  'changes.',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textColor, height: 1.5),
                ),
              ),
            ),
          ),
          // Source: verified verbatim from the existing PST project page
          // (https://pst.rtcsnv.com/intro/), matching the wording on the
          // UNLV DST project page. No newer disclaimer was found in this
          // repository as of this update.
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Footer / Partners
  // ---------------------------------------------------------------------

  Widget _buildFooter(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < narrowBreakpoint;
    return Container(
      key: _partnersKey,
      width: double.infinity,
      color: primary,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: _Wrap(
        maxWidth: maxContentWidth,
        alignment: CrossAxisAlignment.start,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About & Partners',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _institutionBlock(),
                      const SizedBox(height: 24),
                      _collaboratorsBlock(),
                      const SizedBox(height: 24),
                      _dataSourcesBlock(),
                      const SizedBox(height: 24),
                      _fundingBlock(),
                      const SizedBox(height: 24),
                      _logosBlock(),
                    ],
                  )
                : Wrap(
                    spacing: 32,
                    runSpacing: 24,
                    children: [
                      SizedBox(width: 220, child: _institutionBlock()),
                      SizedBox(width: 260, child: _collaboratorsBlock()),
                      SizedBox(width: 260, child: _dataSourcesBlock()),
                      SizedBox(width: 280, child: _fundingBlock()),
                      SizedBox(width: 220, child: _logosBlock()),
                    ],
                  ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
              ),
              child: const Text(
                '© 2026 University of Nevada, Las Vegas. All rights reserved.',
                style: TextStyle(fontSize: 13, color: Color(0xFFC3D1DC)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerHeading(String text) => Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
      );

  Widget _footerBullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          '• $text',
          style: const TextStyle(color: Color(0xFFD7E3EC), height: 1.4),
        ),
      );

  Widget _todoNote(String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0x59FFFFFF), width: 3)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Color(0xFFCBD8E3),
            ),
          ),
        ),
      );

  Widget _institutionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerHeading('Institution'),
        const SizedBox(height: 10),
        _footerBullet('University of Nevada, Las Vegas (UNLV)'),
      ],
    );
  }

  Widget _collaboratorsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerHeading('Project Collaborators'),
        const SizedBox(height: 6),
        const Text(
          'As identified for the existing PST/DST project:',
          style: TextStyle(fontSize: 13, color: Color(0xFFB7C6D3)),
        ),
        const SizedBox(height: 8),
        _footerBullet('UNLV School of Public Health'),
        _footerBullet('Southern Nevada Health District'),
        _footerBullet('City of Las Vegas Public Works Department'),
        _footerBullet('Regional Transportation Commission of Southern Nevada (RTC)'),
        _footerBullet('Nevada Minority & Health Equity Coalition'),
        _todoNote(
          '[TODO: PST team to confirm whether this collaborator list still reflects the '
          'current, updated version of the tool, or should be revised.]',
        ),
      ],
    );
  }

  Widget _dataSourcesBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerHeading('Data & Technical Sources'),
        const SizedBox(height: 10),
        _footerBullet('RTC Southern Nevada — bus stop and bicycle/pedestrian comfort data'),
        _footerBullet('Nevada Department of Transportation (NDOT) — crash data'),
        _footerBullet('U.S. Census Bureau — American Community Survey & TIGER/Web'),
        _footerBullet('Esri / ArcGIS — geocoding and mapping services'),
        _footerBullet('University of Wisconsin Neighborhood Atlas — Area Deprivation Index'),
      ],
    );
  }

  Widget _fundingBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerHeading('Funding & Attribution'),
        const SizedBox(height: 6),
        const Text(
          'Historical attribution, as published for the original PST/DST:',
          style: TextStyle(fontSize: 13, color: Color(0xFFB7C6D3)),
        ),
        const SizedBox(height: 8),
        const Text(
          '“This project was supported by grant #NU58DP6578, funded by the Centers for '
          'Disease Control and Prevention and awarded to the Southern Nevada Health District. '
          'Its contents are solely the responsibility of the authors and do not necessarily '
          'represent the official views of the Centers for Disease Control and Prevention or '
          'the Department of Health and Human Services.”',
          style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFD7E3EC), height: 1.4),
        ),
        _todoNote(
          '[TODO: PST team to confirm whether this funding/support attribution still applies '
          'to the current, updated version of this tool, or whether an updated funding '
          'statement should replace or supplement it. Do not assume it is unchanged without '
          'confirmation.]',
        ),
      ],
    );
  }

  Widget _logosBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerHeading('Partner Logos'),
        const SizedBox(height: 10),
        // TODO: Add partner/sponsor/funder logo Images here once confirmed,
        // e.g. Image.asset('assets/logos/unlv.png').
        // Do not add a logo until the corresponding partnership is
        // confirmed by the PST team.
        _todoNote('[TODO: partner/sponsor logos to be added here.]'),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------

  Widget _section({Key? key, required Color background, required Widget child}) {
    return Container(
      key: key,
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: _Wrap(
        maxWidth: maxContentWidth,
        alignment: CrossAxisAlignment.start,
        child: child,
      ),
    );
  }
}

/// Centers content and caps it at [maxWidth], like the landing page's
/// `.wrap` CSS class.
class _Wrap extends StatelessWidget {
  const _Wrap({
    required this.maxWidth,
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: _LandingPageState.primary,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: _LandingPageState.bg,
        border: Border.all(color: _LandingPageState.border),
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
              color: _LandingPageState.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _LandingPageState.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(color: _LandingPageState.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _TipsDisclosure extends StatelessWidget {
  const _TipsDisclosure({
    required this.expanded,
    required this.onToggle,
    required this.tips,
    required this.focusColor,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final List<String> tips;
  final Color focusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _LandingPageState.bgAlt,
        border: Border.all(color: _LandingPageState.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Focus(
              child: Builder(
                builder: (context) {
                  final hasFocus = Focus.of(context).hasFocus;
                  return InkWell(
                    onTap: onToggle,
                    child: Container(
                      decoration: hasFocus
                          ? BoxDecoration(
                              border: Border.all(color: focusColor, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            )
                          : null,
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'User Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _LandingPageState.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            expanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                            color: _LandingPageState.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              for (final tip in tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• $tip',
                    style: const TextStyle(color: _LandingPageState.textMuted, height: 1.5),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A focusable, tappable text link (used for in-page nav links), with a
/// visible focus outline for keyboard navigation.
class _FocusableTapText extends StatefulWidget {
  const _FocusableTapText({
    required this.label,
    required this.onTap,
    required this.focusColor,
    required this.textStyle,
  });

  final String label;
  final VoidCallback onTap;
  final Color focusColor;
  final TextStyle textStyle;

  @override
  State<_FocusableTapText> createState() => _FocusableTapTextState();
}

class _FocusableTapTextState extends State<_FocusableTapText> {
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
/// landing page's `.cta-button` / `.nav-cta` treatment.
class _FocusableButton extends StatefulWidget {
  const _FocusableButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.hoverBackground,
    required this.focusColor,
    required this.padding,
    required this.fontSize,
  });

  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color hoverBackground;
  final Color focusColor;
  final EdgeInsets padding;
  final double fontSize;

  @override
  State<_FocusableButton> createState() => _FocusableButtonState();
}

class _FocusableButtonState extends State<_FocusableButton> {
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
                    : Border.all(color: widget.background),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
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
