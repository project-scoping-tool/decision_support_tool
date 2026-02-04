import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:flutter/material.dart';

class SelectJurisdictionPage extends StatefulWidget {
  const SelectJurisdictionPage({super.key, required this.viewModel});

  final AssessmentViewModel viewModel;

  @override
  State<SelectJurisdictionPage> createState() => _SelectJurisdictionPageState();
}

class _SelectJurisdictionPageState extends State<SelectJurisdictionPage> {
  static const _nextButtonFontSize = 16.0;

  AssessmentViewModel get _viewModel => widget.viewModel;

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext _) {
    // assert(widget.viewModel.staticData.value != null);
    // assert(widget.viewModel.formData.value != null);

    return Scaffold(
      appBar: AppBar(
        title: Text('Jurisdiction:     Choose the appropriate jurisdiction'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: _viewModel.selectedJurisdictionIndex,
            builder: (_, selectedIndexValue, _) => RadioGroup<int>(
              groupValue: selectedIndexValue,
              onChanged: (index) => setState(() {
                _viewModel.selectJurisdiction(index);
              }),
              child: Column(
                children: [
                  // Padding above list of options
                  Padding(padding: EdgeInsets.only(top: _screenHeight * 0.15)),

                  // Radio group
                  for (final (i, (_, ai))
                      in _viewModel
                          .staticData!
                          .assessmentInfoPairsSorted
                          .indexed)
                    _buildWidgetRadioButtonContainer(i, ai.jurisdiction),

                  // Next button container
                  _buildWidgetNextButtonContainer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetNextButtonContainer() => Align(
    alignment: Alignment.centerRight,
    child: Container(
      padding: EdgeInsets.only(right: _screenWidth * 0.0376),
      child: ValueListenableBuilder(
        valueListenable: widget.viewModel.selectedJurisdictionIndex,
        builder: (_, index, _) =>
            _buildWidgetNextButton(enabled: index != null),
      ),
    ),
  );

  Widget _buildWidgetNextButton({required bool enabled}) {
    final void Function()? onTap = (enabled)
        ? () async {
            await _viewModel.startAssessment();
            _viewModel.goToNextPage();
          }
        : null;

    return InkWell(
      enableFeedback: false,
      onTap: onTap,
      child: Container(
        width: _screenWidth * 0.0752,
        height: _screenHeight * 0.047,
        color: (enabled)
            ? const Color.fromARGB(255, 147, 88, 255)
            : const Color.fromARGB(255, 205, 192, 229),
        alignment: Alignment.center,
        child: Text(
          'Go To Step 1',
          style: TextStyle(
            fontSize: _nextButtonFontSize,
            color: (enabled) ? null : const Color.fromARGB(255, 103, 103, 103),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetRadioButtonContainer(int index, String jurisdiction) {
    return Container(
      width: _screenWidth * 0.2,
      child: RadioListTile<int>(title: Text(jurisdiction), value: index),
    );
  }
}
