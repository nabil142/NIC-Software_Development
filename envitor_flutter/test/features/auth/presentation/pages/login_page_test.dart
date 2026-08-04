import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    expect(find.text('Selamat Datang di\nEcosim'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); 
    expect(find.text('Masuk dengan Google'), findsOneWidget); 
  });
}
