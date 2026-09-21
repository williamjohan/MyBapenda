// lib/presentation/features/reklame/pages/reklame_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart'; // Import header baru
import '../widgets/reklame_history_tile.dart';
import '../widgets/reklame_primary_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ReklameDashboardPage extends StatelessWidget {
  const ReklameDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Putih tulang
      // Hapus properti 'appBar:' standar
      
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 🚀 IMPLEMENTASI HEADER BARU DI SINI
          BapendaSliverHeader(
            title: 'Cek Reklame',
            showBackButton: true, // Ada panah kembali ke Home
            subtitle: Text(
              'Pengawasan reklame Kota Surabaya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          
          // Konten Body dibungkus SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReklamePrimaryActionCard(
                    title: 'Ambil Gambar Reklame',
                    description: 'Foto lokasi & laporkan billboard yang ditemukan di lapangan secara presisi',
                    ctaLabel: 'Mulai Ambil Gambar',
                    onTap: () {
                      // TODO: navigasi
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  ReklameHistoryTile(
                    icon: Icons.history_rounded,
                    title: 'History Laporan',
                    subtitle: 'Riwayat data yang pernah dikirim',
                    onTap: () {
                      context.pushNamed(AppRoutes.history);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}