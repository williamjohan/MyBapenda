import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/services/geo_location_service.dart';
import 'package:bapendacore/domain/entities/pengiriman/antrean_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/master_pengiriman_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:bapendacore/domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/aksi/aksi_cubit.dart';
import 'package:bapendacore/presentation/features/pengiriman/cubit/aksi/aksi_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/aksi_fakes.dart';

void main() {
  late FakeAksiRepository repo;
  late FakeLokasi lokasi;
  late FakeFoto foto;
  late AksiCubit cubit;

  setUp(() {
    repo = FakeAksiRepository();
    lokasi = FakeLokasi();
    foto = FakeFoto();
    cubit = AksiCubit(PengirimanUseCase(repo), lokasi, foto);
  });

  tearDown(() => cubit.close());

  group('lokasi', () {
    test('GPS siap', () async {
      await cubit.cariLokasi();
      expect(cubit.state.lokasiStatus, LokasiStatus.siap);
      expect(cubit.state.lokasiSiap, isTrue);
    });

    test('Fake GPS ditolak', () async {
      lokasi.hasil = const GeoPosition(
        latitude: 0,
        longitude: 0,
        akurasiMeter: 1,
        isMocked: true,
      );
      await cubit.cariLokasi();

      expect(cubit.state.lokasiStatus, LokasiStatus.gagal);
      expect(cubit.state.lokasiError, contains('Fake GPS'));
      expect(cubit.state.lokasiSiap, isFalse);
    });

    test('galat GPS → pesan sesuai, tombol pengaturan tepat', () async {
      lokasi.hasil = const GeoLocationException(
        GeoLocationError.serviceDisabled,
      );
      await cubit.cariLokasi();
      expect(cubit.state.lokasiError, 'GPS HP mati. Nyalakan GPS.');
      await cubit.bukaPengaturanLokasi();

      lokasi.hasil = const GeoLocationException(
        GeoLocationError.permissionDeniedForever,
      );
      await cubit.cariLokasi();
      await cubit.bukaPengaturanLokasi();

      lokasi.hasil = const GeoLocationException(GeoLocationError.timeout);
      await cubit.cariLokasi();
      await cubit.bukaPengaturanLokasi();

      expect(lokasi.dibuka, ['lokasi', 'aplikasi']);
    });

    test('coba lagi berhasil: galat lama hilang', () async {
      lokasi.hasil = const GeoLocationException(GeoLocationError.timeout);
      await cubit.cariLokasi();
      lokasi.hasil = posisiUji;
      await cubit.cariLokasi();

      expect(cubit.state.lokasiStatus, LokasiStatus.siap);
      expect(cubit.state.lokasiError, isNull);
      expect(cubit.state.lokasiErrorKode, isNull);
    });
  });

  group('master', () {
    test('init dengan master: lokasi & master dimuat', () async {
      repo.master = const Right(
        MasterPengirimanEntity(
          alasanGagal: [OpsiMasterEntity(id: 1, nama: 'Rumah kosong')],
        ),
      );
      await cubit.init(butuhMaster: true);

      expect(cubit.state.lokasiSiap, isTrue);
      expect(cubit.state.master!.alasanGagal.single.nama, 'Rumah kosong');
    });

    test('master gagal → ditandai, bisa dicoba lagi', () async {
      repo.master = const Left(NoInternetFailure());
      await cubit.muatMaster();
      expect(cubit.state.masterGagal, isTrue);

      repo.master = const Right(MasterPengirimanEntity());
      await cubit.muatMaster();
      expect(cubit.state.masterGagal, isFalse);
    });
  });

  group('foto', () {
    test('ambil: path tersimpan per slot, lokasi ikut ke cap foto', () async {
      await cubit.cariLokasi();
      await cubit.ambilFoto(FotoSlot.gagal, noResi: 'A');

      expect(cubit.state.foto, {FotoSlot.gagal: '/tmp/foto.jpg'});
      expect(cubit.state.fotoDiproses, isNull);
      expect(foto.diminta.single.judul, FotoSlot.gagal.label);
      expect(foto.diminta.single.lokasi, posisiUji);
    });

    test('dibatalkan: foto lama tidak berubah', () async {
      await cubit.ambilFoto(FotoSlot.serah, noResi: 'A');
      foto.hasil = null;
      await cubit.ambilFoto(FotoSlot.serah, noResi: 'A');

      expect(cubit.state.foto[FotoSlot.serah], '/tmp/foto.jpg');
    });

    test('gagal proses → pesan error, slot tidak terisi', () async {
      foto.hasil = Exception('kompres gagal');
      await cubit.ambilFoto(FotoSlot.tempel, noResi: 'A');

      expect(cubit.state.foto, isEmpty);
      expect(cubit.state.fotoDiproses, isNull);
      expect(cubit.state.error, 'Gagal memproses foto. Coba ambil ulang.');
    });

    test('hapus foto', () async {
      await cubit.ambilFoto(FotoSlot.objek, noResi: 'A');
      cubit.hapusFoto(FotoSlot.objek);
      expect(cubit.state.foto, isEmpty);
    });
  });

  test('pesan validasi yang sama tetap dikirim ulang (snackbar)', () async {
    final errors = <String?>[];
    final sub = cubit.stream.listen((s) => errors.add(s.error));
    cubit
      ..tampilkanError('Nama penerima wajib diisi.')
      ..tampilkanError('Nama penerima wajib diisi.');
    await Future<void>.delayed(Duration.zero);

    expect(errors.whereType<String>(), hasLength(2));
    await sub.cancel();
  });

  group('kirim', () {
    test('tanpa lokasi: tidak dikirim, minta tunggu GPS', () async {
      await cubit.kirimCheckin(JenisCheckin.perjalanan, 'A');

      expect(repo.payload, isEmpty);
      expect(cubit.state.kirim, KirimStatus.idle);
      expect(cubit.state.error, 'Lokasi belum didapat. Tunggu GPS siap.');
    });

    test('isian wajib (aturan usecase) dicek sebelum kirim', () async {
      await cubit.cariLokasi();

      await cubit.kirimCheckin(JenisCheckin.tiba, 'A');
      expect(cubit.state.error, 'Foto lokasi wajib saat tiba.');
      await cubit.kirimAmbil(const []);
      expect(cubit.state.error, 'Scan minimal satu QR berkas.');
      await cubit.kirimKembalikan(const []);
      expect(cubit.state.error, 'Scan minimal satu QR berkas.');
      await cubit.kirimGagal(noResi: 'A', alasan: null);
      expect(cubit.state.error, 'Pilih alasan gagal antar.');
      expect(
        cubit.cekSerah(
          cara: CaraSerah.langsung,
          namaPenerima: '',
          idHubungan: null,
          adaTtd: false,
          wajibFotoObjek: false,
        ),
        isFalse,
      );
      expect(cubit.state.error, 'Nama penerima wajib diisi.');

      expect(repo.payload, isEmpty);
      expect(cubit.state.kirim, KirimStatus.idle);

      await cubit.ambilFoto(FotoSlot.tempel, noResi: 'A');
      await cubit.ambilFoto(FotoSlot.lokasi, noResi: 'A');
      expect(
        cubit.cekSerah(
          cara: CaraSerah.ditempel,
          namaPenerima: '',
          idHubungan: null,
          adaTtd: false,
          wajibFotoObjek: false,
        ),
        isTrue,
      );
    });

    test('ambil: online, hasil per berkas, check-in dari GPS', () async {
      await cubit.cariLokasi();
      await cubit.ambilFoto(FotoSlot.ambil, noResi: 'A');
      await cubit.kirimAmbil(['A', 'B']);

      final p = repo.payload.single as AmbilPayloadEntity;
      expect(p.noResiList, ['A', 'B']);
      expect(p.fotoAmbilPath, '/tmp/foto.jpg');
      expect(p.checkin.latitude, posisiUji.latitude);
      expect(p.checkin.isMockLocation, isFalse);
      expect(p.checkin.checkinUuid, hasLength(36));
      expect(cubit.state.kirim, KirimStatus.sukses);
      expect(cubit.state.hasil.single.noResi, 'A');
      expect(cubit.state.antrean, isNull);
    });

    test('ambil ditolak server → status gagal + pesan', () async {
      repo.ambil = const Left(ServerFailure('Berkas bukan tugas Anda.'));
      await cubit.cariLokasi();
      await cubit.ambilFoto(FotoSlot.ambil, noResi: 'A');
      await cubit.kirimAmbil(['A']);

      expect(cubit.state.kirim, KirimStatus.gagal);
      expect(cubit.state.error, 'Berkas bukan tugas Anda.');
    });

    test('tiba: masuk antrean, foto lokasi & keterangan ikut', () async {
      await cubit.cariLokasi();
      await cubit.ambilFoto(FotoSlot.lokasi, noResi: 'A');
      await cubit.kirimCheckin(JenisCheckin.tiba, 'A', keterangan: 'Pagar');

      final p = repo.payload.single as CheckinPayloadEntity;
      expect(p.jenis, JenisCheckin.tiba);
      expect(p.checkin.fotoLokasiPath, '/tmp/foto.jpg');
      expect(p.checkin.keterangan, 'Pagar');
      expect(cubit.state.kirim, KirimStatus.sukses);
      expect(cubit.state.antrean!.jenis, JenisAksiAntrean.tiba);
    });

    test('serah langsung: data penerima dikirim, foto tempel tidak', () async {
      await cubit.cariLokasi();
      await cubit.ambilFoto(FotoSlot.serah, noResi: 'A');
      await cubit.ambilFoto(FotoSlot.tempel, noResi: 'A');
      await cubit.kirimSerah(
        noResi: 'A',
        cara: CaraSerah.langsung,
        namaPenerima: 'Budi',
        idHubungan: 2,
        fotoTtdPath: '/tmp/ttd.png',
      );

      final p = repo.payload.single as SerahPayloadEntity;
      expect(p.namaPenerima, 'Budi');
      expect(p.idHubungan, 2);
      expect(p.fotoSerahPath, '/tmp/foto.jpg');
      expect(p.fotoTtdPath, '/tmp/ttd.png');
      expect(p.fotoTempelPath, isNull);
    });

    test(
      'serah ditempel: data penerima dibuang, foto tempel dikirim',
      () async {
        await cubit.cariLokasi();
        await cubit.ambilFoto(FotoSlot.tempel, noResi: 'A');
        await cubit.kirimSerah(
          noResi: 'A',
          cara: CaraSerah.ditempel,
          namaPenerima: 'sisa ketikan',
          idHubungan: 2,
          fotoTtdPath: '/tmp/ttd.png',
        );

        final p = repo.payload.single as SerahPayloadEntity;
        expect(p.namaPenerima, isNull);
        expect(p.idHubungan, isNull);
        expect(p.fotoTtdPath, isNull);
        expect(p.fotoSerahPath, isNull);
        expect(p.fotoTempelPath, '/tmp/foto.jpg');
      },
    );

    test('gagal antar & kembalikan masuk antrean', () async {
      await cubit.cariLokasi();
      await cubit.ambilFoto(FotoSlot.gagal, noResi: 'A');
      await cubit.kirimGagal(
        noResi: 'A',
        alasan: const OpsiMasterEntity(id: 3, nama: 'Rumah kosong'),
        keterangan: 'Kosong',
      );

      final g = repo.payload.single as GagalPayloadEntity;
      expect(g.idAlasan, 3);
      expect(g.fotoGagalPath, '/tmp/foto.jpg');
      expect(cubit.state.antrean!.jenis, JenisAksiAntrean.gagal);

      final c2 = AksiCubit(PengirimanUseCase(repo), lokasi, foto);
      await c2.cariLokasi();
      await c2.kirimKembalikan(['A', 'B']);
      final k = repo.payload.last as KembalikanPayloadEntity;
      expect(k.noResiList, ['A', 'B']);
      expect(c2.state.antrean!.jenis, JenisAksiAntrean.kembalikan);
      await c2.close();
    });

    test('gagal simpan antrean → status gagal + pesan', () async {
      repo.antreGagalDengan = const CacheFailure('Gagal menyimpan data di HP.');
      await cubit.cariLokasi();
      await cubit.kirimCheckin(JenisCheckin.perjalanan, 'A');

      expect(cubit.state.kirim, KirimStatus.gagal);
      expect(cubit.state.error, 'Gagal menyimpan data di HP.');
    });

    test('ketuk ganda saat mengirim: hanya terkirim sekali', () async {
      await cubit.cariLokasi();
      await Future.wait([
        cubit.kirimCheckin(JenisCheckin.perjalanan, 'A'),
        cubit.kirimCheckin(JenisCheckin.perjalanan, 'A'),
      ]);

      expect(repo.payload, hasLength(1));
    });
  });
}
