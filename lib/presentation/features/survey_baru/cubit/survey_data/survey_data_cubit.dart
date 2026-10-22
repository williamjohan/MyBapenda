import 'package:mybapenda/presentation/features/survey_baru/constants/survey_option.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../screens/survey_foto_page.dart'; // kunciDraftData
import 'survey_data_state.dart';

typedef SurveyDataTexts = ({
  String? noAlamat,
  String lokasi,
  String materi,
  String panjang,
  String lebar,
  String tinggi,
  String ketSisi,
  String ketSurvey,
});

class SurveyDataCubit extends Cubit<SurveyDataState> {
  final Map<String, dynamic> sisi;
  final Map<String, dynamic>? initial;

  SurveyDataCubit({required this.sisi, this.initial})
    : super(_initialState(initial));

  bool get sudahPunyaNor => sisi['nor'] != null;

  // 0 adalah pilihan sah (mis. "Luar Ruang"), jadi hanya null yang kosong.
  static int? _id(dynamic v) => v is int ? v : null;

  static SurveyDataState _initialState(Map<String, dynamic>? d) {
    if (d == null) return const SurveyDataState();
    final nb = d['norBaru'];
    return SurveyDataState(
      lokasiTertentuId: _id(d['lokasiTertentuId']),
      lokasiPenyelenggaraanId: _id(d['lokasiPenyelenggaraanId']),
      letakId: _id(d['letakReklame']),
      statusTanahId: _id(d['statusTanah']),
      jenisReklameId: _id(d['idJenisReklame']),
      jenisProdukId: _id(d['idJenisProduk']),
      sudutId: _id(d['sudutPandang']),
      jenisBangunanId: nb is Map ? _id(nb['jenisBangunanId']) : null,
      namaJalanId: nb is Map ? _id(nb['namaJalanId']) : null,
      namaJalanNama: nb is Map ? nb['namaJalanNama'] as String? : null,
      persilId: nb is Map ? nb['persilId'] as String? : null,
      persilLabel: nb is Map ? nb['persilLabel'] as String? : null,
    );
  }

  /// Nilai awal field teks (dari data sisi, atau hasil simpan sebelumnya).
  SurveyDataTexts get initialTexts {
    final d = initial;
    final nb = d?['norBaru'];
    String txt(dynamic v) => (v is num && v > 0) ? SurveyOptions.fmtNum(v) : '';

    return (
      noAlamat: nb is Map ? (nb['noAlamat'] as String? ?? '') : '',
      // Tidak dipakai halaman: lokasi sekarang dipilih dari dropdown master.
      lokasi: d?['lokPenyelenggaraan'] as String? ?? '',
      materi:
          d?['materiReklame'] as String? ??
          sisi['materiReklamePermohonan'] as String? ??
          '',
      panjang: txt(d?['panjang']),
      lebar: txt(d?['lebar']),
      tinggi: txt(d?['tinggi']),
      ketSisi: d?['ketSisi'] as String? ?? '',
      ketSurvey: d?['ketSurvey'] as String? ?? '',
    );
  }

  // ---- Setter dropdown ----

  void setLokasiTertentu(int? v) => emit(state.copyWith(lokasiTertentuId: v));
  void setLokasi(int? v) => emit(state.copyWith(lokasiPenyelenggaraanId: v));
  void setLetak(int? v) => emit(state.copyWith(letakId: v));
  void setStatusTanah(int? v) => emit(state.copyWith(statusTanahId: v));
  void setJenisReklame(int? v) => emit(state.copyWith(jenisReklameId: v));
  void setJenisProduk(int? v) => emit(state.copyWith(jenisProdukId: v));
  void setSudut(int? v) => emit(state.copyWith(sudutId: v));
  void setJenisBangunan(int? v) => emit(state.copyWith(jenisBangunanId: v));
  void setNamaJalan(int id, String nama) =>
      emit(state.copyWith(namaJalanId: id, namaJalanNama: nama));
  void setPersil(String id, String label) =>
      emit(state.copyWith(persilId: id, persilLabel: label));

  void clearError() => emit(state.copyWith(error: () => null));

  // ---- Simpan ----

