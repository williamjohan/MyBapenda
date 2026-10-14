import '../../../../domain/entities/pengiriman/berkas_entity.dart';

enum SlaLevel { aman, mendekati, lewat }

class SlaInfo {
  final SlaLevel level;
  final String label;
  const SlaInfo(this.level, this.label);
}

/// Aturan badge SLA:
/// - status final atau tanpa batas SLA → tidak ada badge,
/// - `terlambat` dari server atau lewat batas → merah "Lewat SLA ...",
/// - sisa < 24 jam → kuning "Sisa ... jam",
/// - selebihnya → netral "SLA n hari".
class BerkasSlaLogic {
  BerkasSlaLogic._();

  static const _batasMendekati = Duration(hours: 24);

  static SlaInfo? hitung({
    required StatusBerkas status,
    required DateTime? batasSla,
    required bool terlambat,
    required DateTime now,
  }) {
    if (status.isFinal) return null;
    if (batasSla == null) {
      return terlambat ? const SlaInfo(SlaLevel.lewat, 'Lewat SLA') : null;
    }

    final sisa = batasSla.difference(now);
    if (terlambat || sisa.isNegative) {
      return sisa.isNegative
          ? SlaInfo(SlaLevel.lewat, 'Lewat SLA ${_durasi(-sisa)}')
          : const SlaInfo(SlaLevel.lewat, 'Lewat SLA');
    }
    if (sisa < _batasMendekati) {
      return SlaInfo(SlaLevel.mendekati, 'Sisa ${_durasi(sisa)}');
    }
    return SlaInfo(SlaLevel.aman, 'SLA ${sisa.inDays} hari');
  }

  static SlaInfo? dariBerkas(BerkasEntity b, DateTime now) => hitung(
    status: b.status,
    batasSla: b.tglBatasSla,
    terlambat: b.terlambat,
    now: now,
  );

  static String _durasi(Duration d) {
    if (d.inDays >= 1) return '${d.inDays} hari';
    if (d.inHours >= 1) return '${d.inHours} jam';
    return '${d.inMinutes < 1 ? 1 : d.inMinutes} menit';
  }
}
