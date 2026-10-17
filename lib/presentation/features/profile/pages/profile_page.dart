// lib/presentation/features/profile/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../core/utils/app_file_picker_utils.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/profile/jenis_kontak.dart';
import '../../../../domain/entities/profile/kontak_profil_entity.dart';
import '../../../../domain/entities/users/user_entity.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/utils/date_util.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/bt_image_compressor.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/foto_sumber_sheet.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_kontak_tile.dart';

/// Profil pegawai dari `/api/profile`.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// "2002-04-30 00:00:00" -> "30 April 2002".
  static String _tglLahir(String raw) {
    final d = DateTime.tryParse(raw.split(' ').first);
    return d == null ? raw : DateUtil.tanggal(d);
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(msg)),
      );
  }

  /// Pilih kamera / galeri -> kompres JPEG (server menolak > 2 MB) -> unggah.
  Future<void> _gantiFoto(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final kamera = await FotoSumberSheet.show(context);
    if (kamera == null) return;

    try {
      final file = await AppFilePickerUtils.pickImage(fromCamera: kamera);
      if (file == null) return;
      final path = await BtImageCompressor.toJpeg(
        file.path,
        maxBytes: 1024 * 1024,
      );
      await cubit.gantiFoto(path);
    } catch (e, st) {
      AppLogger.error('Gagal menyiapkan foto profil', e, st);
      if (!context.mounted) return;
      _snack(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _ubahKontak(
    BuildContext context,
    UserEntity user,
    JenisKontak kontak,
  ) async {
    final cubit = context.read<ProfileCubit>();
    final hasil = await context.push<KontakProfilEntity>(
      AppRoutes.profileKontak,
      extra: (kontak: kontak, nilaiSekarang: user.kontak(kontak)),
    );
    if (hasil != null) await cubit.kontakDiperbarui(hasil);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) =>
          (curr.error != null &&
              curr.error != prev.error &&
              curr.status == ProfileStatus.ready) ||
          (curr.info != null && curr.info != prev.info),
      // Data cache tetap tampil, gagal refresh cukup diberi tahu.
      listener: (context, state) => _snack(context, state.error ?? state.info!),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: palette.background,
          body: RefreshIndicator(
            color: palette.accent,
            onRefresh: () => context.read<ProfileCubit>().refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const BapendaSliverHeader(
                  title: 'Profil',
                  showBackButton: true,
                  subtitle: Text('Data diri pegawai'),
                  trailing: ThemeToggleButton(),
                ),
                ..._body(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(BuildContext context, ProfileState state) {
    final user = state.user;

    if (user == null && state.status == ProfileStatus.failure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ErrorView(
            message: state.error ?? 'Gagal memuat profil.',
            onRetry: () => context.read<ProfileCubit>().refresh(),
          ),
        ),
      ];
    }

    if (user == null) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList.list(children: _sections(context, state, user)),
      ),
    ];
  }

  List<Widget> _sections(
    BuildContext context,
    ProfileState state,
    UserEntity user,
  ) {
    return [
      ProfileHeaderCard(
        user: user,
        fotoVersi: state.fotoVersi,
        uploadingFoto: state.uploadingFoto,
        onEditPhoto: () => _gantiFoto(context),
      ),
      const SizedBox(height: 20),
      ProfileInfoSection(
        title: 'Kepegawaian',
        icon: Icons.badge_outlined,
        items: [
          (icon: Icons.numbers_rounded, label: 'NIP', value: user.nip),
          (
            icon: Icons.work_outline_rounded,
            label: 'Jenis Pegawai',
            value: user.jenisPegawai,
          ),
          (
            icon: Icons.military_tech_outlined,
            label: 'Golongan',
            value: user.golongan,
          ),
          (
            icon: Icons.assignment_ind_outlined,
            label: 'Jabatan',
            value: user.jabatan,
          ),
          (
            icon: Icons.account_tree_outlined,
            label: 'Bidang',
            value: user.bidang,
          ),
        ],
      ),
      const SizedBox(height: 20),
      ProfileInfoSection(
        title: 'Kontak',
        icon: Icons.contact_phone_outlined,
        leading: [
          for (final kontak in JenisKontak.values)
            ProfileKontakTile(
              kontak: kontak,
              value: user.kontak(kontak),
              terverifikasi: user.kontakTerverifikasi(kontak),
              onUbah: () => _ubahKontak(context, user, kontak),
            ),
        ],
        items: [
          (
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: user.alamat,
          ),
        ],
      ),
      const SizedBox(height: 20),
      ProfileInfoSection(
        title: 'Data Pribadi',
        icon: Icons.person_outline_rounded,
        items: [
          (
            icon: Icons.cake_outlined,
            label: 'Tanggal Lahir',
            value: _tglLahir(user.tglLahir),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ];
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: palette.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: palette.textSecondary),
          ),
          const SizedBox(height: 16),
          Button(
            label: 'Coba lagi',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
