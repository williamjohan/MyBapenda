import 'dart:convert';
import 'dart:io';

import 'package:bapendacore/core/services/geo_location_service.dart';
import 'package:bapendacore/core/storage/app_preference.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:bapendacore/core/theme/adaptive_theme_scope.dart';
import 'package:bapendacore/core/theme/theme_mode_cubit.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/master_pengiriman_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:bapendacore/domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/aksi/aksi_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/aksi/checkin_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/aksi/gagal_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/aksi/scan_berkas_page.dart';
import 'package:bapendacore/presentation/features/pengiriman/pages/aksi/serah_page.dart';
import 'package:bapendacore/presentation/shared/widgets/signature_pad.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/aksi_fakes.dart';

/// PNG 1×1 untuk pratinjau foto (Image.file butuh file asli).
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

const _master = MasterPengirimanEntity(
  alasanGagal: [
    OpsiMasterEntity(id: 1, nama: 'Rumah kosong'),
    OpsiMasterEntity(id: 2, nama: 'Lainnya', wajibKeterangan: true),
  ],
  hubunganPenerima: [
    OpsiMasterEntity(id: 7, nama: 'Pemilik'),
    OpsiMasterEntity(id: 8, nama: 'Karyawan'),
  ],
);

class _Uji {
  final FakeAksiRepository repo;
  final FakeLokasi lokasi;
  final FakeFoto foto;

  /// Hasil `Navigator.pop` halaman aksi (null = belum ditutup).
  Object? hasilPop;
  bool ditutup = false;

  _Uji(this.repo, this.lokasi, this.foto);
}

