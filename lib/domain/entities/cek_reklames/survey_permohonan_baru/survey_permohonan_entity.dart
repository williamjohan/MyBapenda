import 'package:equatable/equatable.dart';

class SurveyPermohonanEntity extends Equatable {
  final String key;
  final String keyTask;
  final String noPelayanan;
  final String npwpd;
  final String katPenyelenggaraan;
  final String kategoriPenyelenggaraanNama;
  final String jenisReklameNama;
  final String lokPenyelenggaraan;
  final String masaTayang;
  final int masaPajakHari;
  final int jumlahSisi;
  final String statusProses;
  final String statusPermohonan;
  final String startTask;
  final String expTask;
  final bool dikembalikanPenilaian;
  final String? ketPengembalian;
  final DateTime? tglPengembalian;
  final SurveyBadgeEntity? badge;

  const SurveyPermohonanEntity({
    required this.key,
    required this.keyTask,
    required this.noPelayanan,
    required this.npwpd,
    required this.katPenyelenggaraan,
    required this.kategoriPenyelenggaraanNama,
    required this.jenisReklameNama,
    required this.lokPenyelenggaraan,
    required this.masaTayang,
    required this.masaPajakHari,
    required this.jumlahSisi,
    required this.statusProses,
    required this.statusPermohonan,
    required this.startTask,
    required this.expTask,
    this.dikembalikanPenilaian = false,
    this.ketPengembalian,
    this.tglPengembalian,
    this.badge,
  });

  bool get showReturnBanner =>
      dikembalikanPenilaian || (badge?.isVisible ?? false);

  @override
  List<Object?> get props => [
    key,
    keyTask,
    noPelayanan,
    npwpd,
    katPenyelenggaraan,
    kategoriPenyelenggaraanNama,
    jenisReklameNama,
    lokPenyelenggaraan,
    masaTayang,
    masaPajakHari,
    jumlahSisi,
    statusProses,
    statusPermohonan,
    startTask,
    expTask,
  ];
}

class SurveyBadgeEntity extends Equatable {
  final String text;
  final String color;

  const SurveyBadgeEntity({required this.text, required this.color});

  bool get isVisible => text.trim().isNotEmpty && color != 'transparent';

  @override
  List<Object?> get props => [text, color];
}
