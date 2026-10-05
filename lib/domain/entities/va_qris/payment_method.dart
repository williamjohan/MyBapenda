/// Metode pembayaran yang bisa dipilih petugas saat menagih di lapangan.
///
/// TODO(tech-debt): DUMMY ENTITY. Pindahkan/sesuaikan saat domain layer
/// dibuat (mapping dari kode channel milik Bank Jatim).
enum PaymentMethod {
  qris('QRIS'),
  vaBankJatim('VA Bank Jatim');

  const PaymentMethod(this.label);

  final String label;
}
