import 'package:decision_support_tool/ui/site_theme.dart';
import 'package:decision_support_tool/ui/site_widgets.dart';
import 'package:flutter/material.dart';

/// Shared footer (attribution / partners / disclaimer-adjacent info) for
/// the site's own pages. Content unchanged from the original landing page —
/// only relocated here so every page shares the exact same footer.
class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key, this.sectionKey});

  final Key? sectionKey;

  @override
  Widget build(BuildContext context) {
    final narrow =
        MediaQuery.of(context).size.width < SiteTheme.narrowBreakpoint;
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: SiteTheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: SiteWrap(
        alignment: CrossAxisAlignment.start,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About & Partners',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            narrow
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InstitutionBlock(),
                      SizedBox(height: 24),
                      _CollaboratorsBlock(),
                      SizedBox(height: 24),
                      _DataSourcesBlock(),
                      SizedBox(height: 24),
                      _FundingBlock(),
                      SizedBox(height: 24),
                      _LogosBlock(),
                    ],
                  )
                : const Wrap(
                    spacing: 32,
                    runSpacing: 24,
                    children: [
                      SizedBox(width: 220, child: _InstitutionBlock()),
                      SizedBox(width: 260, child: _CollaboratorsBlock()),
                      SizedBox(width: 260, child: _DataSourcesBlock()),
                      // SizedBox(width: 280, child: _FundingBlock()),
                      // SizedBox(width: 220, child: _LogosBlock()),
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
}

Widget _footerHeading(String text) => Text(
  text,
  style: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
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

class _InstitutionBlock extends StatelessWidget {
  const _InstitutionBlock();

  @override
  Widget build(BuildContext context) {
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
}

class _CollaboratorsBlock extends StatelessWidget {
  const _CollaboratorsBlock();

  @override
  Widget build(BuildContext context) {
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
        _footerBullet(
          'Regional Transportation Commission of Southern Nevada (RTC)',
        ),
        _footerBullet('Nevada Minority & Health Equity Coalition'),
        _todoNote(
          '[TODO: PST team to confirm whether this collaborator list still reflects the '
          'current, updated version of the tool, or should be revised.]',
        ),
      ],
    );
  }
}

class _DataSourcesBlock extends StatelessWidget {
  const _DataSourcesBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerHeading('Data & Technical Sources'),
        const SizedBox(height: 10),
        _footerBullet(
          'RTC Southern Nevada — bus stop and bicycle/pedestrian comfort data',
        ),
        _footerBullet(
          'Nevada Department of Transportation (NDOT) — crash data',
        ),
        _footerBullet(
          'U.S. Census Bureau — American Community Survey & TIGER/Web',
        ),
        _footerBullet('Esri / ArcGIS — geocoding and mapping services'),
        _footerBullet(
          'University of Wisconsin Neighborhood Atlas — Area Deprivation Index',
        ),
        _todoNote(
          '[TODO: PST team to confirm whether this data source list still reflects the '
          'current, updated version of the tool, or should be revised.]',
        ),
      ],
    );
  }
}

class _FundingBlock extends StatelessWidget {
  const _FundingBlock();

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Color(0xFFD7E3EC),
            height: 1.4,
          ),
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
}

class _LogosBlock extends StatelessWidget {
  const _LogosBlock();

  @override
  Widget build(BuildContext context) {
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
}
