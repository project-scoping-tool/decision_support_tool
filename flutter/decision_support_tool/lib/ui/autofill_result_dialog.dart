import 'package:flutter/material.dart';

class AutoFillDialogConfig {
  const AutoFillDialogConfig({
    required this.titleText,
    required this.foundLabel,
    required this.foundValueText,
    required this.foundIcon,
    required this.dataSourceText,
    this.onViewMap, // OPTIONAL now
    this.viewMapLabel = 'View Interactive Map',
    this.extraDataSourceWidgets = const [], // OPTIONAL now
    // Parks-dominant defaults
    this.foundBoxBg,
    this.foundBoxBorder,
    this.foundValueColor,
    this.foundIconColor,
    this.viewMapButtonBg,
    this.okButtonBg,
  });

  final String titleText;
  final String foundLabel;
  final String foundValueText;
  final IconData foundIcon;

  final String dataSourceText;

  /// If null => no map button
  final VoidCallback? onViewMap;
  final String viewMapLabel;

  /// Extra lines below data source text (e.g., Block Group / County)
  final List<Widget> extraDataSourceWidgets;

  final Color? foundBoxBg;
  final Color? foundBoxBorder;
  final Color? foundValueColor;
  final Color? foundIconColor;
  final Color? viewMapButtonBg;
  final Color? okButtonBg;
}

Future<void> showAutoFillResultDialog({
  required BuildContext context,
  required double screenWidth,
  required String matchedAddress,
  required String answer,
  required AutoFillDialogConfig config,
}) {
  final Color foundBoxBg = config.foundBoxBg ?? Colors.blue[50]!;
  final Color foundBoxBorder = config.foundBoxBorder ?? Colors.blue[300]!;
  final Color foundValueColor = config.foundValueColor ?? Colors.blue[900]!;
  final Color foundIconColor = config.foundIconColor ?? Colors.green[700]!;
  final Color viewMapButtonBg = config.viewMapButtonBg ?? Colors.blue[700]!;
  final Color okButtonBg = config.okButtonBg ?? Colors.blue[600]!;

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28.0),
            const SizedBox(width: 10.0),
            Flexible(child: Text(config.titleText)),
          ],
        ),
        content: SizedBox(
          width: screenWidth * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Geocoded Address:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
              const SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  matchedAddress,
                  style: const TextStyle(fontSize: 14.0),
                ),
              ),
              const SizedBox(height: 20.0),

              Text(
                config.foundLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: foundBoxBg,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: foundBoxBorder),
                ),
                child: Row(
                  children: [
                    Icon(config.foundIcon, color: foundIconColor, size: 24.0),
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: Text(
                        config.foundValueText,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: foundValueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              const Text(
                'Auto-selected Answer:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
              const SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.green[400]!, width: 2.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.green[900], size: 24.0),
                    const SizedBox(width: 10.0),
                    Text(
                      answer,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Data source block (now supports extra lines + optional map button)
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber[900],
                          size: 20.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            config.dataSourceText,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                              color: Colors.amber[900],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Extra lines (ADI block group, county, etc.)
                    ...config.extraDataSourceWidgets,

                    // Optional View Map button
                    if (config.onViewMap != null) ...[
                      const SizedBox(height: 8.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map, size: 18.0),
                          label: Text(config.viewMapLabel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewMapButtonBg,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            config.onViewMap!.call();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              backgroundColor: okButtonBg,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
            ),
            child: const Text('OK', style: TextStyle(fontSize: 16.0)),
          ),
        ],
      );
    },
  );
}
