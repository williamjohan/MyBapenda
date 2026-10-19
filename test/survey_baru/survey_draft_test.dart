import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_data/survey_data_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/screens/survey_foto_page.dart';
import 'package:flutter_test/flutter_test.dart';

const SurveyDataTexts _kosong = (
  noAlamat: '',
  lokasi: '',
  materi: '',
  panjang: '',
  lebar: '',
  tinggi: '',
  ketSisi: '',
  ketSurvey: '',
);

void main() {
  group('SurveyDataCubit', () {
    test('save menolak isian kosong', () {
      final c = SurveyDataCubit(sisi: {'seq': 1, 'nor': 'N1'})..save(_kosong);
      expect(c.state.error, isNotNull);
      expect(c.state.result, isNull);
    });

    test('simpanDraft tanpa validasi: pilihan kosong = null, ditandai draft', () {
      final c = SurveyDataCubit(sisi: {'seq': 1, 'nor': 'N1'})
        ..setJenisReklame(3)
        ..simpanDraft((
          noAlamat: '',
          lokasi: '',
          materi: 'Iklan',
          panjang: '4',
          lebar: '',
          tinggi: '0',
          ketSisi: '',
          ketSurvey: '',
        ));

      final r = c.state.result!;
      expect(c.state.error, isNull);
      expect(isDataDraft(r), isTrue);
      expect(r['idJenisReklame'], 3);
      expect(r['letakReklame'], isNull);
      expect(r['panjang'], 4);
      expect(r['lebar'], isNull);
      expect(r['tinggi'], isNull);
      expect(r['materiReklame'], 'Iklan');
    });
  });

  group('dataDraftOf / titikDraftOf', () {
    test('isian draft server jadi SurveyData draft', () {
      final sisi = {
        'seq': 2,
        'survey': {
          'seq': 2,
          'lokPenyelenggaraan': '15',
          'panjang': 4.0,
          'ketSurvey': 'ok',
          'latitude': -7.25,
          'longitude': 112.75,
        },
      };

      final d = dataDraftOf(sisi)!;
      expect(isDataDraft(d), isTrue);
      expect(d['seq'], 2);
      expect(d['lokasiPenyelenggaraanId'], 15);
      expect(d['panjang'], 4.0);
      expect(titikDraftOf(sisi), (lat: -7.25, lng: 112.75));
    });

    test('tanpa isian & titik: null', () {
      final sisi = {
        'seq': 1,
        'survey': {'seq': 1, 'latitude': null, 'longitude': null},
      };
      expect(dataDraftOf(sisi), isNull);
      expect(titikDraftOf(sisi), isNull);
    });
  });
}
