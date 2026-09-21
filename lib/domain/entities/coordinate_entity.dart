import 'package:equatable/equatable.dart';

class CoordinateEntity extends Equatable {
  final double latitude;
  final double longitude;

  const CoordinateEntity({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
