import 'package:bapendacore/core/utils/app_logger.dart';
import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_photo_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_submission_entity.dart';
import 'package:bapendacore/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../va_qris/widgets/common/va_qris_app_bar.dart';
import '../config/task_form_config.dart';
import '../config/task_photo_slot.dart';
import '../logic/task_draft.dart';
import '../logic/task_validation_logic.dart';
import '../mock/my_task_mock_data.dart';
import '../mock/task_media_simulator.dart';
import '../widgets/work/checkin_section.dart';
import '../widgets/work/extra_fields_section.dart';
import '../widgets/work/location_section.dart';
import '../widgets/work/notes_section.dart';
import '../widgets/work/photo_section.dart';
import '../widgets/work/photo_source_sheet.dart';
import '../widgets/work/task_work_summary.dart';
import '../widgets/work/work_progress_bar.dart';

/// Form pengerjaan tugas (satu halaman scroll). Isi form mengikuti
/// [TaskFormConfig.forTask], jadi satu halaman ini melayani semua jenis tugas.
class MyTaskWorkPage extends StatefulWidget {
  const MyTaskWorkPage({super.key, required this.task});

  final TaskEntity task;

  @override
  State<MyTaskWorkPage> createState() => _MyTaskWorkPageState();
}

class _MyTaskWorkPageState extends State<MyTaskWorkPage> {
  late final TaskFormConfig _config;

  // TODO(tech-debt): pindahkan ke MyTaskWorkState (+ simpan draft lokal).
  TaskDraft _draft = const TaskDraft();
  bool _isLocating = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _config = TaskFormConfig.forTask(widget.task);
  }

  // ---- Foto ---------------------------------------------------------------

  Future<TaskPhotoEntity?> _selectPhoto({required bool allowGallery}) async {
    var source = TaskPhotoSource.camera;
    if (allowGallery) {
      final chosen = await PhotoSourceSheet.show(context);
      if (chosen == null || !mounted) return null;
      source = chosen;
    }
    // TODO(tech-debt): ganti dengan AppFilePickerUtils.pickImage().
    final photo = await TaskMediaSimulator.pickPhoto(source);
    return mounted ? photo : null;
  }

  Future<void> _pickCheckIn() async {
    final photo = await _selectPhoto(allowGallery: false);
    if (photo != null) setState(() => _draft = _draft.withCheckIn(photo));
  }

  Future<void> _pickSlotPhoto(TaskPhotoSlot slot) async {
    final photo = await _selectPhoto(allowGallery: slot.allowGallery);
    if (photo != null) {
      setState(() => _draft = _draft.withPhoto(slot.id, photo));
    }
  }

  // ---- Lokasi -------------------------------------------------------------

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    try {
      // TODO(tech-debt): ganti dengan geolocator + penanganan izin/GPS mati.
      final location = await TaskMediaSimulator.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _draft = _draft.withLocation(location);
        _isLocating = false;
      });
    } catch (e, st) {
      AppLogger.error('Gagal mengambil lokasi', e, st);
      if (!mounted) return;
      setState(() => _isLocating = false);
      _showSnack('Lokasi belum bisa diambil. Coba lagi.');
    }
  }

  // ---- Kirim --------------------------------------------------------------

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim hasil tugas?'),
        content: const Text(
          'Setelah dikirim, tugas dinyatakan selesai dan hasilnya tidak bisa diubah.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Periksa lagi'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      // TODO(tech-debt): ganti dengan MyTaskCubit.submitTask(). Tangani juga
      // tanpa sinyal: simpan sebagai draft & kirim ulang otomatis.
      await MyTaskMockData.submit(
        TaskSubmissionEntity(
          taskId: widget.task.id,
          submittedAt: DateTime.now(),
          checkInPhoto: _draft.checkInPhoto,
          location: _draft.location,
          photos: _draft.photos,
          extraValues: _draft.extraValues,
          notes: _draft.notes.trim(),
        ),
      );
      if (!mounted) return;
      context.pushReplacement(AppRoutes.myTaskSuccess, extra: widget.task);
    } catch (e, st) {
      AppLogger.error('Gagal mengirim tugas ${widget.task.taskNumber}', e, st);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSubmitFailed();
    }
  }

  void _showSubmitFailed() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gagal mengirim'),
        content: const Text(
          'Periksa koneksi internet, lalu coba lagi. Isian Anda masih tersimpan di halaman ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submit();
            },
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  // ---- Keluar -------------------------------------------------------------

  Future<void> _handleBack() async {
    if (!_draft.hasAnyData) {
      Navigator.of(context).pop();
      return;
    }
    // TODO(tech-debt): tawarkan "Simpan draft" setelah penyimpanan lokal ada.
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari form?'),
        content: const Text('Isian yang sudah dibuat akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tetap di sini'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppThemeColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- Build --------------------------------------------------------------

  List<Widget> _buildSections() {
    final sections = <Widget>[];
    var step = 0;

    if (_config.requireCheckIn) {
      sections.add(
        CheckInSection(
          step: ++step,
          photo: _draft.checkInPhoto,
          onPick: _pickCheckIn,
          onRemove: () => setState(() => _draft = _draft.withCheckIn(null)),
        ),
      );
    }
    if (_config.requireLocation) {
      sections.add(
        LocationSection(
          step: ++step,
          location: _draft.location,
          isLoading: _isLocating,
          onFetch: _fetchLocation,
        ),
      );
    }
    sections.add(
      PhotoSection(
        step: ++step,
        title: _config.photoSectionTitle,
        slots: _config.photoSlots,
        photos: _draft.photos,
        onPick: _pickSlotPhoto,
        onRemove: (slot) =>
            setState(() => _draft = _draft.withPhoto(slot.id, null)),
      ),
    );
    if (_config.extraFields.isNotEmpty) {
      sections.add(
        ExtraFieldsSection(
          step: ++step,
          fields: _config.extraFields,
          values: _draft.extraValues,
          onChanged: (key, value) =>
              setState(() => _draft = _draft.withExtra(key, value)),
        ),
      );
    }
    sections.add(
      NotesSection(
        step: ++step,
        initial: _draft.notes,
        isRequired: _config.notesRequired,
        minLength: _config.notesMinLength,
        onChanged: (v) => setState(() => _draft = _draft.withNotes(v)),
      ),
    );

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final progress = TaskValidationLogic.evaluate(_config, _draft);
    final sections = _buildSections();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSubmitting) _handleBack();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppThemeColors.defaultBackground,
          appBar: VaQrisAppBar(
            title: 'Kerjakan tugas',
            subtitle: widget.task.taskNumber,
            onBackPressed: _isSubmitting ? () {} : _handleBack,
          ),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                TaskWorkSummary(task: widget.task),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      for (var i = 0; i < sections.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        sections[i],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: WorkProgressBar(
            progress: progress,
            isSubmitting: _isSubmitting,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}
