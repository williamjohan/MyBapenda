// lib/presentation/features/profile/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/users/user_entity.dart';
import '../../../shared/utils/date_util.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_section.dart';

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

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.error != null &&
          curr.error != prev.error &&
          curr.status == ProfileStatus.ready,
      // Data cache tetap tampil, gagal refresh cukup diberi tahu.
      listener: (context, state) => _snack(context, state.error!),
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
        sliver: SliverList.list(children: _sections(context, user)),
      ),
    ];
  }

  List<Widget> _sections(BuildContext context, UserEntity user) {
    return [
      ProfileHeaderCard(
        user: user,
        // TODO: sambungkan ke API ubah foto profil saat sudah tersedia.
        onEditPhoto: () =>
            _snack(context, 'Fitur ubah foto profil segera hadir.'),
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
        items: [
          (icon: Icons.mail_outline_rounded, label: 'Email', value: user.email),
          (icon: Icons.phone_outlined, label: 'No. HP', value: user.hp),
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
