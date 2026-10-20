/// Batas detik terakhir saat countdown berubah warna jadi peringatan.
const int kCountdownWarningSeconds = 60;

/// Id master pajak Reklame (EnumFactory.EPajak). Reklame dicari lewat No SKPD,
/// tidak ikut "Cari objek pajak" maupun riwayat "Terakhir dicari".
const int kTaxTypeIdReklame = 7;

/// Jumlah maksimal riwayat "Terakhir dicari" per pegawai.
const int kRecentReferenceLimit = 10;

/// Panjang minimal keyword "Cari objek pajak" (sama dengan API).
const int kTaxObjectMinKeyword = 3;
