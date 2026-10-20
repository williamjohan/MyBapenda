import 'package:equatable/equatable.dart';

/// Hasil `simpan-survey`. Server selalu menyimpan isian sebagai draft dulu,
/// lalu langsung submit ke penilaian bila semua isian wajib sudah lengkap.
class SimpanSurveyHasilEntity extends Equatable {
  static const hasilSubmit = 'Submit';
  static const hasilDraft = 'Draft';

  /// [hasilSubmit] atau [hasilDraft].
  final String hasil;

  /// Isian yang masih kurang / alasan submit ditolak (kosong bila Submit).
  final List<String> kurangLengkap;

  /// Pesan dari server untuk ditampilkan.
  final String message;

  const SimpanSurveyHasilEntity({
    required this.hasil,
    this.kurangLengkap = const [],
    this.message = '',
  });

  /// true = survey sudah dikirim ke penilaian (task hilang dari daftar).
  bool get terkirim => hasil == hasilSubmit;

  @override
  List<Object?> get props => [hasil, kurangLengkap, message];
}
