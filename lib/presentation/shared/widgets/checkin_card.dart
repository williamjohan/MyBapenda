// lib/presentation/shared/widgets/bapenda_selfie_card.dart
import 'dart:io';
import 'package:bapendacore/presentation/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CheckinCard extends StatefulWidget {
  final String title;
  final String hint;
  final String? path;
  final ValueChanged<String> onCaptured;

  const CheckinCard({
    super.key,
    required this.path,
    required this.onCaptured,
    this.title = 'Foto Selfie',
    this.hint = 'Ambil foto selfie petugas sebagai bukti kehadiran di lokasi.',
  });

  @override
  State<CheckinCard> createState() => _CheckinCardState();
}

class _CheckinCardState extends State<CheckinCard> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _capture() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (shot != null) widget.onCaptured(shot.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.path;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.face_rounded,
                size: 18,
                color: Color(0xFFB8680F),
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2933),
                ),
              ),
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Color(0xFFC62828))),
            ],
          ),
          const SizedBox(height: 14),
          if (path == null) ...[
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3DC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: Color(0xFFB8680F),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.hint,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                height: 1.5,
                color: const Color(0xFF7B8794),
              ),
            ),
          ] else
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(path),
                  height: 220,
                  width: 170,
                  fit: BoxFit.cover,
                  cacheWidth: 600,
                ),
              ),
            ),
          const SizedBox(height: 14),
          Button(
            label: path == null ? 'Ambil Selfie' : 'Ambil Ulang',
            icon: path == null
                ? Icons.photo_camera_front_rounded
                : Icons.photo_camera_outlined,
            variant: path == null
                ? BapendaButtonVariant.primary
                : BapendaButtonVariant.outlined,
            height: 44,
            isLoading: _busy,
            onPressed: _capture,
          ),
        ],
      ),
    );
  }
}
