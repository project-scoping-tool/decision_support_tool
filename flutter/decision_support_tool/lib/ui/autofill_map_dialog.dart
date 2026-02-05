import 'package:flutter/material.dart';

class AutoFillMapDialogTheme {
  const AutoFillMapDialogTheme({
    this.loadingBackgroundColor,
    this.loadingTextStyle,
    this.progressIndicatorColor,
    this.loadingContainerBorderRadius = 8.0,
    this.loadingPadding = const EdgeInsets.all(20.0),
  });

  /// Parks-dominant default: white card
  final Color? loadingBackgroundColor;

  /// Parks-dominant default: normal text
  final TextStyle? loadingTextStyle;

  /// Optional: indicator color
  final Color? progressIndicatorColor;

  final double loadingContainerBorderRadius;
  final EdgeInsets loadingPadding;
}

class AutoFillMapDialogConfig<TLastResult, TMapData> {
  const AutoFillMapDialogConfig({
    required this.lastResult,
    required this.noDataMessage,
    this.loadingMessage = 'Loading map...',
    this.errorPrefix = 'Error loading map:',

    // How to extract from lastResult
    required this.getLon,
    required this.getLat,
    required this.getMatchedAddress,
    required this.getLayerId,

    // Fetch + build
    required this.fetchMapData,
    required this.buildMapWidget,

    // Optional theme overrides (defaults are Parks-style)
    this.theme = const AutoFillMapDialogTheme(),
  });

  final TLastResult? lastResult;
  final String noDataMessage;

  /// Parks-dominant default
  final String loadingMessage;

  /// Parks-dominant default
  final String errorPrefix;

  final double Function(TLastResult r) getLon;
  final double Function(TLastResult r) getLat;
  final String Function(TLastResult r) getMatchedAddress;
  final int Function(TLastResult r) getLayerId;

  final Future<TMapData> Function({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int layerId,
  })
  fetchMapData;

  final Widget Function(TMapData mapData) buildMapWidget;

  final AutoFillMapDialogTheme theme;
}

/// Shows a loading dialog, fetches map data, then shows the map widget in a dialog.
/// This is the one function you reuse for Parks / Bus Stops (and future map types).
Future<void> showAutoFillMapDialog<TLastResult, TMapData>({
  required BuildContext context,
  required void Function(String message)
  showErrorDialog, // pass your _showErrorDialog
  required AutoFillMapDialogConfig<TLastResult, TMapData> config,
}) async {
  final lastResult = config.lastResult;
  if (lastResult == null) {
    showErrorDialog(config.noDataMessage);
    return;
  }

  bool loadingDialogShown = false;

  try {
    // --- Loading dialog (Parks-dominant defaults) ---
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final bg = config.theme.loadingBackgroundColor ?? Colors.white;
        final txtStyle = config.theme.loadingTextStyle ?? const TextStyle();
        final indicatorColor = config.theme.progressIndicatorColor;

        return Center(
          child: Container(
            padding: config.theme.loadingPadding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(
                config.theme.loadingContainerBorderRadius,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (indicatorColor == null)
                  const CircularProgressIndicator()
                else
                  CircularProgressIndicator(color: indicatorColor),
                const SizedBox(height: 16.0),
                Text(config.loadingMessage, style: txtStyle),
              ],
            ),
          ),
        );
      },
    );
    loadingDialogShown = true;

    // --- Fetch ---
    final mapData = await config.fetchMapData(
      lon: config.getLon(lastResult),
      lat: config.getLat(lastResult),
      matchedAddress: config.getMatchedAddress(lastResult),
      layerId: config.getLayerId(lastResult),
    );

    // --- Close loading dialog ---
    if (loadingDialogShown && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      loadingDialogShown = false;
    }

    // --- Show map widget dialog ---
    showDialog(
      context: context,
      builder: (ctx) => config.buildMapWidget(mapData),
    );
  } catch (e) {
    // Close loading dialog if still open
    if (loadingDialogShown && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    showErrorDialog('${config.errorPrefix} $e');
  }
}
