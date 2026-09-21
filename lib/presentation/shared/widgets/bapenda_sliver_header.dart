// lib/presentation/shared/widgets/bapenda_sliver_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors_new.dart'; 

class BapendaSliverHeader extends StatelessWidget {
  final String title;
  
  /// Bisa diisi Text biasa, atau BlocBuilder jika datanya reaktif
  final Widget? subtitle; 
  
  final bool showBackButton;
  
  /// Tinggi header saat di-scroll ke paling atas (expanded)
  final double expandedHeight;

  const BapendaSliverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.expandedHeight = 90.0, // Proporsional untuk menampung teks & ikon
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: AppThemeColors.brown, // Warna solid saat di-scroll ke atas
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light, 
            automaticallyImplyLeading: false, 
      
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppThemeColors.headerGradient, // Seragam dengan History
          ),
          child: SafeArea(
            bottom: false, // Menghindari padding aman di bawah notch/status bar
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16), 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBackButton)
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 0), 
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                            splashColor: Colors.white.withValues(alpha: 0.2),
                            highlightColor: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 20), // Jarak kiri jika tidak ada panah
                      
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Mencegah overflow
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.lora(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            subtitle!,
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16), // Jarak aman di sebelah kanan
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}