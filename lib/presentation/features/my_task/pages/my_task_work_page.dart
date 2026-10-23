// lib/presentation/features/my_task/pages/my_task_work_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mybapenda/core/di/injection.dart';
import 'package:mybapenda/core/services/geo_location/i_geo_location_service.dart';
import 'package:mybapenda/core/utils/app_file_picker_utils.dart';
import 'package:mybapenda/core/utils/app_logger.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_checkin_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_entity.dart';
import 'package:mybapenda/domain/entities/my_task/task_photo_entity.dart';
import 'package:mybapenda/domain/repositories/geocoding/geocoding_repository.dart';
import 'package:mybapenda/domain/usecases/auth/auth_usecase.dart';
import 'package:mybapenda/domain/usecases/my_task/my_task_usecase.dart';
import 'package:mybapenda/presentation/features/my_task/cubit/my_task_checkin_cubit.dart';
import 'package:mybapenda/presentation/features/my_task/cubit/my_task_work_cubit.dart';
import 'package:mybapenda/presentation/shared/widgets/mb_dialog.dart';
import 'package:mybapenda/routes/app_routes.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../va_qris/widgets/common/va_qris_app_bar.dart';
import '../config/task_form_config.dart';
import '../config/task_photo_slot.dart';
import '../logic/task_draft.dart';
import '../logic/task_validation_logic.dart';
import '../widgets/work/checkin_section.dart';
import '../widgets/work/extra_fields_section.dart';
import '../widgets/work/location_section.dart';
import '../widgets/work/notes_section.dart';
import '../widgets/work/photo_section.dart';
import '../widgets/work/photo_source_sheet.dart';
import '../widgets/work/task_work_summary.dart';
import '../widgets/work/work_progress_bar.dart';

class MyTaskWorkPage extends StatelessWidget {
  const MyTaskWorkPage({super.key, required this.task});

  final MyTaskEntity task;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyTaskCheckinCubit(
        useCase: getIt<MyTaskUseCase>(),
        geocoding: getIt<IGeocodingRepository>(),
        loadPetugas: _loadPetugas,
      ),
      child: BlocProvider(
        create: (_) => MyTaskWorkCubit(
          geoLocation: getIt<IGeoLocationService>(),
        ),
        child: _MyTaskWorkView(task: task),
      ),
    );
  }
}

Future<TaskPetugasEntity?> _loadPetugas() async {
  final user = await getIt<AuthUseCase>().getCurrentUserProfile();
  final nip = user?.nip?.toString().trim() ?? '';
  if (nip.isEmpty) return null;
  return TaskPetugasEntity(nip: nip);
}

class _MyTaskWorkView extends StatefulWidget {
  const _MyTaskWorkView({required this.task});

  final MyTaskEntity task;

  @override
  State<_MyTaskWorkView> createState() => _MyTaskWorkViewState();
}

