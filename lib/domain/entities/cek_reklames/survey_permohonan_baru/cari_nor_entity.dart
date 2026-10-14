

import 'package:equatable/equatable.dart';

class CariNorEntity extends Equatable {
  final String idNor;
  final String idPersil;
  final String nopPbb;
  final int idJenisBangunan;
  final String jenisBangunan;
  final int idJalan;
  final String namaJalan;
  final String noAlamat;


  const CariNorEntity({
    required this.idNor,
    required this.idPersil,
    required this.nopPbb,
    required this.idJenisBangunan,
    required this.jenisBangunan,
    required this.idJalan,
    required this.namaJalan,
    required this.noAlamat,
  });

  @override
  List<Object?> get props => [
        idNor,
        idPersil,
        nopPbb,
        idJenisBangunan,
        jenisBangunan,
        idJalan,
        namaJalan,
        noAlamat,
      ];
}

// ====================================================================
//  EXTENSION: UI LOGIC HELPERS 
// ====================================================================

extension CariNorEntityHelper on CariNorEntity {
  
  // 1. Cek Ketersediaan NOR
  // Berguna untuk menampilkan state "NOR Ditemukan" atau menyembunyikan form
  bool get isNorFound => idNor.trim().isNotEmpty;

  // 2. Cek Status Persil
  // Berguna untuk memunculkan badge "Persil" atau field khusus Persil
  bool get isPersil => idPersil.trim().isNotEmpty;

  // 3. Cek Ketersediaan NOP PBB
  bool get hasNopPbb => nopPbb.trim().isNotEmpty;

  // 4. Cek Validitas Bangunan & Jalan (Asumsi ID > 0 adalah valid)
  bool get hasJenisBangunan => idJenisBangunan > 0 && jenisBangunan.isNotEmpty;
  bool get hasJalan => idJalan > 0 && namaJalan.isNotEmpty;

  // 5. Helper UI: Alamat Lengkap (Menggabungkan jalan dan nomor secara cerdas)
  // Tidak perlu lagi repot merakit string di dalam Widget UI
  String get alamatLengkap {
    if (!hasJalan) return 'Alamat tidak diketahui';
    final nomor = noAlamat.trim().isNotEmpty ? ' No. $noAlamat' : '';
    return '$namaJalan$nomor';
  }

  // 6. Helper Komposit: Status Kelengkapan Data
  bool get isDataLengkap => isNorFound && hasJalan && hasJenisBangunan;
}