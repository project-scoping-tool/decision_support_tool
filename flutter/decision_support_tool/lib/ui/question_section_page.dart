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
import 'package:decision_support_tool/services/schools_query_service.dart';
import 'package:decision_support_tool/services/schools_map_service.dart';
import 'package:decision_support_tool/ui/schools_map_widget.dart';
import 'package:decision_support_tool/services/bicycle_crash_drawing_service.dart';
import 'package:decision_support_tool/ui/bicycle_crash_drawing_widget.dart';
import 'package:decision_support_tool/ui/bicycle_crash_map_widget.dart';
import 'package:decision_support_tool/services/pedestrian_crash_drawing_service.dart';
import 'package:decision_support_tool/ui/pedestrian_crash_drawing_widget.dart';
import 'package:decision_support_tool/ui/pedestrian_crash_map_widget.dart';
import 'package:decision_support_tool/services/biking_rate_drawing_service.dart';
import 'package:decision_support_tool/ui/biking_rate_drawing_widget.dart';
import 'package:decision_support_tool/ui/biking_rate_map_widget.dart';
import 'package:decision_support_tool/services/walking_rate_drawing_service.dart';
import 'package:decision_support_tool/ui/walking_rate_drawing_widget.dart';
import 'package:decision_support_tool/ui/walking_rate_map_widget.dart';
import 'package:decision_support_tool/services/land_use_diversity_drawing_service.dart';
import 'package:decision_support_tool/ui/land_use_diversity_drawing_widget.dart';
import 'package:decision_support_tool/ui/land_use_diversity_map_widget.dart';
import 'package:decision_support_tool/services/activity_density_drawing_service.dart';
import 'package:decision_support_tool/ui/activity_density_drawing_widget.dart';
import 'package:decision_support_tool/ui/activity_density_map_widget.dart';
import 'package:decision_support_tool/services/walkability_index_drawing_service.dart';
import 'package:decision_support_tool/ui/walkability_index_drawing_widget.dart';
import 'package:decision_support_tool/ui/walkability_index_map_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' show InteractiveFlag;
import 'package:decision_support_tool/ui/project_area_reuse_dialog.dart';

// Helper class for bicycle crash map data (matches BicycleCrashMapWidget expectations)
class BicycleCrashMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> crashFeatures;
  final int crashCount;
  final double density;
  final double areaSqMiles;
  final List<List<double>>? drawnPolyline; // NEW: Store drawn polyline

  BicycleCrashMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.crashFeatures,
    required this.crashCount,
    required this.density,
    required this.areaSqMiles,
    this.drawnPolyline, // NEW: Optional drawn polyline
  });
}

