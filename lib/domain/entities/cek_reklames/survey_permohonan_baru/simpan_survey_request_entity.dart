import 'dart:io';
import 'package:equatable/equatable.dart';

class SimpanSurveyRequestEntity extends Equatable {
  final String key;
  final String tglSurvey; 
  final String kecamatan;
  final String kelurahan;
  final String lokBlok;
  final String lokRt;
  final String lokRw;
  final String latitude;
  final String longitude;
  final List<SisiRequestEntity> sisiList;
  final CheckinRequestEntity checkin;

  const SimpanSurveyRequestEntity({
    required this.key,
    required this.tglSurvey,
    required this.kecamatan,
    required this.kelurahan,
    required this.lokBlok,
    required this.lokRt,
    required this.lokRw,
    required this.latitude,
    required this.longitude,
    required this.sisiList,
    required this.checkin,
  });

  @override
  List<Object?> get props => [
    key,
    tglSurvey,
    kecamatan,
    kelurahan,
    lokBlok,
    lokRt,
    lokRw,
    latitude,
    longitude,
    sisiList,
    checkin,
  ];
}

class CheckinRequestEntity extends Equatable {
  final File fileDataFormFile;
  final String latitude;
  final String longitude;
  final String alamat;
  final List<String> nipPembantu;

  const CheckinRequestEntity({
    required this.fileDataFormFile,
    required this.latitude,
    required this.longitude,
    required this.alamat,
    this.nipPembantu = const [],
  });

  @override
  List<Object?> get props => [
    fileDataFormFile,
    latitude,
    longitude,
    alamat,
    nipPembantu,
  ];
}

class NorBaruRequestEntity extends Equatable {
  final String? idPersil;
  final int? jenisBangunanId;
  final int? jalanId;
  final String noAlamat;

  const NorBaruRequestEntity({
    required this.idPersil,
    required this.jenisBangunanId,
    required this.jalanId,
    required this.noAlamat,
  });

  @override
  List<Object?> get props => [idPersil, jenisBangunanId, jalanId, noAlamat];
}

class FotoRequestEntity extends Equatable {
  final File file;
  final String keterangan;

  const FotoRequestEntity({required this.file, required this.keterangan});

  @override
  List<Object?> get props => [file, keterangan];
}

class SisiRequestEntity extends Equatable {
  final int seq;
  final String? idNor;
  final String? idPersil;
  final int lokasiTertentuId;
  final int letakReklame;
  final int statusTanah;
  final String lokPenyelenggaraan;
  final double panjang;
  final double lebar;
  final double tinggi;
  final int idJenisReklame;
  final int idJenisProduk;
  final int sudutPandang;
  final String ketSisi;
  final String materiReklame;
  final String ketSurvey;
  final NorBaruRequestEntity? norBaru;
  final List<FotoRequestEntity> fotos;

  const SisiRequestEntity({
    required this.seq,
    this.idNor,
    this.idPersil,
    required this.lokasiTertentuId,
    required this.letakReklame,
    required this.statusTanah,
    required this.lokPenyelenggaraan,
    required this.panjang,
    required this.lebar,
    required this.tinggi,
    required this.idJenisReklame,
    required this.idJenisProduk,
    required this.sudutPandang,
    required this.ketSisi,
    required this.materiReklame,
    required this.ketSurvey,
    this.norBaru,
    this.fotos = const [],
  });

  @override
  List<Object?> get props => [
    seq,
    idNor,
    idPersil,
    lokasiTertentuId,
    letakReklame,
    statusTanah,
    lokPenyelenggaraan,
    panjang,
    lebar,
    tinggi,
    idJenisReklame,
    idJenisProduk,
    sudutPandang,
    ketSisi,
    materiReklame,
    ketSurvey,
    norBaru,
    fotos,
  ];
}
