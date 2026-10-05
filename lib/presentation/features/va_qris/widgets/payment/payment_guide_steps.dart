/// TODO(tech-debt): PLACEHOLDER. Konfirmasi redaksi final bersama tim
/// Bapenda / Bank Jatim sebelum rilis.
abstract final class PaymentGuideSteps {
  static const List<String> qris = [
    'Tunjukkan layar ini kepada wajib pajak.',
    'Wajib pajak membuka aplikasi m-banking atau e-wallet yang mendukung QRIS.',
    'Pilih menu Scan / Bayar, lalu arahkan kamera ke kode QR.',
    'Pastikan nominal dan nama penerima sudah sesuai, lalu konfirmasi.',
    'Tunggu status pembayaran berhasil sebelum menyerahkan bukti bayar.',
  ];

  static const List<String> va = [
    'Sampaikan nomor Virtual Account kepada wajib pajak.',
    'Wajib pajak memilih Transfer > Virtual Account di m-banking atau ATM.',
    'Masukkan nomor VA, lalu pastikan nominal dan nama penerima sesuai.',
    'Konfirmasi pembayaran dengan PIN atau OTP.',
    'Tunggu status pembayaran berhasil sebelum menyerahkan bukti bayar.',
  ];
}
