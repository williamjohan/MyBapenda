import 'dart:io';
import 'package:equatable/equatable.dart';

class SimpanSurveyRequestEntity extends Equatable {
  final String key;
  final String tglSurvey;
  final String tim;
  final String kecamatan;
  final String kelurahan;
  final String noImb;
  final String lokNo;
  final String lokBlok;
  final String lokRt;
  final String lokRw;
  final String latitude;
  final String longitude;
  final SisiListRequestEntity sisiList;
  final CheckinRequestEntity checkin;

  const SimpanSurveyRequestEntity({
    required this.key,
    required this.tglSurvey,
    required this.tim,
    required this.kecamatan,
    required this.kelurahan,
    required this.noImb,
    required this.lokNo,
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
        key, tglSurvey, tim, kecamatan, kelurahan, noImb, lokNo,
        lokBlok, lokRt, lokRw, latitude, longitude, sisiList, checkin,
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
  List<Object?> get props => [fileDataFormFile, latitude, longitude, alamat, nipPembantu];
}

class SisiListRequestEntity extends Equatable {
  final int seq;
  final String idNor;
  final String lokPenyelenggaraan;
  // ... tambahkan yang lain
  
  const SisiListRequestEntity({
    required this.seq,
    required this.idNor,
    required this.lokPenyelenggaraan,
  });

  @override
  List<Object?> get props => [seq, idNor, lokPenyelenggaraan];
}