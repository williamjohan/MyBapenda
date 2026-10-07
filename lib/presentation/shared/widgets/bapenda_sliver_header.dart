// lib/presentation/shared/widgets/bapenda_sliver_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors_new.dart';

class BapendaSliverHeader extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final bool showBackButton;
  final double expandedHeight;

  /// Widget opsional di ujung kanan baris judul (mis. ThemeToggleButton).
  final Widget? trailing;

  const BapendaSliverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    // Diperpendek sedikit (dari 130 ke 110) karena sekarang kontennya hanya 1 baris
    this.expandedHeight = 110.0,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    // Tinggi minimum saat di-scroll (sticky)
    const toolbarHeight = 64.0; 
    
    final minHeight = toolbarHeight + topPadding;
    final maxHeight = expandedHeight + topPadding;

    return SliverAppBar(
      pinned: true,
      toolbarHeight: toolbarHeight,
      expandedHeight: expandedHeight,
      backgroundColor: AppThemeColors.brown,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      
      // Matikan tombol panah bawaan agar kita bisa mengaturnya sejajar dengan teks
      automaticallyImplyLeading: false, 
      
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.biggest.height;
          
          // Rasio untuk mengecilkan font secara halus saat di-scroll (1.0 = terbuka, 0.0 = sticky)
          final expandRatio = ((currentHeight - minHeight) / (maxHeight - minHeight)).clamp(0.0, 1.0);
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Latar Belakang Gradien
              Container(
                decoration: const BoxDecoration(
                  gradient: AppThemeColors.headerGradient,
                ),
              ),
              
              // 2. KUNCI UTAMA: Row yang dipaku di tepi bawah (bottom: 10)
              // Saat AppBar mengecil, Row ini akan ikut terangkat ke atas secara otomatis.
              Positioned(
                left: 8.0,
                bottom: 10.0, 
                right: 16.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tombol Panah
                    if (showBackButton)
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          splashColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      )
                    else
                      const SizedBox(width: 12), // Jarak kiri jika tidak ada panah

                    // Teks Judul & Subjudul
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.lora(
                              // Teks sedikit mengecil (dari 22 ke 19) saat di-scroll
                              fontSize: Tween<double>(begin: 19.0, end: 22.0).transform(expandRatio),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          if (subtitle != null) ...[
                            // Jarak antar teks mengecil saat di-scroll
                            SizedBox(height: Tween<double>(begin: 0.0, end: 2.0).transform(expandRatio)),
                            DefaultTextStyle(
                              style: GoogleFonts.plusJakartaSans(
                                // Subtitle mengecil (dari 11.5 ke 12.5) saat di-scroll
                                fontSize: Tween<double>(begin: 11.5, end: 12.5).transform(expandRatio),
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              child: subtitle!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}