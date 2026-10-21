import 'package:mybapenda/data/models/pengiriman/pengiriman_payload_model.dart';
import 'package:mybapenda/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('field check-in multipart sesuai kontrak', () {
    final fields = CheckinPengirimanEntity(
      checkinUuid: 'u-1',
      tglCheckin: DateTime(2026, 10, 14, 9, 5, 7),
      latitude: -7.25,
      longitude: 112.75,
      akurasi: 12.5,
      isMockLocation: false,
      keterangan: '  ',
    ).toFields();
    final map = {for (final e in fields) e.key: e.value};

    expect(map['tglCheckin'], '2026-10-14T09:05:07');
    expect(map['isMockLocation'], 'false');
    expect(map.containsKey('keterangan'), isFalse);
  });
}
