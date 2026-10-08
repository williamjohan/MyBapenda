// lib/data/models/balai_rw/laporan_payload_model.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../domain/entities/balai_rw/laporan_payload_entity.dart';

class LaporanPayloadModel {
  final String tanggalLaporan;
  final List<Map<String, dynamic>> jawaban;
  final String jamMasuk;
  final String jamPulang;
  final String keterangan;
  final List<String> fotoPaths;

  const LaporanPayloadModel({
    required this.tanggalLaporan,
    required this.jawaban,
    required this.jamMasuk,
    required this.jamPulang,
    required this.keterangan,
    required this.fotoPaths,
  });

  Future<FormData> toFormData() async {
    final form = FormData();
    form.fields
      ..add(MapEntry('TanggalLaporan', tanggalLaporan))
      ..add(MapEntry('Jawaban', jsonEncode(jawaban)))
      ..add(MapEntry('Kehadiran.JamMasuk', jamMasuk))
      ..add(MapEntry('Kehadiran.JamPulang', jamPulang))
      ..add(MapEntry('Kehadiran.Keterangan', keterangan));

    // Satu nama field, banyak file (sesuai Swagger)
    for (final p in fotoPaths) {
      form.files.add(
        MapEntry(
          'Kehadiran.FileDataFormFile',
          await MultipartFile.fromFile(p, filename: p.split('/').last),
        ),
      );
    }
    return form;
  }
}

extension LaporanPayloadEntityX on LaporanPayloadEntity {
  LaporanPayloadModel toModel() => LaporanPayloadModel(
    tanggalLaporan: tanggalLaporan,
    jawaban: [
      for (final j in jawaban)
        {'idPertanyaan': j.idPertanyaan, 'jawaban': j.jawaban},
    ],
    jamMasuk: jamMasuk,
    jamPulang: jamPulang,
    keterangan: keterangan,
    fotoPaths: fotoPaths,
  );
}
