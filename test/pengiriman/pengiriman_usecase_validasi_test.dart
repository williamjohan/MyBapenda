import 'package:mybapenda/domain/entities/pengiriman/master_pengiriman_entity.dart';
import 'package:mybapenda/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:mybapenda/domain/usecases/pengiriman/pengiriman_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pengiriman_fakes.dart';

void main() {
  // Aturan isian wajib aksi ada di usecase (domain), tanpa akses repository.
  final uc = PengirimanUseCase(FakePengirimanRepository());

  group('serah', () {
    String? serah({
      CaraSerah? cara = CaraSerah.langsung,
      String nama = 'Budi',
      int? idHubungan = 1,
      bool adaTtd = true,
      bool wajibFotoObjek = false,
      Set<FotoSlot> foto = const {FotoSlot.serah},
    }) => uc.validasiSerah(
      cara: cara,
      namaPenerima: nama,
      idHubungan: idHubungan,
      adaTtd: adaTtd,
      wajibFotoObjek: wajibFotoObjek,
      foto: foto,
    );

    test('langsung lengkap: lolos', () => expect(serah(), isNull));

    test('langsung: penerima, hubungan, foto, TTD wajib', () {
      expect(serah(nama: ' '), contains('Nama penerima'));
      expect(serah(idHubungan: null), contains('hubungan'));
      expect(serah(foto: {}), contains('Foto penyerahan'));
      expect(serah(adaTtd: false), contains('tanda tangan'));
    });

    test('ditempel: tanpa penerima, wajib foto tempel + lokasi', () {
      expect(
        serah(
          cara: CaraSerah.ditempel,
          nama: '',
          idHubungan: null,
          adaTtd: false,
          foto: {FotoSlot.tempel},
        ),
        contains('Foto lokasi'),
      );
      expect(
        serah(
          cara: CaraSerah.ditempel,
          nama: '',
          adaTtd: false,
          foto: {FotoSlot.tempel, FotoSlot.lokasi},
        ),
        isNull,
      );
    });

    test('foto objek wajib bila berkas wajibFotoObjek', () {
      expect(serah(wajibFotoObjek: true), contains('objek'));
      expect(
        serah(wajibFotoObjek: true, foto: {FotoSlot.serah, FotoSlot.objek}),
        isNull,
      );
    });
  });

  test('gagal: keterangan wajib hanya bila alasan wajibKeterangan', () {
    const lainnya = OpsiMasterEntity(
      id: 9,
      nama: 'Lainnya',
      wajibKeterangan: true,
    );
    const kosong = OpsiMasterEntity(id: 1, nama: 'Rumah kosong');
    const foto = {FotoSlot.gagal};

    expect(
      uc.validasiGagal(alasan: lainnya, keterangan: '', foto: foto),
      contains('Keterangan'),
    );
    expect(
      uc.validasiGagal(alasan: kosong, keterangan: '', foto: foto),
      isNull,
    );
    expect(
      uc.validasiGagal(alasan: kosong, keterangan: '', foto: const {}),
      contains('Foto'),
    );
  });

  test('tiba wajib foto lokasi; ambil wajib resi + foto', () {
    expect(uc.validasiTiba(const {}), isNotNull);
    expect(uc.validasiTiba(const {FotoSlot.lokasi}), isNull);
    expect(
      uc.validasiAmbil(jumlahResi: 0, foto: const {FotoSlot.ambil}),
      isNotNull,
    );
    expect(
      uc.validasiAmbil(jumlahResi: 2, foto: const {FotoSlot.ambil}),
      isNull,
    );
  });

  test('kembalikan wajib minimal satu resi', () {
    expect(uc.validasiKembalikan(jumlahResi: 0), isNotNull);
    expect(uc.validasiKembalikan(jumlahResi: 1), isNull);
  });
}
