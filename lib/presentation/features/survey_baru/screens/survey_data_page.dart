// lib/presentation/features/survey_baru/screens/survey_data_page.dart
import 'package:mybapenda/core/di/injection.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_data/survey_data_cubit.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_data/survey_data_state.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/survey_header_card.dart';
import 'package:mybapenda/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:mybapenda/presentation/shared/master_data/domain/entities/paged_master_entities.dart';
import 'package:mybapenda/presentation/shared/master_data/domain/usecases/master_data_usecase.dart';
import 'package:mybapenda/presentation/shared/master_data/presentation/cubit/master_data_cubit.dart';
import 'package:mybapenda/presentation/shared/master_data/presentation/cubit/paged_search_cubit.dart';
import 'package:mybapenda/presentation/shared/master_data/presentation/widgets/master_paged_select_field.dart';
import 'package:mybapenda/presentation/shared/master_data/presentation/widgets/master_select_field.dart';
import 'package:mybapenda/presentation/shared/widgets/button.dart';
import 'package:mybapenda/presentation/features/survey_baru/widgets/tombol_simpan_draft.dart';
import 'package:mybapenda/presentation/shared/widgets/form_fields.dart';
import 'package:mybapenda/presentation/shared/widgets/info_row.dart';
import 'package:mybapenda/presentation/shared/widgets/paged_select_field.dart';
import 'package:mybapenda/presentation/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

class SurveyDataPage extends StatefulWidget {
  final Map<String, dynamic> sisi;
  final Map<String, dynamic>? initial;

  const SurveyDataPage({super.key, required this.sisi, this.initial});

  @override
  State<SurveyDataPage> createState() => _SurveyDataPageState();
}

class _SurveyDataPageState extends State<SurveyDataPage> {
  late final TextEditingController _noAlamatCtrl;
  late final TextEditingController _materiCtrl;
  late final TextEditingController _pCtrl;
  late final TextEditingController _lCtrl;
  late final TextEditingController _tCtrl;
  late final TextEditingController _ketSisiCtrl;
  late final TextEditingController _ketSurveyCtrl;

  late final PagedSearchCubit<JalanEntity> _jalanCubit;
  late final PagedSearchCubit<PersilEntity> _persilCubit;

  bool get _sudahPunyaNor => widget.sisi['nor'] != null;

  @override
  void initState() {
    super.initState();

    _jalanCubit = PagedSearchCubit<JalanEntity>(
      getIt<MasterDataUseCase>().searchJalan,
      idOf: (e) => e.id,
      errorMessage: 'Gagal memuat nama jalan.\nPeriksa koneksi lalu coba lagi.',
    );

    _persilCubit = PagedSearchCubit<PersilEntity>(
      getIt<MasterDataUseCase>().searchPersil,
      idOf: (e) => e.idPersil,
      errorMessage: 'Gagal memuat persil.\nPeriksa koneksi lalu coba lagi.',
    );

    final cubit = context.read<SurveyDataCubit>();
    final t = cubit.initialTexts;
    _noAlamatCtrl = TextEditingController(text: t.noAlamat);
    _materiCtrl = TextEditingController(text: t.materi);
    _pCtrl = TextEditingController(text: t.panjang);
    _lCtrl = TextEditingController(text: t.lebar);
    _tCtrl = TextEditingController(text: t.tinggi);
    _ketSisiCtrl = TextEditingController(text: t.ketSisi);
    _ketSurveyCtrl = TextEditingController(text: t.ketSurvey);

    final f = cubit.state;
    final preload = <MasterOptionType>[
      if (f.lokasiTertentuId != null) MasterOptionType.lokasiTertentu,
      if (f.lokasiPenyelenggaraanId != null)
        MasterOptionType.lokasiPenyelenggaraan,
      if (f.letakId != null) MasterOptionType.letakReklame,
      if (f.statusTanahId != null) MasterOptionType.statusTanah,
      if (f.jenisReklameId != null) MasterOptionType.jenisReklame,
      if (f.jenisProdukId != null) MasterOptionType.jenisProduk,
      if (f.sudutId != null) MasterOptionType.sudutPandang,
      if (!_sudahPunyaNor && f.jenisBangunanId != null)
        MasterOptionType.jenisBangunan,
    ];
    if (preload.isNotEmpty) {
      context.read<MasterDataCubit>().loadOptions(preload);
    }
  }

