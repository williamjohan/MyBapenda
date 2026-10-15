import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/pengiriman/berkas_entity.dart';
import '../logic/berkas_sla_logic.dart';
import '../logic/pantau_logic.dart';
import '../logic/tugas_tab_logic.dart';

/// Pasangan warna (teks/ikon, latar) dari token status [AppPalette].
typedef ToneColors = ({Color fg, Color bg});

extension StatusBerkasStyle on StatusBerkas {
  ToneColors tone(AppPalette p) => switch (this) {
    StatusBerkas.diterima ||
    StatusBerkas.dikirimViaPos => (fg: p.statusSukses, bg: p.statusSuksesSoft),
    StatusBerkas.gagalAntar ||
    StatusBerkas.tidakTerkirim => (fg: p.statusGagal, bg: p.statusGagalSoft),
    StatusBerkas.dibatalkan ||
    StatusBerkas.dikembalikan => (fg: p.statusBatal, bg: p.statusBatalSoft),
    _ => (fg: p.statusProses, bg: p.statusProsesSoft),
  };

  IconData get icon => switch (this) {
    StatusBerkas.disiapkan => Icons.inventory_2_outlined,
    StatusBerkas.ditugaskan => Icons.assignment_ind_outlined,
    StatusBerkas.diambil => Icons.move_to_inbox_outlined,
    StatusBerkas.dalamPerjalanan => Icons.two_wheeler_outlined,
    StatusBerkas.tiba => Icons.place_outlined,
    StatusBerkas.diterima => Icons.task_alt_rounded,
    StatusBerkas.gagalAntar => Icons.report_gmailerrorred_rounded,
    StatusBerkas.dikembalikan => Icons.keyboard_return_rounded,
    StatusBerkas.dibatalkan => Icons.block_rounded,
    StatusBerkas.dikirimViaPos => Icons.markunread_mailbox_outlined,
    StatusBerkas.tidakTerkirim => Icons.cancel_outlined,
  };
}

extension JenisSuratStyle on JenisSurat {
  ToneColors tone(AppPalette p) => switch (this) {
    JenisSurat.himbauan => (fg: p.statusProses, bg: p.statusProsesSoft),
    JenisSurat.teguran => (fg: p.statusWarning, bg: p.statusWarningSoft),
    JenisSurat.skBongkar => (fg: p.statusGagal, bg: p.statusGagalSoft),
    JenisSurat.lainnya => (fg: p.statusBatal, bg: p.statusBatalSoft),
  };
}

extension SlaLevelStyle on SlaLevel {
  ToneColors tone(AppPalette p) => switch (this) {
    SlaLevel.lewat => (fg: p.statusGagal, bg: p.statusGagalSoft),
    SlaLevel.mendekati => (fg: p.statusWarning, bg: p.statusWarningSoft),
    SlaLevel.aman => (fg: p.textSecondary, bg: p.surfaceMuted),
  };
}

/// Ikon tab status (gaya sama di Pengiriman Surat & Pantau Surat).
extension TabTugasStyle on TabTugas {
  IconData get icon => switch (this) {
    TabTugas.ambil => Icons.inventory_2_outlined,
    TabTugas.diantar => Icons.two_wheeler_outlined,
    TabTugas.gagal => Icons.assignment_return_outlined,
  };
}

extension PantauFilterStyle on PantauFilter {
  IconData get icon => switch (this) {
    PantauFilter.semua => Icons.all_inbox_outlined,
    PantauFilter.menunggu => Icons.inventory_2_outlined,
    PantauFilter.diantar => Icons.two_wheeler_outlined,
    PantauFilter.tiba => Icons.place_outlined,
    PantauFilter.diterima => Icons.task_alt_rounded,
    PantauFilter.bermasalah => Icons.report_problem_outlined,
  };
}
