import 'package:flutter/material.dart';

import '../../../../../../core/theme/custom/custom_font_weight.dart';
import '../../../../../../core/theme/custom/custom_theme.dart';

class ViewModuleTitle extends StatelessWidget {
  final String title;

  const ViewModuleTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge.semiBold?.copyWith(
          color: Theme.of(context).colorScheme.contentPrimary,
        ),
      ),
    );
  }
}
