import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/scenario/presentation/pages/future_builder_page.dart';
import 'package:ecosim_flutter/features/village/presentation/controllers/village_controller.dart';
import 'package:ecosim_flutter/features/assessment/presentation/controllers/assessment_controller.dart';
import 'package:ecosim_flutter/features/scenario/presentation/controllers/scenario_controller.dart';
import 'shared_mocks.dart';

void main() {
  testWidgets('FutureBuilderPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          villageControllerProvider.overrideWith((ref) => MockVillageNotifier()),
          assessmentControllerProvider.overrideWith((ref) => MockAssessmentNotifier()),
          scenarioControllerProvider.overrideWith((ref) => MockScenarioNotifier()),
        ],
        child: const MaterialApp(
          home: FutureBuilderPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
