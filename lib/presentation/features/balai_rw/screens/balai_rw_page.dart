// lib/presentation/features/balai_rw/pages/balai_rw_page.dart
import 'package:bapendacore/presentation/features/balai_rw/constant/balai_rw_dummy.dart';
import 'package:bapendacore/presentation/features/balai_rw/screens/balai_rw_absen_page.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/widgets/info_row.dart';
import 'package:bapendacore/presentation/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../widgets/balai_rw_step_card.dart';

class BalaiRwPage extends StatefulWidget {
  const BalaiRwPage({super.key});

  @override
  State<BalaiRwPage> createState() => _BalaiRwPageState();
}

class _BalaiRwPageState extends State<BalaiRwPage> {
  static const _brand = Color(0xFFB8680F);

  final Map<String, dynamic> _tugas = BalaiRwDummy.penugasan;
  bool get _canEdit => BalaiRwDummy.isKoordinator;

  String get _key => DateUtil.iso(DateTime.now());
  Map<String, dynamic> get _rec => BalaiRwStore.of(_key) ?? const {};

  Map<String, dynamic>? get _checkin =>
      _rec['checkin'] as Map<String, dynamic>?;
  Map<String, dynamic>? get _checkout =>
      _rec['checkout'] as Map<String, dynamic>?;
  bool get _laporanDone => _rec['jawaban'] != null;

  void _save(Map<String, dynamic> patch, String message) {
    final now = DateTime.now();
    BalaiRwStore.patch(DateUtil.iso(now), {
      'tanggal': DateUtil.iso(now),
      'hari': DateUtil.hari(now),
      'kecamatan': _tugas['kecamatan'],
      'kelurahan': _tugas['kelurahan'],
      'balaiRw': _tugas['balaiRw'],
      ...patch,
    });
    debugPrint(BalaiRwStore.of(DateUtil.iso(now)).toString());

    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAbsen(BalaiRwAbsenType type) async {
    final isIn = type == BalaiRwAbsenType.checkIn;
    final result = await context.pushNamed<Map<String, dynamic>>(
      AppRoutes.balaiRwAbsen,
      extra: (
        type: type,
        penugasan: _tugas,
        initial: isIn ? _checkin : _checkout,
        readOnly: !_canEdit,
      ),
    );
    if (result == null || !mounted) return;
    _save({
      isIn ? 'checkin' : 'checkout': result,
    }, isIn ? 'Check-in tersimpan' : 'Check-out tersimpan');
  }

  Future<void> _openLaporan() async {
    final result = await context.pushNamed<Map<String, dynamic>>(
      AppRoutes.balaiRwLaporan,
      extra: (
        penugasan: _tugas,
        initial: _laporanDone
            ? {'jawaban': _rec['jawaban'], 'dihadiriOleh': _rec['dihadiriOleh']}
            : null,
        readOnly: !_canEdit,
      ),
    );
    if (result == null || !mounted) return;
    _save({
      ...result,
      'laporanAt': DateTime.now().toIso8601String(),
    }, 'Laporan tersimpan');
  }

  BalaiRwStepState _stateOf({required bool done, required bool unlocked}) {
    if (done) return BalaiRwStepState.done;
    if (!_canEdit) return BalaiRwStepState.pending;
    return unlocked ? BalaiRwStepState.active : BalaiRwStepState.locked;
  }

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

  Widget _summary(DateTime now) {
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
                label: _canEdit ? 'Koordinator' : 'Hanya lihat',
                tone: _canEdit
                    ? BapendaStatusTone.info
                    : BapendaStatusTone.neutral,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEF0F3)),
          ),
          InfoRow(
            label: 'Lokasi',
            value: 'Kel. ${_tugas['kelurahan']}, Kec. ${_tugas['kecamatan']}',
          ),
          InfoRow(label: 'Balai RW', value: '${_tugas['balaiRw']}'),
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final ci = _checkin;
    final co = _checkout;
    final lapDone = _laporanDone;
    final doneCount =
        (ci != null ? 1 : 0) + (lapDone ? 1 : 0) + (co != null ? 1 : 0);
    final lapAt = DateTime.tryParse('${_rec['laporanAt']}');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
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
              delegate: SliverChildListDelegate([
                _summary(now),
                const SizedBox(height: 14),

                if (!_canEdit) ...[
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
                  subtitle: ci != null
                      ? 'Pukul ${ci['jam']} WIB'
                      : _canEdit
                      ? 'Foto saat tiba di balai RW. Jam diisi manual.'
                      : 'Belum check-in',
                  state: _stateOf(done: ci != null, unlocked: true),
                  thumbPath: ci?['path'] as String?,
                  actionLabel: _canEdit
                      ? (ci == null ? 'Check-in Sekarang' : 'Ubah Check-in')
                      : (ci == null ? null : 'Lihat Foto'),
                  actionIcon: _canEdit
                      ? (ci == null
                            ? Icons.photo_camera_rounded
                            : Icons.edit_outlined)
                      : Icons.visibility_outlined,
                  actionPrimary: _canEdit && ci == null,
                  onAction: () => _openAbsen(BalaiRwAbsenType.checkIn),
                  onTap: ci != null
                      ? () => _openAbsen(BalaiRwAbsenType.checkIn)
                      : null,
                ),

                // 2. Laporan
                BalaiRwStepCard(
                  number: 2,
                  title: 'Laporan Pelayanan',
                  subtitle: lapDone
                      ? 'Terakhir diubah ${lapAt == null ? '-' : DateUtil.jam(lapAt)} WIB'
                      : !_canEdit
                      ? 'Belum ada laporan'
                      : ci == null
                      ? 'Selesaikan check-in dulu'
                      : 'Isi data A.1 sampai E.1 (angka saja)',
                  state: _stateOf(done: lapDone, unlocked: ci != null),
                  actionLabel: _canEdit
                      ? (ci == null
                            ? null
                            : (lapDone ? 'Ubah Laporan' : 'Isi Laporan'))
                      : (lapDone ? 'Lihat Laporan' : null),
                  actionIcon: _canEdit
                      ? (lapDone
                            ? Icons.edit_outlined
                            : Icons.assignment_rounded)
                      : Icons.visibility_outlined,
                  actionPrimary: _canEdit && ci != null && !lapDone,
                  onAction: _openLaporan,
                  onTap: lapDone ? _openLaporan : null,
                ),

                // 3. Check-out
                BalaiRwStepCard(
                  number: 3,
                  title: 'Check-out',
                  isLast: true,
                  subtitle: co != null
                      ? 'Pukul ${co['jam']} WIB'
                      : !_canEdit
                      ? 'Belum check-out'
                      : !lapDone
                      ? 'Isi laporan dulu'
                      : 'Foto saat selesai. Lokasi dan jam otomatis tercetak.',
                  state: _stateOf(done: co != null, unlocked: lapDone),
                  thumbPath: co?['path'] as String?,
                  actionLabel: _canEdit
                      ? (!lapDone
                            ? null
                            : (co == null
                                  ? 'Check-out Sekarang'
                                  : 'Ubah Check-out'))
                      : (co == null ? null : 'Lihat Foto'),
                  actionIcon: _canEdit
                      ? (co == null
                            ? Icons.photo_camera_rounded
                            : Icons.edit_outlined)
                      : Icons.visibility_outlined,
                  actionPrimary: _canEdit && lapDone && co == null,
                  onAction: () => _openAbsen(BalaiRwAbsenType.checkOut),
                  onTap: co != null
                      ? () => _openAbsen(BalaiRwAbsenType.checkOut)
                      : null,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
