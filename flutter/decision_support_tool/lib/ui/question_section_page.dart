import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/ui/expanded_section.dart';
import 'package:decision_support_tool/ui/question_section_view_model.dart';
import 'package:decision_support_tool/ui/video_app.dart';
import 'package:decision_support_tool/ui/parks_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:decision_support_tool/services/parks_query_service.dart';
import 'package:decision_support_tool/services/adi_query_service.dart';
import 'package:decision_support_tool/services/parks_map_service.dart';
import 'package:decision_support_tool/services/bus_stops_query_service.dart';
import 'package:decision_support_tool/services/bus_stops_map_service_flutter.dart';
import 'package:decision_support_tool/ui/bus_stops_map_widget.dart';
import 'package:decision_support_tool/ui/autofill_result_dialog.dart';
import 'package:decision_support_tool/ui/autofill_map_dialog.dart';
import 'package:decision_support_tool/services/bike_lanes_query_service.dart';
import 'package:decision_support_tool/services/bike_lanes_map_service.dart';
import 'package:decision_support_tool/ui/bike_lanes_map_widget.dart';

class QuestionSectionPage extends StatefulWidget {
  const QuestionSectionPage({
    super.key,
    required this.viewModel,
    required this.sectionIndex,
    this.previousPageButtonText = "WARNING: NOT SPECIFIED",
    this.nextPageButtonText = "WARNING: NOT SPECIFIED",
  });

  final QuestionSectionViewModel viewModel;
  final int sectionIndex;

  final String previousPageButtonText;
  final String nextPageButtonText;

  @override
  State<QuestionSectionPage> createState() => _QuestionSectionPageState();
}

class _QuestionSectionPageState extends State<QuestionSectionPage> {
  static const _fontSize = 16.0;

  static final _cellBgColors = [Colors.grey[200]!, Colors.blueGrey[100]!];

  /// Text controller for project address
  late final TextEditingController _projectAddressController;

  /// Store the last parks query result for map display
  ParksQueryResult? _lastParksResult;

  /// Store the last bus stops query result for map display
  BusStopsQueryResult? _lastBusStopsResult;

  /// Store the last bike lines query result for map display
  BikeLanesQueryResult? _lastBikeLanesResult;

  QuestionSectionViewModel get _viewModel => widget.viewModel;
  String get _jurisdiction => widget.viewModel.assessmentInfo.jurisdiction;
  List<QuestionInfo> get _questionInfos => widget.viewModel.questionInfos;

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  static Color _getCellBgColor(int questionIndex) {
    return _cellBgColors[questionIndex % 2];
  }

  @override
  void initState() {
    super.initState();
    // Initialize the text controller with existing project address if available
    _projectAddressController = TextEditingController(
      text: _viewModel.assessmentInfo.projectAddress ?? '',
    );

    // Listen to changes and update the view model
    _projectAddressController.addListener(() {
      _viewModel.setProjectAddress(_projectAddressController.text);
    });
  }

  @override
  void dispose() {
    _projectAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Step 1:     Assess Area's Existing Need"),
            Text('Jurisdiction:     $_jurisdiction'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: _buildWidgetBody(),
    );
  }

