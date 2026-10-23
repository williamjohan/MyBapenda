// lib/data/models/my_task/my_task_model.dart
import 'package:mybapenda/domain/entities/my_task/my_task_detail_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';

// ---------------------------------------------------------------------------
// Helper parsing (tahan terhadap null / tipe yang tidak terduga)
// ---------------------------------------------------------------------------

String _str(dynamic v, [String fallback = '-']) {
  if (v == null) return fallback;
  final s = '$v'.trim();
  return s.isEmpty ? fallback : s;
}

String? _strOrNull(dynamic v) {
  if (v == null) return null;
  final s = '$v'.trim();
  return s.isEmpty ? null : s;
}

int _int(dynamic v, [int fallback = 0]) =>
    v is num ? v.toInt() : int.tryParse('$v') ?? fallback;

bool _bool(dynamic v) => v is bool ? v : '$v'.toLowerCase() == 'true';

DateTime? _date(dynamic v) {
  final s = _strOrNull(v);
  return s == null ? null : DateTime.tryParse(s);
}

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

List<Map<String, dynamic>> _maps(dynamic v) => [
  for (final e in (v as List? ?? const [])) _map(e),
];

String _requireString(Map<String, dynamic> json, String key) {
  final s = _str(json[key], '');
  if (s.isEmpty) {
    throw FormatException(
      'Field "$key" tidak ditemukan. Key tersedia: ${json.keys.toList()}',
    );
  }
  return s;
}

// ---------------------------------------------------------------------------
// Satu tugas
// ---------------------------------------------------------------------------

class MyTaskModel {
  final String jenis;
  final String jenisNama;
  final String keyTask;
  final String noSkpd;
  final DateTime? tglSurat;
  final DateTime? startTask;
  final DateTime? expTask;
  final int sisaHari;
  final String status;
  final String statusNama;
  final bool bisaDikerjakan;
  final String? keterangan;
  final String npwpd;
  final String namaWp;
  final String alamatWp;
  final String jenisReklameNama;

  const MyTaskModel({
    required this.jenis,
    required this.jenisNama,
    required this.keyTask,
    required this.noSkpd,
    required this.tglSurat,
    required this.startTask,
    required this.expTask,
    required this.sisaHari,
    required this.status,
    required this.statusNama,
    required this.bisaDikerjakan,
    required this.keterangan,
    required this.npwpd,
    required this.namaWp,
    required this.alamatWp,
    required this.jenisReklameNama,
  });

  factory MyTaskModel.fromJson(Map<String, dynamic> json) => MyTaskModel(
    jenis: _str(json['jenis'], ''),
    jenisNama: _str(json['jenisNama']),
    keyTask: _requireString(json, 'keyTask'),
    noSkpd: _str(json['noSkpd']),
    tglSurat: _date(json['tglSurat']),
    startTask: _date(json['startTask']),
    expTask: _date(json['expTask']),
    sisaHari: _int(json['sisaHari']),
    status: _str(json['status'], ''),
    statusNama: _str(json['statusNama']),
    bisaDikerjakan: _bool(json['bisaDikerjakan']),
    keterangan: _strOrNull(json['keterangan']),
    npwpd: _str(json['npwpd']),
    namaWp: _str(json['namaWp']),
    alamatWp: _str(json['alamatWp']),
    jenisReklameNama: _str(json['jenisReklameNama']),
  );

  MyTaskEntity toEntity() => MyTaskEntity(
    jenis: jenis,
    jenisNama: jenisNama,
    keyTask: keyTask,
    noSkpd: noSkpd,
    tglSurat: tglSurat,
    startTask: startTask,
    expTask: expTask,
    sisaHari: sisaHari,
    status: status,
    statusNama: statusNama,
    bisaDikerjakan: bisaDikerjakan,
    keterangan: keterangan,
    npwpd: npwpd,
    namaWp: namaWp,
    alamatWp: alamatWp,
    jenisReklameNama: jenisReklameNama,
  );
}

// ---------------------------------------------------------------------------
// Tab / filter jenis: { kode, nama, jumlah }
// ---------------------------------------------------------------------------

class MyTaskFilterModel {
  final String kode;
  final String nama;
  final int jumlah;

  const MyTaskFilterModel({
    required this.kode,
    required this.nama,
    required this.jumlah,
  });

  factory MyTaskFilterModel.fromJson(Map<String, dynamic> json) =>
      MyTaskFilterModel(
        kode: _str(json['kode'], ''),
        nama: _str(json['nama']),
        jumlah: _int(json['jumlah']),
      );

  MyTaskFilterEntity toEntity() =>
      MyTaskFilterEntity(kode: kode, nama: nama, jumlah: jumlah);
}

// ---------------------------------------------------------------------------
// Ringkasan
// ---------------------------------------------------------------------------

