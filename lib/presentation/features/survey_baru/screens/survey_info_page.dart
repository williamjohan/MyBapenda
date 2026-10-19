import 'dart:async';

import 'package:bapendacore/core/di/injection.dart';
import 'package:bapendacore/presentation/features/survey_baru/constants/survey_option.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_info/survey_info_cubit.dart';
import 'package:bapendacore/presentation/features/survey_baru/cubit/survey_info/survey_info_state.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/entities/paged_master_entities.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/usecases/master_data_usecase.dart';
import 'package:bapendacore/presentation/shared/master_data/presentation/cubit/master_data_cubit.dart';
import 'package:bapendacore/presentation/shared/master_data/presentation/cubit/master_data_state.dart';
import 'package:bapendacore/presentation/shared/master_data/presentation/cubit/paged_search_cubit.dart';
import 'package:bapendacore/presentation/shared/master_data/presentation/widgets/master_paged_select_field.dart';
import 'package:bapendacore/presentation/shared/widgets/bt_select_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:bapendacore/presentation/shared/widgets/checkin_card.dart';
import 'package:bapendacore/presentation/shared/widgets/form_fields.dart';
import 'package:bapendacore/presentation/shared/widgets/paged_select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_image.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';

class SurveyInfoPage extends StatefulWidget {
  final String nomorPelayanan;
  final String surveyKey;
  final List<Map<String, dynamic>> sisiList;

  const SurveyInfoPage({
    super.key,
    required this.nomorPelayanan,
    required this.surveyKey,
    required this.sisiList,
  });

  @override
  State<SurveyInfoPage> createState() => _SurveyInfoPageState();
}

class _SurveyInfoPageState extends State<SurveyInfoPage> {
  final DateTime _tanggal = DateTime.now();
  final TextEditingController _tanggalCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _imbCtrl = TextEditingController();
  final _blokCtrl = TextEditingController();
  final _petugasCtrl = TextEditingController();
  late final PagedSearchCubit<PegawaiSurveyEntity> _pegawaiCubit;
  final Map<String, String> _namaPembantu = {};

  /// Check-in draft tersimpan di server (survey baru yang sudah ber-draft).
  /// Ada = selfie & lokasi tidak diminta lagi; server memakai check-in itu.
  Map<String, dynamic>? _checkinTersimpan;

  @override
  void initState() {
    super.initState();

    _tanggalCtrl.text = SurveyOptions.fmtTanggal(_tanggal);

    _pegawaiCubit = PagedSearchCubit<PegawaiSurveyEntity>(
      getIt<MasterDataUseCase>().searchPegawaiSurvey,
      idOf: (e) => e.nip,
      errorMessage:
          'Gagal memuat daftar petugas.\nPeriksa koneksi lalu coba lagi.',
    );

    context.read<SurveyInfoCubit>().loadPetugas();
    final prefill = widget.sisiList.firstOrNull?['infoPrefill'];
    if (prefill is Map) {
      final kec = prefill['kecamatanId'] as String?;
      final nipPembantu = [
        for (final n in (prefill['nipPembantu'] as List? ?? const [])) '$n',
      ];
      context.read<SurveyInfoCubit>().applyPrefill(
        kecamatanId: kec,
        kelurahanId: prefill['kelurahanId'] as String?,
        nipPembantu: nipPembantu,
      );
      if (kec != null) context.read<MasterDataCubit>().loadKelurahan(kec);
      if (nipPembantu.isNotEmpty) unawaited(_resolveNamaPembantu(nipPembantu));

      void put(TextEditingController c, String k) {
        final v = prefill[k] as String?;
        if (v != null && v.isNotEmpty) c.text = v;
      }

      put(_blokCtrl, 'blok');
      put(_rtCtrl, 'rt');
      put(_rwCtrl, 'rw');

      final c = prefill['checkin'];
      final lat = c is Map ? c['latitude'] : null;
      final lng = c is Map ? c['longitude'] : null;
      if (c is Map && lat is double && lng is double) {
        _checkinTersimpan = Map<String, dynamic>.from(c);
        final alamat = c['alamat'] as String?;
        context.read<SurveyInfoCubit>().pakaiCheckinTersimpan(
          latitude: lat,
          longitude: lng,
          alamat: alamat,
        );
        // Listener koordinat belum terpasang saat initState.
        _latCtrl.text = lat.toStringAsFixed(6);
        _lngCtrl.text = lng.toStringAsFixed(6);
        _alamatCtrl.text = alamat ?? '-';
      }
    }
    context.read<MasterDataCubit>().loadOption(MasterOptionType.kecamatan);
  }

