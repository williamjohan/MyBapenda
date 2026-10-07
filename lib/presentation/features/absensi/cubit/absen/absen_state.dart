import 'package:equatable/equatable.dart';

import '../../../../../core/services/geo_location_service.dart';
import '../../../../../domain/entities/absensi/absen_entity.dart';

enum AbsenStep { locating, submitting }

sealed class AbsenState extends Equatable {
  const AbsenState();
  @override
  List<Object?> get props => [];
}

class AbsenIdle extends AbsenState {
  const AbsenIdle();
}

class AbsenInProgress extends AbsenState {
  final AbsenStep step;
  const AbsenInProgress(this.step);
  @override
  List<Object?> get props => [step];
}

class AbsenSuccess extends AbsenState {
  final AbsenResultEntity result;
  const AbsenSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

/// GPS mati / izin lokasi ditolak → layar menampilkan dialog pengaturan.
class AbsenLocationRequired extends AbsenState {
  final GeoLocationError reason;
  const AbsenLocationRequired(this.reason);
  @override
  List<Object?> get props => [reason];
}

class AbsenFailure extends AbsenState {
  /// Pesan dari API ditampilkan apa adanya.
  final String message;
  const AbsenFailure(this.message);
  @override
  List<Object?> get props => [message];
}
