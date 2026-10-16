import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/va_qris/tax_object_entity.dart';
import '../../../presentation/shared/master_data/data/models/paged_master_data_model.dart';

part 'tax_object_model.g.dart';

/// Satu baris `items` dari `/api/pembayaran/cari-objek`.
@JsonSerializable()
class TaxObjectModel {
  @JsonKey(name: 'jenisPajak', defaultValue: 0)
  final int jenisPajak;

  @JsonKey(name: 'jenisPajakNama', defaultValue: '')
  final String jenisPajakNama;

  @JsonKey(name: 'nop', defaultValue: '')
  final String nop;

  @JsonKey(name: 'nama', defaultValue: '')
  final String nama;

  @JsonKey(name: 'alamat', defaultValue: '')
  final String alamat;

  const TaxObjectModel({
    required this.jenisPajak,
    required this.jenisPajakNama,
    required this.nop,
    required this.nama,
    required this.alamat,
  });

  factory TaxObjectModel.fromJson(Map<String, dynamic> json) =>
      _$TaxObjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxObjectModelToJson(this);
}

/// Satu baris `perJenisPajak` dari `/api/pembayaran/cari-objek`.
@JsonSerializable()
class TaxTypeCountModel {
  @JsonKey(name: 'jenisPajak', defaultValue: 0)
  final int jenisPajak;

  @JsonKey(name: 'jenisPajakNama', defaultValue: '')
  final String jenisPajakNama;

  @JsonKey(name: 'jumlah', defaultValue: 0)
  final int jumlah;

  const TaxTypeCountModel({
    required this.jenisPajak,
    required this.jenisPajakNama,
    required this.jumlah,
  });

  factory TaxTypeCountModel.fromJson(Map<String, dynamic> json) =>
      _$TaxTypeCountModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxTypeCountModelToJson(this);
}

/// Response `/api/pembayaran/cari-objek`: halaman hasil (bentuk [PagedModel])
/// + jumlah per jenis pajak.
class TaxObjectSearchModel {
  final PagedModel<TaxObjectModel> page;
  final List<TaxTypeCountModel> perJenisPajak;

  const TaxObjectSearchModel({required this.page, required this.perJenisPajak});

  factory TaxObjectSearchModel.fromJson(
    Map<String, dynamic> json,
  ) => TaxObjectSearchModel(
    page: PagedModel<TaxObjectModel>.fromJson(json, TaxObjectModel.fromJson),
    perJenisPajak: ((json['perJenisPajak'] as List?) ?? const [])
        .map(
          (e) =>
              TaxTypeCountModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
  );
}

extension TaxObjectModelX on TaxObjectModel {
  TaxObjectEntity toEntity() => TaxObjectEntity(
    taxTypeId: jenisPajak,
    taxTypeName: jenisPajakNama,
    nop: nop,
    name: nama,
    address: alamat,
  );
}

extension TaxObjectSearchModelX on TaxObjectSearchModel {
  TaxObjectSearchResultEntity toEntity() => TaxObjectSearchResultEntity(
    page: page.toEntity((e) => e.toEntity()),
    typeCounts: perJenisPajak
        .map(
          (e) => TaxTypeCountEntity(
            taxTypeId: e.jenisPajak,
            taxTypeName: e.jenisPajakNama,
            count: e.jumlah,
          ),
        )
        .toList(),
  );
}
