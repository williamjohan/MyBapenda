import 'package:equatable/equatable.dart';

class HistoryEntity extends Equatable {
  final String key;
  final String longitude;
  final String latitude;
  final String alamat;
  final DateTime insDate;
  final String insBy;
  final String? ukuran;
  final String? photoUrl;

  const HistoryEntity({
    required this.key,
    required this.longitude,
    required this.latitude,
    required this.alamat,
    required this.insDate,
    required this.insBy,
    this.ukuran,
    this.photoUrl,
  });

  double get lat => double.tryParse(latitude) ?? 0;
  double get lng => double.tryParse(longitude) ?? 0;

  bool get hasUkuran => ukuran != null && ukuran!.trim().isNotEmpty;
  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  String get coordinateLabel => '$latitude, $longitude';

  @override
  List<Object?> get props => [
        key,
        longitude,
        latitude,
        alamat,
        insDate,
        insBy,
        ukuran,
        photoUrl,
      ];
}