import 'package:bapendacore/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
          backgroundColor: const Color(0xFFF5F6F8),
          drawer: HomeBapendaCoreDrawer(
            userName: userName,
            userRole: userRole,
            onLogout: () {
              // TODO: Panggil method logout di AuthCubit
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
                      // TODO: Widget Total Pendapatan & Volume Kendaraan
                      const SizedBox(height: 32),
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
        icon: Icons.camera_alt_outlined,
        title: 'Cek Reklame',
        subtitle: 'Lapor & verifikasi',
        onTap: () {
          context.push(AppRoutes.reklameDashboard);
        },
        enabled: true,
      ),
      HomeFeatureMenuItem(
        icon: Icons.receipt_long_outlined,
        title: 'Pantau Surat Pengiriman',
        subtitle: 'Segera hadir',
        onTap: () {},
        enabled: false,
      ),
    ];
  }
}
