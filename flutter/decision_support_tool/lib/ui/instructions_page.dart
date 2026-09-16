import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:decision_support_tool/ui/question_instructions_content.dart';
import 'package:decision_support_tool/ui/site_footer.dart';
import 'package:decision_support_tool/ui/site_header.dart';
import 'package:decision_support_tool/ui/site_theme.dart';
import 'package:decision_support_tool/ui/site_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

/// Instructions page at '/instructions'.
///
/// Shows, per jurisdiction, the exact Step 1 and Step 2 questions and their
/// instructions — sourced live from the SAME [AssessmentViewModel] /
/// [StaticData] the PST tool itself uses (`assets/assessment_info/*.toml`
/// for which questions belong to a jurisdiction and in what order, and
/// `assets/question_info/*.toml` for each question's title, instructions,
/// resource link, and video). There is no second copy of this data and no
/// jurisdiction list of its own: jurisdictions come from
/// `staticData.assessmentInfoPairsSorted`, and each jurisdiction's
/// questions come from `AssessmentInfo.getQuestionInfos(...)` — the exact
/// same method [QuestionSectionViewModel] uses inside the PST assessment.
class InstructionsPage extends StatefulWidget {
  const InstructionsPage({
    super.key,
    required this.viewModel,
    this.initialJurisdictionId,
    this.initialQuestionId,
  });

  final AssessmentViewModel viewModel;

  /// Optional deep-link: an assessment-info id (e.g. 'clark-county'), from
  /// `/instructions?jurisdiction=<id>`.
  final String? initialJurisdictionId;

  /// Optional deep-link: a question-info id (e.g. 'underserved'), from
  /// `/instructions?...&question=<id>`.
  final String? initialQuestionId;