  @override
  void dispose() {
    _pegawaiCubit.close();
    for (final c in [
      _latCtrl,
      _lngCtrl,
      _alamatCtrl,
      _rtCtrl,
      _rwCtrl,
      _imbCtrl,
      _blokCtrl,
      _tanggalCtrl,
      _petugasCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// NIP dari profil login dan dari daftar pegawai bisa beda format (spasi).
  String _normNip(String? s) => (s ?? '').replaceAll(RegExp(r'\s'), '');

  /// Prefill hanya membawa NIP. Cari namanya (pencarian pegawai berdasarkan
  /// NIP) supaya chip tidak menampilkan angka. Kalau tidak ketemu, chip tetap
  /// menampilkan NIP.
  Future<void> _resolveNamaPembantu(List<String> nips) async {
    final useCase = getIt<MasterDataUseCase>();

    for (final nip in nips) {
      if (!mounted) return;
      if (_namaPembantu.containsKey(nip)) continue;

      final result = await useCase.searchPegawaiSurvey(
        keyword: nip,
        page: 1,
        pageSize: 5,
      );
      if (!mounted) return;

      result.fold((_) {}, (page) {
        final match = page.items
            .where((e) => _normNip(e.nip) == _normNip(nip))
            .firstOrNull;
        if (match != null) setState(() => _namaPembantu[nip] = match.nama);
      });
    }
  }

  String? _validate(SurveyInfoState s) {
    // Check-in tersimpan: selfie & lokasi tidak perlu diambil lagi.
    if (_checkinTersimpan == null) {
      if (s.selfiePath == null) return 'Foto selfie wajib diambil';
      if (s.isLocating || s.isStamping) {
        return 'Tunggu proses lokasi dan stamp foto selesai';
      }
      if (s.latitude == null || s.longitude == null) {
        return 'Lokasi belum didapat. Tekan "Lokasi Saat Ini"';
      }
      if (!s.isPhotoStamped) {
        return 'Foto belum diberi stamp lokasi. Tekan "Lokasi Saat Ini"';
      }
    }
    if (s.kecamatanId == null || s.kelurahanId == null) {
      return 'Pilih kecamatan dan kelurahan';
    }
    if (_blokCtrl.text.trim().isEmpty) {
      return 'Keterangan lokasi wajib diisi.';
    }
    if (s.namaPetugas == null) return 'Data petugas belum termuat';
    return null;
  }

  Map<String, dynamic> _payload(SurveyInfoState s) => {
    'key': widget.surveyKey,
    // true = pakai check-in draft di server (foto/lokasi Checkin tidak
    // dikirim).
    'checkinTersimpan': _checkinTersimpan != null,
    // Sudah berstamp.
    'selfiePath': _checkinTersimpan == null ? s.selfiePath : null,
    'latitude': s.latitude,
    'longitude': s.longitude,
    // Alamat hasil reverse geocoding ('-' kalau tidak ditemukan).
    'alamat': s.address,
    'kecamatanId': s.kecamatanId,
    'kelurahanId': s.kelurahanId,
    'rt': _rtCtrl.text.trim(),
    'rw': _rwCtrl.text.trim(),
    'blok': _blokCtrl.text.trim(),
    'nipPetugas': s.nipPetugas,
    'namaPetugas': s.namaPetugas,
    // Petugas pembantu (boleh lebih dari satu). Nama hanya untuk tampilan.
    'nipPembantu': List<String>.of(s.nipPembantu),
    'namaPembantu': [for (final n in s.nipPembantu) _namaPembantu[n] ?? n],
    'tanggalSurvey': SurveyOptions.isoDate(_tanggal),
  };

  void _next() {
    final s = context.read<SurveyInfoCubit>().state;
    final err = _validate(s);
    if (err != null) {
      _snack(err);
      return;
    }
    context.pushNamed(
      AppRoutes.surveySisi,
      extra: (
        nomor: widget.nomorPelayanan,
        sisiList: widget.sisiList,
        info: _payload(s),
      ),
    );
  }

  static const _gap = SizedBox(height: 14);

  /// Petugas pembantu: pilih dari daftar (bisa berkali-kali), hasilnya
  /// tampil sebagai chip yang bisa dihapus.
  Widget _buildPembantu(SurveyInfoState info) {
    final cubit = context.read<SurveyInfoCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MasterPagedSelectField<String, PegawaiSurveyEntity>(
          cubit: _pegawaiCubit,
          toOption: (e) =>
              PagedOption(value: e.nip, label: e.nama, subtitle: e.nip),
          // Tidak boleh: petugas yang login, dan yang sudah dipilih.
          excludeWhere: (e) =>
              (info.nipPetugas != null &&
                  _normNip(e.nip) == _normNip(info.nipPetugas)) ||
              info.nipPembantu.any((n) => _normNip(n) == _normNip(e.nip)),
          label: 'Petugas Pembantu',
          hint: info.nipPembantu.isEmpty
              ? 'Pilih petugas pembantu'
              : 'Tambah petugas pembantu',
          searchHint: 'Cari nama petugas',
          mandatory: false,
          // Selalu kosong: setiap pilihan langsung jadi chip di bawahnya.
          value: null,
          valueLabel: null,
          onChanged: (nip, nama) {
            setState(() => _namaPembantu[nip] = nama);
            cubit.addPembantu(nip);
          },
        ),
        if (info.nipPembantu.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final nip in info.nipPembantu)
                InputChip(
                  label: Text(
                    _namaPembantu[nip] ?? nip,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  backgroundColor: const Color(0xFFFFF3DC),
                  side: BorderSide.none,
                  deleteIconColor: const Color(0xFFB8680F),
                  onDeleted: () {
                    setState(() => _namaPembantu.remove(nip));
                    cubit.removePembantu(nip);
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        //Petugas
        BlocListener<SurveyInfoCubit, SurveyInfoState>(
          listenWhen: (p, c) => p.namaPetugas != c.namaPetugas,
          listener: (context, s) => _petugasCtrl.text = s.namaPetugas ?? '',
        ),
        // Koordinat -> field latitude/longitude.
        BlocListener<SurveyInfoCubit, SurveyInfoState>(
          listenWhen: (p, c) =>
              p.latitude != c.latitude || p.longitude != c.longitude,
          listener: (context, s) {
            _latCtrl.text = s.latitude?.toStringAsFixed(6) ?? '';
            _lngCtrl.text = s.longitude?.toStringAsFixed(6) ?? '';
          },
        ),
        // Alamat hasil reverse geocoding -> field alamat (read-only).
        BlocListener<SurveyInfoCubit, SurveyInfoState>(
          listenWhen: (p, c) => p.address != c.address,
          listener: (context, s) => _alamatCtrl.text = s.address,
        ),
        BlocListener<SurveyInfoCubit, SurveyInfoState>(
          listenWhen: (p, c) =>
              p.isLocating && !c.isLocating && c.latitude != null,
          listener: (context, s) {
            void fill(TextEditingController ctrl, String? value) {
              final text = ctrl.text.trim();
              if (text.isEmpty || text == '-') ctrl.text = value ?? '-';
            }

            fill(_rtCtrl, s.rt);
            fill(_rwCtrl, s.rw);
          },
        ),
        BlocListener<SurveyInfoCubit, SurveyInfoState>(
          listenWhen: (p, c) =>
              p.kecamatanId != c.kecamatanId && c.kecamatanId != null,
          listener: (context, s) =>
              context.read<MasterDataCubit>().loadKelurahan(s.kecamatanId!),
        ),
        // Pesan dari cubit -> snackbar.
        BlocListener<SurveyInfoCubit, SurveyInfoState>(
          listenWhen: (p, c) => p.message != c.message && c.message != null,
          listener: (context, s) {
            _snack(s.message!);
            context.read<SurveyInfoCubit>().clearMessage();
          },
        ),
      ],
      child: BlocBuilder<MasterDataCubit, MasterDataState>(
        builder: (context, master) {
          return BlocBuilder<SurveyInfoCubit, SurveyInfoState>(
            builder: (context, info) {
              final kecItems = master.optionsOf(MasterOptionType.kecamatan);
              final kecLoading = master.isLoading(MasterOptionType.kecamatan);
              final kecError = master.hasError(MasterOptionType.kecamatan);

              final kecId = info.kecamatanId;
              final kelItems = master.kelurahanOf(kecId);
              final kelLoading =
                  kecId != null && master.kelurahanLoadingFor == kecId;
              final kelError =
                  kecId != null && master.kelurahanErrorFor == kecId;

              return Scaffold(
                backgroundColor: const Color(0xFFF5F6F8),
                body: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    BapendaSliverHeader(
                      title: 'Survey Permohonan Baru',
                      showBackButton: true,
                      subtitle: Text(
                        widget.nomorPelayanan,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(18),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (_checkinTersimpan case final c?)
                            _CheckinTersimpanCard(checkin: c)
                          else
                            CheckinCard(
                              // Tampilkan foto berstamp kalau sudah jadi.
                              path: info.selfiePath,
                              // Selfie masuk -> cubit ambil lokasi, geocoding,
                              // lalu bikin stamp.
                              onCaptured: (p) => context
                                  .read<SurveyInfoCubit>()
                                  .onPhotoCaptured(p),
                            ),
                          const SizedBox(height: 14),
                          Container(
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
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: Color(0xFFB8680F),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Informasi Survey',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2933),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                if (_checkinTersimpan == null) ...[
                                  Button(
                                    label: 'Lokasi Saat Ini',
                                    icon: Icons.my_location_rounded,
                                    variant: BapendaButtonVariant.outlined,
                                    height: 44,
                                    isLoading:
                                        info.isLocating || info.isStamping,
                                    onPressed: () => context
                                        .read<SurveyInfoCubit>()
                                        .fetchCurrentLocation(),
                                  ),
                                  _gap,
                                ],
                                Row(
                                  children: [
                                    Expanded(
                                      child: BapendaTextField(
                                        label: 'Latitude *',
                                        controller: _latCtrl,
                                        readOnly: true,
                                        hint: '-',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: BapendaTextField(
                                        label: 'Longitude *',
                                        controller: _lngCtrl,
                                        readOnly: true,
                                        hint: '-',
                                      ),
                                    ),
                                  ],
                                ),
                                _gap,
                                BapendaTextField(
                                  label: 'Alamat',
                                  controller: _alamatCtrl,
                                  readOnly: true,
                                  maxLines: 2,
                                  hint: '-',
                                ),
                                _gap,
                                BtSelectField<String>(
                                  // Key ikut jumlah item & nilai supaya field
                                  // ter-refresh saat selesai dimuat / autofill.
                                  key: ValueKey(
                                    'kec-${kecItems.length}-$kecId',
                                  ),
                                  label: 'Kecamatan',
                                  hint: kecLoading
                                      ? 'Memuat kecamatan...'
                                      : 'Pilih',
                                  items: kecItems,
                                  value: kecId,
                                  onChanged: (v) => context
                                      .read<SurveyInfoCubit>()
                                      .setKecamatan(v),
                                  mandatory: true,
                                ),
                                if (kecError)
                                  _InlineRetry(
                                    message: 'Gagal memuat kecamatan.',
                                    onRetry: () => context
                                        .read<MasterDataCubit>()
                                        .loadOption(
                                          MasterOptionType.kecamatan,
                                          force: true,
                                        ),
                                  ),
                                _gap,
                                BtSelectField<String>(
                                  key: ValueKey(
                                    'kel-$kecId-${kelItems.length}-${info.kelurahanId}',
                                  ),
                                  label: 'Kelurahan',
                                  hint: kecId == null
                                      ? 'Pilih kecamatan dulu'
                                      : kelLoading
                                      ? 'Memuat kelurahan...'
                                      : 'Pilih',
                                  items: kelItems,
                                  value: info.kelurahanId,
                                  onChanged: (v) => context
                                      .read<SurveyInfoCubit>()
                                      .setKelurahan(v),
                                  mandatory: true,
                                ),
                                if (kelError)
                                  _InlineRetry(
                                    message: 'Gagal memuat kelurahan.',
                                    onRetry: () => context
                                        .read<MasterDataCubit>()
                                        .loadKelurahan(kecId, force: true),
                                  ),
                                _gap,
                                Row(
                                  children: [
                                    Expanded(
                                      child: BapendaTextField(
                                        label: 'RT',
                                        controller: _rtCtrl,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: BapendaTextField(
                                        label: 'RW',
                                        controller: _rwCtrl,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                _gap,
                                BapendaTextField(
                                  label: 'Keterangan Lokasi',
                                  controller: _blokCtrl,
                                  hint:
                                      'Jelaskan patokan atau posisi objek secara spesifik',
                                  mandatory: true,
                                ),
                                _gap,
                                BapendaTextField(
                                  label: 'Nama Petugas',
                                  controller: _petugasCtrl,
                                  readOnly: true,
                                  mandatory: true,
                                ),
                                _gap,
                                _buildPembantu(info),
                                _gap,
                                BapendaTextField(
                                  label: 'Tanggal Survey',
                                  controller: _tanggalCtrl,
                                  readOnly: true,
                                ),
                              ],
                            ),
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
                    child: Button(
                      label: 'Lanjutkan',
                      icon: Icons.arrow_forward_rounded,
                      iconAtEnd: true,
                      onPressed: _next,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InlineRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFFD81A48)),
          ),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }
}

/// Check-in draft yang sudah tersimpan di server: ditampilkan saja, petugas
/// tidak perlu selfie & ambil lokasi ulang.
class _CheckinTersimpanCard extends StatelessWidget {
  final Map<String, dynamic> checkin;

  const _CheckinTersimpanCard({required this.checkin});

  @override
  Widget build(BuildContext context) {
    final foto = checkin['fotoUrl'] as String?;
    final tgl = checkin['tglCheckin'] as String?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: foto == null || foto.isEmpty
                ? Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFF5F6F8),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF7B8794),
                    ),
                  )
                : BapendaImage(
                    path: foto,
                    width: 72,
                    height: 72,
                    cacheWidth: 216,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: Color(0xFF1F9D55),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Check-in sudah tersimpan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2933),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Dari draft survey sebelumnya. Tidak perlu foto selfie dan '
                  'ambil lokasi lagi.'
                  '${tgl == null ? '' : '\nCheck-in: $tgl'}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Color(0xFF7B8794),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
