import 'package:equatable/equatable.dart';
import '../../../presentation/shared/master_data/domain/entities/paged_master_entities.dart';

/// Objek pajak hasil "Cari objek pajak" (`/api/pembayaran/cari-objek`).
/// [taxTypeId] + [nop] langsung dipakai untuk mencari tagihan.
class TaxObjectEntity extends Equatable {
  const TaxObjectEntity({
    required this.taxTypeId,
    required this.taxTypeName,
    required this.nop,
    required this.name,
    required this.address,
  });

  final int taxTypeId;
  final String taxTypeName;

  /// NOP berformat titik dari API.
  final String nop;
  final String name;
  final String address;

  @override
  List<Object?> get props => [taxTypeId, taxTypeName, nop, name, address];
}

/// Jumlah hasil pencarian untuk satu jenis pajak (chip filter).
class TaxTypeCountEntity extends Equatable {
  const TaxTypeCountEntity({
    required this.taxTypeId,
    required this.taxTypeName,
    required this.count,
  });

  final int taxTypeId;
  final String taxTypeName;
  final int count;

  @override
  List<Object?> get props => [taxTypeId, taxTypeName, count];
}

/// Satu halaman hasil "Cari objek pajak". [page] mengikuti filter jenis pajak;
/// [typeCounts] selalu tanpa filter (urut jumlah terbanyak, dari API).
class TaxObjectSearchResultEntity extends Equatable {
  const TaxObjectSearchResultEntity({
    required this.page,
    required this.typeCounts,
  });

  final PagedResultEntity<TaxObjectEntity> page;
  final List<TaxTypeCountEntity> typeCounts;

  @override
  List<Object?> get props => [page, typeCounts];
}
