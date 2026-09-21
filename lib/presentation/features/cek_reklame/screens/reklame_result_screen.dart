import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart'; 
import '../../../../routes/app_routes.dart';

class ReklameResultPage extends StatelessWidget {
  // Kita bisa menerima data lemparan dari CameraPage untuk ditampilkan
  final String? address;
  
  const ReklameResultPage({
    super.key,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    // PopScope (WillPopScope di Flutter lama) mencegah user menekan tombol Back fisik (Android)
    // kembali ke halaman loading/camera. Mereka harus menggunakan tombol di layar.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // 1. Icon Sukses
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 2. Teks Konfirmasi
                const Text(
                  'Laporan Berhasil Terkirim!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Data pengawasan reklame telah berhasil masuk ke dalam sistem pusat Bapenda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Ringkasan (Opsional tapi sangat bagus untuk UX)
                if (address != null && address!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: AppThemeColors.gold, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            address!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // 4. Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Hapus tumpukan layar kamera dan kembali ke Dashboard Reklame
                      context.go(AppRoutes.reklameDashboard);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      // Langsung bawa ke halaman riwayat
                      // Pakai .pushReplacement agar jika di-back, kembalinya ke Dashboard, bukan ke Result lagi
                      context.pushReplacement(AppRoutes.history);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeColors.primary,
                      side: BorderSide(color: AppThemeColors.primary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Lihat Riwayat Laporan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}