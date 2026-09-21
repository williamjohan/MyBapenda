import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../profile/widgets/logout_bottom_widget.dart';

class HomeBapendaCoreDrawer extends StatelessWidget {
  const HomeBapendaCoreDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    this.onLogout,
  });

  final String userName;
  final String userRole;
  final VoidCallback? onLogout;

  void _showLogoutConfirmation(BuildContext context) {
    // 1. Tutup Drawer terlebih dahulu agar UI tidak bertumpuk
    Navigator.of(context).pop();

    // 2. Munculkan Bottom Sheet Konfirmasi
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Wajib transparan agar radius atas terlihat
      isScrollControlled: true,
      builder: (bottomSheetContext) => LogoutBottomSheet(
        onConfirmLogout: () {
          // 3. Tutup Bottom Sheet
          Navigator.of(bottomSheetContext).pop();
          
          // 4. Eksekusi logika AuthCubit yang dilempar dari parent (HomePage)
          if (onLogout != null) {
            onLogout!(); 
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Drawer(
        backgroundColor: AppThemeColors.defaultSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: const BoxDecoration(
                gradient: AppThemeColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userRole,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            ListTile(
              leading: Icon(
                Icons.home_outlined,
                color: AppThemeColors.secondaryText,
              ),
              title: const Text('Beranda'),
              onTap: () => Navigator.of(context).pop(),
            ),

            const Spacer(),

            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.logout, color: AppThemeColors.danger),
              title: const Text(
                'Keluar',
                style: TextStyle(color: AppThemeColors.danger),
              ),
              // 🚀 Arahkan onTap ke fungsi interceptor yang kita buat di atas
              onTap: () => _showLogoutConfirmation(context), 
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}