import 'dart:convert';
import 'dart:io';

import 'package:mybapenda/data/models/survey_permohonan_baru/simpan_survey_hasil_model.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/simpan_survey_request_model.dart';
import 'package:mybapenda/data/models/survey_permohonan_baru/survey_detail_model.dart';
import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpanSurveyRequestModel', () {
    late Directory tmp;
    late File foto;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('simpan_survey_test');
      foto = File('${tmp.path}/foto.jpg')..writeAsBytesSync([1, 2, 3]);
    });

    tearDown(() => tmp.deleteSync(recursive: true));

    test('titik reklame dikirim per sisi, tanpa Latitude header', () async {
      final form = await SimpanSurveyRequestEntity(
        key: 'k',
        tglSurvey: '2026-10-19T09:00:00',
        kecamatan: '1',
        kelurahan: '2',
        lokBlok: '',
        lokRt: '',
        lokRw: '',
        sisiList: [
          SisiRequestEntity(
            seq: 1,
            latitude: '-7.2500000',
            longitude: '112.7500000',
            lokasiTertentuId: 1,
            letakReklame: 1,
            statusTanah: 1,
            lokPenyelenggaraan: '3',
            panjang: 4,
            lebar: 2,
            tinggi: 6,
            idJenisReklame: 1,
            idJenisProduk: 1,
            sudutPandang: 1,
            ketSisi: 'a',
            materiReklame: 'b',
            ketSurvey: 'c',
            fotos: [FotoRequestEntity(file: foto, keterangan: 'depan')],
          ),
        ],
        checkin: CheckinRequestEntity(
          fileDataFormFile: foto,
          latitude: '-7.2499',
          longitude: '112.7499',
          alamat: 'Jl. A',
        ),
      ).toModel().toFormData();

      final fields = Map.fromEntries(form.fields);
      expect(fields.containsKey('Latitude'), isFalse);
      expect(fields.containsKey('Longitude'), isFalse);
      expect(fields['Checkin.Latitude'], '-7.2499');

      final sisi = (jsonDecode(fields['SisiList']!) as List).single as Map;
      expect(sisi['latitude'], '-7.2500000');
      expect(sisi['longitude'], '112.7500000');
      expect(
        form.files.map((e) => e.key),
        contains('SisiList[0].Fotos[0].FileDataFormFile'),
      );
    });
  });

  test('check-in tersimpan: Checkin foto & lokasi tidak dikirim', () async {
    final form = await const SimpanSurveyRequestEntity(
      key: 'k',
      tglSurvey: '2026-10-19T09:00:00',
      kecamatan: '1',
      kelurahan: '2',
      lokBlok: '',
      lokRt: '',
      lokRw: '',
      sisiList: [
        SisiRequestEntity(
          seq: 1,
          latitude: '-7.25',
          longitude: '112.75',
          ketSisi: '',
          materiReklame: '',
          ketSurvey: '',
        ),
      ],
      checkin: CheckinRequestEntity(nipPembantu: ['199001']),
    ).toModel().toFormData();

    final fields = Map.fromEntries(form.fields);
    expect(
      fields.keys.where(
        (k) => k.startsWith('Checkin.') && !k.startsWith('Checkin.NipPembantu'),
      ),
      isEmpty,
    );
    expect(fields['Checkin.NipPembantu[0]'], '199001');
    expect(form.files, isEmpty);
  });

  group('SimpanSurveyHasilModel', () {
    test('Submit = terkirim', () {
      final h = SimpanSurveyHasilModel.fromJson({
        'hasil': 'Submit',
        'kurangLengkap': <String>[],
        'message': 'Survey berhasil disubmit dan dilanjutkan ke penilaian.',
      }).toEntity();
      expect(h.terkirim, isTrue);
    });

    test('Draft membawa daftar kekurangan', () {
      final h = SimpanSurveyHasilModel.fromJson({
        'hasil': 'Draft',
        'kurangLengkap': ['Keterangan survey (sisi 1)'],
        'message': 'Draft survey tersimpan.',
      }).toEntity();
      expect(h.terkirim, isFalse);
      expect(h.kurangLengkap, ['Keterangan survey (sisi 1)']);
    });

    test('field kosong tetap aman (dianggap Draft)', () {
      final h = SimpanSurveyHasilModel.fromJson({}).toEntity();
      expect(h.terkirim, isFalse);
      expect(h.kurangLengkap, isEmpty);
    });
  });

  test('survey-form draft: isDraft & titik reklame per sisi terbaca', () {
    final d = SurveyDetailModel.fromJson({
      'key': 'k',
      'noPelayanan': 'P1',
      'npwpd': 'N1',
      'katPenyelenggaraan': '1',
      'isDraft': true,
      'checkin': {
        'nipPembantu': <String>[],
        'tersimpan': true,
        'latitude': '-7.2501',
        'longitude': '112.7501',
        'alamat': 'Jl. A',
        'fotoUrl': 'https://x/foto.jpg',
        'tglCheckin': '2026-10-19 09:00:00',
      },
      'sisiList': [
        {
          'seq': 1,
          'keySisi': 's1',
          'survey': {'seq': 1, 'latitude': '-7.25', 'longitude': '112.75'},
        },
        {
          'seq': 2,
          'keySisi': 's2',
          'survey': {'seq': 2, 'latitude': '', 'longitude': null},
        },
      ],
    }).toEntity();

    expect(d.isDraft, isTrue);
    expect(d.checkin?.tersimpan, isTrue);
    expect(d.checkin?.latitude, -7.2501);
    expect(d.checkin?.fotoUrl, 'https://x/foto.jpg');
    expect(d.sisiList[0].survey?.latitude, -7.25);
    expect(d.sisiList[0].survey?.longitude, 112.75);
    expect(d.sisiList[1].survey?.latitude, isNull);
  });
}