  @override
  void dispose() {
    _jalanCubit.close();
    _persilCubit.close();
    for (final c in [
      _noAlamatCtrl,
      _materiCtrl,
      _pCtrl,
      _lCtrl,
      _tCtrl,
      _ketSisiCtrl,
      _ketSurveyCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  SurveyDataTexts _teks() {
    final cubit = context.read<SurveyDataCubit>();

    // Nama lokasi diambil dari cache master berdasarkan ID yang dipilih.
    final lokasiId = cubit.state.lokasiPenyelenggaraanId;
    final lokasiNama = lokasiId == null
        ? ''
        : context.read<MasterDataCubit>().state.intOptionsOf(
                MasterOptionType.lokasiPenyelenggaraan,
              )[lokasiId] ??
              '';

    return (
      noAlamat: _noAlamatCtrl.text,
      lokasi: lokasiNama,
      materi: _materiCtrl.text,
      panjang: _pCtrl.text,
      lebar: _lCtrl.text,
      tinggi: _tCtrl.text,
      ketSisi: _ketSisiCtrl.text,
      ketSurvey: _ketSurveyCtrl.text,
    );
  }

  void _save() => context.read<SurveyDataCubit>().save(_teks());

  /// Survey baru: boleh simpan sebagai draft walau isian belum lengkap.
  void _simpanDraft() => context.read<SurveyDataCubit>().simpanDraft(_teks());

  bool get _bolehDraft {
    final h = widget.sisi['header'];
    return !(h is Map && h['dikembalikan'] == true);
  }

  static const _gap = SizedBox(height: 14);

  Widget _buildNorBaruForm(SurveyDataState form) {
    final cubit = context.read<SurveyDataCubit>();
    return _card(
      title: 'Input NOR Baru',
      icon: Icons.edit_note_rounded,
      children: [
        MasterPagedSelectField<String, PersilEntity>(
          cubit: _persilCubit,
          toOption: (e) => PagedOption(value: e.idPersil, label: e.label),
          label: 'Persil',
          hint: 'Pilih persil',
          searchHint: 'Cari ID / alamat persil',
          value: form.persilId,
          valueLabel: form.persilLabel,
          onChanged: cubit.setPersil,
        ),
        _gap,
        MasterSelectField<int>(
          type: MasterOptionType.jenisBangunan,
          itemsOf: (s) => s.intOptionsOf(MasterOptionType.jenisBangunan),
          value: form.jenisBangunanId,
          onChanged: cubit.setJenisBangunan,
        ),
        _gap,
        MasterPagedSelectField<int, JalanEntity>(
          cubit: _jalanCubit,
          toOption: (e) => PagedOption(value: e.id, label: e.nama),
          label: 'Nama Jalan',
          hint: 'Pilih nama jalan',
          searchHint: 'Cari nama jalan',
          value: form.namaJalanId,
          valueLabel: form.namaJalanNama,
          onChanged: cubit.setNamaJalan,
        ),
        _gap,
        BapendaTextField(
          label: 'No. Alamat',
          hint: 'Masukkan nomor alamat',
          controller: _noAlamatCtrl,
          mandatory: true,
        ),
      ],
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFB8680F)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2933),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sisi;
    final cubit = context.read<SurveyDataCubit>();

    return BlocListener<SurveyDataCubit, SurveyDataState>(
      listenWhen: (p, c) => p.error != c.error || p.result != c.result,
      listener: (context, state) {
        final result = state.result;
        if (result != null) {
          context.pop<Map<String, dynamic>>(result);
          return;
        }
        final err = state.error;
        if (err != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
          context.read<SurveyDataCubit>().clearError();
        }
      },
      child: BlocBuilder<SurveyDataCubit, SurveyDataState>(
        builder: (context, form) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6F8),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                BapendaSliverHeader(
                  title: 'Survey Permohonan Baru',
                  showBackButton: true,
                  subtitle: Text(
                    'Sisi ${s['seq']}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: const StepIndicator(
                      labels: ['Lokasi & Foto', 'Data', 'Review'],
                      currentIndex: 1,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(18),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SurveyHeaderCard(sisi: s, initiallyExpanded: false),
                      const SizedBox(height: 14),

                      if (_sudahPunyaNor)
                        _card(
                          title: 'NOR',
                          icon: Icons.pin_drop_rounded,
                          children: [
                            InfoRow(
                              label: 'NOR Terdaftar',
                              value: '${s['nor']}',
                            ),
                          ],
                        )
                      else
                        _buildNorBaruForm(form),
                      const SizedBox(height: 14),

                      _card(
                        title: 'Data Hasil Survey',
                        icon: Icons.assignment_rounded,
                        children: [
                          MasterSelectField<int>(
                            type: MasterOptionType.lokasiTertentu,
                            itemsOf: (m) =>
                                m.intOptionsOf(MasterOptionType.lokasiTertentu),
                            value: form.lokasiTertentuId,
                            onChanged: cubit.setLokasiTertentu,
                          ),
                          _gap,
                          MasterSelectField<int>(
                            type: MasterOptionType.letakReklame,
                            itemsOf: (m) =>
                                m.intOptionsOf(MasterOptionType.letakReklame),
                            value: form.letakId,
                            onChanged: cubit.setLetak,
                          ),
                          _gap,
                          MasterSelectField<int>(
                            type: MasterOptionType.statusTanah,
                            itemsOf: (m) =>
                                m.intOptionsOf(MasterOptionType.statusTanah),
                            value: form.statusTanahId,
                            onChanged: cubit.setStatusTanah,
                          ),
                          _gap,
                          MasterSelectField<int>(
                            type: MasterOptionType.lokasiPenyelenggaraan,
                            itemsOf: (m) => m.intOptionsOf(
                              MasterOptionType.lokasiPenyelenggaraan,
                            ),
                            value: form.lokasiPenyelenggaraanId,
                            onChanged: cubit.setLokasi,
                          ),
                          _gap,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ukuran Reklame',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2933),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: BapendaTextField(
                                      label: 'Panjang (P)',
                                      suffixText: 'm',
                                      controller: _pCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: BapendaTextField(
                                      label: 'Lebar (L)',
                                      suffixText: 'm',
                                      controller: _lCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: BapendaTextField(
                                      label: 'Tinggi (T)',
                                      suffixText: 'm',
                                      controller: _tCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _gap,
                          MasterSelectField<int>(
                            type: MasterOptionType.jenisReklame,
                            itemsOf: (m) =>
                                m.intOptionsOf(MasterOptionType.jenisReklame),
                            value: form.jenisReklameId,
                            onChanged: cubit.setJenisReklame,
                          ),
                          _gap,
                          MasterSelectField<int>(
                            type: MasterOptionType.jenisProduk,
                            label: 'Jenis Produk',
                            itemsOf: (m) =>
                                m.intOptionsOf(MasterOptionType.jenisProduk),
                            value: form.jenisProdukId,
                            onChanged: cubit.setJenisProduk,
                            mandatory: true,
                          ),
                          _gap,
                          MasterSelectField<int>(
                            type: MasterOptionType.sudutPandang,
                            itemsOf: (m) =>
                                m.intOptionsOf(MasterOptionType.sudutPandang),
                            value: form.sudutId,
                            onChanged: cubit.setSudut,
                          ),
                          _gap,
                          BapendaTextField(
                            label: 'Materi Reklame',
                            controller: _materiCtrl,
                          ),
                          _gap,
                          BapendaTextField(
                            label: 'Keterangan Sisi (Opsional)',
                            controller: _ketSisiCtrl,
                            maxLines: 2,
                          ),
                          _gap,
                          BapendaTextField(
                            label: 'Keterangan Survey (Opsional)',
                            hint: 'Tambahkan catatan jika ada...',
                            controller: _ketSurveyCtrl,
                            maxLines: 3,
                            maxLength: 200,
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Row(
                  children: [
                    if (_bolehDraft) ...[
                      TombolSimpanDraft(onPressed: _simpanDraft),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Button(
                        label: _bolehDraft ? 'Lanjutkan' : 'Simpan & Lanjutkan',
                        icon: Icons.arrow_forward_rounded,
                        iconAtEnd: true,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
