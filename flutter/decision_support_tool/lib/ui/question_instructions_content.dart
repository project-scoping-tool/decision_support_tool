import 'package:decision_support_tool/data/static_data_models.dart';
import 'package:decision_support_tool/ui/video_app.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an external link in a new browser tab/window.
///
/// Shared by the PST assessment flow ([QuestionSectionPage]) and the
/// Instructions page, so there is a single implementation of "open this
/// question's resource link" for the whole app.
Future<void> openExternalLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

/// Renders a question's `instructionsMarkdown` and (if present) its
/// instructional video.
///
/// This is the single implementation of how a question's instructions are
/// rendered, used both inside the PST assessment (each question's
/// expandable "Instructions" panel in [QuestionSectionPage]) and on the
/// Instructions page — so the two surfaces can never drift apart.
/// `instructionsMarkdown` and `videoId` always come from [QuestionInfo],
/// loaded from `assets/question_info/*.toml`; nothing here duplicates or
/// re-derives that data.
class QuestionInstructionsContent extends StatelessWidget {
  const QuestionInstructionsContent({
    super.key,
    required this.questionInfo,
    this.videoMaxWidth = 420,
  });

  final QuestionInfo questionInfo;
  final double videoMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: MarkdownBlock(data: questionInfo.instructionsMarkdown),
        ),
        if (questionInfo.videoId.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: videoMaxWidth),
                // Matches the PST's existing video aspect ratio.
                child: AspectRatio(
                  aspectRatio: 16 / 11,
                  child: VideoApp(videoId: questionInfo.videoId),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
