import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class SurveyDataState extends Equatable {
  // Pilihan dropdown (ID angka)
  final int? lokasiTertentuId;
  final int? lokasiPenyelenggaraanId;
  final int? letakId;
  final int? statusTanahId;
  final int? jenisReklameId;
  final int? jenisProdukId;
  final int? sudutId;
  final int? jenisBangunanId;
  final int? namaJalanId;
  final String? namaJalanNama;
  final String? persilId;
  final String? persilLabel;
  final String? error;
  final Map<String, dynamic>? result;

  const SurveyDataState({
    this.lokasiTertentuId,
    this.lokasiPenyelenggaraanId,
    this.letakId,
    this.statusTanahId,
    this.jenisReklameId,
    this.jenisProdukId,
    this.sudutId,
    this.jenisBangunanId,
    this.namaJalanId,
    this.namaJalanNama,
    this.persilId,
    this.persilLabel,
    this.error,
    this.result,
  });

  SurveyDataState copyWith({
    int? lokasiTertentuId,
    int? lokasiPenyelenggaraanId,
    int? letakId,
    int? statusTanahId,
    int? jenisReklameId,
    int? jenisProdukId,
    int? sudutId,
    int? jenisBangunanId,
    int? namaJalanId,
    String? namaJalanNama,
    String? persilId,
    String? persilLabel,
    ValueGetter<String?>? error,
    Map<String, dynamic>? result,
  }) => SurveyDataState(
    lokasiTertentuId: lokasiTertentuId ?? this.lokasiTertentuId,
    lokasiPenyelenggaraanId: lokasiPenyelenggaraanId ?? this.lokasiPenyelenggaraanId,
    letakId: letakId ?? this.letakId,
    statusTanahId: statusTanahId ?? this.statusTanahId,
    jenisReklameId: jenisReklameId ?? this.jenisReklameId,
    jenisProdukId: jenisProdukId ?? this.jenisProdukId,
    sudutId: sudutId ?? this.sudutId,
    jenisBangunanId: jenisBangunanId ?? this.jenisBangunanId,
    namaJalanId: namaJalanId ?? this.namaJalanId,
    namaJalanNama: namaJalanNama ?? this.namaJalanNama,
    persilId: persilId ?? this.persilId,
    persilLabel: persilLabel ?? this.persilLabel,
    error: error != null ? error() : this.error,
    result: result ?? this.result,
  );

  @override
  List<Object?> get props => [
    lokasiTertentuId,
    lokasiPenyelenggaraanId,
    letakId,
    statusTanahId,
    jenisReklameId,
    jenisProdukId,
    sudutId,
    jenisBangunanId,
    namaJalanId,
    namaJalanNama,
    persilId,
    persilLabel,
    error,
    result,
  ];
}
