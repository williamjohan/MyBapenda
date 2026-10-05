/// Aturan pemilihan masa pajak: WAJIB BERURUTAN dari yang terlama.
///
/// Karena pilihan selalu berupa "awalan" daftar (terlama sampai ke-N), state
/// cukup disimpan sebagai satu angka `selectedCount`. Kelas ini murni Dart,
/// sehingga nanti bisa dipindah ke Cubit/UseCase tanpa perubahan.
abstract final class PeriodSelectionLogic {
  /// Default: masa pajak terlama yang belum dibayar (= bulan ini jika tidak
  /// ada tunggakan).
  static int defaultSelectedCount(int unpaidLength) =>
      unpaidLength > 0 ? 1 : 0;

  static bool isSelected(int index, int selectedCount) => index < selectedCount;

  /// Hanya item yang sudah dipilih (untuk dibatalkan) dan satu item
  /// berikutnya (untuk ditambah) yang bisa disentuh.
  static bool isEnabled(int index, int selectedCount) => index <= selectedCount;

  /// Mencentang item ke-[index] ikut mencentang semua yang lebih lama.
  /// Membatalkan item ke-[index] ikut membatalkan semua yang lebih baru.
  static int toggle({required int selectedCount, required int index}) =>
      index < selectedCount ? index : index + 1;
}
