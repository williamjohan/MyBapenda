import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:bapendacore/core/utils/date_format_id.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_method.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';

/// Helper tampilan teks VA & QRIS.
class VaQrisUiHelper {
  const VaQrisUiHelper._();

  /// Teks dari API siap tampil: spasi beruntun dirapikan jadi satu, dan
  /// kosong ditampilkan "-" (mis. nama WP yang belum diisi di master).
  static String teks(String? value) {
    final rapi = (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return rapi.isEmpty ? '-' : rapi;
  }

  /// Nomor referensi di kartu tagihan: "NOP 35.78..." tetap berlabel,
  /// No SKPD cukup nomornya saja.
  static String nomorReferensi(String label, String nomor) =>
      label.trim().toUpperCase() == 'NO SKPD' ? nomor : '$label $nomor';

  /// NMID QRIS siap tampil; null bila kosong (baris NMID disembunyikan).
  static String? nmid(String? value) {
    final rapi = (value ?? '').trim();
    return rapi.isEmpty ? null : rapi;
  }

  /// "16 Okt 2026 pukul 10:15" untuk batas waktu kode bayar.
  static String batasWaktu(DateTime waktu) =>
      '${formatTanggalId(waktu)} pukul ${formatJamId(waktu)}';

  /// Daftar masa pajak singkat: maks. 3 nama masa, lebih dari itu diringkas
  /// "12 masa (Jul 2025 s.d. Jun 2026)".
  static String daftarMasa(PaymentSessionEntity session) {
    final labels = session.periods.map((p) => p.label).toList();
    if (labels.length <= 3) return labels.join(', ');
    return '${labels.length} masa (${labels.first} s.d. ${labels.last})';
  }

  /// Teks yang ikut dibagikan ke wajib pajak (WhatsApp dll.). QRIS: teks
  /// pendamping gambar QR; VA: berisi nomor VA.
  static String teksBagikan(PaymentSessionEntity session) {
    final baris = <String>[
      'Pembayaran Pajak Daerah Kota Surabaya',
      '',
      'Wajib pajak: ${teks(session.taxpayerName)}',
      '${session.referenceLabel}: ${session.referenceNumber}',
      if (session.periods.isNotEmpty) 'Masa pajak: ${daftarMasa(session)}',
      'Total bayar: ${CurrencyFormatter.toIdr(session.total)}',
      '',
      if (session.method == PaymentMethod.vaBankJatim) ...[
        'Virtual Account Bank Jatim: ${session.vaNumber ?? '-'}',
        'Bayar lewat m-banking, ATM, atau teller sebelum '
            '${batasWaktu(session.expiresAt)}.',
      ] else
        'Scan gambar QRIS dengan m-banking atau e-wallet sebelum '
            '${batasWaktu(session.expiresAt)}.',
    ];
    return baris.join('\n');
  }
}
