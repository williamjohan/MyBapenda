import 'package:bapendacore/domain/entities/my_task/task_type.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_new.dart';

/// Ikon & warna per jenis tugas (semua dari palet AppThemeColors).
extension TaskTypeStyle on TaskType {
  IconData get icon => switch (this) {
    TaskType.himbauanPembayaran => Icons.mark_email_unread_outlined,
    TaskType.teguranPembayaran => Icons.warning_amber_rounded,
    TaskType.silang => Icons.do_not_disturb_on_outlined,
    TaskType.unsilang => Icons.check_circle_outline_rounded,
    TaskType.bongkar => Icons.construction_outlined,
    TaskType.pengawasanExisting => Icons.visibility_outlined,
    TaskType.pengawasanTemuanBaru => Icons.add_location_alt_outlined,
  };

  Color get color => switch (this) {
    TaskType.himbauanPembayaran => AppThemeColors.information,
    TaskType.teguranPembayaran => AppThemeColors.gold,
    TaskType.silang => AppThemeColors.brown3,
    TaskType.unsilang => AppThemeColors.success,
    TaskType.bongkar => AppThemeColors.black1,
    TaskType.pengawasanExisting => AppThemeColors.secondary,
    TaskType.pengawasanTemuanBaru => AppThemeColors.completed,
  };

  Color get softColor => color.withValues(alpha: 0.12);
}
