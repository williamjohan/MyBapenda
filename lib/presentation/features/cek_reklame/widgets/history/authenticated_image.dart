import 'dart:typed_data';

import 'package:bapendacore/core/di/injection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthenticatedImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget Function()? placeholder;
  final Widget Function(Object error, StackTrace? stackTrace)? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  static final Map<String, Uint8List> _cache = {};

  Uint8List? _bytes;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _bytes = null;
      _error = null;
      _loading = true;
      _load();
    }
  }

  Future<void> _load() async {
    final cached = _cache[widget.url];

    if (cached != null) {
      if (!mounted) return;

      setState(() {
        _bytes = cached;
        _loading = false;
      });

      return;
    }

    try {
      debugPrint('🖼️ IMAGE REQUEST: ${widget.url}');

      final dio = getIt<Dio>();

      final response = await dio.get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );

      final data = response.data;

      if (data == null || data.isEmpty) {
        throw Exception('Image response kosong');
      }

      final bytes = Uint8List.fromList(data);

      _cache[widget.url] = bytes;

      debugPrint('✅ IMAGE SUCCESS: ${widget.url} (${bytes.length} bytes)');

      if (!mounted) return;

      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ IMAGE ERROR: ${widget.url}');
      debugPrint('ERROR: $e');

      if (!mounted) return;

      setState(() {
        _error = e;
        _loading = false;
      });

      widget.errorWidget?.call(e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.placeholder?.call() ??
          const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    if (_error != null || _bytes == null) {
      return widget.errorWidget?.call(_error!, null) ??
          const Icon(Icons.broken_image_outlined);
    }

    return Image.memory(
      _bytes!,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ IMAGE DECODE ERROR');
        debugPrint('URL: ${widget.url}');
        debugPrint('ERROR: $error');

        return widget.errorWidget?.call(error, stackTrace) ??
            const Icon(Icons.broken_image_outlined);
      },
    );
  }
}
