import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/assessment/presentation/pages/questionnaire_page.dart';

void main() {
  testWidgets('QuestionnairePage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: QuestionnairePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Asesmen Lingkungan'), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets);
    expect(find.text('Simpan & Analisis DNA Desa'), findsOneWidget);
  });
}
