import 'package:decision_support_tool/data/assessments_repository.dart';
import 'package:decision_support_tool/data/local_data_service.dart';
import 'package:decision_support_tool/ui/assessment_app.dart';
import 'package:decision_support_tool/ui/assessment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Main entry point function.
void main() {
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
      initialRoute: '/',
      routes: {
        '/': (context) => AssessmentApp(viewModel: _assessmentViewModel),
      },
    );
  }
}
