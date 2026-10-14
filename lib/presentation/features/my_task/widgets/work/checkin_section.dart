import 'package:bapendacore/domain/entities/my_task/task_photo_entity.dart';
import 'package:flutter/material.dart';

import 'form_section_card.dart';
import 'task_photo_slot_card.dart';

/// Check-in: selfie petugas sebagai bukti sedang mengerjakan tugas.
///
/// TODO(tech-debt): gunakan kamera depan; aturan check-in (wajib, radius
/// dari objek pajak) belum ditetapkan. Hanya kamera, tanpa galeri, karena
/// selfie harus diambil saat itu juga.
class CheckInSection extends StatelessWidget {
  const CheckInSection({
    super.key,
    required this.step,
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  final int step;
  final TaskPhotoEntity? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      step: step,
      title: 'Check-in',
      subtitle: 'Bukti Anda berada di lokasi tugas',
      isDone: photo != null,
      child: TaskPhotoSlotCard(
        label: 'Selfie petugas',
        hint: 'Foto wajah Anda di lokasi, pastikan terlihat jelas.',
        photo: photo,
        onPick: onPick,
        onRemove: onRemove,
      ),
    );
  }
}
