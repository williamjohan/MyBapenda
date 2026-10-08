// lib/presentation/features/balai_rw/pages/balai_rw_page.dart
import 'package:bapendacore/domain/entities/balai_rw/roster_pegawai_entity.dart';
import 'package:bapendacore/presentation/features/balai_rw/constant/balai_rw_dummy.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../cubit/balai_rw_hub_cubit.dart';
import '../cubit/balai_rw_hub_state.dart';
import '../widgets/balai_rw_step_card.dart';
import 'balai_rw_absen_page.dart';

class BalaiRwPage extends StatefulWidget {
  const BalaiRwPage({super.key});

  @override
  State<BalaiRwPage> createState() => _BalaiRwPageState();
}

class _BalaiRwPageState extends State<BalaiRwPage> {
  static const _brand = Color(0xFFB8680F);

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// "08:00:00" / "08.00" -> "08.00". Kosong -> null.
  String? _jam(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final t = DateUtil.parseJam(s);
    return t == null ? s : DateUtil.jamOf(t);
  }

  /// Dipakai halaman check-in/out/laporan.
  /// TODO: nama wilayah dari master (sekarang masih kode dari roster)
  /// TODO: nama petugas dari auth
  Map<String, dynamic> _tugas(RosterPegawaiEntity r) => {
    'kecamatan': r.kodeKecamatan,
    'kelurahan': r.kodeKelurahan,
    'balaiRw': 'Balai RW ${r.rw}',
    'petugas': BalaiRwDummy.penugasan['petugas'],
  };

  // --------------------------------------------------------------- aksi

  Future<void> _openAbsen(
    BalaiRwAbsenType type,
    BalaiRwHubState st,
    bool canEdit,
  ) async {
    final cubit = context.read<BalaiRwHubCubit>();
    final isIn = type == BalaiRwAbsenType.checkIn;

    final jamLama = isIn ? st.jamMasuk : st.jamPulang;
    final fotoLama = isIn ? st.fotoMasuk : st.fotoPulang;
    final initial = jamLama == null
        ? null
        : <String, dynamic>{'path': fotoLama, 'jam': jamLama};

    final result = await context.pushNamed<Map<String, dynamic>>(
      AppRoutes.balaiRwAbsen,
      extra: (
        type: type,
        penugasan: _tugas(st.roster!),
        initial: initial,
        readOnly: !canEdit,
      ),
    );
    if (result == null || !mounted) return;

    final jam = result['jam'] as String;
    final path = result['path'] as String;
    if (isIn) {
      cubit.setCheckin(jam: jam, fotoPath: path);
    } else {
      cubit.setCheckout(jam: jam, fotoPath: path);
    }
    _snack(
      '${isIn ? 'Check-in' : 'Check-out'} dicatat. Tekan "Kirim Laporan" kalau semua sudah lengkap.',
    );
  }

  Future<void> _openLaporan(
    BalaiRwHubState st,
    bool canEdit,
    bool lapDone,
  ) async {
    final cubit = context.read<BalaiRwHubCubit>();

    final result = await context.pushNamed<Map<String, dynamic>>(
      AppRoutes.balaiRwLaporan,
      extra: (
        penugasan: _tugas(st.roster!),
        initial: lapDone
            ? <String, dynamic>{
                'jawaban': {
                  for (final j in st.jawaban)
                    '${j.idPertanyaan}': j.jawaban ?? '',
                },
                if (st.dihadiriOleh.isNotEmpty) 'dihadiriOleh': st.dihadiriOleh,
              }
            : null,
        readOnly: !canEdit,
      ),
    );
    if (result == null || !mounted) return;

    cubit.setLaporan(
      jawaban: (result['jawaban'] as Map).cast<String, String>(),
      pertanyaan: (result['pertanyaan'] as Map).cast<String, String>(),
      dihadiriOleh: result['dihadiriOleh'] as String,
    );
    _snack('Laporan dicatat. Tekan "Kirim Laporan" kalau semua sudah lengkap.');
  }

  // ----------------------------------------------------------- komponen