  static const _stepLabels = ['Step 1 — Existing Need', 'Step 2 — Existing Infrastructure'];

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  int? _selectedIndex;
  String? _expandedKey;
  bool _initialSelectionApplied = false;
  final Map<String, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  void _applyInitialSelectionIfNeeded(StaticData staticData) {
    if (_initialSelectionApplied) return;
    _initialSelectionApplied = true;

    final pairs = staticData.assessmentInfoPairsSorted;
    if (widget.initialJurisdictionId != null) {
      final index = pairs.indexWhere((p) => p.$1 == widget.initialJurisdictionId);
      if (index != -1) _selectedIndex = index;
    }
    if (_selectedIndex != null && widget.initialQuestionId != null) {
      final assessmentInfo = pairs[_selectedIndex!].$2;
      for (final (sectionIndex, ids) in assessmentInfo.questionInfoIds.indexed) {
        final qIndex = ids.indexOf(widget.initialQuestionId!);
        if (qIndex != -1) {
          _expandedKey = '$sectionIndex:${widget.initialQuestionId}';
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToExpanded());
          break;
        }
      }
    }
  }

  void _scrollToExpanded() {
    final key = _expandedKey == null ? null : _cardKeys[_expandedKey];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.1);
    }
  }

  /// Reflects the current selection in the URL, so the current view can be
  /// bookmarked/shared/linked to directly.
  ///
  /// This talks to the browser's History API directly (via [urlStrategy])
  /// instead of going through `Navigator.pushReplacementNamed`. Using the
  /// Navigator here would replace the current route with a brand new one on
  /// every click — rebuilding this whole page and playing Flutter's default
  /// page-transition animation each time, which is exactly the unwanted
  /// "drawer/transition" effect this page must not have. `replaceState`
  /// updates the address bar with zero effect on the widget tree.
  void _updateUrl(StaticData staticData) {
    final params = <String, String>{};
    if (_selectedIndex != null) {
      params['jurisdiction'] = staticData.assessmentInfoPairsSorted[_selectedIndex!].$1;
    }
    if (_expandedKey != null) {
      params['question'] = _expandedKey!.split(':').skip(1).join(':');
    }
    final uri = Uri(path: '/instructions', queryParameters: params.isEmpty ? null : params);
    urlStrategy?.replaceState(null, '', uri.toString());
  }

  void _selectJurisdiction(int? index, StaticData staticData) {
    setState(() {
      _selectedIndex = index;
      _expandedKey = null;
    });
    _updateUrl(staticData);
  }

  void _toggleQuestion(String key, StaticData staticData) {
    setState(() => _expandedKey = _expandedKey == key ? null : key);
    _updateUrl(staticData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiteTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SiteHeader(currentRoute: '/instructions'),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.viewModel.loaded,
                builder: (context, loaded, _) {
                  if (!loaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final staticData = widget.viewModel.staticData!;
                  _applyInitialSelectionIfNeeded(staticData);
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIntro(context, staticData),
                        if (_selectedIndex != null) _buildQuestions(context, staticData),
                        const SiteFooter(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context, StaticData staticData) {
    return SiteSection(
      background: SiteTheme.bgAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteSectionHeading('Instructions'),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Text(
              'Instructions and resources vary by jurisdiction. Select a jurisdiction below '
              'to view the instructions for each question.',
              style: TextStyle(fontSize: 16, color: SiteTheme.textMuted, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          _JurisdictionSelector(
            pairs: staticData.assessmentInfoPairsSorted,
            selectedIndex: _selectedIndex,
            onChanged: (i) => _selectJurisdiction(i, staticData),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestions(BuildContext context, StaticData staticData) {
    final assessmentInfo = staticData.assessmentInfoPairsSorted[_selectedIndex!].$2;
    final questionsBySection = assessmentInfo.getQuestionInfos(staticData.questionInfoMap);

    return SiteSection(
      background: SiteTheme.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (sectionIndex, questions) in questionsBySection.indexed) ...[
            if (sectionIndex > 0) const SizedBox(height: 36),
            SiteSectionHeading(
              sectionIndex < InstructionsPage._stepLabels.length
                  ? InstructionsPage._stepLabels[sectionIndex]
                  : 'Step ${sectionIndex + 1}',
              fontSize: 20,
            ),
            const SizedBox(height: 16),
            for (final (indexInSection, questionInfo) in questions.indexed)
              _buildCard(sectionIndex, indexInSection, questionInfo),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(int sectionIndex, int indexInSection, QuestionInfo questionInfo) {
    // Question ids are unique keys into questionInfoMap; keying by id (not
    // list position) keeps the expanded/deep-linked question stable even if
    // a jurisdiction's question order changes.
    final id = _idFor(sectionIndex, indexInSection, questionInfo);
    final key = '$sectionIndex:$id';
    final cardKey = _cardKeys.putIfAbsent(key, () => GlobalKey());
    final staticData = widget.viewModel.staticData!;

    return Padding(
      key: cardKey,
      padding: const EdgeInsets.only(bottom: 12),
      child: _QuestionAccordionCard(
        label: 'S${sectionIndex + 1}Q${indexInSection + 1}',
        questionInfo: questionInfo,
        expanded: _expandedKey == key,
        onToggle: () => _toggleQuestion(key, staticData),
      ),
    );
  }

  /// Recovers the question-info id for display/URL purposes by matching
  /// this question back to its id in the jurisdiction's own configuration —
  /// avoids inferring/guessing ids from anything other than the actual
  /// `questionInfoIds` list.
  String _idFor(int sectionIndex, int indexInSection, QuestionInfo questionInfo) {
    final assessmentInfo = widget.viewModel.staticData!.assessmentInfoPairsSorted[_selectedIndex!].$2;
    return assessmentInfo.questionInfoIds[sectionIndex][indexInSection];
  }
}

class _JurisdictionSelector extends StatelessWidget {
  const _JurisdictionSelector({
    required this.pairs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<(String, AssessmentInfo)> pairs;
  final int? selectedIndex;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        decoration: BoxDecoration(
          color: SiteTheme.bg,
          border: Border.all(color: SiteTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: selectedIndex,
            hint: const Text('Select a jurisdiction', style: TextStyle(color: SiteTheme.textMuted)),
            icon: const Icon(Icons.expand_more, color: SiteTheme.primary),
            focusColor: SiteTheme.bg,
            items: [
              for (final (i, pair) in pairs.indexed)
                DropdownMenuItem(value: i, child: Text(pair.$2.jurisdiction)),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _QuestionAccordionCard extends StatelessWidget {
  const _QuestionAccordionCard({
    required this.label,
    required this.questionInfo,
    required this.expanded,
    required this.onToggle,
  });

  final String label;
  final QuestionInfo questionInfo;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SiteTheme.bg,
        border: Border.all(color: SiteTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            // Keep InkWell only for its built-in keyboard activation
            // (Enter/Space), focus outline, and hover cursor — but disable
            // its animated ripple/splash and highlight fade, so tapping a
            // question has no visual transition of its own. The only things
            // that change on click are the icon (instant swap, see below)
            // and whether the content below is rendered at all.
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: SiteTheme.bgAlt,
            child: Semantics(
              button: true,
              expanded: expanded,
              label: '$label: ${questionInfo.questionText}',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: SiteTheme.bgAlt,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SiteTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        questionInfo.questionText,
                        style: const TextStyle(fontSize: 15, color: SiteTheme.textColor),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: SiteTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: SiteTheme.border),
                  const SizedBox(height: 12),
                  if (questionInfo.url.isNotEmpty)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${questionInfo.useUrl} ',
                          style: const TextStyle(color: SiteTheme.textColor),
                        ),
                        InkWell(
                          onTap: () => openExternalLink(questionInfo.url),
                          child: const Text(
                            'available here',
                            style: TextStyle(
                              color: SiteTheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (questionInfo.hint.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      questionInfo.hint,
                      style: const TextStyle(
                        color: SiteTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  QuestionInstructionsContent(questionInfo: questionInfo),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