class _MyTaskWorkViewState extends State<_MyTaskWorkView> {
  late final TaskFormConfig _config;

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
    File? file;
    try {
      file = await AppFilePickerUtils.pickImage(
        fromCamera: source == TaskPhotoSource.camera,
        preferredCameraDevice: allowGallery
            ? CameraDevice.rear
            : CameraDevice.front,
        maxMbSize: 5,
      );
    } catch (error, st) {
      AppLogger.error('Gagal memilih foto tugas', error, st);
      if (mounted) {
        await BapendaDialog.showError(
          context,
          title: 'Gagal Mengambil Foto',
          message: error.toString().replaceAll('Exception: ', ''),
        );
      }
      return null;
    }
    if (!mounted || file == null) return null;
    return TaskPhotoEntity(
      source: source,
      capturedAt: DateTime.now(),
      path: file.path,
    );
  }

  Future<void> _pickCheckIn() async {
    final photo = await _selectPhoto(allowGallery: false);
    if (photo != null && mounted) {
      context.read<MyTaskWorkCubit>().setCheckIn(photo);
    }
  }

  Future<void> _pickSlotPhoto(TaskPhotoSlot slot) async {
    final photo = await _selectPhoto(allowGallery: slot.allowGallery);
    if (photo != null) {
      if (mounted) context.read<MyTaskWorkCubit>().setPhoto(slot.id, photo);
    }
  }

  // ---- Lokasi -------------------------------------------------------------

  Future<void> _fetchLocation() async {
    try {
      await context.read<MyTaskWorkCubit>().fetchLocation();
      if (!mounted) return;
      final error = context.read<MyTaskWorkCubit>().state.locationError;
      if (error == null) return;
      final retry = await BapendaDialog.showError(
        context,
        title: 'Lokasi Belum Bisa Diambil',
        message: error,
        retryLabel: 'Coba Lagi',
      );
      if (retry && mounted) await _fetchLocation();
    } catch (e, st) {
      AppLogger.error('Gagal mengambil lokasi', e, st);
      if (!mounted) return;
      final retry = await BapendaDialog.showError(
        context,
        title: 'Lokasi Belum Bisa Diambil',
        message:
            'Pastikan GPS menyala dan izin lokasi diberikan, lalu coba lagi.',
        retryLabel: 'Coba Lagi',
      );
      if (retry && mounted) _fetchLocation();
    }
  }

  // ---- Kirim --------------------------------------------------------------

  Future<void> _submit() async {
    final confirmed = await BapendaDialog.showConfirm(
      context,
      title: 'Kirim hasil tugas?',
      message:
          'Setelah dikirim, tugas dinyatakan selesai dan hasilnya tidak bisa diubah.',
      confirmLabel: 'Kirim',
      cancelLabel: 'Periksa lagi',
      icon: Icons.send_rounded,
    );
    if (!confirmed || !mounted) return;

    await _kirim();
  }

  /// Dipisah dari _submit supaya "Coba Lagi" tidak mengulang konfirmasi.
  Future<void> _kirim() async {
    final res = await BapendaDialog.runWithLoading(
      context,
      (_) => context.read<MyTaskCheckinCubit>().submit(
        task: widget.task,
        draft: context.read<MyTaskWorkCubit>().state.draft,
        slots: _config.photoSlots,
      ),
      title: 'Mengirim hasil tugas',
      message: 'Foto dan laporan sedang dikirim. Mohon tunggu.',
    );
    if (!mounted) return;

    if (res.ok) {
      await BapendaDialog.showSuccess(
        context,
        title: 'Tugas Terkirim',
        message:
            'Hasil pengerjaan ${widget.task.noSkpd} berhasil dikirim.',
        primaryLabel: 'Kembali ke My Task',
        primaryIcon: Icons.check_rounded,
        barrierDismissible: false,
      );
      if (mounted) context.go(AppRoutes.myTask);
      return;
    }
    final error = res.error;
    if (error != null) await _showSubmitFailed(error);
  }

  /// Pesan error dari server (atau penyiapan data) ikut ditampilkan.
  Future<void> _showSubmitFailed(String message) async {
    final retry = await BapendaDialog.showError(
      context,
      title: 'Gagal Mengirim',
      message: '$message\n\nIsian Anda masih tersimpan di halaman ini.',
      retryLabel: 'Coba Lagi',
    );
    if (retry && mounted) await _kirim();
  }

  // ---- Keluar -------------------------------------------------------------

  Future<void> _handleBack() async {
    if (!context.read<MyTaskWorkCubit>().state.draft.hasAnyData) {
      Navigator.of(context).pop();
      return;
    }
    final leave = await BapendaDialog.showConfirm(
      context,
      title: 'Keluar dari form?',
      message: 'Isian yang sudah dibuat akan hilang.',
      confirmLabel: 'Keluar',
      cancelLabel: 'Tetap di sini',
      destructive: true,
      icon: Icons.logout_rounded,
    );
    if (leave && mounted) Navigator.of(context).pop();
  }

  // ---- Build --------------------------------------------------------------

  List<Widget> _buildSections(TaskDraft draft, bool isLocating) {
    final sections = <Widget>[];
    var step = 0;

    if (_config.requireCheckIn) {
      sections.add(
        CheckInSection(
          step: ++step,
          photo: draft.checkInPhoto,
          onPick: _pickCheckIn,
          onRemove: () => context.read<MyTaskWorkCubit>().setCheckIn(null),
        ),
      );
    }
    if (_config.requireLocation) {
      sections.add(
        LocationSection(
          step: ++step,
          location: draft.location,
          isLoading: isLocating,
          onFetch: _fetchLocation,
        ),
      );
    }
    sections.add(
      PhotoSection(
        step: ++step,
        title: _config.photoSectionTitle,
        slots: _config.photoSlots,
        photos: draft.photos,
        onPick: _pickSlotPhoto,
        onRemove: (slot) =>
            context.read<MyTaskWorkCubit>().setPhoto(slot.id, null),
      ),
    );
    if (_config.extraFields.isNotEmpty) {
      sections.add(
        ExtraFieldsSection(
          step: ++step,
          fields: _config.extraFields,
          values: draft.extraValues,
          onChanged: context.read<MyTaskWorkCubit>().setExtra,
        ),
      );
    }
    sections.add(
      NotesSection(
        step: ++step,
        initial: draft.notes,
        isRequired: _config.notesRequired,
        minLength: _config.notesMinLength,
        onChanged: context.read<MyTaskWorkCubit>().setNotes,
      ),
    );

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final workState = context.watch<MyTaskWorkCubit>().state;
    final draft = workState.draft;
    final progress = TaskValidationLogic.evaluate(_config, draft);
    final sections = _buildSections(draft, workState.isLocating);
    final isSubmitting = context.watch<MyTaskCheckinCubit>().state;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !isSubmitting) _handleBack();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppThemeColors.defaultBackground,
          appBar: VaQrisAppBar(
            title: 'Kerjakan tugas',
            subtitle: widget.task.noSkpd,
            onBackPressed: isSubmitting ? () {} : _handleBack,
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
            isSubmitting: isSubmitting,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}
