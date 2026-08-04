import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/core/theme/app_theme.dart';
import 'package:ecosim_flutter/features/scenario/presentation/controllers/scenario_controller.dart';

class SharedBottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const SharedBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 30,
        top: 10,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: const Color(0xFF67B05C),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, ref, 0, Icons.home_outlined, Icons.home),
            _buildNavItem(context, ref, 1, Icons.hexagon_outlined, Icons.hexagon),
            _buildNavItem(context, ref, 2, Icons.auto_awesome_outlined, Icons.auto_awesome),
            _buildNavItem(context, ref, 3, Icons.person_outline, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, int index, IconData outline, IconData solid) {
    final isActive = currentIndex == index;
    final color = isActive ? const Color(0xFF3E6D4E) : Colors.black87;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          context.go('/scenarios');
        } else if (index == 1) {
          context.go('/future-builder');
        } else if (index == 2) {
          final activeScenario = ref.read(scenarioControllerProvider).activeScenario;
          if (activeScenario == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Buat skenario di Future Builder terlebih dahulu.'),
                backgroundColor: AppTheme.poorColor,
              ),
            );
            context.go('/future-builder');
          } else {
            context.go('/policy-analyst');
          }
        } else if (index == 3) {
          context.go('/village-profile');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? solid : outline, color: color, size: 28),
            if (isActive) ...[
              const SizedBox(height: 4),
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6D4E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
