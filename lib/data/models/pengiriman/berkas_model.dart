import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/pengiriman/berkas_entity.dart';
import '../../../domain/entities/pengiriman/jejak_entity.dart';
import 'pengiriman_json_util.dart';

part 'berkas_model.g.dart';

@JsonSerializable()
class FotoJejakModel {
  @JsonKey(name: 'key')
  final String key;
  @JsonKey(name: 'jenisFoto', fromJson: jsonAsString)
  final String? jenisFoto;

  const FotoJejakModel({required this.key, this.jenisFoto});

  factory FotoJejakModel.fromJson(Map<String, dynamic> json) =>
      _$FotoJejakModelFromJson(json);

  Map<String, dynamic> toJson() => _$FotoJejakModelToJson(this);
}

/// Jejak dari `detail` dan `lacak` (monitoring menambah foto & flag).
@JsonSerializable()
class JejakModel {
  @JsonKey(name: 'statusId')
  final int? statusId;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'sumber', fromJson: jsonAsString)
  final String? sumber;
  @JsonKey(name: 'nip')
  final String? nip;
  @JsonKey(name: 'namaPetugas')
  final String? namaPetugas;
  @JsonKey(name: 'tglCheckin')
  final String? tglCheckin;
  @JsonKey(name: 'latitude')
  final double? latitude;
  @JsonKey(name: 'longitude')
  final double? longitude;
  @JsonKey(name: 'akurasi')
  final double? akurasi;
  @JsonKey(name: 'jarakKeTujuan')
  final double? jarakKeTujuan;
  @JsonKey(name: 'keterangan')
  final String? keterangan;
  @JsonKey(name: 'diabaikan', fromJson: jsonAsBool)
  final bool diabaikan;
  @JsonKey(name: 'perluReview', fromJson: jsonAsBool)
  final bool perluReview;
  @JsonKey(name: 'jumlahFoto', defaultValue: 0)
  final int jumlahFoto;
  @JsonKey(name: 'foto', defaultValue: <FotoJejakModel>[])
  final List<FotoJejakModel> foto;
  @JsonKey(name: 'flagAkurasi', fromJson: jsonAsBool)
  final bool flagAkurasi;
  @JsonKey(name: 'flagWaktu', fromJson: jsonAsBool)
  final bool flagWaktu;
  @JsonKey(name: 'percobaanKe')
  final int? percobaanKe;

  const JejakModel({
    this.statusId,
    this.status,
    this.sumber,
    this.nip,
    this.namaPetugas,
    this.tglCheckin,
    this.latitude,
    this.longitude,
    this.akurasi,
    this.jarakKeTujuan,
    this.keterangan,
    this.diabaikan = false,
    this.perluReview = false,
    this.jumlahFoto = 0,
    this.foto = const [],
    this.flagAkurasi = false,
    this.flagWaktu = false,
    this.percobaanKe,
  });

  factory JejakModel.fromJson(Map<String, dynamic> json) =>
      _$JejakModelFromJson(json);

  Map<String, dynamic> toJson() => _$JejakModelToJson(this);
}

/// `BerkasItem` dari `GET daftar`.
@JsonSerializable()
class BerkasModel {
  @JsonKey(name: 'noResi')
  final String noResi;
  @JsonKey(name: 'jenisKode')
  final String? jenisKode;
  @JsonKey(name: 'jenisNama')
  final String? jenisNama;
  @JsonKey(name: 'noSurat')
  final String? noSurat;
  @JsonKey(name: 'tglSurat')
  final String? tglSurat;
  @JsonKey(name: 'noReferensi')
  final String? noReferensi;
  @JsonKey(name: 'npwpd')
  final String? npwpd;
  @JsonKey(name: 'namaWp', defaultValue: '-')
  final String namaWp;
  @JsonKey(name: 'statusId')
  final int? statusId;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'modeTempel', fromJson: jsonAsBool)
  final bool modeTempel;
  @JsonKey(name: 'percobaanKe', defaultValue: 0)
  final int percobaanKe;
  @JsonKey(name: 'jumlahGagal', defaultValue: 0)
  final int jumlahGagal;
  @JsonKey(name: 'jenisTujuan', fromJson: jsonAsString)
  final String? jenisTujuan;
  @JsonKey(name: 'alamatTujuan', defaultValue: '-')
  final String alamatTujuan;
  @JsonKey(name: 'latTujuan')
  final double? latTujuan;
  @JsonKey(name: 'longTujuan')
  final double? longTujuan;
  @JsonKey(name: 'penanggungJawab', fromJson: jsonAsBool)
  final bool penanggungJawab;
  @JsonKey(name: 'tglDitugaskan')
  final String? tglDitugaskan;
  @JsonKey(name: 'tglBatasSla')
  final String? tglBatasSla;
  @JsonKey(name: 'terlambat', fromJson: jsonAsBool)
  final bool terlambat;
  @JsonKey(name: 'perluDikembalikan', fromJson: jsonAsBool)
  final bool perluDikembalikan;
  @JsonKey(name: 'wajibFotoObjek', fromJson: jsonAsBool)
  final bool wajibFotoObjek;
  @JsonKey(name: 'aksi', defaultValue: <String>[])
  final List<String> aksi;

  const BerkasModel({
    required this.noResi,
    this.jenisKode,
    this.jenisNama,
    this.noSurat,
    this.tglSurat,
    this.noReferensi,
    this.npwpd,
    required this.namaWp,
    this.statusId,
    this.status,
    this.modeTempel = false,
    required this.percobaanKe,
    required this.jumlahGagal,
    this.jenisTujuan,
    required this.alamatTujuan,
    this.latTujuan,
    this.longTujuan,
    this.penanggungJawab = false,
    this.tglDitugaskan,
    this.tglBatasSla,
    this.terlambat = false,
    this.perluDikembalikan = false,
    this.wajibFotoObjek = false,
    required this.aksi,
  });

  factory BerkasModel.fromJson(Map<String, dynamic> json) =>
      _$BerkasModelFromJson(json);

  Map<String, dynamic> toJson() => _$BerkasModelToJson(this);
}

