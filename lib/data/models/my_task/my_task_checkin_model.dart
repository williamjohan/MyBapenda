// lib/data/models/my_task/my_task_checkin_model.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_checkin_entity.dart';

class MyTaskCheckinPhotoModel {
  final String path;
  final double? latitude;
  final double? longitude;
  final String? alamat;

  const MyTaskCheckinPhotoModel({
    required this.path,
    this.latitude,
    this.longitude,
    this.alamat,
  });

  String get fileName => path.replaceAll('\\', '/').split('/').last;
}

class MyTaskCheckinRequestModel {
  final String jenis;
  final String key;
  final int status;
  final String? keyKirim;
  final String keterangan;
  final List<TaskPetugasEntity> petugas;
  final MyTaskCheckinPhotoModel? fotoCheckin;
  final MyTaskCheckinPhotoModel? fotoSebelum;
  final MyTaskCheckinPhotoModel? fotoSesudah;

  const MyTaskCheckinRequestModel({
    required this.jenis,
    required this.key,
    required this.status,
    required this.keyKirim,
    required this.keterangan,
    required this.petugas,
    required this.fotoCheckin,
    required this.fotoSebelum,
    required this.fotoSesudah,
  });

  /// Rakit multipart form sesuai nama field di Swagger.
  Future<FormData> toFormData() async {
    final form = FormData();

    void field(String name, String? value) {
      if (value != null) form.fields.add(MapEntry(name, value));
    }

    field('Jenis', jenis);
    field('Key', key);
    field('Status', '$status');
    field('KeyKirim', keyKirim);
    field('Keterangan', keterangan);
    field(
      'Petugas',
      jsonEncode([
        for (final p in petugas) {'nipPetugas': p.nip, 'opdPetugas': p.opd},
      ]),
    );

    // Foto: file + titik + alamat. Foto yang tidak ada dilewati.
    Future<void> photo(String prefix, MyTaskCheckinPhotoModel? p) async {
      if (p == null) return;
      form.files.add(
        MapEntry(
          '$prefix.FileDataFormFile',
          await MultipartFile.fromFile(p.path, filename: p.fileName),
        ),
      );
      if (p.latitude != null) field('$prefix.Latitude', '${p.latitude}');
      if (p.longitude != null) field('$prefix.Longitude', '${p.longitude}');
      field('$prefix.Alamat', p.alamat);
    }

    await photo('FotoCheckin', fotoCheckin);
    await photo('FotoSebelum', fotoSebelum);
    await photo('FotoSesudah', fotoSesudah);

    return form;
  }
}

extension MyTaskCheckinRequestEntityX on MyTaskCheckinRequestEntity {
  MyTaskCheckinRequestModel toModel() {
    MyTaskCheckinPhotoModel? photo(TaskCheckinPhotoEntity? p) => p == null
        ? null
        : MyTaskCheckinPhotoModel(
            path: p.path,
            latitude: p.latitude,
            longitude: p.longitude,
            alamat: p.alamat,
          );

    return MyTaskCheckinRequestModel(
      jenis: jenis,
      key: key,
      status: status,
      keyKirim: keyKirim,
      keterangan: keterangan,
      petugas: petugas,
      fotoCheckin: photo(fotoCheckin),
      fotoSebelum: photo(fotoSebelum),
      fotoSesudah: photo(fotoSesudah),
    );
  }
}