  Widget _notice(IconData icon, Color bg, Color fg, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.5,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary({
    required DateTime now,
    required RosterPegawaiEntity roster,
    required bool isKoord,
    required String pukul,
  }) {
    final jadwal =
        '${_jam(roster.jamMasuk) ?? '-'} - ${_jam(roster.jamPulang) ?? '-'} WIB';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF7B8794),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateUtil.hari(now)}, ${DateUtil.tanggal(now)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2933),
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: isKoord ? 'Koordinator' : 'Hanya lihat',
                tone: isKoord
                    ? BapendaStatusTone.info
                    : BapendaStatusTone.neutral,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEF0F3)),
          ),
          // TODO: tampilkan nama wilayah, bukan kode
          InfoRow(
            label: 'Lokasi',
            value: 'Kel. ${roster.kodeKelurahan}, Kec. ${roster.kodeKecamatan}',
          ),
          InfoRow(label: 'Balai RW', value: 'Balai RW ${roster.rw}'),
          InfoRow(label: 'Jadwal', value: jadwal),
        ],
      ),
    );
  }

  Widget _progress(int done) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Progres hari ini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2933),
                ),
              ),
            ),
            Text(
              '$done/3 selesai',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _brand,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: done / 3,
            minHeight: 6,
            backgroundColor: const Color(0xFFE4E7EB),
            color: _brand,
          ),
        ),
      ],
    );
  }

  Widget _failure(BalaiRwHubState st) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: Color(0xFF9AA5B1),
          ),
          const SizedBox(height: 12),
          Text(
            st.error ?? 'Gagal memuat data',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF7B8794),
            ),
          ),
          const SizedBox(height: 16),
          Button(
            label: 'Coba Lagi',
            icon: Icons.refresh_rounded,
            variant: BapendaButtonVariant.outlined,
            expanded: false,
            height: 44,
            onPressed: () => context.read<BalaiRwHubCubit>().load(),
          ),
        ],
      ),
    );
  }

  BalaiRwStepState _stateOf({
    required bool done,
    required bool unlocked,
    required bool canEdit,
  }) {
    if (done) return BalaiRwStepState.done;
    if (!canEdit) return BalaiRwStepState.pending;
    return unlocked ? BalaiRwStepState.active : BalaiRwStepState.locked;
  }

  // -------------------------------------------------------------- isi

  List<Widget> _content(BalaiRwHubState st) {
    final roster = st.roster!;

    final isKoord = BalaiRwDummy.isKoordinator; // TODO: role dari API
    final canEdit = isKoord && !roster.isLibur;
    final busy = st.saving;

    final jamIn = st.jamMasuk;
    final jamOut = st.jamPulang;
    final ciDone = jamIn != null;
    final coDone = jamOut != null;
    final lapDone = st.laporanDone;
    final doneCount = (ciDone ? 1 : 0) + (lapDone ? 1 : 0) + (coDone ? 1 : 0);

    final pukul = !ciDone
        ? '-'
        : coDone
        ? '$jamIn - $jamOut WIB'
        : '$jamIn - belum check-out';

    return [
      if (busy) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: const LinearProgressIndicator(minHeight: 4),
        ),
        const SizedBox(height: 10),
      ],
      _summary(
        now: DateTime.now(),
        roster: roster,
        isKoord: isKoord,
        pukul: pukul,
      ),
      const SizedBox(height: 14),

      if (roster.isLibur) ...[
        _notice(
          Icons.beach_access_rounded,
          const Color(0xFFFFF3DC),
          const Color(0xFFB8680F),
          'Hari ini libur. Check-in, laporan, dan check-out tidak perlu diisi.',
        ),
        const SizedBox(height: 14),
      ] else if (!isKoord) ...[
        _notice(
          Icons.visibility_outlined,
          const Color(0xFFEEF0F3),
          const Color(0xFF52606D),
          'Mode lihat saja. Hanya koordinator yang dapat mengisi check-in, laporan, dan check-out.',
        ),
        const SizedBox(height: 14),
      ] else if (doneCount == 3) ...[
        _notice(
          Icons.check_circle_rounded,
          const Color(0xFFE6F6EC),
          const Color(0xFF1B8A4B),
          'Laporan hari ini lengkap. Kamu masih bisa mengubah tiap langkah, dan perubahan terakhir yang dipakai.',
        ),
        const SizedBox(height: 14),
      ],

      _progress(doneCount),
      const SizedBox(height: 18),

      // 1. Check-in
      BalaiRwStepCard(
        number: 1,
        title: 'Check-in',
        subtitle: ciDone
            ? 'Pukul $jamIn WIB'
            : canEdit
            ? 'Foto saat tiba di balai RW. Jam diisi manual.'
            : 'Belum check-in',
        state: _stateOf(done: ciDone, unlocked: true, canEdit: canEdit),
        thumbPath: ciDone ? st.fotoMasuk : null,
        actionLabel: canEdit
            ? (ciDone ? 'Ubah Check-in' : 'Check-in Sekarang')
            : (ciDone ? 'Lihat Foto' : null),
        actionIcon: canEdit
            ? (ciDone ? Icons.edit_outlined : Icons.photo_camera_rounded)
            : Icons.visibility_outlined,
        actionPrimary: canEdit && !ciDone,
        onAction: busy
            ? null
            : () => _openAbsen(BalaiRwAbsenType.checkIn, st, canEdit),
        onTap: ciDone && !busy
            ? () => _openAbsen(BalaiRwAbsenType.checkIn, st, canEdit)
            : null,
      ),

      // 2. Laporan
      BalaiRwStepCard(
        number: 2,
        title: 'Laporan Pelayanan',
        subtitle: lapDone
            ? 'Sudah diisi (${st.jawaban.length} jawaban)'
            : !canEdit
            ? 'Belum ada laporan'
            : !ciDone
            ? 'Selesaikan check-in dulu'
            : 'Isi data laporan pelayanan',
        state: _stateOf(done: lapDone, unlocked: ciDone, canEdit: canEdit),
        actionLabel: canEdit
            ? (!ciDone ? null : (lapDone ? 'Ubah Laporan' : 'Isi Laporan'))
            : (lapDone ? 'Lihat Laporan' : null),
        actionIcon: canEdit
            ? (lapDone ? Icons.edit_outlined : Icons.assignment_rounded)
            : Icons.visibility_outlined,
        actionPrimary: canEdit && ciDone && !lapDone,
        onAction: busy ? null : () => _openLaporan(st, canEdit, lapDone),
        onTap: lapDone && !busy
            ? () => _openLaporan(st, canEdit, lapDone)
            : null,
      ),

      // 3. Check-out
      BalaiRwStepCard(
        number: 3,
        title: 'Check-out',
        isLast: true,
        subtitle: coDone
            ? 'Pukul $jamOut WIB'
            : !canEdit
            ? 'Belum check-out'
            : !lapDone
            ? 'Isi laporan dulu'
            : 'Foto saat selesai. Lokasi dan jam otomatis tercetak.',
        state: _stateOf(done: coDone, unlocked: lapDone, canEdit: canEdit),
        thumbPath: coDone ? st.fotoPulang : null,
        actionLabel: canEdit
            ? (!lapDone
                  ? null
                  : (coDone ? 'Ubah Check-out' : 'Check-out Sekarang'))
            : (coDone ? 'Lihat Foto' : null),
        actionIcon: canEdit
            ? (coDone ? Icons.edit_outlined : Icons.photo_camera_rounded)
            : Icons.visibility_outlined,
        actionPrimary: canEdit && lapDone && !coDone,
        onAction: busy
            ? null
            : () => _openAbsen(BalaiRwAbsenType.checkOut, st, canEdit),
        onTap: coDone && !busy
            ? () => _openAbsen(BalaiRwAbsenType.checkOut, st, canEdit)
            : null,
      ),
    ];
  }

  List<Widget> _body(BalaiRwHubState st) {
    switch (st.status) {
      case BalaiRwHubStatus.loading:
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          ),
        ];
      case BalaiRwHubStatus.failure:
        return [_failure(st)];
      case BalaiRwHubStatus.ready:
        if (st.roster == null) {
          return [
            _notice(
              Icons.event_busy_rounded,
              const Color(0xFFEEF0F3),
              const Color(0xFF52606D),
              'Tidak ada penugasan Balai RW untuk hari ini.',
            ),
          ];
        }
        return _content(st);
    }
  }

  Future<void> _submit() async {
    final err = await context.read<BalaiRwHubCubit>().submit();
    _snack(err ?? 'Laporan hari ini berhasil dikirim');
  }

  Widget? _submitBar(BalaiRwHubState st) {
    final r = st.roster;
    if (st.status != BalaiRwHubStatus.ready ||
        r == null ||
        r.isLibur ||
        !BalaiRwDummy.isKoordinator) {
      return null; 
    }

    final sent = st.isComplete && !st.dirty;
    final label = st.saving
        ? 'Mengirim...'
        : sent
        ? 'Laporan Terkirim'
        : 'Kirim Laporan';

    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!st.isComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Lengkapi check-in, laporan, dan check-out untuk mengirim.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF7B8794),
                  ),
                ),
              ),
            Button(
              label: label,
              icon: sent ? Icons.check_circle_rounded : Icons.send_rounded,
              isLoading: st.saving,
              onPressed: st.isComplete && st.dirty && !st.saving
                  ? _submit
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalaiRwHubCubit, BalaiRwHubState>(
      builder: (context, st) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          bottomNavigationBar: _submitBar(st),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              BapendaSliverHeader(
                title: 'Balai RW',
                showBackButton: true,
                subtitle: Text(
                  'Laporan pelayanan balai RW',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(_body(st)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
