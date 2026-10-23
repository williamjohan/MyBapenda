import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_new.dart';

extension MyTaskJenisStyle on MyTaskJenis {
  IconData get icon => switch (this) {
    MyTaskJenis.himbauan => Icons.mark_email_unread_outlined,
    MyTaskJenis.teguran => Icons.warning_amber_rounded,
    MyTaskJenis.silang => Icons.do_not_disturb_on_outlined,
    MyTaskJenis.unsilang => Icons.check_circle_outline_rounded,
    MyTaskJenis.bongkar => Icons.construction_outlined,
    MyTaskJenis.unknown => Icons.assignment_outlined,
  };

  Color get color => switch (this) {
    MyTaskJenis.himbauan => AppThemeColors.information,
    MyTaskJenis.teguran => AppThemeColors.gold,
    MyTaskJenis.silang => AppThemeColors.brown3,
    MyTaskJenis.unsilang => AppThemeColors.success,
    MyTaskJenis.bongkar => AppThemeColors.black1,
    MyTaskJenis.unknown => AppThemeColors.completed,
  };

  Color get softColor => color.withValues(alpha: 0.12);
}