// Helper class for pedestrian crash map data (matches PedestrianCrashMapWidget expectations)
class PedestrianCrashMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> crashFeatures;
  final int crashCount;
  final double density;
  final double areaSqMiles;
  final List<List<double>>? drawnPolyline;

  PedestrianCrashMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.crashFeatures,
    required this.crashCount,
    required this.density,
    required this.areaSqMiles,
    this.drawnPolyline,
  });
}

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

  /// Store the last schools query result for map display
  SchoolsQueryResult? _lastSchoolsResult;

  /// NEW: Store the last bicycle crash drawing result for map display
  BicycleCrashDrawingResult? _lastBicycleCrashResult;

  /// Store the last pedestrian crash drawing result for map display
  PedestrianCrashDrawingResult? _lastPedestrianCrashResult;

  /// Store the last biking rate drawing result for map display
  BikingRateDrawingResult? _lastBikingRateResult;

  /// Store the last walking rate drawing result for map display
  WalkingRateDrawingResult? _lastWalkingRateResult;

  /// Store the last land use diversity drawing result for map display
  LandUseDiversityDrawingResult? _lastLandUseDiversityResult;

  /// Store the last House per acre drawing result for map display
  ActivityDensityDrawingResult? _lastActivityDensityResult;

  /// Store the last walkability drawing result for map display
  WalkabilityIndexDrawingResult? _lastWalkabilityResult;

  /// Saved project area polygon shared across all drawing-based questions.
  /// Set after the first successful polygon calculation and offered for reuse
  /// on subsequent questions.
  List<LatLng>? _savedProjectPolygon;

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
          _buildProjectAddressInput(), //  Address for auto
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
                'This address will be used for location-based queries (e.g., parks within Â½ mile)',
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
          _buildWidgetAutoFillButton(questionIndex), // Button for auto
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
            Padding(
              padding: EdgeInsets.only(left: _screenWidth * 0.94 * 0.04),
              child: InkWell(
                onTap: () {
                  _viewModel.goToPreviousPage();
                },
                child: Container(
                  height: _screenHeight * 0.05,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: Colors.deepPurple[200],
                  alignment: Alignment.center,
                  child: Text(
                    widget.previousPageButtonText,
                    style: TextStyle(fontSize: fontSize),
                    softWrap: false,
                  ),
                ),
              ),
            ),
            // Next page button
            Padding(
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
                      height: _screenHeight * 0.05,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      color: (isAllQuestionsAnswered)
                          ? const Color.fromARGB(255, 147, 88, 255)
                          : const Color.fromARGB(255, 228, 222, 240),
                      alignment: Alignment.center,
                      child: Text(
                        widget.nextPageButtonText,
                        style: TextStyle(fontSize: fontSize),
                        softWrap: false,
                      ),
                    ),
                  );
                },
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
      case 'ADI': // S1-Q1
        buttonText = 'Auto-fill from ADI Database';
        buttonIcon = Icons.analytics;
        onPressed = () => _fetchAdiValue(questionIndex);
        break;

      case 'Biking Rate': // S1-Q2
        buttonText = 'Draw Area & Calculate Biking Rate';
        buttonIcon = Icons.pedal_bike;
        onPressed = () => _openBikingRateDrawing(questionIndex);
        break;

      case 'Parks': // S1-Q9
        buttonText = 'Auto-fill from Park Data';
        buttonIcon = Icons.map;
        onPressed = () => _fetchParksCount(questionIndex);
        break;

      case 'Bus Stops': // S1-Q10
        buttonText = 'Auto-fill from Bus Stop Data';
        buttonIcon = Icons.directions_bus;
        onPressed = () => _fetchBusStopsCount(questionIndex);
        break;

      case 'Bike Lanes': // S1-Q11
        buttonText = 'Auto-fill from Bike Lane Data';
        buttonIcon = Icons.directions_bike;
        onPressed = () => _fetchBikeLanesCount(questionIndex);
        break;

      // update v2

      case 'Schools': // S1-Q8
        buttonText = 'Auto-fill from Schools Data';
        buttonIcon = Icons.school;
        onPressed = () => _fetchSchoolsCount(questionIndex);
        break;

      case 'Bicycle Crash': // S1-Q5
        buttonText = 'Draw Area & Calculate Crashes';
        buttonIcon = Icons.draw;
        onPressed = () => _openBicycleCrashDrawing(questionIndex);
        break;

      case 'Pedestrian Crash': // S1-Q4
        buttonText = 'Draw Area & Calculate Crashes';
        buttonIcon = Icons.draw;
        onPressed = () => _openPedestrianCrashDrawing(questionIndex);
        break;

      // update v3

      case 'Walking Rate': // S1-Q3
        buttonText = 'Draw Area & Calculate Walking Rate';
        buttonIcon = Icons.directions_walk;
        onPressed = () => _openWalkingRateDrawing(questionIndex);
        break;

      case 'Land Use Diversity': // S1-Q6
        buttonText = 'Draw Area & Calculate Diversity Index';
        buttonIcon = Icons.landscape;
        onPressed = () => _openLandUseDiversityDrawing(questionIndex);
        break;

      case 'Activity Density (HU+Jobs/Acre)': // S1-Q7
        buttonText = 'Draw Area & Calculate Activity Density';
        buttonIcon = Icons.apartment;
        onPressed = () => _openActivityDensityDrawing(questionIndex);
        break;

      // case 'Walkability Index': // S2-Q1
      //   buttonText = 'Draw Area & Calculate Walkability Score';
      //   buttonIcon = Icons.directions_walk;
      //   onPressed = () => _openWalkabilityDrawing(questionIndex);
      //   break;

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
        _showWarningDialog('Please enter a project address first.');
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
        _showWarningDialog('Please enter a project address first.');
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
        foundValueText: '$count park(s) within Â½ mile radius',
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
        foundValueText: '$count bus stop(s) within Â¼ mile radius',
        foundIcon: Icons.directions_bus,
        dataSourceText: 'Data from ArcGIS bus stops layer $layerId',
        onViewMap: _showBusStopsMap,
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
      ),
    );
  }

  /// Show schools map in a dialog using Flutter widgets
  Future<void> _showSchoolsMap() async {
    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: _lastSchoolsResult,
        noDataMessage: 'No schools data available to display map.',
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
              return SchoolsMapService.getMapData(
                lon: lon,
                lat: lat,
                matchedAddress: matchedAddress,
                layerId: layerId,
              );
            },

        buildMapWidget: (mapData) => SchoolsMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          schoolFeatures: mapData.schoolFeatures,
          layerId: mapData.layerId,
        ),
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
        getLayerId: (r) => r.bikeLaneLayerId,

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async {
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

  /// Show warning dialog
  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28.0,
              ),
              SizedBox(width: 10.0),
              Text('Warning'),
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

  /// Fetch schools count using the Dart service
  Future<void> _fetchSchoolsCount(int questionIndex) async {
    try {
      _viewModel.setFetchingParksData(true);

      // Get the project address from the text controller
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      // Call the schools service
      final result = await SchoolsQueryService.countSchoolsNearAddress(address);

      // Store the result for map display
      _lastSchoolsResult = result;

      // Find the answer index that matches
      final questionInfo = _questionInfos[questionIndex];
      int answerIndex = questionInfo.answers.indexWhere(
        (a) => a.text == result.answer,
      );

      if (answerIndex != -1) {
        // Auto-select the answer
        _viewModel.selectAnswer(questionIndex, answerIndex);

        // Show success dialog with results
        _showSchoolsResultDialog(
          result.count,
          result.matchedAddress,
          result.answer,
          result.layerId,
        );
      } else {
        _showErrorDialog('Could not match answer: ${result.answer}');
      }
    } catch (e) {
      _showErrorDialog('Error fetching schools data: $e');
    } finally {
      _viewModel.setFetchingParksData(false);
    }
  }

  /// Fetch bike lanes and shared use paths count using the Dart service
  Future<void> _fetchBikeLanesCount(int questionIndex) async {
    try {
      _viewModel.setFetchingParksData(true);

      // Get the project address from the text controller
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showWarningDialog('Please enter a project address first.');
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
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showWarningDialog('Please enter a project address first.');
        return;
      }

      _viewModel.setFetchingParksData(true);
      final (:lon, :lat) = await _geocodeAddress(address);
      _viewModel.setFetchingParksData(false);

      // Call the ADI service with pre-resolved coordinates
      final result = await AdiQueryService.getAdiForCoordinates(
        lon,
        lat,
        address,
      );

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

  void _showSchoolsResultDialog(
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
        titleText: 'Schools Query Results',
        foundLabel: 'Schools Found:',
        foundValueText: '$count school(s) within Â½ mile radius',
        foundIcon: Icons.school,
        dataSourceText: 'Data from Clark County Education layer $layerId',
        onViewMap: _showSchoolsMap,
        foundIconColor: Colors.purple[700],
      ),
    );
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
        foundValueText: '$count feature(s) within Â¼ mile radius',
        foundIcon: Icons.directions_bike,
        dataSourceText:
            'Data from RTC (Regional Transportation Commission) layers',
        onViewMap: _showBikeLanesMap,
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
        foundIconColor: Colors.blue[700],
      ),
    );
  }

  /// If a project polygon has been drawn before, shows a small dialog asking
  /// whether to reuse it or draw a new one. Returns the points to pre-populate
  /// (null = open draw widget with blank slate).
  Future<List<LatLng>?> _askReuseOrDraw({
    required double lat,
    required double lon,
  }) async {
    if (_savedProjectPolygon == null || _savedProjectPolygon!.length < 2) {
      return null; // No saved polygon – go straight to blank draw widget.
    }
    if (!mounted) return null;
    final choice = await showProjectAreaReuseDialog(
      context: context,
      savedPoints: _savedProjectPolygon!,
      lat: lat,
      lon: lon,
    );
    return choice.reuse ? choice.points : null;
  }

  /// Geocodes a plain-text address via ArcGIS and returns (lon, lat).
  /// Throws an [Exception] if the address cannot be resolved.
  Future<({double lon, double lat})> _geocodeAddress(String address) async {
    final geocodeUrl = Uri.parse(
      'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
    );
    final params = {
      'f': 'json',
      'singleLine': address,
      'outFields': 'Match_addr',
      'maxLocations': '1',
    };
    final response = await http.get(
      geocodeUrl.replace(queryParameters: params),
    );
    if (response.statusCode != 200) {
      throw Exception('Geocoding failed (HTTP ${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Could not geocode address: $address');
    }
    final best = candidates[0] as Map<String, dynamic>;
    final location = best['location'] as Map<String, dynamic>;
    return (
      lon: (location['x'] as num).toDouble(),
      lat: (location['y'] as num).toDouble(),
    );
  }

  /// Opens the polygon-drawing dialog for the walkability index question.
  Future<void> _openWalkabilityDrawing(int questionIndex) async {
    try {
      final address = _projectAddressController.text.trim();
      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }
      _viewModel.setFetchingParksData(true);
      final (:lon, :lat) = await _geocodeAddress(address);
      _viewModel.setFetchingParksData(false);
      final initialPoints = await _askReuseOrDraw(lat: lat, lon: lon);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WalkabilityIndexDrawingWidget(
          lat: lat,
          lon: lon,
          matchedAddress: address,
          initialPoints: initialPoints,
          onPolygonSaved: (pts) => setState(() => _savedProjectPolygon = pts),
          onCalculationComplete: (result) {
            _handleWalkabilityResult(result, questionIndex);
          },
        ),
      );
    } catch (e) {
      _viewModel.setFetchingParksData(false);
      _showErrorDialog('Error: $e');
    }
  }

  /// Handles the result from walkability drawing and auto-fills the answer.
  void _handleWalkabilityResult(
    WalkabilityIndexDrawingResult result,
    int questionIndex,
  ) {
    _lastWalkabilityResult = result;
    final questionInfo = _questionInfos[questionIndex];
    final answerIndex = questionInfo.answers.indexWhere(
      (a) => a.text == result.answer,
    );
    if (answerIndex != -1) {
      _viewModel.selectAnswer(questionIndex, answerIndex);
      _showWalkabilityResultDialog(
        result.regionCount,
        result.matchedAddress,
        result.answer,
        result.simpleAverage,
        result.weightedAverage,
        result.roundedCategory,
      );
    } else {
      _showErrorDialog('Could not match answer range: ${result.answer}');
    }
  }

  /// Shows the walkability result dialog.
  void _showWalkabilityResultDialog(
    int regionCount,
    String matchedAddress,
    String answer,
    double simpleAvg,
    double weightedAvg,
    int roundedCategory,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'National Walkability Index Results',
        foundLabel: 'EPA Block Groups Analysed:',
        foundValueText:
            '$regionCount region(s) found\n'
            'Simple avg (NatWalkInd): ${simpleAvg.toStringAsFixed(2)}\n'
            'Weighted avg (NatWalkInd): ${weightedAvg.toStringAsFixed(2)}\n'
            'Rounded category: $roundedCategory',
        foundIcon: Icons.directions_walk,
        dataSourceText:
            'Source: EPA National Walkability Index\n'
            'Layer 0 – NatWalkInd (1–20)',
        onViewMap: _showWalkabilityResultMap,
        foundIconColor: Colors.teal[700],
      ),
    );
  }

  /// Shows the walkability result map.
  Future<void> _showWalkabilityResultMap() async {
    if (_lastWalkabilityResult == null) {
      _showErrorDialog('No walkability data available to display.');
      return;
    }
    final result = _lastWalkabilityResult!;
    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: result,
        noDataMessage: 'No walkability data available to display map.',
        loadingMessage: 'Loading walkability index map…',
        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => 0,
        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async => WalkabilityIndexMapData(
              lon: result.lon,
              lat: result.lat,
              matchedAddress: result.matchedAddress,
              result: result,
            ),
        buildMapWidget: (mapData) => WalkabilityIndexMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          result: mapData.result,
        ),
      ),
    );
  }

  /// Opens the polygon-drawing dialog for the activity density question.
  Future<void> _openActivityDensityDrawing(int questionIndex) async {
    try {
      final address = _projectAddressController.text.trim();
      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }
      _viewModel.setFetchingParksData(true);
      final (:lon, :lat) = await _geocodeAddress(address);
      _viewModel.setFetchingParksData(false);
      final initialPoints = await _askReuseOrDraw(lat: lat, lon: lon);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ActivityDensityDrawingWidget(
          lat: lat,
          lon: lon,
          matchedAddress: address,
          initialPoints: initialPoints,
          onPolygonSaved: (pts) => setState(() => _savedProjectPolygon = pts),
          onCalculationComplete: (result) {
            _handleActivityDensityResult(result, questionIndex);
          },
        ),
      );
    } catch (e) {
      _viewModel.setFetchingParksData(false);
      _showErrorDialog('Error: $e');
    }
  }

  /// Handles the result from activity density drawing and auto-fills the answer.
  void _handleActivityDensityResult(
    ActivityDensityDrawingResult result,
    int questionIndex,
  ) {
    _lastActivityDensityResult = result;
    final questionInfo = _questionInfos[questionIndex];
    final answerIndex = questionInfo.answers.indexWhere(
      (a) => a.text == result.answer,
    );
    if (answerIndex != -1) {
      _viewModel.selectAnswer(questionIndex, answerIndex);
      _showActivityDensityResultDialog(
        result.regionCount,
        result.matchedAddress,
        result.answer,
        result.simpleAverage,
        result.weightedAverage,
        result.weightedScoreAverage,
        result.roundedScore,
      );
    } else {
      _showErrorDialog('Could not match answer range: ${result.answer}');
    }
  }

  /// Shows the activity density result dialog.
  void _showActivityDensityResultDialog(
    int regionCount,
    String matchedAddress,
    String answer,
    double simpleAvg,
    double weightedAvg,
    double scoreAvg,
    int roundedScore,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Activity Density Calculation Results',
        foundLabel: 'EPA Block Groups Analysed:',
        foundValueText:
            '$regionCount region(s) found\n'
            'Simple avg density: ${simpleAvg.toStringAsFixed(2)}\n'
            'Weighted avg density: ${weightedAvg.toStringAsFixed(2)}\n'
            'Weighted score avg: ${scoreAvg.toStringAsFixed(2)} â†’ rounded: $roundedScore',
        foundIcon: Icons.apartment,
        dataSourceText:
            'Source: EPA Smart Location Database\n'
            'Layer 4 â€” Activity Density (D1D)',
        onViewMap: _showActivityDensityResultMap,
        foundIconColor: Colors.blue[700],
      ),
    );
  }

  /// Shows the activity density result map.
  Future<void> _showActivityDensityResultMap() async {
    if (_lastActivityDensityResult == null) {
      _showErrorDialog('No activity density data available to display.');
      return;
    }
    final result = _lastActivityDensityResult!;
    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: result,
        noDataMessage: 'No activity density data available to display map.',
        loadingMessage: 'Loading activity density map...',
        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => 0,
        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async => ActivityDensityMapData(
              lon: result.lon,
              lat: result.lat,
              matchedAddress: result.matchedAddress,
              result: result,
            ),
        buildMapWidget: (mapData) => ActivityDensityMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          result: mapData.result,
        ),
      ),
    );
  }

  /// Opens the polygon-drawing dialog for the land use diversity question.
  Future<void> _openLandUseDiversityDrawing(int questionIndex) async {
    try {
      final address = _projectAddressController.text.trim();
      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }
      _viewModel.setFetchingParksData(true);
      final (:lon, :lat) = await _geocodeAddress(address);
      // âœ… Use `address` (what the user typed) â€“ NOT ArcGIS canonical.
      // This ensures the dialog title always shows the user's entered address.
      _viewModel.setFetchingParksData(false);
      final initialPoints = await _askReuseOrDraw(lat: lat, lon: lon);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LandUseDiversityDrawingWidget(
          lat: lat,
          lon: lon,
          matchedAddress:
              address, // â† user-typed address, not ArcGIS canonical
          initialPoints: initialPoints,
          onPolygonSaved: (pts) => setState(() => _savedProjectPolygon = pts),
          onCalculationComplete: (result) {
            _handleLandUseDiversityResult(result, questionIndex);
          },
        ),
      );
    } catch (e) {
      _viewModel.setFetchingParksData(false);
      _showErrorDialog('Error: $e');
    }
  }

  /// Handles the result from land use diversity drawing and auto-fills the answer.
  void _handleLandUseDiversityResult(
    LandUseDiversityDrawingResult result,
    int questionIndex,
  ) {
    _lastLandUseDiversityResult = result;
    final questionInfo = _questionInfos[questionIndex];
    final answerIndex = questionInfo.answers.indexWhere(
      (a) => a.text == result.answer,
    );
    if (answerIndex != -1) {
      _viewModel.selectAnswer(questionIndex, answerIndex);
      _showLandUseDiversityResultDialog(
        result.regionCount,
        result.matchedAddress,
        result.answer,
        result.simpleAverage,
        result.weightedAverage,
      );
    } else {
      _showErrorDialog('Could not match answer range: ${result.answer}');
    }
  }

  /// Shows the land use diversity result dialog (mirrors biking rate result dialog).
  void _showLandUseDiversityResultDialog(
    int regionCount,
    String matchedAddress,
    String answer,
    double simpleAvg,
    double weightedAvg,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Land Use Diversity Calculation Results',
        foundLabel: 'EPA Block Groups Analysed:',
        foundValueText:
            '$regionCount region(s) found\n'
            'Simple avg: ${simpleAvg.toStringAsFixed(2)}\n'
            'Weighted avg: ${weightedAvg.toStringAsFixed(2)}',
        foundIcon: Icons.landscape,
        dataSourceText:
            'Source: EPA Smart Location Database\n'
            'Layer 7 â€” Land Use Diversity (D2B_E8MIXA)',
        onViewMap: _showLandUseDiversityResultMap,
        foundIconColor: Colors.green[700],
      ),
    );
  }

  /// Shows the land use diversity result map (mirrors biking rate map pattern).
  Future<void> _showLandUseDiversityResultMap() async {
    if (_lastLandUseDiversityResult == null) {
      _showErrorDialog('No land use diversity data available to display.');
      return;
    }
    final result = _lastLandUseDiversityResult!;
    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: result,
        noDataMessage: 'No land use diversity data available to display map.',
        loadingMessage: 'Loading land use diversity map...',
        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => 0,
        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async => LandUseDiversityMapData(
              lon: result.lon,
              lat: result.lat,
              matchedAddress: result.matchedAddress,
              result: result,
            ),
        buildMapWidget: (mapData) => LandUseDiversityMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          result: mapData.result,
        ),
      ),
    );
  }

  /// Opens the polygon-drawing dialog for the walking rate question
  Future<void> _openWalkingRateDrawing(int questionIndex) async {
    try {
      // Read the live text field â€“ same as all other autofill methods
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      _viewModel.setFetchingParksData(true);

      final (:lon, :lat) = await _geocodeAddress(address);
      // âœ… Use `address` (what the user typed) â€“ NOT ArcGIS canonical.
      // This ensures the dialog title always shows the user's entered address.

      _viewModel.setFetchingParksData(false);

      final initialPoints = await _askReuseOrDraw(lat: lat, lon: lon);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WalkingRateDrawingWidget(
          lat: lat,
          lon: lon,
          matchedAddress:
              address, // â† user-typed address, not ArcGIS canonical
          initialPoints: initialPoints,
          onPolygonSaved: (pts) => setState(() => _savedProjectPolygon = pts),
          onCalculationComplete: (result) {
            _handleWalkingRateResult(result, questionIndex);
          },
        ),
      );
    } catch (e) {
      _viewModel.setFetchingParksData(false);
      _showErrorDialog('Error: $e');
    }
  }

  /// Handles the result from walking rate drawing and auto-fills the answer
  void _handleWalkingRateResult(
    WalkingRateDrawingResult result,
    int questionIndex,
  ) {
    _lastWalkingRateResult = result;

    final questionInfo = _questionInfos[questionIndex];
    final answerIndex = questionInfo.answers.indexWhere(
      (a) => a.text == result.answer,
    );

    if (answerIndex != -1) {
      _viewModel.selectAnswer(questionIndex, answerIndex);
      _showWalkingRateResultDialog(
        result.tractCount,
        result.matchedAddress,
        result.answer,
        result.simpleAverage,
        result.weightedAverage,
      );
    } else {
      _showErrorDialog('Could not match answer range: ${result.answer}');
    }
  }

  /// Shows the walking rate result dialog (mirrors biking rate result dialog)
  void _showWalkingRateResultDialog(
    int tractCount,
    String matchedAddress,
    String answer,
    double simpleAvg,
    double weightedAvg,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Walking Rate Calculation Results',
        foundLabel: 'Census Tracts Analysed:',
        foundValueText:
            '$tractCount tract(s) found\n'
            'Simple avg: ${simpleAvg.toStringAsFixed(2)}%\n'
            'Weighted avg: ${weightedAvg.toStringAsFixed(2)}%',
        foundIcon: Icons.directions_walk,
        dataSourceText:
            'Source: U.S. Census ACS 5-Year (2020)\n'
            'Variable: S0801_C01_010E',
        onViewMap: _showWalkingRateResultMap,
        foundIconColor: Colors.green[700],
      ),
    );
  }

  /// Shows the walking rate result map (mirrors biking rate map pattern)
  Future<void> _showWalkingRateResultMap() async {
    if (_lastWalkingRateResult == null) {
      _showErrorDialog('No walking rate data available to display.');
      return;
    }
    final result = _lastWalkingRateResult!;

    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: result,
        noDataMessage: 'No walking rate data available to display map.',
        loadingMessage: 'Loading walking rate map...',

        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => 0,

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async => WalkingRateMapData(
              lon: result.lon,
              lat: result.lat,
              matchedAddress: result.matchedAddress,
              result: result,
            ),

        buildMapWidget: (mapData) => WalkingRateMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          result: mapData.result,
        ),
      ),
    );
  }

  /// Opens the polygon-drawing dialog for the biking rate question
  Future<void> _openBikingRateDrawing(int questionIndex) async {
    try {
      // Read the live text field â€” same as all other autofill methods
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showWarningDialog('Please enter a project address first.');
        return;
      }

      _viewModel.setFetchingParksData(true);

      final (:lon, :lat) = await _geocodeAddress(address);
      // âœ… Use `address` (what the user typed) â€” NOT `matched` (ArcGIS canonical).
      // This ensures the dialog title always shows the user's entered address.

      _viewModel.setFetchingParksData(false);

      final initialPoints = await _askReuseOrDraw(lat: lat, lon: lon);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BikingRateDrawingWidget(
          lat: lat,
          lon: lon,
          matchedAddress:
              address, // â† user-typed address, not ArcGIS canonical
          initialPoints: initialPoints,
          onPolygonSaved: (pts) => setState(() => _savedProjectPolygon = pts),
          onCalculationComplete: (result) {
            _handleBikingRateResult(result, questionIndex);
          },
        ),
      );
    } catch (e) {
      _viewModel.setFetchingParksData(false);
      _showErrorDialog('Error: $e');
    }
  }

  /// Opens the pedestrian crash drawing interface
  Future<void> _openPedestrianCrashDrawing(int questionIndex) async {
    try {
      // Get the project address
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      _viewModel.setFetchingParksData(true);
      final (:lon, :lat) = await _geocodeAddress(address);
      final matched = address;

      _viewModel.setFetchingParksData(false);

      // Open drawing dialog
      final initialPoints = await _askReuseOrDraw(lat: lat, lon: lon);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PedestrianCrashDrawingWidget(
          lat: lat,
          lon: lon,
          matchedAddress: matched,
          initialPoints: initialPoints,
          onPolygonSaved: (pts) => setState(() => _savedProjectPolygon = pts),
          onCalculationComplete: (result) {
            // Handle the calculation result
            _handlePedestrianCrashResult(result, questionIndex);
          },
        ),
      );
    } catch (e) {
      _viewModel.setFetchingParksData(false);
      _showErrorDialog('Error: $e');
    }
  }

  /// Opens the bicycle crash drawing interface
  Future<void> _openBicycleCrashDrawing(int questionIndex) async {
    try {
      // Get the project address
      final address = _projectAddressController.text.trim();

      if (address.isEmpty) {
        _showErrorDialog('Please enter a project address first.');
        return;
      }

      _viewModel.setFetchingParksData(true);
      final (:lon, :lat) = await _geocodeAddress(address);
      final matched = address;

      _viewModel.setFetchingParksData(false);

      // Open drawing dialog
      final initialPoints = await _askReuseOrDraw(lat: lat, lon: lon);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BicycleCrashDrawingWidget(
          lat: lat,
          lon: lon,
          matchedAddress: matched,
          initialPoints: initialPoints,
          onPolygonSaved: (pts) => setState(() => _savedProjectPolygon = pts),
          onCalculationComplete: (result) {
            // Handle the calculation result
            _handleBicycleCrashResult(result, questionIndex);
          },
        ),
      );
    } catch (e) {
      _viewModel.setFetchingParksData(false);
      _showErrorDialog('Error: $e');
    }
  }

  /// Handles the result from biking rate drawing and auto-fills the answer
  void _handleBikingRateResult(
    BikingRateDrawingResult result,
    int questionIndex,
  ) {
    _lastBikingRateResult = result;

    final questionInfo = _questionInfos[questionIndex];
    final answerIndex = questionInfo.answers.indexWhere(
      (a) => a.text == result.answer,
    );

    if (answerIndex != -1) {
      _viewModel.selectAnswer(questionIndex, answerIndex);
      _showBikingRateResultDialog(
        result.tractCount,
        result.matchedAddress,
        result.answer,
        result.simpleAverage,
        result.weightedAverage,
      );
    } else {
      _showErrorDialog('Could not match answer range: ${result.answer}');
    }
  }

  /// Handles the result from pedestrian crash drawing and auto-fills the answer
  void _handlePedestrianCrashResult(
    PedestrianCrashDrawingResult result,
    int questionIndex,
  ) {
    // Store the result
    _lastPedestrianCrashResult = result;

    // Find the matching answer
    final questionInfo = _questionInfos[questionIndex];
    int answerIndex = questionInfo.answers.indexWhere(
      (a) => a.text == result.answer,
    );

    if (answerIndex != -1) {
      // Auto-select the answer
      _viewModel.selectAnswer(questionIndex, answerIndex);

      // Show success dialog
      _showPedestrianCrashResultDialog(
        result.count,
        result.matchedAddress,
        result.answer,
        result.density,
        result.areaSqMiles,
      );
    } else {
      _showErrorDialog('Could not match answer range: ${result.answer}');
    }
  }

  /// Handles the result from bicycle crash drawing and auto-fills the answer
  void _handleBicycleCrashResult(
    BicycleCrashDrawingResult result,
    int questionIndex,
  ) {
    // Store the result
    _lastBicycleCrashResult = result;

    // Find the matching answer
    final questionInfo = _questionInfos[questionIndex];
    int answerIndex = questionInfo.answers.indexWhere(
      (a) => a.text == result.answer,
    );

    if (answerIndex != -1) {
      // Auto-select the answer
      _viewModel.selectAnswer(questionIndex, answerIndex);

      // Show success dialog
      _showBicycleCrashResultDialog(
        result.count,
        result.matchedAddress,
        result.answer,
        result.density,
        result.areaSqMiles,
      );
    } else {
      _showErrorDialog('Could not match answer range: ${result.answer}');
    }
  }

  /// Shows the biking rate result dialog (mirrors bicycle crash result dialog)
  void _showBikingRateResultDialog(
    int tractCount,
    String matchedAddress,
    String answer,
    double simpleAvg,
    double weightedAvg,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Biking Rate Calculation Results',
        foundLabel: 'Census Tracts Analysed:',
        foundValueText:
            '$tractCount tract(s) found\n'
            'Simple avg: ${simpleAvg.toStringAsFixed(2)}%\n'
            'Weighted avg: ${weightedAvg.toStringAsFixed(2)}%',
        foundIcon: Icons.directions_bike,
        dataSourceText:
            'Source: U.S. Census ACS 5-Year (2020)\n'
            'Variable: S0801_C01_011E',
        onViewMap: _showBikingRateResultMap,
        foundIconColor: Colors.teal[700],
      ),
    );
  }

  /// Shows the pedestrian crash result dialog
  void _showPedestrianCrashResultDialog(
    int count,
    String matchedAddress,
    String answer,
    double density,
    double areaSqMiles,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Pedestrian Crash Calculation Results',
        foundLabel: 'Crashes in Drawn Area:',
        foundValueText:
            '$count crash(es) found\nDensity: ${density.toStringAsFixed(1)} per sq mi',
        foundIcon: Icons.directions_walk,
        dataSourceText:
            'Based on your drawn area\n'
            'Area: ${areaSqMiles.toStringAsFixed(4)} sq miles',
        onViewMap: _showPedestrianCrashResultMap,
        foundIconColor: Colors.blue[700],
        // foundIconColor: Colors.orange[700],
      ),
    );
  }

  /// Shows the bicycle crash result dialog
  void _showBicycleCrashResultDialog(
    int count,
    String matchedAddress,
    String answer,
    double density,
    double areaSqMiles,
  ) {
    showAutoFillResultDialog(
      context: context,
      screenWidth: _screenWidth,
      matchedAddress: matchedAddress,
      answer: answer,
      config: AutoFillDialogConfig(
        titleText: 'Bicycle Crash Calculation Results',
        foundLabel: 'Crashes in Drawn Area:',
        foundValueText:
            '$count crash(es) found\nDensity: ${density.toStringAsFixed(1)} per sq mi',
        foundIcon: Icons.pedal_bike,
        dataSourceText:
            'Based on your drawn area\n'
            'Area: ${areaSqMiles.toStringAsFixed(4)} sq miles',
        onViewMap: _showBicycleCrashResultMap,
        foundIconColor: Colors.red[700],
      ),
    );
  }

  /// Shows the biking rate result map (mirrors bicycle crash map pattern)
  Future<void> _showBikingRateResultMap() async {
    if (_lastBikingRateResult == null) {
      _showErrorDialog('No biking rate data available to display.');
      return;
    }
    final result = _lastBikingRateResult!;

    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: result,
        noDataMessage: 'No biking rate data available to display map.',
        loadingMessage: 'Loading biking rate map...',

        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => 0,

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async => BikingRateMapData(
              lon: result.lon,
              lat: result.lat,
              matchedAddress: result.matchedAddress,
              result: result,
            ),

        buildMapWidget: (mapData) => BikingRateMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          result: mapData.result,
        ),
      ),
    );
  }

  /// Shows the pedestrian crash result map
  Future<void> _showPedestrianCrashResultMap() async {
    if (_lastPedestrianCrashResult == null) {
      _showErrorDialog('No pedestrian crash data available to display.');
      return;
    }

    // Create a local variable to avoid null check issues
    final result = _lastPedestrianCrashResult!;

    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: result,
        noDataMessage: 'No pedestrian crash data available to display map.',
        loadingMessage: 'Loading crash map...',

        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => 0,

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async {
              // Return the result directly wrapped in map data format
              return PedestrianCrashMapData(
                lon: result.lon,
                lat: result.lat,
                matchedAddress: result.matchedAddress,
                crashFeatures: result.crashesInArea,
                crashCount: result.count,
                density: result.density,
                areaSqMiles: result.areaSqMiles,
                drawnPolyline: result.drawnPolyline,
              );
            },

        buildMapWidget: (mapData) => PedestrianCrashMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          crashFeatures: mapData.crashFeatures,
          crashCount: mapData.crashCount,
          density: mapData.density,
          areaSqMiles: mapData.areaSqMiles,
          drawnPolyline: mapData.drawnPolyline,
        ),
      ),
    );
  }

  /// Shows the bicycle crash result map
  Future<void> _showBicycleCrashResultMap() async {
    if (_lastBicycleCrashResult == null) {
      _showErrorDialog('No bicycle crash data available to display.');
      return;
    }

    // Create a local variable to avoid null check issues
    final result = _lastBicycleCrashResult!;

    await showAutoFillMapDialog(
      context: context,
      showErrorDialog: _showErrorDialog,
      config: AutoFillMapDialogConfig(
        lastResult: result,
        noDataMessage: 'No bicycle crash data available to display map.',
        loadingMessage: 'Loading crash map...',

        getLon: (r) => r.lon,
        getLat: (r) => r.lat,
        getMatchedAddress: (r) => r.matchedAddress,
        getLayerId: (r) => 0,

        fetchMapData:
            ({
              required double lon,
              required double lat,
              required String matchedAddress,
              required int layerId,
            }) async {
              // Return the result directly wrapped in map data format
              return BicycleCrashMapData(
                lon: result.lon,
                lat: result.lat,
                matchedAddress: result.matchedAddress,
                crashFeatures: result.crashesInArea,
                crashCount: result.count,
                density: result.density,
                areaSqMiles: result.areaSqMiles,
                drawnPolyline: result.drawnPolyline,
              );
            },

        buildMapWidget: (mapData) => BicycleCrashMapWidget(
          lat: mapData.lat,
          lon: mapData.lon,
          matchedAddress: mapData.matchedAddress,
          crashFeatures: mapData.crashFeatures,
          crashCount: mapData.crashCount,
          density: mapData.density,
          areaSqMiles: mapData.areaSqMiles,
          drawnPolyline: mapData.drawnPolyline,
        ),
      ),
    );
  }
}