class MyTaskSummaryModel {
  final int aktif;
  final int mendesak;
  final int selesai;
  final int terlewat;
  final MyTaskModel? tugasTerdekat;
  final List<MyTaskFilterModel> tabList;
  final List<MyTaskFilterModel> jenisList;
  final int totalItems;
  final int page;
  final int pageSize;

  const MyTaskSummaryModel({
    required this.aktif,
    required this.mendesak,
    required this.selesai,
    required this.terlewat,
    required this.tugasTerdekat,
    required this.tabList,
    required this.jenisList,
    required this.totalItems,
    required this.page,
    required this.pageSize,
  });

  factory MyTaskSummaryModel.fromJson(Map<String, dynamic> json) {
    final terdekat = json['tugasTerdekat'];
    return MyTaskSummaryModel(
      aktif: _int(json['aktif']),
      mendesak: _int(json['mendesak']),
      selesai: _int(json['selesai']),
      terlewat: _int(json['terlewat']),
      tugasTerdekat: terdekat is Map
          ? MyTaskModel.fromJson(_map(terdekat))
          : null,
      tabList: [
        for (final e in _maps(json['tabList'])) MyTaskFilterModel.fromJson(e),
      ],
      jenisList: [
        for (final e in _maps(json['jenisList'])) MyTaskFilterModel.fromJson(e),
      ],
      totalItems: _int(json['totalItems']),
      page: _int(json['page'], 1),
      pageSize: _int(json['pageSize']),
    );
  }

  MyTaskSummaryEntity toEntity() => MyTaskSummaryEntity(
    aktif: aktif,
    mendesak: mendesak,
    selesai: selesai,
    terlewat: terlewat,
    tugasTerdekat: tugasTerdekat?.toEntity(),
    tabList: tabList.map((e) => e.toEntity()).toList(),
    jenisList: jenisList.map((e) => e.toEntity()).toList(),
    totalItems: totalItems,
    page: page,
    pageSize: pageSize,
  );
}

// ---------------------------------------------------------------------------
// Isi `data` dari /api/mytask/header
// ---------------------------------------------------------------------------

class MyTaskHeaderModel {
  final MyTaskSummaryModel summary;
  final List<MyTaskModel> items;

  const MyTaskHeaderModel({required this.summary, required this.items});

  factory MyTaskHeaderModel.fromJson(Map<String, dynamic> json) =>
      MyTaskHeaderModel(
        summary: MyTaskSummaryModel.fromJson(_map(json['summary'])),
        items: [for (final e in _maps(json['items'])) MyTaskModel.fromJson(e)],
      );

  MyTaskHeaderEntity toEntity() => MyTaskHeaderEntity(
    summary: summary.toEntity(),
    items: items.map((e) => e.toEntity()).toList(),
  );
}

// ---------------------------------------------------------------------------
// Isi `data` dari /api/mytask/headerdetail
// ---------------------------------------------------------------------------

class MyTaskDetailModel {
  final String jenis;
  final String jenisNama;
  final String keyTask;
  final String noReferensi;
  final String nomorPelayanan;
  final String namaWp;
  final String jenisPajak;
  final String jenisObjek;
  final String alamatObjek;
  final DateTime? taskAssign;
  final DateTime? expAssign;

  const MyTaskDetailModel({
    required this.jenis,
    required this.jenisNama,
    required this.keyTask,
    required this.noReferensi,
    required this.nomorPelayanan,
    required this.namaWp,
    required this.jenisPajak,
    required this.jenisObjek,
    required this.alamatObjek,
    required this.taskAssign,
    required this.expAssign,
  });

  factory MyTaskDetailModel.fromJson(Map<String, dynamic> json) =>
      MyTaskDetailModel(
        jenis: _str(json['jenis'], ''),
        jenisNama: _str(json['jenisNama']),
        keyTask: _requireString(json, 'keyTask'),
        noReferensi: _str(json['noReferensi']),
        nomorPelayanan: _str(json['nomorPelayanan']),
        namaWp: _str(json['namaWp']),
        jenisPajak: _str(json['jenisPajak']),
        jenisObjek: _str(json['jenisObjek']),
        alamatObjek: _str(json['alamatObjek']),
        taskAssign: _date(json['taskAssign']),
        expAssign: _date(json['expAssign']),
      );

  MyTaskDetailEntity toEntity() => MyTaskDetailEntity(
    jenis: jenis,
    jenisNama: jenisNama,
    keyTask: keyTask,
    noReferensi: noReferensi,
    nomorPelayanan: nomorPelayanan,
    namaWp: namaWp,
    jenisPajak: jenisPajak,
    jenisObjek: jenisObjek,
    alamatObjek: alamatObjek,
    taskAssign: taskAssign,
    expAssign: expAssign,
  );
}
