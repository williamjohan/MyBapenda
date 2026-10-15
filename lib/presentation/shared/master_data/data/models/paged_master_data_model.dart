import '../../domain/entities/paged_master_entities.dart';

// ---------------------------------------------------------------------------
// Helper parsing
// ---------------------------------------------------------------------------

int _asInt(dynamic v, {int? fallback}) {
  final n = v is num ? v.toInt() : int.tryParse('$v');
  if (n != null) return n;
  if (fallback != null) return fallback;
  throw FormatException('Nilai "$v" bukan angka');
}

/// Selalu di-trim. Kosong / null -> [fallback].
String _asString(dynamic v, [String fallback = '-']) {
  if (v == null) return fallback;
  final s = '$v'.trim();
  return s.isEmpty ? fallback : s;
}

/// Field wajib berupa angka. Pesan error menyebut key yang tersedia.
int _requireInt(Map<String, dynamic> json, String key) {
  final v = json[key];
  final n = v is num ? v.toInt() : int.tryParse('$v');
  if (n == null) {
    throw FormatException(
      'Field "$key" tidak ditemukan / bukan angka. '
      'Key tersedia: ${json.keys.toList()}',
    );
  }
  return n;
}

/// Field wajib berupa teks tidak kosong. Pesan error menyebut key yang tersedia.
String _requireString(Map<String, dynamic> json, String key) {
  final s = _asString(json[key], '');
  if (s.isEmpty) {
    throw FormatException(
      'Field "$key" tidak ditemukan. Key tersedia: ${json.keys.toList()}',
    );
  }
  return s;
}

// ---------------------------------------------------------------------------
// Pembungkus halaman: { currentPage, pageSize, totalData, totalPage, items }
// ---------------------------------------------------------------------------

class PagedModel<T> {
  final int currentPage;
  final int pageSize;
  final int totalData;
  final int totalPage;
  final List<T> items;

  const PagedModel({
    required this.currentPage,
    required this.pageSize,
    required this.totalData,
    required this.totalPage,
    required this.items,
  });

  factory PagedModel.empty() => PagedModel<T>(
    currentPage: 1,
    pageSize: 0,
    totalData: 0,
    totalPage: 0,
    items: <T>[],
  );

  factory PagedModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) parseItem,
  ) => PagedModel<T>(
    currentPage: _asInt(json['currentPage'], fallback: 1),
    pageSize: _asInt(json['pageSize'], fallback: 0),
    totalData: _asInt(json['totalData'], fallback: 0),
    totalPage: _asInt(json['totalPage'], fallback: 0),
    items: ((json['items'] as List?) ?? const [])
        .map((e) => parseItem(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );

  factory PagedModel.fromAny(
    dynamic data,
    T Function(Map<String, dynamic> json) parseItem,
  ) {
    if (data is Map) {
      return PagedModel<T>.fromJson(Map<String, dynamic>.from(data), parseItem);
    }
    if (data is List) {
      final items = data
          .map((e) => parseItem(Map<String, dynamic>.from(e as Map)))
          .toList();
      return PagedModel<T>(
        currentPage: 1,
        pageSize: items.length,
        totalData: items.length,
        totalPage: 1,
        items: items,
      );
    }
    return PagedModel<T>.empty();
  }
}

/// Extension untuk mapping Model ke Entity
extension PagedModelX<T> on PagedModel<T> {
  PagedResultEntity<R> toEntity<R>(R Function(T item) map) =>
      PagedResultEntity<R>(
        items: items.map(map).toList(),
        currentPage: currentPage,
        totalPage: totalPage,
        totalData: totalData,
      );
}

// ---------------------------------------------------------------------------
// Nama jalan: { id (int), nama }
// ---------------------------------------------------------------------------

class JalanItemModel {
  final int id;
  final String nama;

  const JalanItemModel({required this.id, required this.nama});

  factory JalanItemModel.fromJson(Map<String, dynamic> json) => JalanItemModel(
    id: _requireInt(json, 'id'),
    nama: _asString(json['nama']),
  );
}

extension JalanItemModelX on JalanItemModel {
  JalanEntity toEntity() => JalanEntity(id: id, nama: nama);
}

// ---------------------------------------------------------------------------
// Persil: { idPersil (String, ada nol di depan), alamat, kec, kel }
// ---------------------------------------------------------------------------

class PersilItemModel {
  final String idPersil;
  final String alamat;
  final String kec;
  final String kel;

  const PersilItemModel({
    required this.idPersil,
    required this.alamat,
    required this.kec,
    required this.kel,
  });

  factory PersilItemModel.fromJson(Map<String, dynamic> json) =>
      PersilItemModel(
        idPersil: _requireString(json, 'idPersil'),
        alamat: _asString(json['alamat']),
        kec: _asString(json['kec'], ''),
        kel: _asString(json['kel'], ''),
      );
}

extension PersilItemModelX on PersilItemModel {
  PersilEntity toEntity() =>
      PersilEntity(idPersil: idPersil, alamat: alamat, kec: kec, kel: kel);
}

// ---------------------------------------------------------------------------
// Pegawai survey: { nip (String), nama }
// ---------------------------------------------------------------------------

class PegawaiSurveyModel {
  final String nip;
  final String nama;

  const PegawaiSurveyModel({required this.nip, required this.nama});

  factory PegawaiSurveyModel.fromJson(Map<String, dynamic> json) =>
      PegawaiSurveyModel(
        nip: _requireString(json, 'nip'),
        nama: _asString(json['nama']),
      );
}

extension PegawaiSurveyModelX on PegawaiSurveyModel {
  PegawaiSurveyEntity toEntity() => PegawaiSurveyEntity(nip: nip, nama: nama);
}
