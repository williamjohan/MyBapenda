// // ignore_for_file: depend_on_referenced_packages
// import 'dart:convert';
// import 'dart:io';

// import 'package:mybapenda/core/services/geo_location_service.dart';
// import 'package:mybapenda/presentation/features/pengiriman/utils/pengiriman_foto.dart';
// import 'package:mybapenda/presentation/features/pengiriman/utils/pengiriman_foto_url.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

// import 'helpers/platform_fakes.dart';

// /// PNG 1×1.
// final _png = base64Decode(
//   'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
// );

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   late Directory dir;
//   late FakeImagePicker picker;

//   setUp(() {
//     dir = Directory.systemTemp.createTempSync('foto_uji');
//     final sumber = File('${dir.path}/kamera.png')..writeAsBytesSync(_png);
//     picker = FakeImagePicker(sumber.path);
//     ImagePickerPlatform.instance = picker;
//     FlutterImageCompressPlatform.instance = FakeImageCompress();
//   });

//   tearDown(() {
//     try {
//       dir.deleteSync(recursive: true);
//     } on FileSystemException catch (_) {}
//   });

//   test('kamera → cap waktu & lokasi → JPEG kecil', () async {
//     final hasil = await PengirimanFoto().ambil(
//       judul: 'Foto Lokasi',
//       noResi: 'TGR2',
//       lokasi: const GeoPosition(
//         latitude: -7.29,
//         longitude: 112.75,
//         akurasiMeter: 8,
//         isMocked: false,
//       ),
//     );

//     expect(hasil, isNotNull);
//     expect(hasil, endsWith('.jpg'));
//     expect(File(hasil!).existsSync(), isTrue);
//     // Kamera belakang, dikecilkan sebelum dicap (hemat memori).
//     expect(picker.opsiTerakhir!.preferredCameraDevice, CameraDevice.rear);
//     expect(picker.opsiTerakhir!.maxWidth, 1600);
//     File(hasil).deleteSync();
//   });

//   test('tanpa lokasi tetap dicap', () async {
//     final hasil = await PengirimanFoto().ambil(judul: 'Foto', noResi: 'A');
//     expect(hasil, isNotNull);
//     File(hasil!).deleteSync();
//   });

//   test('kamera dibatalkan → null', () async {
//     picker.path = null;
//     expect(await PengirimanFoto().ambil(judul: 'Foto', noResi: 'A'), isNull);
//   });

//   test('URL foto jejak: key di-encode', () {
//     final url = pengirimanFotoUrl('a b/c');
//     expect(url, contains('/api/pengiriman/foto?key=a+b%2Fc'));
//     // Base URL berakhiran '/' tidak membuat garis miring ganda.
//     expect(url.contains('//api/pengiriman'), isFalse);
//   });
// }
