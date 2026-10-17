// lib/domain/entities/profile/jenis_kontak.dart

/// Kontak pegawai yang bisa diubah / diverifikasi lewat OTP.
enum JenisKontak {
  email('Email', 1),
  whatsapp('No. WhatsApp', 2);

  const JenisKontak(this.label, this.apiValue);

  final String label;

  /// Nilai yang dikirim ke API, sesuai enum backend `Pegawai.EKontak`.
  final int apiValue;
}
