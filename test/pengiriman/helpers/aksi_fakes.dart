// import 'package:mybapenda/core/errors/failure.dart';
// import 'package:mybapenda/core/services/geo_location_service.dart';
// import 'package:mybapenda/domain/entities/pengiriman/antrean_entity.dart';
// import 'package:mybapenda/domain/entities/pengiriman/master_pengiriman_entity.dart';
// import 'package:mybapenda/domain/entities/pengiriman/pengiriman_payload_entity.dart';
// import 'package:mybapenda/domain/repositories/pengiriman/i_pengiriman_repository.dart';
// import 'package:mybapenda/presentation/features/pengiriman/utils/pengiriman_foto.dart';
// import 'package:dartz/dartz.dart';

// const posisiUji = GeoPosition(
//   latitude: -7.29,
//   longitude: 112.75,
//   akurasiMeter: 8,
//   isMocked: false,
// );

// class FakeLokasi implements GeoLocationService {
//   /// GeoPosition atau GeoLocationException.
//   Object hasil = posisiUji;
//   final dibuka = <String>[];

//   @override
//   Future<GeoPosition> getCurrentPosition() async {
//     final h = hasil;
//     if (h is GeoLocationException) throw h;
//     return h as GeoPosition;
//   }

//   @override
//   Future<void> openLocationSettings() async => dibuka.add('lokasi');

//   @override
//   Future<void> openAppSettings() async => dibuka.add('aplikasi');
// }

// class FakeFoto implements PengirimanFoto {
//   /// Path hasil, null = dibatalkan, Exception = gagal proses.
//   Object? hasil = '/tmp/foto.jpg';
//   final diminta = <({String judul, String noResi, GeoPosition? lokasi})>[];

//   @override
//   Future<String?> ambil({
//     required String judul,
//     required String noResi,
//     GeoPosition? lokasi,
//   }) async {
//     diminta.add((judul: judul, noResi: noResi, lokasi: lokasi));
//     final h = hasil;
//     if (h is Exception) throw h;
//     return h as String?;
//   }
// }

// AntreanPengirimanEntity antreanUji(JenisAksiAntrean jenis) =>
//     AntreanPengirimanEntity(
//       checkinUuid: 'u',
//       jenis: jenis,
//       noResi: const ['A'],
//       tglDibuat: DateTime(2026, 10, 15),
//     );

// /// Repository palsu: catat payload, balas sesuai field yang diatur tes.
// class FakeAksiRepository implements IPengirimanRepository {
//   Either<Failure, MasterPengirimanEntity> master = const Right(
//     MasterPengirimanEntity(),
//   );
//   Either<Failure, List<HasilCheckinEntity>> ambil = const Right([
//     HasilCheckinEntity(noResi: 'A'),
//   ]);
//   Failure? antreGagalDengan;
//   final payload = <Object>[];

//   Future<Either<Failure, AntreanPengirimanEntity>> _antre(
//     Object p,
//     JenisAksiAntrean jenis,
//   ) async {
//     payload.add(p);
//     final f = antreGagalDengan;
//     return f == null ? Right(antreanUji(jenis)) : Left(f);
//   }

//   @override
//   Future<Either<Failure, MasterPengirimanEntity>> getMaster() async => master;

//   @override
//   Future<Either<Failure, List<HasilCheckinEntity>>> postAmbil(
//     AmbilPayloadEntity p,
//   ) async {
//     payload.add(p);
//     return ambil;
//   }

//   @override
//   Future<Either<Failure, AntreanPengirimanEntity>> antreCheckin(
//     CheckinPayloadEntity p,
//   ) => _antre(
//     p,
//     p.jenis == JenisCheckin.tiba
//         ? JenisAksiAntrean.tiba
//         : JenisAksiAntrean.perjalanan,
//   );

//   @override
//   Future<Either<Failure, AntreanPengirimanEntity>> antreSerah(
//     SerahPayloadEntity p,
//   ) => _antre(p, JenisAksiAntrean.serah);

//   @override
//   Future<Either<Failure, AntreanPengirimanEntity>> antreGagal(
//     GagalPayloadEntity p,
//   ) => _antre(p, JenisAksiAntrean.gagal);

//   @override
//   Future<Either<Failure, AntreanPengirimanEntity>> antreKembalikan(
//     KembalikanPayloadEntity p,
//   ) => _antre(p, JenisAksiAntrean.kembalikan);

//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }
