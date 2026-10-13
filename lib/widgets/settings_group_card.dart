import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroupCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                color: AppColors.dividerDark.withValues(alpha: 0.6),
                height: 1,
                thickness: 1,
              ),
          ],
        ],
      ),
    );
  }
}
