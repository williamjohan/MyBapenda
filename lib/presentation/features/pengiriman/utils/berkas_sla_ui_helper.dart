import '../../../../domain/entities/pengiriman/berkas_entity.dart';

/// Teks badge SLA: "Lewat SLA 2 hari", "Sisa 5 jam", "SLA 3 hari".
/// Aturan level ada di [SlaBerkas.hitung] (domain).
extension SlaBerkasUi on SlaBerkas {
  String get label {
    final d = selisih;
    return switch (level) {
      SlaLevel.lewat => d == null ? 'Lewat SLA' : 'Lewat SLA ${_durasi(d)}',
      SlaLevel.mendekati => 'Sisa ${_durasi(d!)}',
      SlaLevel.aman => 'SLA ${d!.inDays} hari',
    };
  }
}

String _durasi(Duration d) {
  if (d.inDays >= 1) return '${d.inDays} hari';
  if (d.inHours >= 1) return '${d.inHours} jam';
  return '${d.inMinutes < 1 ? 1 : d.inMinutes} menit';
}
