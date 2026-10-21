// lib/core/errors/failure.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ======================
// Network / Server
// ======================

class ServerFailure extends Failure {
  const ServerFailure([String? message])
    : super(message ?? "Terjadi kesalahan pada server.");
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String? message])
    : super(message ?? "Sesi Anda telah berakhir. Silakan login kembali.");
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([String? message])
    : super(
        message ??
            "Permintaan ke server melebihi batas waktu. Silakan coba lagi.",
      );
}

class NoInternetFailure extends Failure {
  const NoInternetFailure([String? message])
    : super(message ?? "Tidak ada koneksi internet. Periksa jaringan Anda.");
}

// ======================
// File / Upload
// ======================

class FileFailure extends Failure {
  const FileFailure([String? message])
    : super(message ?? "Terjadi kesalahan pada file.");
}

class FileTooLargeFailure extends FileFailure {
  const FileTooLargeFailure([String? message])
    : super(message ?? "Ukuran file terlalu besar.");
}

class UnsupportedFileTypeFailure extends FileFailure {
  const UnsupportedFileTypeFailure([String? message])
    : super(message ?? "Jenis file tidak didukung.");
}

class FileUploadFailedFailure extends FileFailure {
  const FileUploadFailedFailure([String? message])
    : super(message ?? "Gagal mengunggah file.");
}

// ======================
// PDF / Storage
// ======================

class PdfFailure extends Failure {
  const PdfFailure([String? message])
    : super(message ?? "Terjadi kesalahan pada dokumen PDF.");
}

class PdfGenerationFailure extends PdfFailure {
  const PdfGenerationFailure([String? message])
    : super(message ?? "Gagal membuat file PDF.");
}

class StoragePermissionFailure extends Failure {
  const StoragePermissionFailure([String? message])
    : super(message ?? "Izin penyimpanan diperlukan untuk melanjutkan.");
}

class FileWriteFailure extends Failure {
  const FileWriteFailure([String? message])
    : super(message ?? "Gagal menyimpan file ke perangkat.");
}

class DownloadCancelledFailure extends Failure {
  const DownloadCancelledFailure([String? message]) : super(message ?? 'Unduhan dibatalkan');
}

// ======================
// Parsing / Data
// ======================

class ParsingFailure extends Failure {
  const ParsingFailure([String? message])
    : super(message ?? "Gagal memproses data dari server.");
}

class InvalidDataFailure extends Failure {
  const InvalidDataFailure([String? message])
    : super(message ?? "Data yang diterima tidak valid.");
}

// ======================
// Permission / Feature
// ======================

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([String? message])
    : super(message ?? "Akses ditolak. Izin tidak diberikan.");
}

class FeatureNotAvailableFailure extends Failure {
  const FeatureNotAvailableFailure([String? message])
    : super(message ?? "Fitur ini tidak tersedia di perangkat Anda.");
}

class PermissionFailure extends Failure {
  const PermissionFailure([String? message])
    : super(message ?? "Izin akses ke fitur perangkat tidak diberikan.");
}

// ======================
// Cache / Local Storage
// ======================

class CacheFailure extends Failure {
  const CacheFailure([String? message])
    : super(message ?? "Gagal memproses data lokal.");
}

// ======================
// Location / Maps
// ======================

class GeocodingFailure extends Failure {
  const GeocodingFailure([String? message])
    : super(message ?? "Gagal menemukan alamat dari titik koordinat tersebut.");
}

class LocationNotFoundFailure extends Failure {
  const LocationNotFoundFailure([String? message])
    : super(message ?? "Alamat atau nama tempat tidak ditemukan.");
}

class LocationHardwareFailure extends Failure {
  const LocationHardwareFailure([String? message])
    : super(message ?? "Terjadi masalah pada sensor GPS atau perangkat keras lokasi.");
}

// ======================
// Validation Failures (Base)
// ======================

abstract class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class FieldValidationFailure extends ValidationFailure {
  final String fieldName;

  const FieldValidationFailure(this.fieldName, String message) : super(message);

  @override
  List<Object?> get props => [fieldName, message];
}

// ======================
// Fallback
// ======================

class UnknownFailure extends Failure {
  const UnknownFailure([String? message])
    : super(message ?? "Terjadi kesalahan. Silakan coba lagi.");
}