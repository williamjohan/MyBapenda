import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/pengiriman_queue_storage.dart';
import '../../../domain/entities/pengiriman/antrean_entity.dart';
import '../../../domain/entities/pengiriman/pengiriman_payload_entity.dart';

/// Body multipart `/api/pengiriman/*`: field rata + file per nama field.
/// Dipakai juga oleh antrean offline untuk membangun ulang request.
Future<FormData> buildPengirimanFormData({
  required List<MapEntry<String, String>> fields,
  Map<String, String?> files = const {},
}) async {
  final form = FormData()..fields.addAll(fields);
  for (final e in files.entries) {
    final path = e.value;
    if (path == null) continue;
    final png = path.toLowerCase().endsWith('.png');
    form.files.add(
      MapEntry(
        e.key,
        await MultipartFile.fromFile(
          path,
          filename: path.split(RegExp(r'[\\/]')).last,
          contentType: png
              ? MediaType('image', 'png')
              : MediaType('image', 'jpeg'),
        ),
      ),
    );
  }
  return form;
}

final _fmtTgl = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

extension CheckinPengirimanEntityX on CheckinPengirimanEntity {
  List<MapEntry<String, String>> toFields() => [
    MapEntry('checkinUuid', checkinUuid),
    MapEntry('tglCheckin', _fmtTgl.format(tglCheckin)),
    MapEntry('latitude', '$latitude'),
    MapEntry('longitude', '$longitude'),
    if (akurasi != null) MapEntry('akurasi', '$akurasi'),
    MapEntry('isMockLocation', '$isMockLocation'),
    if (keterangan?.trim().isNotEmpty ?? false)
      MapEntry('keterangan', keterangan!.trim()),
  ];
}

List<MapEntry<String, String>> _list(String key, List<String> values) => [
  for (final v in values) MapEntry(key, v),
];

/// Rekaman antrean dari field + file (file null dibuang).
AntreanRecord _record({
  required JenisAksiAntrean jenis,
  required String endpoint,
  required List<String> noResi,
  required CheckinPengirimanEntity checkin,
  required List<MapEntry<String, String>> fields,
  required Map<String, String?> files,
}) => AntreanRecord(
  checkinUuid: checkin.checkinUuid,
  jenis: jenis.kode,
  endpoint: endpoint,
  noResi: noResi,
  fields: [
    for (final f in fields) [f.key, f.value],
  ],
  files: {
    for (final e in files.entries)
      if (e.value != null) e.key: e.value!,
  },
  tglDibuat: checkin.tglCheckin,
);

extension AntreanRecordX on AntreanRecord {
  Future<FormData> toFormData() => buildPengirimanFormData(
    fields: [for (final f in fields) MapEntry(f[0], f[1])],
    files: files,
  );

  AntreanPengirimanEntity toEntity() => AntreanPengirimanEntity(
    checkinUuid: checkinUuid,
    jenis: JenisAksiAntrean.fromKode(jenis),
    noResi: noResi,
    tglDibuat: tglDibuat,
    jmlCoba: jmlCoba,
    pesan: pesanError,
    diabaikan: diabaikan,
  );
}

extension AmbilPayloadEntityX on AmbilPayloadEntity {
  /// Ambil selalu online (tidak lewat antrean).
  Future<FormData> toFormData() => buildPengirimanFormData(
    fields: [
      ..._list('noResiList', noResiList),
      ..._list('nipTim', nipTim),
      ...checkin.toFields(),
    ],
    files: {'fotoAmbil': fotoAmbilPath, 'fotoLokasi': checkin.fotoLokasiPath},
  );
}

extension CheckinPayloadEntityX on CheckinPayloadEntity {
  AntreanRecord toRecord() => _record(
    jenis: jenis == JenisCheckin.tiba
        ? JenisAksiAntrean.tiba
        : JenisAksiAntrean.perjalanan,
    endpoint: jenis == JenisCheckin.tiba
        ? ApiEndpoints.pengirimanTiba
        : ApiEndpoints.pengirimanPerjalanan,
    noResi: [noResi],
    checkin: checkin,
    fields: [MapEntry('noResi', noResi), ...checkin.toFields()],
    files: {'fotoLokasi': checkin.fotoLokasiPath},
  );
}

extension SerahPayloadEntityX on SerahPayloadEntity {
  AntreanRecord toRecord() => _record(
    jenis: JenisAksiAntrean.serah,
    endpoint: ApiEndpoints.pengirimanSerah,
    noResi: [noResi],
    checkin: checkin,
    fields: [
      MapEntry('noResi', noResi),
      MapEntry('caraSerah', '${caraSerah.id}'),
      if (namaPenerima?.trim().isNotEmpty ?? false)
        MapEntry('namaPenerima', namaPenerima!.trim()),
      if (idHubungan != null) MapEntry('idHubungan', '$idHubungan'),
      ...checkin.toFields(),
    ],
    files: {
      'fotoSerah': fotoSerahPath,
      'fotoTtd': fotoTtdPath,
      'fotoTempel': fotoTempelPath,
      'fotoObjek': fotoObjekPath,
      'fotoLokasi': checkin.fotoLokasiPath,
    },
  );
}

extension GagalPayloadEntityX on GagalPayloadEntity {
  AntreanRecord toRecord() => _record(
    jenis: JenisAksiAntrean.gagal,
    endpoint: ApiEndpoints.pengirimanGagal,
    noResi: [noResi],
    checkin: checkin,
    fields: [
      MapEntry('noResi', noResi),
      MapEntry('idAlasan', '$idAlasan'),
      ...checkin.toFields(),
    ],
    files: {'fotoGagal': fotoGagalPath, 'fotoLokasi': checkin.fotoLokasiPath},
  );
}

extension KembalikanPayloadEntityX on KembalikanPayloadEntity {
  AntreanRecord toRecord() => _record(
    jenis: JenisAksiAntrean.kembalikan,
    endpoint: ApiEndpoints.pengirimanKembalikan,
    noResi: noResiList,
    checkin: checkin,
    fields: [..._list('noResiList', noResiList), ...checkin.toFields()],
    files: {'fotoLokasi': checkin.fotoLokasiPath},
  );
}