/// `GET detail`: field BerkasItem (rata di objek yang sama) + tambahan.
@JsonSerializable()
class BerkasDetailModel {
  @JsonKey(name: 'berkas', readValue: jsonSelf, includeToJson: false)
  final BerkasModel berkas;
  @JsonKey(name: 'alamatWp')
  final String? alamatWp;
  @JsonKey(name: 'caraSerah', fromJson: jsonAsString)
  final String? caraSerah;
  @JsonKey(name: 'tglTerima')
  final String? tglTerima;
  @JsonKey(name: 'namaPenerima')
  final String? namaPenerima;
  @JsonKey(name: 'jejak', defaultValue: <JejakModel>[])
  final List<JejakModel> jejak;

  const BerkasDetailModel({
    required this.berkas,
    this.alamatWp,
    this.caraSerah,
    this.tglTerima,
    this.namaPenerima,
    required this.jejak,
  });

  factory BerkasDetailModel.fromJson(Map<String, dynamic> json) =>
      _$BerkasDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$BerkasDetailModelToJson(this);
}

extension FotoJejakModelX on FotoJejakModel {
  FotoJejakEntity toEntity() => FotoJejakEntity(key: key, jenisFoto: jenisFoto);
}

extension JejakModelX on JejakModel {
  JejakEntity toEntity() {
    final s = StatusBerkas.fromId(statusId);
    return JejakEntity(
      status: s,
      statusNama: (status?.trim().isNotEmpty ?? false) ? status! : s.label,
      sumber: sumber,
      nip: nip,
      namaPetugas: namaPetugas,
      tglCheckin: parseTgl(tglCheckin),
      latitude: latitude,
      longitude: longitude,
      akurasi: akurasi,
      jarakKeTujuan: jarakKeTujuan,
      keterangan: keterangan,
      diabaikan: diabaikan,
      perluReview: perluReview,
      jumlahFoto: jumlahFoto > foto.length ? jumlahFoto : foto.length,
      foto: foto.map((e) => e.toEntity()).toList(),
      flagAkurasi: flagAkurasi,
      flagWaktu: flagWaktu,
      percobaanKe: percobaanKe,
    );
  }
}

/// Timeline terbaru di atas; jejak tanpa tanggal di paling bawah.
List<JejakEntity> jejakTerurut(List<JejakModel> jejak) =>
    jejak.map((e) => e.toEntity()).toList()..sort((a, b) {
      final ta = a.tglCheckin, tb = b.tglCheckin;
      if (ta == null || tb == null) return ta == null ? 1 : -1;
      return tb.compareTo(ta);
    });

extension BerkasModelX on BerkasModel {
  BerkasEntity toEntity() {
    final s = StatusBerkas.fromId(statusId);
    final j = JenisSurat.fromKode(jenisKode);
    return BerkasEntity(
      noResi: noResi,
      jenis: j,
      jenisNama: namaJenisSurat(j.label, j != JenisSurat.lainnya, jenisNama),
      noSurat: noSurat,
      tglSurat: parseTgl(tglSurat),
      noReferensi: noReferensi,
      npwpd: npwpd,
      namaWp: namaWp,
      status: s,
      statusNama: (status?.trim().isNotEmpty ?? false) ? status! : s.label,
      modeTempel: modeTempel,
      percobaanKe: percobaanKe,
      jumlahGagal: jumlahGagal,
      jenisTujuan: jenisTujuan,
      alamatTujuan: alamatTujuan,
      latTujuan: latTujuan,
      longTujuan: longTujuan,
      penanggungJawab: penanggungJawab,
      tglDitugaskan: parseTgl(tglDitugaskan),
      tglBatasSla: parseTgl(tglBatasSla),
      terlambat: terlambat,
      perluDikembalikan: perluDikembalikan,
      wajibFotoObjek: wajibFotoObjek,
      aksi: aksi.map(AksiBerkas.fromKode).whereType<AksiBerkas>().toList(),
    );
  }
}

extension BerkasDetailModelX on BerkasDetailModel {
  BerkasDetailEntity toEntity() => BerkasDetailEntity(
    berkas: berkas.toEntity(),
    alamatWp: alamatWp,
    caraSerah: caraSerah,
    tglTerima: parseTgl(tglTerima),
    namaPenerima: namaPenerima,
    jejak: jejakTerurut(jejak),
  );
}
