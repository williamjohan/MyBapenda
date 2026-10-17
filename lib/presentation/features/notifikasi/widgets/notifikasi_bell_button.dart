import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors_new.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/notifikasi_badge_cubit.dart';

/// Lonceng di header Home dengan jumlah belum dibaca.
class NotifikasiBellButton extends StatelessWidget {
  const NotifikasiBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final jumlah = context.watch<NotifikasiBadgeCubit>().state;

    return Material(
      borderRadius: BorderRadius.circular(10),
      color: AppThemeColors.defaultSurface.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push(AppRoutes.notifikasi),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Badge(
            isLabelVisible: jumlah > 0,
            label: Text(jumlah > 99 ? '99+' : '$jumlah'),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
