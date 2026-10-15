/// Metode pembayaran yang bisa dipilih petugas saat menagih di lapangan.
enum PaymentMethod {
  qris('QRIS', 'qris'),
  vaBankJatim('VA Bank Jatim', 'va');

  const PaymentMethod(this.label, this.apiValue);

  final String label;

  /// Nilai `tipePembayaran` di API pembayaran.
  final String apiValue;
}
