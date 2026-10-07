import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_type.dart';

import 'task_extra_field.dart';
import 'task_photo_slot.dart';

/// Konfigurasi form pengerjaan tugas. Semua widget form (check-in, lokasi,
/// foto, field tambahan, keterangan) membaca konfigurasi ini, sehingga
/// perbedaan antar jenis tugas cukup diatur DI SINI.
///
/// Menambah aturan baru:
/// - jenis tugas baru   -> tambah case di [TaskFormConfig.forTask]
/// - kondisi "IF" pajak -> tambah blok kondisi di bagian bawah forTask
///
/// TODO(tech-debt): semua isi field tambahan di bawah adalah USULAN. Konfirmasi
/// ke Bapenda/BE sebelum rilis. Di masa depan config bisa dikirim dari BE.
class TaskFormConfig {
  const TaskFormConfig({
    required this.photoSlots,
    this.photoSectionTitle = 'Foto bukti',
    this.extraFields = const [],
    this.requireCheckIn = true,
    this.requireLocation = true,
    this.notesRequired = false,
    this.notesMinLength = 0,
  });

  final List<TaskPhotoSlot> photoSlots;
  final String photoSectionTitle;
  final List<TaskExtraField> extraFields;

  // TODO(tech-debt): aturan check-in (wajib sebelum kirim, radius dari objek
  // pajak/geofencing, deteksi lokasi palsu) belum ditetapkan. Saat ini hanya
  // mengambil selfie + geotag.
  final bool requireCheckIn;
  final bool requireLocation;

  final bool notesRequired;
  final int notesMinLength;

  TaskFormConfig withExtraFields(List<TaskExtraField> more) {
    return TaskFormConfig(
      photoSlots: photoSlots,
      photoSectionTitle: photoSectionTitle,
      extraFields: [...extraFields, ...more],
      requireCheckIn: requireCheckIn,
      requireLocation: requireLocation,
      notesRequired: notesRequired,
      notesMinLength: notesMinLength,
    );
  }

  static const List<TaskPhotoSlot> _letterSlots = [
    TaskPhotoSlot(
      id: 'surat',
      label: 'Foto surat di lokasi',
      hint: 'Tunjukkan surat dan letak surat diletakkan (mis. ditempel di pagar).',
    ),
  ];

  static const List<TaskPhotoSlot> _beforeAfterSlots = [
    TaskPhotoSlot(
      id: 'sebelum',
      label: 'Foto sebelum',
      hint: 'Kondisi objek sebelum tindakan.',
    ),
    TaskPhotoSlot(
      id: 'sesudah',
      label: 'Foto sesudah',
      hint: 'Ambil dari sudut yang sama dengan foto sebelum.',
    ),
  ];

  static const TaskExtraField _letterRecipient = TaskExtraField(
    key: 'penerima_surat',
    label: 'Surat diterima oleh',
    type: TaskExtraFieldType.choice,
    options: ['Wajib pajak', 'Pegawai/pengelola', 'Ditempel di lokasi'],
  );

  static const TaskExtraField _demolitionResult = TaskExtraField(
    key: 'hasil_bongkar',
    label: 'Hasil pembongkaran',
    type: TaskExtraFieldType.choice,
    options: ['Selesai dibongkar', 'Dibongkar sebagian', 'Tidak dapat dibongkar'],
  );

  static const TaskExtraField _supervisionResult = TaskExtraField(
    key: 'hasil_pengawasan',
    label: 'Hasil pengawasan',
    type: TaskExtraFieldType.choice,
    options: ['Sesuai ketentuan', 'Tidak sesuai', 'Objek tidak ditemukan'],
  );

  static const TaskExtraField _installedSize = TaskExtraField(
    key: 'ukuran_terpasang',
    label: 'Ukuran terpasang (meter)',
    type: TaskExtraFieldType.text,
    hint: 'Contoh: 4 x 8',
    isRequired: false,
  );

  factory TaskFormConfig.forTask(TaskEntity task) {
    final base = switch (task.type) {
      TaskType.himbauanPembayaran || TaskType.teguranPembayaran =>
        const TaskFormConfig(
          photoSlots: _letterSlots,
          photoSectionTitle: 'Foto surat',
          extraFields: [_letterRecipient],
        ),
      TaskType.silang || TaskType.unsilang => const TaskFormConfig(
        photoSlots: _beforeAfterSlots,
        photoSectionTitle: 'Foto sebelum & sesudah',
      ),
      TaskType.bongkar => const TaskFormConfig(
        photoSlots: _beforeAfterSlots,
        photoSectionTitle: 'Foto sebelum & sesudah',
        extraFields: [_demolitionResult],
      ),
      TaskType.pengawasanExisting || TaskType.pengawasanTemuanBaru =>
        const TaskFormConfig(
          photoSlots: _beforeAfterSlots,
          photoSectionTitle: 'Foto sebelum & sesudah',
          extraFields: [_supervisionResult],
        ),
    };

    // ---- Contoh kondisi "IF" berdasarkan jenis pajak -----------------------
    final isSupervision = task.type == TaskType.pengawasanExisting ||
        task.type == TaskType.pengawasanTemuanBaru;
    if (isSupervision && task.taxType == 'Pajak Reklame') {
      return base.withExtraFields(const [_installedSize]);
    }

    return base;
  }
}
