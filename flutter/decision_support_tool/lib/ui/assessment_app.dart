import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:decision_support_tool/ui/question_section_page.dart';
import 'package:decision_support_tool/ui/recommendations_page.dart';
import 'package:decision_support_tool/ui/select_jurisdiction_page.dart';
import 'package:flutter/material.dart';

class AssessmentApp extends StatefulWidget {
  const AssessmentApp({super.key, required this.viewModel});

  final AssessmentViewModel viewModel;

  @override
  State<AssessmentApp> createState() => _AssessmentAppState();
}

class _AssessmentAppState extends State<AssessmentApp> {
  AssessmentViewModel get _viewModel => widget.viewModel;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _viewModel.load(); // Asynchronously load static data from the view model.
    _viewModel.page.addListener(_onChangePage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _viewModel.loaded,
        builder: (_, loadedValue, _) {
          if (loadedValue) {
            return PageView(
              controller: _pageController,
              children: [
                SelectJurisdictionPage(viewModel: _viewModel),
                ValueListenableBuilder(
                  valueListenable: _viewModel.hasStartedAssessment,
                  builder: (_, started, _) {
                    if (!started) return Placeholder();
                    return QuestionSectionPage(
                      viewModel: _viewModel.questionSectionViewModels[0],
                      sectionIndex: 0,
                      previousPageButtonText: 'Jurisdictions',
                      nextPageButtonText: 'Go to Step 2',
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _viewModel.hasStartedAssessment,
                  builder: (_, started, _) {
                    if (!started) return Placeholder();
                    return QuestionSectionPage(
                      viewModel: _viewModel.questionSectionViewModels[1],
                      sectionIndex: 1,
                      previousPageButtonText: 'Go to Step 1',
                      nextPageButtonText: 'Go to Step 3',
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _viewModel.hasStartedAssessment,
                  builder: (_, started, _) {
                    if (!started) return Placeholder();
                    return RecommendationsPage(
                      viewModel: _viewModel.recommendationsViewModel!,
                    );
                  },
                ),
              ],
              physics: NeverScrollableScrollPhysics(),
            );
          } else {
            // When the view model has not loaded yet.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// Called when the page changed.
  void _onChangePage() {
    _pageController.animateToPage(
      widget.viewModel.page.value,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOutCirc,
    );
  }
}
