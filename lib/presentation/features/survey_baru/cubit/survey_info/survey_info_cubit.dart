import 'dart:async';
import 'dart:io';

import 'package:bapendacore/domain/usecases/auth/auth_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/usecases/master_data_usecase.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/utils/foto_stamp_util.dart';
import 'package:bapendacore/presentation/shared/utils/location_util.dart';

import 'survey_info_state.dart';

class SurveyInfoCubit extends Cubit<SurveyInfoState> {
  final String nomorPelayanan;
  final MasterDataUseCase _master;
  final AuthUseCase _auth;
  String? _prefillKec;
  String? _prefillKel;

  // Setiap operasi baru membatalkan hasil operasi sebelumnya.
  int _operationId = 0;

  SurveyInfoCubit({
    required this.nomorPelayanan,
    required MasterDataUseCase masterUseCase,
    required AuthUseCase authUseCase,
  }) : _master = masterUseCase,
       _auth = authUseCase,
       super(const SurveyInfoState());

  bool _isCurrentOperation(int id) => !isClosed && id == _operationId;

  // ---------------------------------------------------------------------------
  // PETUGAS
  // ---------------------------------------------------------------------------

  /// Petugas utama = user yang sedang login.
  Future<void> loadPetugas() async {
    try {
      final user = await _auth.getCurrentUserProfile();
      if (isClosed) return;
      final nama = user?.nama; // sesuaikan dengan field nama di UserEntity
      final nipRaw = user?.nip; // sesuaikan dengan field NIP di UserEntity
      final nip = nipRaw?.toString().trim();
      if (nama == null || nama.isEmpty) {
        emit(
          state.copyWith(
            message: 'Data petugas tidak ditemukan. Coba login ulang.',
            messageType: SurveyInfoMessageType.error,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          namaPetugas: nama,
          nipPetugas: (nip == null || nip.isEmpty) ? null : nip,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          message: 'Gagal memuat data petugas.',
          messageType: SurveyInfoMessageType.error,
        ),
      );
    }
  }

  void applyPrefill({
    String? kecamatanId,
    String? kelurahanId,
    List<String> nipPembantu = const [],
  }) {
    _prefillKec = kecamatanId;
    _prefillKel = kelurahanId;
    emit(
      state.copyWith(
        kecamatanId: kecamatanId,
        kelurahanId: kelurahanId,
        nipPembantu: nipPembantu,
      ),
    );
  }

  void addPembantu(String nip) {
    if (state.nipPembantu.contains(nip)) return;
    emit(state.copyWith(nipPembantu: [...state.nipPembantu, nip]));
  }

  void removePembantu(String nip) => emit(
    state.copyWith(
      nipPembantu: state.nipPembantu.where((e) => e != nip).toList(),
    ),
  );

  // ---------------------------------------------------------------------------
  // FOTO & LOKASI
  // ---------------------------------------------------------------------------

  Future<void> _deleteStampFile(String? path, {String? exceptPath}) async {
    if (path == null || path.isEmpty || path == exceptPath) {
      return;
    }

    final prefix =
        '${Directory.systemTemp.path}${Platform.pathSeparator}stamp_';

    if (!path.startsWith(prefix)) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Kegagalan cleanup tidak boleh menggagalkan survey.
    }
  }

  /// Dipanggil setelah foto baru berhasil diambil.
  ///
  /// Operasi sebelumnya langsung dianggap kedaluwarsa.
  Future<void> onPhotoCaptured(String path) async {
    final previousStamp = state.isPhotoStamped ? state.selfiePath : null;

    final operationId = ++_operationId;

    emit(
      state.copyWith(
        originalPhotoPath: path,
        selfiePath: path,
        photoCapturedAt: DateTime.now(),
        isPhotoStamped: false,
        clearLocation: true,
        kecamatanId: _prefillKec,
        kelurahanId: _prefillKel,
        clearKecamatan: _prefillKec == null,
        clearKelurahan: _prefillKel == null,
        isLocating: true,
        isStamping: false,
        clearMessage: true,
      ),
    );

    await _deleteStampFile(previousStamp, exceptPath: path);

    if (!_isCurrentOperation(operationId)) return;

    await _fetchLocationAndStamp(operationId);
  }

  Future<void> fetchCurrentLocation() async {
    if (state.isLocating || state.isStamping) return;

    final previousStamp = state.isPhotoStamped ? state.selfiePath : null;

    final originalPath = state.originalPhotoPath;
    final operationId = ++_operationId;

    emit(
      state.copyWith(
        // Jangan tampilkan stamp lama ketika sedang membuat stamp baru.
        selfiePath: originalPath ?? state.selfiePath,
        isPhotoStamped: originalPath == null ? state.isPhotoStamped : false,
        isLocating: true,
        isStamping: false,
        clearMessage: true,
      ),
    );

    await _deleteStampFile(previousStamp, exceptPath: originalPath);

    if (!_isCurrentOperation(operationId)) return;

    await _fetchLocationAndStamp(operationId);
  }

