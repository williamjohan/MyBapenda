import 'package:equatable/equatable.dart';
import '../../../../../core/services/geo_location/i_geo_location_service.dart'; 
import '../../../../../domain/entities/pengiriman/antrean_entity.dart';
import '../../../../../domain/entities/pengiriman/master_pengiriman_entity.dart';
import '../../../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';

enum LokasiStatus { mencari, siap, gagal }

enum KirimStatus { idle, mengirim, sukses, gagal }

class AksiState extends Equatable {
  final LokasiStatus lokasiStatus;
  
  final GeoPosition? lokasi;
  
  final String? lokasiError;


  final bool requiresLocationSettings;

  final MasterPengirimanEntity? master;
  final bool masterGagal;

  final Map<FotoSlot, String> foto;

  /// Slot yang sedang memproses foto (kamera/stempel/kompres).
  final FotoSlot? fotoDiproses;

  final KirimStatus kirim;
  final String? error;
  final List<HasilCheckinEntity> hasil;

  /// Terisi bila aksi disimpan ke antrean offline (bukan langsung terkirim).
  final AntreanPengirimanEntity? antrean;

  const AksiState({
    this.lokasiStatus = LokasiStatus.mencari,
    this.lokasi,
    this.lokasiError,
    this.requiresLocationSettings = false, 
    this.master,
    this.masterGagal = false,
    this.foto = const {},
    this.fotoDiproses,
    this.kirim = KirimStatus.idle,
    this.error,
    this.hasil = const [],
    this.antrean,
  });

  bool get lokasiSiap => lokasiStatus == LokasiStatus.siap && lokasi != null;

  AksiState copyWith({
    LokasiStatus? lokasiStatus,
    GeoPosition? lokasi,
    String? lokasiError,
    bool? requiresLocationSettings, 
    MasterPengirimanEntity? master,
    bool? masterGagal,
    Map<FotoSlot, String>? foto,
    FotoSlot? fotoDiproses,
    bool hapusFotoDiproses = false,
    KirimStatus? kirim,
    String? error,
    List<HasilCheckinEntity>? hasil,
    AntreanPengirimanEntity? antrean,
  }) {
    return AksiState(
      lokasiStatus: lokasiStatus ?? this.lokasiStatus,
      lokasi: lokasi ?? this.lokasi,
      // Galat lokasi ikut berganti hanya saat status lokasi berubah.
      lokasiError: lokasiStatus != null
          ? lokasiError
          : (lokasiError ?? this.lokasiError),
      requiresLocationSettings: lokasiStatus != null
          ? (requiresLocationSettings ?? false)
          : (requiresLocationSettings ?? this.requiresLocationSettings),
      master: master ?? this.master,
      masterGagal: masterGagal ?? this.masterGagal,
      foto: foto ?? this.foto,
      fotoDiproses: hapusFotoDiproses
          ? null
          : (fotoDiproses ?? this.fotoDiproses),
      kirim: kirim ?? this.kirim,
      // Galat form/kirim di-reset tiap kali tidak diisi eksplisit.
      error: error,
      hasil: hasil ?? this.hasil,
      antrean: antrean ?? this.antrean,
    );
  }

  @override
  List<Object?> get props => [
    lokasiStatus,
    lokasi,
    lokasiError,
    requiresLocationSettings, 
    master,
    masterGagal,
    foto,
    fotoDiproses,
    kirim,
    error,
    hasil,
    antrean,
  ];
}