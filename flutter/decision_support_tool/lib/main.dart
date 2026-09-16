import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/local_data_service.dart';
import 'package:decision_support_tool/ui/assessment_app.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:decision_support_tool/ui/instructions_page.dart';
import 'package:decision_support_tool/ui/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Main entry point function.
void main() {
  // Use real paths ("/pst") instead of hash fragments ("/#/pst") for URLs on
  // web, so the site's URL structure is domain/ -> landing, domain/pst/ ->
  // the PST tool, both in `flutter run -d chrome` and in a production build.
  usePathUrlStrategy();
  runApp(MultiProvider(providers: providers, child: MainApp()));
}

/// List of providers for the app.
List<SingleChildWidget> get providers {
  return [
    Provider<LocalDataService>(create: (context) => LocalDataService()),
    Provider<AssessmentsRepository>(
      create: (context) =>
          AssessmentsRepositoryLocal(localDataService: context.read()),
    ),
  ];
}

/// Main application widget.
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AssessmentViewModel _assessmentViewModel;

  @override
  void initState() {
    super.initState();
    _assessmentViewModel = AssessmentViewModel(
      assessmentsRepository: context.read(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infrastructure for Healthy Living: A Project Scoping Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // No `initialRoute` here: on web, Flutter derives the initial route
      // from the actual browser URL (via the path URL strategy set in
      // main()), so a fresh load of "/" shows the landing page and a fresh
      // load of "/pst" or "/instructions" shows that page directly.
      onGenerateRoute: (settings) {
        // `settings.name` includes the query string (e.g.
        // "/instructions?jurisdiction=washoe") when path URL strategy is
        // active, so parsing it as a Uri gives clean access to both.
        final uri = Uri.parse(settings.name ?? '/');
        // Normalize a trailing slash (e.g. "/pst/" -> "/pst") so both forms
        // match the same route.
        final path = uri.path.length > 1 && uri.path.endsWith('/')
            ? uri.path.substring(0, uri.path.length - 1)
            : uri.path;

        if (path == '/pst') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => AssessmentApp(viewModel: _assessmentViewModel),
          );
        }
        if (path == '/instructions') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => InstructionsPage(
              viewModel: _assessmentViewModel,
              initialJurisdictionId: uri.queryParameters['jurisdiction'],
              initialQuestionId: uri.queryParameters['question'],
            ),
          );
        }
        // '/' and any unrecognized path fall back to the landing page.
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (context) => const LandingPage(),
        );
      },
    );
  }
}
