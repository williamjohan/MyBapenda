import 'package:bapendacore/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bapendacore/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_bapenda_core_header.dart';
import '../widgets/home_bapenda_core_feature_grid.dart';
import '../widgets/home_bapenda_core_drawer.dart';
import '../widgets/home_feature_menu_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Kalkulasi tinggi rasio layar dinamis untuk overlap card
    final screenHeight = MediaQuery.of(context).size.height;
    final headerOverlapHeight = screenHeight * 0.16;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // PERBAIKAN: Langsung ambil dari state (Freezed)
        final userName = state.userName;
        final userRole = state.userRole;

        return Scaffold(
          backgroundColor: context.palette.background,
          drawer: HomeBapendaCoreDrawer(
            userName: userName,
            userRole: userRole,
            onLogout: () async {
              context.read<AuthCubit>().logout();
            },
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. HEADER
                HomeBapendaCoreHeader(userName: userName, userRole: userRole),

                // 2. BODY / CARDS
                Padding(
                  padding: EdgeInsets.only(top: headerOverlapHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      HomeBapendaCoreFeatureGrid(
                        items: _buildFeatureItems(context),
                      ),
                      const SizedBox(height: 16),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<HomeFeatureMenuItem> _buildFeatureItems(BuildContext context) {
    return [
      HomeFeatureMenuItem(
        icon: Icons.fingerprint,
        title: 'Absensi',
        subtitle: 'Absen & riwayat kehadiran',
        onTap: () {
          context.push(AppRoutes.absensi);
        },
        enabled: true,
      ),
      HomeFeatureMenuItem(
        icon: Icons.summarize_outlined,
        title: 'Laporan Kehadiran',
        subtitle: 'Unduh rekap bulanan (PDF)',
        onTap: () {
          context.push(AppRoutes.laporanKehadiran);
        },
        enabled: true,
      ),
      HomeFeatureMenuItem(
        icon: Icons.camera_alt_outlined,
        title: 'Cek Reklame',
        subtitle: 'Lapor & verifikasi',
        onTap: () {
          context.push(AppRoutes.reklameDashboard);
        },
        enabled: true,
      ),
      HomeFeatureMenuItem(
        //  Menggunakan ikon truk pengiriman untuk surat jalan/pengiriman
        icon: Icons.local_shipping_outlined, 
        title: 'Pantau Surat Pengiriman',
        subtitle: 'Segera hadir',
        onTap: () {},
        enabled: false,
      ),
      HomeFeatureMenuItem(
        //  Menggunakan ikon grafik statistik untuk memantau aktivitas
        icon: Icons.analytics_outlined, 
        title: 'Aktivitas Pajak',
        subtitle: 'Segera hadir',
        onTap: () {},
        enabled: false,
      ),
      HomeFeatureMenuItem(
        //  Menggunakan ikon QR Code yang sangat identik dengan QRIS
        icon: Icons.qr_code_scanner_outlined, 
        title: 'Create VA & Qris',
        subtitle: 'Tagih via QRIS / VA',
        onTap: () {
          context.push(AppRoutes.nop);
        },
        enabled: true,
      ),
    ];
  }
  }