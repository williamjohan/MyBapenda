import 'package:equatable/equatable.dart';

/// Kode jenis notifikasi petugas (`M_NOTIF_PEGAWAI_JENIS.KODE`).
abstract final class KodeNotifikasi {
  static const suratDitugaskan = 'SURAT_DITUGASKAN';
}

/// Satu notifikasi di kotak masuk petugas (`GET /api/notifikasi/inbox`).
class NotifikasiEntity extends Equatable {
  final int id;
  final String kodeJenis;
  final String namaJenis;

  /// Referensi sumber, mis. no resi berkas pengiriman.
  final String? reffNo;
  final String judul;
  final String isi;
  final DateTime? tglNotifikasi;
  final bool dibaca;
  final DateTime? tglBaca;

  const NotifikasiEntity({
    required this.id,
    required this.kodeJenis,
    required this.namaJenis,
    this.reffNo,
    required this.judul,
    required this.isi,
    this.tglNotifikasi,
    required this.dibaca,
    this.tglBaca,
  });

  /// No resi berkas yang dibuka saat notifikasi di-tap; null bila jenisnya
  /// tidak terkait berkas.
  String? get noResiBerkas =>
      kodeJenis == KodeNotifikasi.suratDitugaskan &&
          (reffNo?.trim().isNotEmpty ?? false)
      ? reffNo!.trim()
      : null;

  NotifikasiEntity tandaiDibaca(DateTime waktu) => NotifikasiEntity(
    id: id,
    kodeJenis: kodeJenis,
    namaJenis: namaJenis,
    reffNo: reffNo,
    judul: judul,
    isi: isi,
    tglNotifikasi: tglNotifikasi,
    dibaca: true,
    tglBaca: tglBaca ?? waktu,
  );

  @override
  List<Object?> get props => [
    id,
    kodeJenis,
    namaJenis,
    reffNo,
    judul,
    isi,
    tglNotifikasi,
    dibaca,
    tglBaca,
  ];
}

/// Satu halaman kotak masuk.
class HalamanNotifikasiEntity extends Equatable {
  final List<NotifikasiEntity> items;
  final int page;
  final int totalPage;
  final int totalData;

  const HalamanNotifikasiEntity({
    required this.items,
    required this.page,
    required this.totalPage,
    required this.totalData,
  });

  bool get adaLagi => page < totalPage;

  @override
  List<Object?> get props => [items, page, totalPage, totalData];
}
