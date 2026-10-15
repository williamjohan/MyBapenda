import 'master_json_helper.dart';

/// Master sederhana (id -> nama): jenis reklame, kecamatan, kelurahan, dll.
/// ID disimpan sebagai String supaya cocok untuk ID angka maupun kode wilayah.
class MasterOptionModel {
  final String id;
  final String nama;

  const MasterOptionModel({required this.id, required this.nama});

  factory MasterOptionModel.fromJson(Map<String, dynamic> json) =>
      MasterOptionModel(
        id: MasterJson.requireId(json, MasterJson.idKeys, 'id'),
        nama: MasterJson.requireString(json, MasterJson.namaKeys, 'nama'),
      );

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama};
}

extension MasterOptionListX on List<MasterOptionModel> {
  /// Untuk master dengan ID berupa kode (kecamatan, kelurahan): {id: nama}.
  Map<String, String> toOptionMap() => {for (final o in this) o.id: o.nama};

  /// Untuk master dengan ID angka (jenis reklame, status tanah, dll): {id: nama}.
  /// Urutan mengikuti urutan dari API.
  Map<int, String> toIntOptionMap() {
    final result = <int, String>{};
    for (final o in this) {
      final id = int.tryParse(o.id);
      if (id == null) {
        throw FormatException(
          'ID master "${o.id}" (${o.nama}) bukan angka. '
          'Pakai toOptionMap() untuk master ini.',
        );
      }
      result[id] = o.nama;
    }
    return result;
  }
}
