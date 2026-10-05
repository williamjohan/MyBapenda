// lib/presentation/features/reklame/widgets/reklame_dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_colors_new.dart';

class ReklameDashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const ReklameDashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // 🚀 FIX 1: Memaksa ikon status bar (Baterai, Jam, Sinyal) menjadi PUTIH
      systemOverlayStyle: SystemUiOverlayStyle.light,
      
      // Background transparan agar gradient dari flexibleSpace terlihat penuh
      backgroundColor: Colors.transparent, 
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      
      // 🚀 FIX 2: Memberikan gradien penuh ke seluruh AppBar
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppThemeColors.primaryGradient,
        ),
      ),
      
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back, color: Colors.white), // Ikon putih
      ),
      
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cek Reklame',
            style: TextStyle(
              fontSize: 17, // Diperbesar sedikit agar berwibawa
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pengawasan reklame Kota Surabaya',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85), // Agak redup untuk hierarki
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}