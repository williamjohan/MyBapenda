/// Satu slot foto pada form tugas (mis. "Foto sebelum").
class TaskPhotoSlot {
  const TaskPhotoSlot({
    required this.id,
    required this.label,
    this.hint,
    this.allowGallery = true,
  });

  final String id;
  final String label;
  final String? hint;

  /// false = hanya kamera langsung.
  final bool allowGallery;
}
