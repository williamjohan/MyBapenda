// Fake plugin platform untuk tes widget (peta Google & pembuka URL).
// Paket *_platform_interface sudah ada di lockfile (dependensi transitif).
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Peta palsu: tidak ada platform view, hanya mencatat marker/polyline
/// terakhir dan perintah kamera.
class FakeMapsPlatform extends GoogleMapsFlutterPlatform {
  Set<Marker> marker = {};
  Set<Polyline> polyline = {};
  final kamera = <CameraUpdate>[];
  final _dibuat = <int>{};
  int dibuang = 0;

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    marker = mapObjects.markers;
    polyline = mapObjects.polylines;
    // Seperti platform view sungguhan: "dibuat" sekali per peta.
    if (_dibuat.add(creationId)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => onPlatformViewCreated(creationId),
      );
    }
    return const SizedBox.expand(key: ValueKey('peta-palsu'));
  }

  @override
  Future<void> init(int mapId) async {}

  @override
  Future<void> updateMapConfiguration(
    MapConfiguration configuration, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) async {
    marker = {
      ...marker.where(
        (m) => !markerUpdates.markerIdsToRemove.contains(m.markerId),
      ),
      ...markerUpdates.markersToAdd,
    };
    final ganti = {for (final m in markerUpdates.markersToChange) m.markerId};
    marker = {
      ...marker.where((m) => !ganti.contains(m.markerId)),
      ...markerUpdates.markersToChange,
    };
  }

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) async {
    polyline = {
      ...polyline.where(
        (p) => !polylineUpdates.polylineIdsToRemove.contains(p.polylineId),
      ),
      ...polylineUpdates.polylinesToAdd,
      ...polylineUpdates.polylinesToChange,
    };
  }

  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateHeatmaps(
    HeatmapUpdates heatmapUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) async {}

  @override
  Future<void> updateClusterManagers(
    ClusterManagerUpdates clusterManagerUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateGroundOverlays(
    GroundOverlayUpdates groundOverlayUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) async => kamera.add(cameraUpdate);

  @override
  Future<void> animateCameraWithConfiguration(
    CameraUpdate cameraUpdate,
    CameraUpdateAnimationConfiguration configuration, {
    required int mapId,
  }) async => kamera.add(cameraUpdate);

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MapTapEvent> onTap({required int mapId}) => const Stream.empty();
  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) =>
      const Stream.empty();

  @override
  void dispose({required int mapId}) => dibuang++;
}

/// Pembuka URL palsu: catat URL; [berhasil] false = aplikasi tidak ada.
class FakeUrlLauncher extends UrlLauncherPlatform {
  final dibuka = <String>[];
  bool berhasil = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => berhasil;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    dibuka.add(url);
    return berhasil;
  }
}

/// Pasang fake peta & URL untuk satu tes; dikembalikan setelah selesai.
({FakeMapsPlatform peta, FakeUrlLauncher url}) pasangPlatformPalsu(
  void Function(void Function()) addTearDown,
) {
  final petaLama = GoogleMapsFlutterPlatform.instance;
  final urlLama = UrlLauncherPlatform.instance;
  final peta = FakeMapsPlatform();
  final url = FakeUrlLauncher();
  GoogleMapsFlutterPlatform.instance = peta;
  UrlLauncherPlatform.instance = url;
  addTearDown(() {
    GoogleMapsFlutterPlatform.instance = petaLama;
    UrlLauncherPlatform.instance = urlLama;
  });
  return (peta: peta, url: url);
}

/// Kamera palsu: kembalikan [path] (null = dibatalkan).
class FakeImagePicker extends ImagePickerPlatform {
  String? path;
  ImagePickerOptions? opsiTerakhir;

  FakeImagePicker(this.path);

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    opsiTerakhir = options;
    return path == null ? null : XFile(path!);
  }
}

/// Kompres palsu: salin file sumber ke target (ukuran tidak berubah).
class FakeImageCompress extends FlutterImageCompressPlatform {
  @override
  Future<XFile?> compressAndGetFile(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    await File(path).copy(targetPath);
    return XFile(targetPath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Folder aplikasi palsu di folder temp sistem.
class FakePathProvider extends PathProviderPlatform {
  final String dir;
  FakePathProvider(this.dir);

  @override
  Future<String?> getApplicationDocumentsPath() async => dir;

  @override
  Future<String?> getTemporaryPath() async => dir;
}
