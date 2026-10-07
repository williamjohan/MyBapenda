import 'package:bapendacore/domain/entities/my_task/task_photo_entity.dart';
import 'package:flutter/material.dart';

import '../../config/task_photo_slot.dart';
import 'form_section_card.dart';
import 'task_photo_slot_card.dart';

/// Foto bukti. Jumlah & label slot mengikuti TaskFormConfig (1 foto surat,
/// atau sebelum + sesudah).
class PhotoSection extends StatelessWidget {
  const PhotoSection({
    super.key,
    required this.step,
    required this.title,
    required this.slots,
    required this.photos,
    required this.onPick,
    required this.onRemove,
  });

  final int step;
  final String title;
  final List<TaskPhotoSlot> slots;
  final Map<String, TaskPhotoEntity> photos;
  final ValueChanged<TaskPhotoSlot> onPick;
  final ValueChanged<TaskPhotoSlot> onRemove;

  @override
  Widget build(BuildContext context) {
    final isDone = slots.every((s) => photos.containsKey(s.id));

    return FormSectionCard(
      step: step,
      title: title,
      subtitle: slots.length == 1 ? '1 foto' : '${slots.length} foto',
      isDone: isDone,
      child: Column(
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            TaskPhotoSlotCard(
              label: slots[i].label,
              hint: slots[i].hint,
              photo: photos[slots[i].id],
              onPick: () => onPick(slots[i]),
              onRemove: () => onRemove(slots[i]),
            ),
          ],
        ],
      ),
    );
  }
}