  double _num(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;

  String? _validate(SurveyDataTexts t) {
    final kurang = <String>[];

    if (!sudahPunyaNor) {
      if (state.persilId == null) kurang.add('Persil');
      if (state.jenisBangunanId == null) kurang.add('Jenis Bangunan');
      if (state.namaJalanId == null) kurang.add('Nama Jalan');
      if ((t.noAlamat ?? '').trim().isEmpty) kurang.add('No. Alamat');
      
    }

    if (state.lokasiTertentuId == null) kurang.add('Lokasi Tertentu');
    if (state.letakId == null) kurang.add('Letak Reklame');
    if (state.statusTanahId == null) kurang.add('Status Tanah');
    if (state.lokasiPenyelenggaraanId == null) {
      kurang.add('Lokasi Penyelenggaraan');
    }
    if (_num(t.panjang) <= 0 || _num(t.lebar) <= 0 || _num(t.tinggi) <= 0) {
      kurang.add('Ukuran (P, L, T harus lebih dari 0)');
    }
    if (state.jenisReklameId == null) kurang.add('Jenis Reklame');
    if (state.jenisProdukId == null) kurang.add('Jenis Produk');
    if (state.sudutId == null) kurang.add('Sudut Pandang');
    if (t.materi.trim().isEmpty) kurang.add('Materi Reklame');
    if (t.ketSisi.trim().isEmpty) kurang.add('Keterangan Sisi');
    if (t.ketSurvey.trim().isEmpty) kurang.add('Keterangan Survey');

    if (kurang.isNotEmpty) return 'Lengkapi dulu: ${kurang.join(', ')}';

    if (t.lokasi.trim().isEmpty) {
      return 'Lokasi penyelenggaraan belum termuat. Pilih ulang lokasinya';
    }
    return null;
  }

  Map<String, dynamic> _payload(SurveyDataTexts t) => {
    'seq': sisi['seq'],
    'idNor': null,
    'norBaru': sudahPunyaNor
        ? null
        : {
            'jenisBangunanId': state.jenisBangunanId,
            'namaJalanId': state.namaJalanId,
            'namaJalanNama': state.namaJalanNama,
            'noAlamat': t.noAlamat?.trim(),
            'persilId': state.persilId,
            'persilLabel': state.persilLabel,
          },
    'lokasiTertentuId': state.lokasiTertentuId ?? 0,
    'lokasiPenyelenggaraanId': state.lokasiPenyelenggaraanId,
    'lokPenyelenggaraan': t.lokasi.trim(),
    'letakReklame': state.letakId ?? 0,
    'statusTanah': state.statusTanahId ?? 0,
    'panjang': _num(t.panjang),
    'lebar': _num(t.lebar),
    'tinggi': _num(t.tinggi),
    'idJenisReklame': state.jenisReklameId ?? 0,
    'idJenisProduk': state.jenisProdukId ?? 0,
    'sudutPandang': state.sudutId ?? 0,
    'ketSisi': t.ketSisi.trim(),
    'materiReklame': t.materi.trim(),
    'ketSurvey': t.ketSurvey.trim(),
  };

  void save(SurveyDataTexts texts) {
    final err = _validate(texts);
    if (err != null) {
      emit(state.copyWith(error: () => err));
      return;
    }
    emit(state.copyWith(result: _payload(texts)));
  }

  /// Simpan apa adanya tanpa validasi (draft): pilihan kosong = null, bukan
  /// 0, supaya server mempertahankan nilai draft lama. Kelengkapan dicek
  /// server saat simpan (`kurangLengkap`).
  void simpanDraft(SurveyDataTexts texts) {
    double? ukuran(String s) {
      final n = _num(s);
      return n > 0 ? n : null;
    }

    emit(
      state.copyWith(
        result: {
          ..._payload(texts),
          'lokasiTertentuId': state.lokasiTertentuId,
          'letakReklame': state.letakId,
          'statusTanah': state.statusTanahId,
          'idJenisReklame': state.jenisReklameId,
          'idJenisProduk': state.jenisProdukId,
          'sudutPandang': state.sudutId,
          'panjang': ukuran(texts.panjang),
          'lebar': ukuran(texts.lebar),
          'tinggi': ukuran(texts.tinggi),
          kunciDraftData: true,
        },
      ),
    );
  }
}