/// Buka [halaman] dari halaman peluncur supaya hasil pop(true) terbaca.
Future<_Uji> _buka(
  WidgetTester tester,
  Widget halaman, {
  FakeAksiRepository? repo,
  FakeLokasi? lokasi,
  bool butuhMaster = false,
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final dir = Directory.systemTemp.createTempSync('aksi_uji');
  addTearDown(() {
    // Windows: file foto bisa masih dibuka image loader; folder temp saja.
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException catch (_) {}
  });
  final fotoFile = File('${dir.path}/foto.png')..writeAsBytesSync(_png);

  final uji = _Uji(
    repo ?? (FakeAksiRepository()..master = const Right(_master)),
    lokasi ?? FakeLokasi(),
    FakeFoto()..hasil = fotoFile.path,
  );

  SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
  final prefs = AppPreferences(await SharedPreferences.getInstance());

  await tester.pumpWidget(
    BlocProvider(
      create: (_) =>
          ThemeModeCubit(prefs, AppSecureStorage(const FlutterSecureStorage())),
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  uji.hasilPop = await Navigator.of(context).push<Object?>(
                    MaterialPageRoute<Object?>(
                      builder: (_) => BlocProvider(
                        create: (_) => AksiCubit(
                          PengirimanUseCase(uji.repo),
                          uji.lokasi,
                          uji.foto,
                        )..init(butuhMaster: butuhMaster),
                        child: AdaptiveThemeScope(child: halaman),
                      ),
                    ),
                  );
                  uji.ditutup = true;
                },
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('buka'));
  await tester.pumpAndSettle();
  return uji;
}

Future<void> _ketuk(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Gulir isi form sampai [f] terbangun & terlihat (list dibangun malas).
Future<void> _gulirKe(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _kirim(WidgetTester tester, String label) =>
    _ketuk(tester, find.text(label));

/// Ketuk kotak foto [slot] (ambil dari kamera palsu).
Future<void> _foto(WidgetTester tester, FotoSlot slot) async {
  final kotak = find.descendant(
    of: find.ancestor(
      of: find.textContaining(slot.label, findRichText: true),
      matching: find.byType(Column),
    ),
    matching: find.text('Ambil foto'),
  );
  await _ketuk(tester, kotak.first);
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  group('Check-in Tiba / Perjalanan', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('tiba: foto lokasi wajib, lalu tersimpan & kembali '
          '(${mode.name})', (tester) async {
        final uji = await _buka(
          tester,
          const CheckinPage(noResi: 'TGR2', jenis: JenisCheckin.tiba),
          mode: mode,
        );

        expect(find.text('Tiba di Tujuan'), findsOneWidget);
        expect(find.text('Lokasi didapat'), findsOneWidget);
        expect(find.textContaining('-7.290000, 112.750000'), findsOneWidget);

        await _kirim(tester, 'Kirim Check-in Tiba');
        expect(find.text('Foto lokasi wajib saat tiba.'), findsOneWidget);
        expect(uji.repo.payload, isEmpty);

        await _foto(tester, FotoSlot.lokasi);
        expect(find.byTooltip('Ambil ulang'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'Depan pagar');
        await _kirim(tester, 'Kirim Check-in Tiba');

        final p = uji.repo.payload.single as CheckinPayloadEntity;
        expect(p.jenis, JenisCheckin.tiba);
        expect(p.noResi, 'TGR2');
        expect(p.checkin.keterangan, 'Depan pagar');
        expect(p.checkin.fotoLokasiPath, isNotNull);
        expect(uji.ditutup, isTrue);
        expect(uji.hasilPop, isTrue);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('perjalanan: foto opsional, langsung terkirim', (tester) async {
      final uji = await _buka(
        tester,
        const CheckinPage(noResi: 'TGR2', jenis: JenisCheckin.perjalanan),
      );

      expect(find.textContaining('(opsional)', findRichText: true), findsOne);
      await _kirim(tester, 'Kirim Posisi');

      expect(
        (uji.repo.payload.single as CheckinPayloadEntity).jenis,
        JenisCheckin.perjalanan,
      );
      expect(uji.hasilPop, isTrue);
    });

    testWidgets('foto: ambil ulang & hapus', (tester) async {
      final uji = await _buka(
        tester,
        const CheckinPage(noResi: 'TGR2', jenis: JenisCheckin.tiba),
      );

      await _foto(tester, FotoSlot.lokasi);
      await _ketuk(tester, find.byTooltip('Ambil ulang'));
      expect(uji.foto.diminta, hasLength(2));

      await _ketuk(tester, find.byTooltip('Hapus'));
      expect(find.text('Ambil foto'), findsOneWidget);
    });

    testWidgets('GPS mati: tombol kirim nonaktif, buka pengaturan, coba lagi', (
      tester,
    ) async {
      final lokasi = FakeLokasi()
        ..hasil = const GeoLocationException(GeoLocationError.serviceDisabled);
      final uji = await _buka(
        tester,
        const CheckinPage(noResi: 'TGR2', jenis: JenisCheckin.perjalanan),
        lokasi: lokasi,
      );

      expect(find.text('Lokasi gagal'), findsOneWidget);
      expect(find.text('GPS HP mati. Nyalakan GPS.'), findsOneWidget);
      await _kirim(tester, 'Kirim Posisi');
      expect(uji.repo.payload, isEmpty);

      await _ketuk(tester, find.text('Pengaturan'));
      expect(lokasi.dibuka, ['lokasi']);

      lokasi.hasil = posisiUji;
      await _ketuk(tester, find.byTooltip('Perbarui lokasi'));
      expect(find.text('Lokasi didapat'), findsOneWidget);
    });

    testWidgets('akurasi GPS rendah diberi peringatan', (tester) async {
      await _buka(
        tester,
        const CheckinPage(noResi: 'TGR2', jenis: JenisCheckin.perjalanan),
        lokasi: FakeLokasi()
          ..hasil = const GeoPosition(
            latitude: -7.29,
            longitude: 112.75,
            akurasiMeter: 120,
            isMocked: false,
          ),
      );

      expect(
        find.text('Akurasi rendah: tetap terkirim, tapi ditandai review.'),
        findsOneWidget,
      );
    });

    testWidgets('gagal simpan: snackbar, halaman tetap terbuka', (
      tester,
    ) async {
      final uji = await _buka(
        tester,
        const CheckinPage(noResi: 'TGR2', jenis: JenisCheckin.perjalanan),
        repo: FakeAksiRepository()
          ..antreGagalDengan = const CacheFailure(
            'Gagal menyimpan data di HP.',
          ),
      );

      await _kirim(tester, 'Kirim Posisi');

      expect(find.text('Gagal menyimpan data di HP.'), findsOneWidget);
      expect(uji.ditutup, isFalse);
    });
  });

  group('Gagal Antar', () {
    testWidgets('alasan wajib keterangan, foto bukti, lalu tersimpan', (
      tester,
    ) async {
      final uji = await _buka(
        tester,
        const GagalPage(noResi: 'TGR2'),
        butuhMaster: true,
      );

      await _kirim(tester, 'Kirim Laporan Gagal');
      expect(find.text('Pilih alasan gagal antar.'), findsOneWidget);

      await _ketuk(tester, find.text('Lainnya'));
      expect(find.text('Keterangan *'), findsOneWidget);
      await _kirim(tester, 'Kirim Laporan Gagal');
      expect(
        find.text('Keterangan wajib untuk alasan "Lainnya".'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'Pindah alamat');
      await _foto(tester, FotoSlot.gagal);
      await _kirim(tester, 'Kirim Laporan Gagal');

      final p = uji.repo.payload.single as GagalPayloadEntity;
      expect(p.idAlasan, 2);
      expect(p.checkin.keterangan, 'Pindah alamat');
      expect(uji.hasilPop, isTrue);
    });

    testWidgets('master gagal dimuat → muat ulang', (tester) async {
      final repo = FakeAksiRepository()
        ..master = const Left(NoInternetFailure());
      await _buka(
        tester,
        const GagalPage(noResi: 'TGR2'),
        repo: repo,
        butuhMaster: true,
      );

      expect(find.text('Gagal memuat pilihan.'), findsOneWidget);
      repo.master = const Right(_master);
      await _ketuk(tester, find.text('Muat ulang'));

      expect(find.text('Rumah kosong'), findsOneWidget);
    });
  });

  group('Serah Terima', () {
    BerkasEntity b({bool tempel = false, bool objek = false}) => BerkasEntity(
      noResi: 'TGR2',
      jenis: JenisSurat.teguran,
      jenisNama: 'Teguran',
      namaWp: 'CV Sentosa',
      alamatTujuan: 'Jl. Pemuda 1',
      status: StatusBerkas.tiba,
      statusNama: 'Tiba di Tujuan',
      modeTempel: tempel,
      wajibFotoObjek: objek,
    );

    testWidgets('langsung: penerima, hubungan, foto, tanda tangan', (
      tester,
    ) async {
      final uji = await _buka(
        tester,
        SerahPage(berkas: b()),
        butuhMaster: true,
      );

      // Tanpa modeTempel: opsi Ditempel tidak ada.
      expect(find.text('Ditempel'), findsNothing);
      await _kirim(tester, 'Kirim Serah Terima');
      expect(find.text('Pilih cara serah.'), findsOneWidget);

      await _ketuk(tester, find.text('Langsung'));
      await _kirim(tester, 'Kirim Serah Terima');
      expect(find.text('Nama penerima wajib diisi.'), findsOneWidget);
      await _gulirKe(tester, find.byType(SignaturePad));
      expect(find.text('Belum ditandatangani'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Budi');
      await _ketuk(tester, find.text('Pemilik'));
      await _foto(tester, FotoSlot.serah);
      final pad = find.byType(SignaturePad);
      await _gulirKe(tester, pad);
      await tester.drag(pad, const Offset(0, 60));
      await tester.drag(pad, const Offset(80, 0));
      await tester.pumpAndSettle();

      // Ekspor tanda tangan ke PNG memakai IO sungguhan.
      await tester.runAsync(() async {
        await tester.tap(find.text('Kirim Serah Terima'));
        for (var i = 0; i < 50 && uji.repo.payload.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      });
      await tester.pumpAndSettle();

      final p = uji.repo.payload.single as SerahPayloadEntity;
      expect(p.caraSerah, CaraSerah.langsung);
      expect(p.namaPenerima, 'Budi');
      expect(p.idHubungan, 7);
      expect(p.fotoTtdPath, isNotNull);
      expect(File(p.fotoTtdPath!).existsSync(), isTrue);
      File(p.fotoTtdPath!).deleteSync();
      expect(uji.hasilPop, isTrue);
    });

    testWidgets('ditempel: foto tempel + lokasi (+ objek bila wajib)', (
      tester,
    ) async {
      final uji = await _buka(
        tester,
        SerahPage(berkas: b(tempel: true, objek: true)),
        butuhMaster: true,
      );

      await _ketuk(tester, find.text('Ditempel'));
      expect(find.byType(SignaturePad), findsNothing);

      await _kirim(tester, 'Kirim Serah Terima');
      expect(find.text('Foto surat tertempel wajib.'), findsOneWidget);
      await _foto(tester, FotoSlot.tempel);
      await _foto(tester, FotoSlot.lokasi);
      await _kirim(tester, 'Kirim Serah Terima');
      expect(
        find.text('Foto objek pajak wajib untuk berkas ini.'),
        findsOneWidget,
      );
      await _foto(tester, FotoSlot.objek);
      await _kirim(tester, 'Kirim Serah Terima');

      final p = uji.repo.payload.single as SerahPayloadEntity;
      expect(p.caraSerah, CaraSerah.ditempel);
      expect(p.fotoTempelPath, isNotNull);
      expect(p.fotoObjekPath, isNotNull);
      expect(p.namaPenerima, isNull);
    });
  });

  group('Scan Ambil / Kembalikan', () {
    testWidgets('ambil: daftar resi, hapus, foto wajib, lembar hasil', (
      tester,
    ) async {
      final repo = FakeAksiRepository()
        ..ambil = const Right([
          HasilCheckinEntity(noResi: 'A', statusNama: 'Diambil'),
          HasilCheckinEntity(
            noResi: 'B',
            diabaikan: true,
            pesan: 'Bukan tugas Anda',
          ),
        ]);
      final uji = await _buka(
        tester,
        const ScanBerkasPage(mode: ModeScanBerkas.ambil, awal: ['A', 'B', 'C']),
        repo: repo,
      );

      expect(find.text('3 berkas terscan'.toUpperCase()), findsOneWidget);
      await _ketuk(tester, find.byTooltip('Hapus').last);
      expect(find.text('Ambil 2 Surat'), findsOneWidget);

      await _kirim(tester, 'Ambil 2 Surat');
      expect(find.text('Foto pengambilan wajib.'), findsOneWidget);

      await _foto(tester, FotoSlot.ambil);
      await _kirim(tester, 'Ambil 2 Surat');

      expect((uji.repo.payload.single as AmbilPayloadEntity).noResiList, [
        'A',
        'B',
      ]);
      expect(find.text('Surat berhasil diambil'), findsOneWidget);
      expect(find.text('1 dari 2 berkas berhasil diproses'), findsOneWidget);
      expect(find.text('Bukan tugas Anda'), findsOneWidget);
      expect(uji.ditutup, isFalse);

      await _ketuk(tester, find.text('Selesai'));
      expect(uji.hasilPop, isTrue);
    });

    testWidgets('kembalikan: masuk antrean; tanpa resi ditolak', (
      tester,
    ) async {
      final uji = await _buka(
        tester,
        const ScanBerkasPage(mode: ModeScanBerkas.kembalikan, awal: ['A']),
      );

      expect(find.text('Kembalikan Surat'), findsOneWidget);
      await _ketuk(tester, find.byTooltip('Hapus'));
      expect(find.textContaining('Belum ada berkas'), findsOneWidget);
      await _kirim(tester, 'Kembalikan 0 Surat');
      expect(find.text('Scan minimal satu QR berkas.'), findsOneWidget);
      expect(uji.repo.payload, isEmpty);
    });

    testWidgets('kembalikan: terkirim ke antrean lalu kembali', (tester) async {
      final uji = await _buka(
        tester,
        const ScanBerkasPage(mode: ModeScanBerkas.kembalikan, awal: ['A']),
      );

      await _kirim(tester, 'Kembalikan 1 Surat');

      expect((uji.repo.payload.single as KembalikanPayloadEntity).noResiList, [
        'A',
      ]);
      expect(uji.hasilPop, isTrue);
    });
  });
}
