// lib/presentation/shared/widgets/bapenda_image.dart
import 'dart:io';
import 'package:flutter/material.dart';

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

  bool get _remote => path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    Widget error(BuildContext _, Object __, StackTrace? ___) => Container(
      width: width,
      height: height,
      color: const Color(0xFFEEF0F3),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF9AA5B1)),
    );

    if (_remote) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        errorBuilder: error,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      errorBuilder: error,
    );
  }
}
