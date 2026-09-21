import 'package:bapendacore/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';

class MyReportsCard extends StatelessWidget {
  const MyReportsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior:
          Clip.none, 
      children: [
        // 1. Card Utama
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showComingSoonModal(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade100,
                  ), // Border tipis ala M3
                ),
                child: Row(
                  children: [
                    // Ikon dengan warna muted
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: Colors.grey.shade400, // Warna pudar
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Teks Label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Reports",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600, // Text muted
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Lihat laporan Anda",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ikon Gembok & Panah
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. Badge Coming Soon (Melayang)
        Positioned(
          top: -5,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4), // Kuning lembut sesuai AI
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(1, 10),
                ),
              ],
            ),
            child: const Text(
              "Coming Soon",
              style: TextStyle(
                color: Color(0xFFFBC02D), // Warna teks kuning tua
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoonModal(BuildContext context) {
    showAppModal(
      context: context,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 70,
            color: Colors.blue.shade100,
          ),
          const SizedBox(height: 20),
          const Text(
            'Under Construction',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Fitur riwayat laporan sedang kami siapkan untuk memudahkan Anda memantau status laporan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
      primaryButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF175CFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text('Tunggu Ya!'),
      ),
      showCloseButton: false,
    );
  }
}
