import 'package:equatable/equatable.dart';

enum SurveyInfoMessageType { info, success, error }

class SurveyInfoState extends Equatable {
  // Petugas
  final String? nipPetugas;
  final String? namaPetugas;
  final String? nipPetugasPembantu;
  final String? namaPetugasPembantu;

  // Foto
  final String? originalPhotoPath;
  final String? selfiePath;
  final DateTime? photoCapturedAt;
  final bool isPhotoStamped;

  // Lokasi GPS
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime? gpsTime;

  // Reverse geocoding dan wilayah (ID dari API berupa String)
  final String address;
  final String? kecamatanId;
  final String? kelurahanId;
  final String? rt;
  final String? rw;

  // Status UI
  final bool isLocating;
  final bool isStamping;
  final String? message;
  final SurveyInfoMessageType? messageType;

  const SurveyInfoState({
    this.nipPetugas,
    this.namaPetugas,
    this.nipPetugasPembantu,
    this.namaPetugasPembantu,
    this.originalPhotoPath,
    this.selfiePath,
    this.photoCapturedAt,
    this.isPhotoStamped = false,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.gpsTime,
    this.address = '-',
    this.kecamatanId,
    this.kelurahanId,
    this.isLocating = false,
    this.isStamping = false,
    this.message,
    this.messageType,
    this.rt,
    this.rw,
  });

  SurveyInfoState copyWith({
    String? nipPetugas,
    String? namaPetugas,
    String? nipPetugasPembantu,
    String? namaPetugasPembantu,
    String? originalPhotoPath,
    String? selfiePath,
    DateTime? photoCapturedAt,
    bool? isPhotoStamped,
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? gpsTime,
    String? address,
    String? rt,
    String? rw,
    String? kecamatanId,
    String? kelurahanId,
    bool? isLocating,
    bool? isStamping,
    String? message,
    SurveyInfoMessageType? messageType,
    bool clearPetugasPembantu = false,
    bool clearLocation = false,
    bool clearKecamatan = false,
    bool clearKelurahan = false,
    bool clearMessage = false,
  }) {
    return SurveyInfoState(
      nipPetugas: nipPetugas ?? this.nipPetugas,
      namaPetugas: namaPetugas ?? this.namaPetugas,
      nipPetugasPembantu: clearPetugasPembantu ? null : nipPetugasPembantu ?? this.nipPetugasPembantu,
      namaPetugasPembantu: clearPetugasPembantu ? null : namaPetugasPembantu ?? this.namaPetugasPembantu,

      originalPhotoPath: originalPhotoPath ?? this.originalPhotoPath,
      selfiePath: selfiePath ?? this.selfiePath,
      photoCapturedAt: photoCapturedAt ?? this.photoCapturedAt,
      isPhotoStamped: isPhotoStamped ?? this.isPhotoStamped,

      latitude: clearLocation ? null : latitude ?? this.latitude,
      longitude: clearLocation ? null : longitude ?? this.longitude,
      accuracy: clearLocation ? null : accuracy ?? this.accuracy,
      gpsTime: clearLocation ? null : gpsTime ?? this.gpsTime,

      address: clearLocation ? '-' : address ?? this.address,
      rt: clearLocation ? null : rt ?? this.rt,
      rw: clearLocation ? null : rw ?? this.rw,

      kecamatanId: clearKecamatan ? null : kecamatanId ?? this.kecamatanId,
      kelurahanId: clearKelurahan ? null : kelurahanId ?? this.kelurahanId,

      isLocating: isLocating ?? this.isLocating,
      isStamping: isStamping ?? this.isStamping,

      message: clearMessage ? null : message ?? this.message,
      messageType: clearMessage ? null : messageType ?? this.messageType,
    );
  }

  @override
  List<Object?> get props => [
    nipPetugas,
    namaPetugas,
    nipPetugasPembantu,
    namaPetugasPembantu,
    originalPhotoPath,
    selfiePath,
    photoCapturedAt,
    isPhotoStamped,
    latitude,
    longitude,
    accuracy,
    gpsTime,
    address,
    rt,
    rw,
    kecamatanId,
    kelurahanId,
    isLocating,
    isStamping,
    message,
    messageType,
  ];
}
