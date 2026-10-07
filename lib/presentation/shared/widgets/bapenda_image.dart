// lib/presentation/shared/widgets/bapenda_image.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';

class BapendaImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final int? cacheWidth;
  final double? width;
  final double? height;

  const BapendaImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.width,
    this.height,
  });

  Widget _error() => Container(
    width: width,
    height: height,
    color: const Color(0xFFEEF0F3),
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined, color: Color(0xFF9AA5B1)),
  );

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return _RemoteImage(
        url: path,
        fit: fit,
        cacheWidth: cacheWidth,
        width: width,
        height: height,
        error: _error,
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      errorBuilder: (_, __, ___) => _error(),
    );
  }
}

class _RemoteImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final int? cacheWidth;
  final double? width;
  final double? height;
  final Widget Function() error;

  const _RemoteImage({
    required this.url,
    required this.fit,
    required this.cacheWidth,
    required this.width,
    required this.height,
    required this.error,
  });

  @override
  State<_RemoteImage> createState() => _RemoteImageState();
}

class _RemoteImageState extends State<_RemoteImage> {
  late Future<Uint8List> _future = _load();

  Future<Uint8List> _load() async {
    final res = await getIt<Dio>().get<List<int>>(
      widget.url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(res.data!);
  }

  @override
  void didUpdateWidget(covariant _RemoteImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) return widget.error();
        if (!snap.hasData) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return Image.memory(
          snap.data!,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          cacheWidth: widget.cacheWidth,
          errorBuilder: (_, __, ___) => widget.error(),
        );
      },
    );
  }
}
