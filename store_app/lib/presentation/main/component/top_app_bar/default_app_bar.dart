import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/custom/custom_theme.dart';
import '../../../../core/utils/constant.dart';
import '../../cubit/bottom_nav_cubit.dart';
import '../../cubit/mall_type_cubit.dart';

class DefaultAppBar extends StatelessWidget {
  const DefaultAppBar(this.bottomNav, {super.key});

  final BottomNav bottomNav;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MallTypeCubit, MallType>(
      builder: (_, state) {
        return Container(
          child: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              color: (state.isStore)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              child: AppBar(
                title: Text(
                  bottomNav.toName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: state.isStore
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.contentPrimary,
                  ),
                ),
                backgroundColor: Colors.transparent,
                centerTitle: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
