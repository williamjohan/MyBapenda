// ignore_for_file: unused_import
//
// PETA CUBIT (BLUEPRINT, bukan kode aktif).
// Tujuan: menandai tech debt agar saat Cubit dibuat tidak ada yang terlewat.
//
// ---------------------------------------------------------------------------
// VaQrisState (Freezed) -- field yang dibutuhkan
// ---------------------------------------------------------------------------
//   status            : initial | searching | loaded | notFound | failure
//   nop               : String                (18 digit)
//   billing           : TaxBillingEntity?
//   selectedCount     : int                   (lihat PeriodSelectionLogic)
//   confirming        : bool
//   session           : PaymentSessionEntity? (QRIS/VA aktif)
//   sessionStatus     : pending | paid | expired
//   errorMessage      : String?
//
// ---------------------------------------------------------------------------
// VaQrisCubit -- method
// ---------------------------------------------------------------------------
//   searchBilling(String nop)
//       Layar NOP. Validasi 18 digit -> UseCase GetTaxBilling(nop).
//       Ganti: VaQrisMockData.fetchBilling di va_qris_nop_page.dart.
//
//   togglePeriod(int index)
//       Layar tagihan. Pakai PeriodSelectionLogic.toggle (sudah murni Dart).
//       Ganti: setState di va_qris_billing_page.dart (_onToggle).
//
//   confirmPayment(PaymentMethod method)
//       Setelah pilih metode di bottom sheet -> UseCase CreatePayment(
//       nop, periodIds, method) -> isi state.session.
//       Ganti: VaQrisMockData.createSession di va_qris_billing_page.dart.
//
//   regenerateSession()
//       Tombol "Buat ulang" saat kedaluwarsa -> CreatePayment ulang.
//       Ganti: VaQrisMockData.regenerateSession di payment_page_layout.dart.
//
//   watchPaymentStatus()
//       Polling/stream status sesi (pending -> paid/expired) dan hentikan di
//       close(). Ganti: tombol simulasi di payment_action_bar.dart.
//
//   markExpired()
//       Dipanggil onTimeout PaymentCountdownTimer agar state sinkron.
//
// ---------------------------------------------------------------------------
// Lapisan data/domain (ditunda)
// ---------------------------------------------------------------------------
//   Repository : VaQrisRepository { getBilling, createPayment, getPaymentStatus }
//   UseCase    : GetTaxBilling, CreatePayment, GetPaymentStatus
//   Entity     : pindahkan dummy di lib/domain/entities/va_qris/