  Widget _buildWidgetBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: _screenHeight * 0.05)),
          _buildProjectAddressInput(),
          Padding(padding: EdgeInsets.only(top: _screenHeight * 0.02)),
          _buildWidgetTableHeader(),
          _buildWidgetTableCells(),
          _buildWidgetTotalPointsSum(),
          _buildWidgetFooterButtons(),
        ],
      ),
    );
  }

  /// Build project address input widget
  Widget _buildProjectAddressInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.03),
      child: Card(
        elevation: 3.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue[700], size: 24.0),
                  SizedBox(width: 8.0),
                  Text(
                    'Project Address',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _projectAddressController,
                decoration: InputDecoration(
                  hintText:
                      'Enter project address (e.g., 1250 American Pacific Dr, Henderson, NV 89074)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.blue[700]!,
                      width: 2.0,
                    ),
                  ),
                  prefixIcon: Icon(Icons.home, color: Colors.blue[600]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                ),
                style: TextStyle(fontSize: 16.0),
                maxLines: 1,
              ),
              SizedBox(height: 8.0),
              Text(
                'This address will be used for location-based queries (e.g., parks within ½ mile)',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetTableHeader() {
    final bgColor = Colors.blue[400]!;
    final textColor = Colors.white;
    final fontSize = 16.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03,
      ),
      child: ColoredBox(
        color: bgColor,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Column 1
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: _screenHeight * 0.02,
                  horizontal: _screenWidth * 0.94 * 0.02,
                ),
                width: _screenWidth * 0.94 * 0.8 - 6.0,
                child: Text(
                  'Existing Needs Assessment',
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(width: 3.0, color: Colors.white),

              // Column 2
              Container(
                alignment: Alignment.center,
                width: _screenWidth * 0.94 * 0.15,
                child: Text(
                  'Domain',
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(width: 3.0, color: Colors.white),

              // Column 3
              Container(
                alignment: Alignment.center,
                width: _screenWidth * 0.94 * 0.05,
                child: Text(
                  'Points',
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetTableCells() {
    return Column(
      children: [
        for (int i = 0; i < _questionInfos.length; i++) _buildWidgetQuestion(i),
      ],
    );
  }

  Widget _buildWidgetQuestion(int questionIndex) {
    final backgroundColor = _getCellBgColor(questionIndex);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.03),
      child: ColoredBox(
        color: backgroundColor,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWidgetQuestionCell1(questionIndex),
              Container(width: 3.0, color: Colors.white),
              _buildWidgetQuestionCell2(questionIndex),
              Container(width: 3.0, color: Colors.white),
              _buildWidgetQuestionCell3(questionIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetQuestionCell1(int questionIndex) {
    final backgroundColor = _getCellBgColor(questionIndex);
    final questionInfo = _questionInfos[questionIndex];
    final fontSize = 16.0;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _screenHeight * 0.01,
        horizontal: _screenWidth * 0.94 * 0.01,
      ),
      width: _screenWidth * 0.94 * 0.8 - 6.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Question text
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(3.0),
              color: backgroundColor,
              child: Container(
                child: Text(
                  'Q${questionIndex + 1}: ${questionInfo.questionText}',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ),
          ),
          // URL Text
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: _screenWidth * 0.94 * 0.03),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${questionInfo.useUrl} ',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
              TextButton(
                onPressed: () => _openLink(questionInfo.url),
                child: Text(
                  'available here',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ],
          ),
          // Hint
          questionInfo.hint == ""
              ? Container()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: _screenWidth * 0.94 * 0.03,
                      right: 3.0,
                      top: 3.0,
                      bottom: 3.0,
                    ),
                    color: backgroundColor,
                    child: Container(
                      child: Text(
                        questionInfo.hint,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
          // Space
          Container(padding: EdgeInsets.only(top: _screenHeight * 0.005)),
          // Instructions dropdown
          _buildWidgetInstructions(questionIndex),
          // Space
          Container(padding: EdgeInsets.only(top: _screenHeight * 0.01)),

          // AUTO-FILL BUTTON
          _buildWidgetAutoFillButton(questionIndex),

          // Space
          Container(padding: EdgeInsets.only(top: _screenHeight * 0.01)),
          // Row for answers
          Container(
            child: Row(
              children: [
                // Leading header for answer type & points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        questionInfo.answerLeadingHeader,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Selectable answers
                Container(
                  width: _screenWidth * 0.9 * 0.69,
                  child: _buildWidgetAnswersRow(questionIndex),
                ),
              ],
            ),
          ),
          // Space
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.001,
            ),
          ),
        ],
      ),
    );
  }

  /// Drop down animated instruction
  Widget _buildWidgetInstructions(int questionIndex) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: ValueListenableBuilder(
          valueListenable: _viewModel.expandedBools[questionIndex],
          builder: (context, expanded, child) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: _screenWidth * 0.94 * 0.03),
                  child: InkWell(
                    onTap: () {
                      _viewModel.expandInstructions(questionIndex, !expanded);
                    },
                    child: Row(
                      children: [
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: _fontSize,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ExpandedSection(
                    child: _buildWidgetExpandedSectionContents(questionIndex),
                    expand: expanded,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWidgetExpandedSectionContents(int questionIndex) {
    final questionInfo = _questionInfos[questionIndex];
    return Column(
      children: [
        _buildWidgetInstructionsText(questionInfo.instructionsMarkdown),
        _buildWidgetInstructionsVideo(questionInfo.videoId),
      ],
    );
  }

  /// Builds the widget containing the instructions (typically containing
  /// bulletpoints)
  Widget _buildWidgetInstructionsText(String markdownData) {
    const double verticalPadding = 5.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0.0),
              child: MarkdownBlock(data: markdownData),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the widget containing the video player under each set of
  /// instructions.
  Widget _buildWidgetInstructionsVideo(String videoId) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.94 * 0.7,
        height:
            ((MediaQuery.of(context).size.width * 0.94 * 0.7) / 16.0) * 11.0 +
            2,
        child: VideoApp(videoId: videoId),
      ),
    );
  }

  Widget _buildWidgetAnswersRow(int questionIndex) {
    final questionInfo = _questionInfos[questionIndex];
    final backgroundColor = _getCellBgColor(questionIndex);
    return ValueListenableBuilder(
      valueListenable: _viewModel.selectedAnswerIndices[questionIndex],
      builder: (_, selectedIndex, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (i, answer) in questionInfo.answers.indexed)
            Container(
              child: InkWell(
                onTap: () {
                  _viewModel.selectAnswer(questionIndex, i);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _screenWidth * 0.94 * 0.015,
                    vertical: _screenWidth * 0.94 * 0.01,
                  ),
                  color: selectedIndex == i
                      ? Colors.green[400]
                      : backgroundColor,
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          answer.text,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: _fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWidgetQuestionCell2(int questionIndex) {
    final questionInfo = _questionInfos[questionIndex];
    return Container(
      alignment: Alignment.center,
      color: _getCellBgColor(questionIndex),
      width: _screenWidth * 0.94 * 0.15,
      child: Text(
        questionInfo.domain,
        style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWidgetQuestionCell3(int questionIndex) {
    final backgroundColor = _getCellBgColor(questionIndex);
    final questionInfo = _questionInfos[questionIndex];
    final pointsMax =
        questionInfo.answers[questionInfo.answers.length - 1].points;
    return ValueListenableBuilder(
      valueListenable: _viewModel.selectedAnswerIndices[questionIndex],
      builder: (_, selectedIndex, _) {
        final numerator = (selectedIndex != null)
            ? '${questionInfo.answers[selectedIndex].points}'
            : '';
        return Container(
          alignment: Alignment.center,
          color: backgroundColor,
          width: _screenWidth * 0.94 * 0.05,
          child: Text(
            '${numerator}/${pointsMax}',
            style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildWidgetTotalPointsSum() {
    double fontSize = 16.0;
    Color backgroundColor = Colors.blue[200]!;

    return Column(
      children: [
        Container(width: _screenWidth * 0.94, height: 5.0, color: Colors.black),
        Container(
          padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.03),
          child: ColoredBox(
            color: backgroundColor,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1st Column
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: _screenHeight * 0.01,
                      horizontal: _screenWidth * 0.94 * 0.01,
                    ),
                    width: _screenWidth * 0.94 * 0.8 - 6.0,
                  ),
                  Container(width: 3.0, color: Colors.white),
                  // 2nd column
                  Container(
                    alignment: Alignment.center,
                    color: backgroundColor,
                    width: _screenWidth * 0.94 * 0.15,
                    child: Text(
                      'Total Points',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(width: 3.0, color: Colors.white),
                  // 3rd column
                  Container(
                    padding: EdgeInsets.all(_screenHeight * 0.02),
                    alignment: Alignment.center,
                    color: backgroundColor,
                    width: _screenWidth * 0.94 * 0.05,
                    child: ListenableBuilder(
                      listenable: _viewModel.anyAnswerChanged,
                      builder: (_, _) {
                        return Text(
                          '${_viewModel.pointsSum}',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: _screenHeight * 0.05)),
      ],
    );
  }

  Widget _buildWidgetFooterButtons() {
    final fontSize = 16.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous page button
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(left: _screenWidth * 0.94 * 0.04),
                child: InkWell(
                  onTap: () {
                    _viewModel.goToPreviousPage();
                  },
                  child: Container(
                    width: _screenWidth * 0.94 * 0.08,
                    height: _screenHeight * 0.05,
                    color: Colors.deepPurple[200],
                    alignment: Alignment.center,
                    child: Text(
                      widget.previousPageButtonText,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ),
                ),
              ),
            ),
            // Next page button
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.only(right: _screenWidth * 0.94 * 0.04),
                child: ListenableBuilder(
                  listenable: _viewModel.anyAnswerChanged,
                  builder: (_, _) {
                    final isAllQuestionsAnswered =
                        _viewModel.isAllQuestionsAnswered;
                    return InkWell(
                      onTap: (isAllQuestionsAnswered)
                          ? () {
                              if (!_viewModel.isLastQuestionSection) {
                                _viewModel.goToNextPage();
                              } else {
                                _showCustomDialog();
                              }
                            }
                          : null,
                      child: Container(
                        width: _screenWidth * 0.94 * 0.08,
                        height: _screenHeight * 0.05,
                        color: (isAllQuestionsAnswered)
                            ? const Color.fromARGB(255, 147, 88, 255)
                            : const Color.fromARGB(255, 228, 222, 240),
                        alignment: Alignment.center,
                        child: Text(
                          widget.nextPageButtonText,
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: _screenHeight * 0.05)),
      ],
    );
  }

  /// Opens a link on the browser.
  Future<void> _openLink(String url) async {
    Uri uri = Uri.parse(url);
    await canLaunchUrl(uri)
        ? await launchUrl(uri)
        : throw 'Could not launch $url';
  }

  /// Shows a custom dialogue.
  void _showCustomDialog() {
    const fontSize = 16.0;
    final recommendation = _viewModel.getInfrastructureRecommendation();
    final recommended = recommendation.recommendedText;

    // Log the recommended value
    print('Recommended Infrastructure: $recommended');

    AlertDialog dialog = AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          hoverColor: Colors.grey,
          highlightColor: Colors.grey[700],
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(5.0),
            child: Icon(Icons.close, color: Colors.red, size: 20.0),
          ),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
      content: Container(
        width: _screenWidth * 0.4,
        height: _screenHeight * 0.2,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Text(
                      'Selected Infrastructure',
                      style: TextStyle(color: Colors.black, fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      'Based on Steps 1 & 2, below is the selected recommendation to pursue.',
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ),
                ],
              ),
              flex: 1,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    recommended,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              flex: 1,
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0),
              alignment: Alignment.bottomRight,
              child: ColoredBox(
                color: Colors.blue[300]!,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewModel.goToNextPage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Continue to Step 3',
                      style: TextStyle(fontSize: fontSize, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  /// Build auto-fill button for parks question
  Widget _buildWidgetAutoFillButton(int questionIndex) {
    final questionInfo = _questionInfos[questionIndex];

    // Check if auto-fill is enabled for this question
    if (!questionInfo.autoFillEnabled) {
      return Container(); // Don't show button
    }

    // Determine which service to use based on domain and question text
    String buttonText;
    IconData buttonIcon;
    VoidCallback onPressed;

    switch (questionInfo.buttonText) {
      case 'Parks':
        buttonText = 'Auto-fill from Park Data';
        buttonIcon = Icons.map;
        onPressed = () => _fetchParksCount(questionIndex);
        break;

      case 'Bus Stops':
        buttonText = 'Auto-fill from Bus Stop Data';
        buttonIcon = Icons.directions_bus;
        onPressed = () => _fetchBusStopsCount(questionIndex);
        break;

      case 'ADI':
        buttonText = 'Auto-fill from ADI Database';
        buttonIcon = Icons.analytics;
        onPressed = () => _fetchAdiValue(questionIndex);
        break;

      case 'Bike Lanes':
        buttonText = 'Auto-fill from Bike Lane Data';
        buttonIcon = Icons.directions_bike;
        onPressed = () => _fetchBikeLanesCount(questionIndex);
        break;

      default:
        debugPrint(
          'No auto-fill configuration for question: ${questionInfo.questionText}',
        );
        return Container();
    }

    return Container(
      padding: EdgeInsets.only(
        left: _screenWidth * 0.94 * 0.03,
        top: _screenHeight * 0.01,
        bottom: _screenHeight * 0.01,
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            icon: Icon(buttonIcon, size: 16.0),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            ),
            onPressed: onPressed,
          ),
          SizedBox(width: 10.0),
          // Show loading indicator when fetching
          ValueListenableBuilder(
            valueListenable: _viewModel.isFetchingParksData,
            builder: (context, isFetching, child) {
              if (isFetching) {
                return Row(
                  children: [
                    SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Querying data...',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  /// Fetch parks count using the Dart service
  Future<void> _fetchParksCount(int questionIndex) async {
    try {
      _viewModel.setFetchingParksData(true);

      // Get the project address from the text controller
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      // Call the Dart service instead of external API
      final result = await ParksQueryService.countParksNearAddress(address);

      // Store the result for map display
      _lastParksResult = result;

      // Find the answer index that matches
      final questionInfo = _questionInfos[questionIndex];
      int answerIndex = questionInfo.answers.indexWhere(
        (a) => a.text == result.answer,
      );

      if (answerIndex != -1) {
        // Auto-select the answer
        _viewModel.selectAnswer(questionIndex, answerIndex);

        // Show success dialog with results
        _showParksResultDialog(
          result.count,
          result.matchedAddress,
          result.answer,
          result.layerId,
        );
      } else {
        _showErrorDialog('Could not match answer: ${result.answer}');
      }
    } catch (e) {
      _showErrorDialog('Error fetching parks data: $e');
    } finally {
      _viewModel.setFetchingParksData(false);
    }
  }

  /// Fetch bus stops count using the Dart service
  Future<void> _fetchBusStopsCount(int questionIndex) async {
    try {
      _viewModel.setFetchingParksData(true);

      // Get the project address from the text controller
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      // Call the bus stops service
      final result = await BusStopsQueryService.countBusStopsNearAddress(
        address,
      );

      // Store the result for map display
      _lastBusStopsResult = result;

      // Find the answer index that matches
      final questionInfo = _questionInfos[questionIndex];
      int answerIndex = questionInfo.answers.indexWhere(
        (a) => a.text == result.answer,
      );

      if (answerIndex != -1) {
        // Auto-select the answer
        _viewModel.selectAnswer(questionIndex, answerIndex);

        // Show success dialog with results
        _showBusStopsResultDialog(
          result.count,
          result.matchedAddress,
          result.answer,
          result.layerId,
        );
      } else {
        _showErrorDialog('Could not match answer: ${result.answer}');
      }
    } catch (e) {
      _showErrorDialog('Error fetching bus stops data: $e');
    } finally {
      _viewModel.setFetchingParksData(false);
    }
  }

  void _showParksResultDialog(
    int count,
    String matchedAddress,
    String answer,
    int layerId,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Parks Query Results',
        foundLabel: 'Parks Found:',
        foundValueText: '$count park(s) within ½ mile radius',
        foundIcon: Icons.park,
        dataSourceText: 'Data from Clark County Recreation layer $layerId',
        onViewMap: _showParksMap,
      ),
    );
  }

  void _showBusStopsResultDialog(
    int count,
    String matchedAddress,
    String answer,
    int layerId,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Bus Stops Query Results',
        foundLabel: 'Bus Stops Found:',
        foundValueText: '$count bus stop(s) within ¼ mile radius',
        foundIcon: Icons.directions_bus,
        dataSourceText: 'Data from ArcGIS bus stops layer $layerId',
        onViewMap: _showBusStopsMap,
        // optional: make bus icon orange but keep everything else parks-blue
        // foundIconColor: Colors.orange[700],
      ),
    );
  }

  /// Show map in a dialog using Flutter widgets
  Future<void> _showParksMap() async {
    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: _lastParksResult,
        noDataMessage: 'No parks data available to display map.',
        loadingMessage: 'Loading map...',

        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => r.layerId,

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) {
              return ParksMapService.getMapData(
                lon: lon,
                lat: lat,
                matchedAddress: matchedAddress,
                layerId: layerId,
              );
            },

        buildMapWidget: (mapData) => ParksMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          parkFeatures: mapData.parkFeatures,
          layerId: mapData.layerId,
        ),

        // Parks-dominant defaults already apply; theme can be omitted.
      ),
    );
  }

  Future<void> _showBikeLanesMap() async {
    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: _lastBikeLanesResult,
        noDataMessage: 'No bike lanes data available to display map.',
        loadingMessage: 'Loading map...',

        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) =>
            r.bikeLaneLayerId, // Use bike lane layer ID as primary

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId, // This will be bikeLaneLayerId
            }) async {
              // We need both layer IDs, so get them from the result
              return BikeLanesMapService.getMapData(
                lon: lon,
                lat: lat,
                matchedAddress: matchedAddress,
                bikeLaneLayerId: _lastBikeLanesResult!.bikeLaneLayerId,
                sharedUsePathLayerId:
                    _lastBikeLanesResult!.sharedUsePathLayerId,
              );
            },

        buildMapWidget: (mapData) => BikeLanesMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          bikeLaneFeatures: mapData.bikeLaneFeatures,
          sharedUsePathFeatures: mapData.sharedUsePathFeatures,
          bikeLaneLayerId: mapData.bikeLaneLayerId,
          sharedUsePathLayerId: mapData.sharedUsePathLayerId,
        ),
      ),
    );
  }

  /// Show bus stops map in a dialog using Flutter widgets
  Future<void> _showBusStopsMap() async {
    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: _lastBusStopsResult,
        noDataMessage: 'No bus stops data available to display map.',
        loadingMessage: 'Loading map...', // parks-dominant wording

        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => r.layerId,

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) {
              return BusStopsMapService.getMapData(
                lon: lon,
                lat: lat,
                matchedAddress: matchedAddress,
                layerId: layerId,
              );
            },

        buildMapWidget: (mapData) => BusStopsMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          busStopFeatures: mapData.busStopFeatures,
          layerId: mapData.layerId,
        ),
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28.0),
              SizedBox(width: 10.0),
              Text('Error'),
            ],
          ),
          content: Container(
            constraints: BoxConstraints(maxWidth: _screenWidth * 0.4),
            child: Text(message, style: TextStyle(fontSize: 14.0)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(fontSize: 16.0)),
            ),
          ],
        );
      },
    );
  }

  /// Fetch bike lanes and shared use paths count using the Dart service
  Future<void> _fetchBikeLanesCount(int questionIndex) async {
    try {
      _viewModel.setFetchingParksData(true);

      // Get the project address from the text controller
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      // Call the bike lanes service
      final result = await BikeLanesQueryService.countBikeLanesNearAddress(
        address,
      );

      // Store the result for map display
      _lastBikeLanesResult = result;

      // Find the answer index that matches
      final questionInfo = _questionInfos[questionIndex];
      int answerIndex = questionInfo.answers.indexWhere(
        (a) => a.text == result.answer,
      );

      if (answerIndex != -1) {
        // Auto-select the answer
        _viewModel.selectAnswer(questionIndex, answerIndex);

        // Show success dialog with results
        _showBikeLanesResultDialog(
          result.count,
          result.matchedAddress,
          result.answer,
          result.bikeLaneLayerId,
          result.sharedUsePathLayerId,
        );
      } else {
        _showErrorDialog('Could not match answer: ${result.answer}');
      }
    } catch (e) {
      _showErrorDialog('Error fetching bike lanes data: $e');
    } finally {
      _viewModel.setFetchingParksData(false);
    }
  }

  /// Fetch ADI value using the Dart service
  Future<void> _fetchAdiValue(int questionIndex) async {
    try {
      _viewModel.setFetchingParksData(true);

      // Get the project address from the text controller
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      // Call the ADI service
      final result = await AdiQueryService.getAdiForAddress(address);

      // Find the answer index that matches the ADI value
      final questionInfo = _questionInfos[questionIndex];
      int answerIndex = questionInfo.answers.indexWhere(
        (a) => a.text == result.adiValue.toString(),
      );

      if (answerIndex != -1) {
        // Auto-select the answer
        _viewModel.selectAnswer(questionIndex, answerIndex);

        // Show success dialog with results
        _showAdiResultDialog(
          result.adiValue,
          result.matchedAddress,
          result.blockGroup,
          result.county,
        );
      } else {
        _showErrorDialog('Could not match ADI value: ${result.adiValue}');
      }
    } catch (e) {
      _showErrorDialog('Error fetching ADI data: $e');
    } finally {
      _viewModel.setFetchingParksData(false);
    }
  }

  void _showBikeLanesResultDialog(
    int count,
    String matchedAddress,
    String answer,
    int bikeLaneLayerId,
    int sharedUsePathLayerId,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Bike Lanes & Shared Use Paths Query Results',
        foundLabel: 'Bike Infrastructure Found:',
        foundValueText: '$count feature(s) within ¼ mile radius',
        foundIcon: Icons.directions_bike,
        dataSourceText:
            'Data from RTC (Regional Transportation Commission) layers',
        onViewMap: _showBikeLanesMap,
        // Use bike-themed colors
        foundIconColor: Colors.blue[700],
        foundBoxBg: Colors.blue[50],
        foundBoxBorder: Colors.blue[300],
      ),
    );
  }

  void _showAdiResultDialog(
    int adiValue,
    String matchedAddress,
    String blockGroup,
    String county,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: adiValue.toString(),
      config: AutoFillDialogConfig(
        titleText: 'ADI Query Results',
        foundLabel: 'Area Deprivation Index (State Decile):',
        foundValueText: 'ADI State Decile: $adiValue',
        foundIcon: Icons.analytics,
        dataSourceText: 'Data from U. of Wisconsin ADI Database',

        // No map button for ADI (onViewMap: null)

        // Extra blockGroup/county lines inside the amber box
        extraDataSourceWidgets: [
          if (blockGroup != 'Unknown') ...[
            const SizedBox(height: 5.0),
            Text(
              'Block Group: $blockGroup',
              style: TextStyle(fontSize: 11.0, color: Colors.amber[900]),
            ),
          ],
          if (county != 'Unknown') ...[
            const SizedBox(height: 3.0),
            Text(
              'County: $county',
              style: TextStyle(fontSize: 11.0, color: Colors.amber[900]),
            ),
          ],
        ],

        // Optional: make ADI icon blue but keep Parks theme elsewhere
        foundIconColor: Colors.blue[700],
      ),
    );
  }
}
