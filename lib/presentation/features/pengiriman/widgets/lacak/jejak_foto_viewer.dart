import 'package:flutter/material.dart';

import '../../../../../domain/entities/pengiriman/jejak_entity.dart';
import '../../../../shared/widgets/bapenda_image.dart';
import '../../utils/pengiriman_foto_url.dart';

/// Lihat foto jejak layar penuh: geser antar foto, cubit untuk zoom.
class JejakFotoViewer extends StatefulWidget {
  final List<FotoJejakEntity> foto;
  final int awal;

  const JejakFotoViewer({super.key, required this.foto, this.awal = 0});

  static Future<void> open(
    BuildContext context,
    List<FotoJejakEntity> foto, {
    int awal = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => JejakFotoViewer(foto: foto, awal: awal),
      ),
    );
  }

  @override
  State<JejakFotoViewer> createState() => _JejakFotoViewerState();
}

class _JejakFotoViewerState extends State<JejakFotoViewer> {
  late final _controller = PageController(initialPage: widget.awal);
  late int _index = widget.awal;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foto = widget.foto[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          [
            if (foto.jenisFoto?.isNotEmpty ?? false) foto.jenisFoto!,
            '${_index + 1}/${widget.foto.length}',
          ].join('  ·  '),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.foto.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: BapendaImage(
              path: pengirimanFotoUrl(widget.foto[i].key),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
