import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/village/data/repositories/village_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/village/presentation/pages/village_profile_page.dart';
import 'package:ecosim_flutter/features/village/presentation/controllers/village_controller.dart';
import 'package:ecosim_flutter/features/village/data/models/village_model.dart';

void main() {
  testWidgets('VillageProfilePage renders fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          villageControllerProvider.overrideWith(
            (ref) =>
                VillageNotifier(ref.read(villageRepositoryProvider))
                  ..state = VillageState(
                    activeVillage: VillageModel(
                      id: 'v1',
                      userId: 'u1',
                      villageName: 'Desa Maju',
                      population: 500,
                      areaKm2: 20,
                    ),
                    isLoading: false,
                  ),
          ),
        ],
        child: const MaterialApp(home: VillageProfilePage()),
      ),
    );

    expect(find.text('Desa Maju'), findsOneWidget);
  });
}
