import 'package:equatable/equatable.dart';

sealed class LaporanState extends Equatable {
  const LaporanState();
  @override
  List<Object?> get props => [];
}

class LaporanIdle extends LaporanState {
  const LaporanIdle();
}

class LaporanDownloading extends LaporanState {
  /// 0..1, null jika server tidak mengirim Content-Length.
  final double? progress;
  const LaporanDownloading(this.progress);
  @override
  List<Object?> get props => [progress];
}

class LaporanSuccess extends LaporanState {
  final String filePath;
  const LaporanSuccess(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

class LaporanFailure extends LaporanState {
  final String message;
  const LaporanFailure(this.message);
  @override
  List<Object?> get props => [message];
}
