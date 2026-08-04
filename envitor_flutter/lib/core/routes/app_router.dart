import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/village/presentation/controllers/village_controller.dart';
import '../../features/assessment/presentation/controllers/assessment_controller.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/village/presentation/pages/village_profile_page.dart';
import '../../features/assessment/presentation/pages/questionnaire_page.dart';
import '../../features/assessment/presentation/pages/dna_result_page.dart';
import '../../features/scenario/presentation/pages/future_builder_page.dart';
import '../../features/scenario/presentation/pages/scenario_list_page.dart';
import '../../features/scenario/presentation/pages/policy_analyst_page.dart';
import '../../features/scenario/presentation/pages/blueprint_page.dart';
import '../../features/scenario/presentation/pages/summary_report_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _StateNotifierListenable([
      ref.read(authControllerProvider.notifier),
      ref.read(villageControllerProvider.notifier),
      ref.read(assessmentControllerProvider.notifier),
    ]),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final villageState = ref.read(villageControllerProvider);
      final assessmentState = ref.read(assessmentControllerProvider);

      final loggedIn = authState.user != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplashing = state.matchedLocation == '/';

      if (isSplashing) return null;

      if (!loggedIn) {
        return isLoggingIn ? null : '/';
      }

      if (villageState.activeVillage == null && !villageState.isLoading) {
        if (state.matchedLocation != '/village-profile') {
          return '/village-profile';
        }
        return null;
      }

      if (villageState.activeVillage != null &&
          !assessmentState.isInitialized &&
          !assessmentState.isLoading) {
        Future.microtask(() {
          ref
              .read(assessmentControllerProvider.notifier)
              .loadLatestAssessment(villageState.activeVillage!.id);
        });
        return null;
      }

      if (villageState.activeVillage != null &&
          assessmentState.isInitialized &&
          assessmentState.latestAssessment == null &&
          !assessmentState.isLoading) {
        if (state.matchedLocation != '/assessment' &&
            state.matchedLocation != '/village-profile') {
          return '/assessment';
        }
        return null;
      }

      if (isLoggingIn) {
        return '/scenarios';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/village-profile',
        builder: (context, state) => const VillageProfilePage(),
      ),
      GoRoute(
        path: '/assessment',
        builder: (context, state) => const QuestionnairePage(),
      ),
      GoRoute(
        path: '/dna-result',
        builder: (context, state) => const DnaResultPage(),
      ),
      GoRoute(
        path: '/future-builder',
        builder: (context, state) => const FutureBuilderPage(),
      ),
      GoRoute(
        path: '/scenarios',
        builder: (context, state) => const ScenarioListPage(),
      ),
      GoRoute(
        path: '/policy-analyst',
        builder: (context, state) => const PolicyAnalystPage(),
      ),
      GoRoute(
        path: '/blueprint',
        builder: (context, state) => const BlueprintPage(),
      ),
      GoRoute(
        path: '/summary-report',
        builder: (context, state) => const SummaryReportPage(),
      ),
    ],
  );
});

class _StateNotifierListenable extends ChangeNotifier {
  final List<StateNotifier> _notifiers;
  final List<RemoveListener> _removeListeners = [];

  _StateNotifierListenable(this._notifiers) {
    for (final notifier in _notifiers) {
      final remove = notifier.addListener((_) {
        notifyListeners();
      });
      _removeListeners.add(remove);
    }
  }

  @override
  void dispose() {
    for (final remove in _removeListeners) {
      remove();
    }
    super.dispose();
  }
}
