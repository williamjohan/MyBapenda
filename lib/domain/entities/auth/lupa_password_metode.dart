// lib/domain/entities/auth/lupa_password_metode.dart

/// Saluran pengiriman reset kata sandi yang dipilih pegawai.
enum LupaPasswordMetode {
  email('Email', 1),
  whatsapp('WhatsApp', 2);

  const LupaPasswordMetode(this.label, this.apiValue);

  final String label;

  /// Nilai yang dikirim ke API, sesuai enum backend `EChannelKodeReset`.
  final int apiValue;
}
