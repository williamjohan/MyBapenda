// lib/data/models/balai_rw/laporan_payload_model.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../domain/entities/balai_rw/laporan_payload_entity.dart';

Future<MultipartFile> _file(String path) =>
    MultipartFile.fromFile(path, filename: path.split('/').last);

class CheckinPayloadModel {
  final String tanggalLaporan;
  final String waktuCheckIn;
  final String fotoPath;
  final double? latitude;
  final double? longitude;

  const CheckinPayloadModel({
    required this.tanggalLaporan,
    required this.waktuCheckIn,
    required this.fotoPath,
    this.latitude,
    this.longitude,
  });

  Future<FormData> toFormData() async {
    final f = FormData();
    f.fields
      ..add(MapEntry('WaktuCheckIn', waktuCheckIn))
      ..add(MapEntry('TanggalLaporan', tanggalLaporan));
    if (latitude != null) f.fields.add(MapEntry('Latitude', '$latitude'));
    if (longitude != null) f.fields.add(MapEntry('Longitude', '$longitude'));
    f.files.add(MapEntry('FileDataFormFile', await _file(fotoPath)));
    return f;
  }
}

class CheckoutPayloadModel {
  final String tanggalLaporan;
  final String fotoPath;
  final double latitude;
  final double longitude;

  const CheckoutPayloadModel({
    required this.tanggalLaporan,
    required this.fotoPath,
    required this.latitude,
    required this.longitude,
  });

  Future<FormData> toFormData() async {
    final f = FormData();
    f.fields
      ..add(MapEntry('TanggalLaporan', tanggalLaporan))
      ..add(MapEntry('Latitude', '$latitude'))
      ..add(MapEntry('Longitude', '$longitude'));
    f.files.add(MapEntry('FileDataFormFile', await _file(fotoPath)));
    return f;
  }
}

class LaporanPayloadModel {
  final String tanggalLaporan;
  final List<Map<String, dynamic>> jawaban;

  const LaporanPayloadModel({
    required this.tanggalLaporan,
    required this.jawaban,
  });

  Future<FormData> toFormData() async {
    final f = FormData();
    f.fields
      ..add(MapEntry('TanggalLaporan', tanggalLaporan))
      ..add(MapEntry('Jawaban', jsonEncode(jawaban)));
    return f;
  }
}

extension CheckinPayloadEntityX on CheckinPayloadEntity {
  CheckinPayloadModel toModel() => CheckinPayloadModel(
        tanggalLaporan: tanggalLaporan,
        waktuCheckIn: waktuCheckIn,
        fotoPath: fotoPath,
        latitude: latitude,
        longitude: longitude,
      );
}

extension CheckoutPayloadEntityX on CheckoutPayloadEntity {
  CheckoutPayloadModel toModel() => CheckoutPayloadModel(
        tanggalLaporan: tanggalLaporan,
        fotoPath: fotoPath,
        latitude: latitude,
        longitude: longitude,
      );
}

extension LaporanPayloadEntityX on LaporanPayloadEntity {
  LaporanPayloadModel toModel() => LaporanPayloadModel(
        tanggalLaporan: tanggalLaporan,
        jawaban: [
          for (final j in jawaban)
            {'idPertanyaan': j.idPertanyaan, 'jawaban': j.jawaban},
        ],
      );
}
