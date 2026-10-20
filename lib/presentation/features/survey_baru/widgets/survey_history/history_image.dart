import 'dart:collection';
import 'dart:typed_data';
import 'package:bapendacore/core/di/injection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Cache gambar di memori (maks 40) supaya tidak diunduh ulang saat
/// kartu dibuka-tutup atau halaman di-scroll.
class _ImageCache {
  static final _map = LinkedHashMap<String, Uint8List>();
  static const _max = 40;

  static Uint8List? get(String url) => _map[url];

  static void put(String url, Uint8List bytes) {
    _map.remove(url);
    _map[url] = bytes;
    if (_map.length > _max) _map.remove(_map.keys.first);
  }
}

class HistoryImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  const HistoryImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  @override
  State<HistoryImage> createState() => _HistoryImageState();
}

class _HistoryImageState extends State<HistoryImage> {
  late Future<Uint8List> _future = _load();

  @override
  void didUpdateWidget(covariant HistoryImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _future = _load();
  }

  Future<Uint8List> _load() async {
    final cached = _ImageCache.get(widget.url);
    if (cached != null) return cached;

    try {
      // Dio utama: token, interceptor, dan koneksi sama dengan panggilan API.
      final res = await getIt<Dio>().get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = res.data;
      if (data == null || data.isEmpty) {
        throw Exception('Respons kosong');
      }
      final bytes = Uint8List.fromList(data);
      _ImageCache.put(widget.url, bytes);
      return bytes;
    } catch (e) {
      debugPrint('HistoryImage gagal: ${widget.url}\n  -> $e');
      rethrow;
    }
  }

  void _retry() => setState(() => _future = _load());

  Widget _box(Widget child) => Container(
    width: widget.width,
    height: widget.height,
    color: const Color(0xFFF1F3F5),
    alignment: Alignment.center,
    child: child,
  );

  Widget _error() => _box(
    InkWell(
      onTap: _retry,
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: Color(0xFF9AA5B1)),
            SizedBox(height: 2),
            Text(
              'Gagal, ketuk ulang',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: Color(0xFF9AA5B1)),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: FutureBuilder<Uint8List>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) return _error();
          final bytes = snap.data;
          if (bytes == null) {
            return _box(
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return Image.memory(
            bytes,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            gaplessPlayback: true,
            errorBuilder: (_, e, __) {
              // Bytes diterima tapi bukan gambar yang bisa didecode.
              debugPrint('Decode gambar gagal: ${widget.url}\n  -> $e');
              return _box(
                const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF9AA5B1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Pratinjau layar penuh dengan zoom.
void showHistoryPhoto(BuildContext context, String url, {String? caption}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: HistoryImage(url: url, fit: BoxFit.contain),
                ),
              ),
              if (caption != null && caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}
