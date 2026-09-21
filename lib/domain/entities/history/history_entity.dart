import 'package:equatable/equatable.dart';

class HistoryEntity extends Equatable {
  final String key;
  final String longitude;
  final String latitude;
  final String alamat;

  final double? panjang;
  final double? lebar;
  final double? tinggi;

  final DateTime insDate;
  final String insBy;

  final String? photoUrl;

  const HistoryEntity({
    required this.key,
    required this.longitude,
    required this.latitude,
    required this.alamat,
    this.panjang,
    this.lebar,
    this.tinggi,
    required this.insDate,
    required this.insBy,
    this.photoUrl,
  });

  double get lat => double.tryParse(latitude) ?? 0;

  double get lng => double.tryParse(longitude) ?? 0;

  bool get hasUkuran => panjang != null || lebar != null || tinggi != null;

  String? get ukuran {
    if (!hasUkuran) return null;

    final values = <String>[];

    if (panjang != null) {
      values.add('P ${_formatNumber(panjang!)}');
    }

    if (lebar != null) {
      values.add('L ${_formatNumber(lebar!)}');
    }

    if (tinggi != null) {
      values.add('T ${_formatNumber(tinggi!)}');
    }

    return values.join(' x ');
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  String get coordinateLabel => '$latitude, $longitude';

  @override
  List<Object?> get props => [
    key,
    longitude,
    latitude,
    alamat,
    panjang,
    lebar,
    tinggi,
    insDate,
    insBy,
    photoUrl,
  ];
}