  String _norm(String? value) => (value ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'^(kecamatan|kelurahan|kec\.|kel\.)\s*'), '')
      .trim();

  static final _rtRe = RegExp(
    r'\bRT\.?\s*[:\-]?\s*0*(\d{1,3})',
    caseSensitive: false,
  );
  static final _rwRe = RegExp(
    r'\bRW\.?\s*[:\-]?\s*0*(\d{1,3})',
    caseSensitive: false,
  );
  // Format gabungan: "RT/RW 02/03"
  static final _rtRwRe = RegExp(
    r'\bRT\s*/\s*RW\s*[:\-]?\s*0*(\d{1,3})\s*/\s*0*(\d{1,3})',
    caseSensitive: false,
  );

  ({String? rt, String? rw}) _parseRtRw(Placemark p) {
    final text = [
      p.name,
      p.street,
      p.thoroughfare,
      p.subThoroughfare,
      p.subLocality,
    ].where((e) => (e ?? '').trim().isNotEmpty).join(', ');

    final combined = _rtRwRe.firstMatch(text);
    if (combined != null) {
      return (rt: combined.group(1), rw: combined.group(2));
    }
    return (
      rt: _rtRe.firstMatch(text)?.group(1),
      rw: _rwRe.firstMatch(text)?.group(1),
    );
  }

  /// Cocokkan nama dari geocoding ke master. Return ID (String) atau null.
  String? _matchId(Map<String, String> items, Iterable<String?> candidates) {
    final names = candidates
        .map(_norm)
        .where((name) => name.isNotEmpty)
        .toList();

    // 1. Prioritaskan kandidat alamat sesuai urutannya.
    // Kandidat pertama, misalnya "Ketabang", harus diperiksa dahulu.
    for (final candidate in names) {
      for (final entry in items.entries) {
        if (_norm(entry.value) == candidate) {
          return entry.key;
        }
      }
    }

    // 2. Fallback partial match jika tidak ada exact match.
    // Prioritas kandidat alamat tetap dipertahankan.
    for (final candidate in names) {
      for (final entry in items.entries) {
        final name = _norm(entry.value);

        if (name.isNotEmpty && candidate.contains(name)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  Future<
    ({
      String address,
      String? kecamatanId,
      String? kelurahanId,
      String? rt,
      String? rw,
    })
  >
  _reverseGeocode(double lat, double lng) async {
    const empty = (
      address: '-',
      kecamatanId: null,
      kelurahanId: null,
      rt: null,
      rw: null,
    );

    try {
      await setLocaleIdentifier('id_ID');

      final marks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 8));

      if (marks.isEmpty) return empty;

      final placemark = marks.first;

      final parts = <String?>[
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
        placemark.postalCode,
        placemark.country,
      ].map((part) => (part ?? '').trim()).where((part) => part.isNotEmpty);

      final uniqueParts = <String>[];
      for (final part in parts) {
        if (!uniqueParts.any(
          (existing) => existing.toLowerCase() == part.toLowerCase(),
        )) {
          uniqueParts.add(part);
        }
      }

      final address = uniqueParts.isEmpty ? '-' : uniqueParts.join(', ');

      final kecItems = (await _master.getOptions(
        MasterOptionType.kecamatan,
      )).getOrElse(() => const <String, String>{});

      final kecamatanId = _matchId(kecItems, [
        placemark.subAdministrativeArea,
        placemark.locality,
        placemark.subLocality,
      ]);

      String? kelurahanId;
      if (kecamatanId != null) {
        final kelItems = (await _master.getKelurahan(
          kecamatanId,
        )).getOrElse(() => const <String, String>{});

        kelurahanId = _matchId(kelItems, [
          placemark.subLocality,
          placemark.locality,
        ]);
      }

      final rtRw = _parseRtRw(placemark);

      return (
        address: address,
        kecamatanId: kecamatanId,
        kelurahanId: kelurahanId,
        rt: rtRw.rt,
        rw: rtRw.rw,
      );
    } catch (_) {
      return empty;
    }
  }

  Future<void> _fetchLocationAndStamp(int operationId) async {
    if (!_isCurrentOperation(operationId)) return;

    try {
      final fix = await LocationUtil.current();

      if (!_isCurrentOperation(operationId)) return;

      // Simpan GPS sebelum reverse geocoding.
      emit(
        state.copyWith(
          latitude: fix.lat,
          longitude: fix.lng,
          accuracy: fix.accuracy,
          gpsTime: fix.time,
        ),
      );

      final geo = await _reverseGeocode(fix.lat, fix.lng);

      if (!_isCurrentOperation(operationId)) return;
      final String? nextKecamatanId = geo.kecamatanId ?? state.kecamatanId;

      final String? nextKelurahanId = geo.kecamatanId != null
          ? geo.kelurahanId
          : state.kelurahanId;

      emit(
        state.copyWith(
          address: geo.address,
          rt: geo.rt,
          rw: geo.rw,
          kecamatanId: nextKecamatanId,
          clearKecamatan: nextKecamatanId == null,
          kelurahanId: nextKelurahanId,
          clearKelurahan: nextKelurahanId == null,
        ),
      );

      final sourcePath = state.originalPhotoPath;
      final capturedAt = state.photoCapturedAt;

      // GPS boleh diambil sebelum foto diambil.
      if (sourcePath == null || capturedAt == null) {
        emit(
          state.copyWith(
            message: geo.address == '-'
                ? 'Koordinat didapat, tetapi alamat tidak ditemukan.'
                : 'Lokasi berhasil diperbarui.',
            messageType: SurveyInfoMessageType.info,
          ),
        );
        return;
      }

      // Selama stamp dibuat, hanya foto asli yang dipertahankan.
      emit(
        state.copyWith(
          selfiePath: sourcePath,
          isPhotoStamped: false,
          isStamping: true,
        ),
      );

      String? stampedPath;

      try {
        stampedPath = await FotoStampUtil.stamp(
          sourcePath: sourcePath,
          title: 'BUKTI SURVEI • $nomorPelayanan',
          lines: [
            '${DateUtil.hari(capturedAt)}, '
                '${DateUtil.tanggal(capturedAt)} / '
                '${DateUtil.jam(capturedAt)} WIB',
            'Lokasi: ${geo.address}',
            if (geo.rt != null && geo.rw != null) 'RT/RW: ${geo.rt}/${geo.rw}',
            'Latitude: ${fix.lat.toStringAsFixed(6)}, Longitude: ${fix.lng.toStringAsFixed(6)}',
            'Akurasi GPS: ±${fix.accuracy.round()} meter',
          ],
        );

        // Jika ada foto/operasi baru, jangan gunakan hasil lama.
        if (!_isCurrentOperation(operationId)) {
          await _deleteStampFile(stampedPath);
          return;
        }

        emit(
          state.copyWith(
            selfiePath: stampedPath,
            isPhotoStamped: true,
            message: geo.address == '-'
                ? 'Foto diberi stamp, tetapi alamat tidak ditemukan. Cek wilayah secara manual.'
                : (geo.kecamatanId == null || geo.kelurahanId == null)
                ? 'Foto berhasil diberi stamp. Cek kecamatan dan kelurahan.'
                : 'Foto berhasil diberi stamp lokasi.',
            messageType: SurveyInfoMessageType.success,
          ),
        );
      } catch (error) {
        if (!_isCurrentOperation(operationId)) {
          if (stampedPath != null) {
            await _deleteStampFile(stampedPath);
          }
          return;
        }

        emit(
          state.copyWith(
            selfiePath: sourcePath,
            isPhotoStamped: false,
            message: 'Gagal membuat stamp foto: $error',
            messageType: SurveyInfoMessageType.error,
          ),
        );
      }
    } on LocationException catch (error) {
      if (!_isCurrentOperation(operationId)) return;

      emit(
        state.copyWith(
          message: state.originalPhotoPath == null
              ? error.message
              : '${error.message} Foto belum memiliki stamp lokasi. '
                    'Tekan "Lokasi Saat Ini" untuk mencoba lagi.',
          messageType: SurveyInfoMessageType.error,
        ),
      );
    } on TimeoutException {
      if (!_isCurrentOperation(operationId)) return;

      emit(
        state.copyWith(
          message: 'Sinyal GPS lemah, coba lagi di area lebih terbuka.',
          messageType: SurveyInfoMessageType.error,
        ),
      );
    } catch (error) {
      if (!_isCurrentOperation(operationId)) return;

      emit(
        state.copyWith(
          message: 'Gagal mengambil lokasi: $error',
          messageType: SurveyInfoMessageType.error,
        ),
      );
    } finally {
      // Proses lama tidak boleh mengubah loading state proses baru.
      if (_isCurrentOperation(operationId)) {
        emit(state.copyWith(isLocating: false, isStamping: false));
      }
    }
  }

  void setKecamatan(String? id) {
    emit(
      state.copyWith(
        kecamatanId: id,
        clearKecamatan: id == null,
        clearKelurahan: true,
        clearMessage: true,
      ),
    );
  }

  void setKelurahan(String? id) {
    emit(
      state.copyWith(
        kelurahanId: id,
        clearKelurahan: id == null,
        clearMessage: true,
      ),
    );
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  @override
  Future<void> close() {
    // Invalidasi seluruh operasi asynchronous saat Cubit ditutup.
    _operationId++;
    return super.close();
  }
}
