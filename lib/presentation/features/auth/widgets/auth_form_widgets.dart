// lib/presentation/features/auth/widgets/auth_form_widgets.dart
import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/material.dart';

/// Warna latar halaman auth (sama dengan halaman login).
const Color kAuthCanvas = Color(0xFFFBF8F3);

OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide(color: color, width: width),
);

/// Dekorasi input yang dipakai di halaman login, lupa & reset password.
InputDecoration authInputDecoration(
  String hint,
  IconData icon, {
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AppThemeColors.tertiaryText,
      fontSize: 14,
    ),
    prefixIcon: Icon(icon, color: AppThemeColors.blackPrimary, size: 22),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppThemeColors.grey3,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: _border(AppThemeColors.grey4, 1),
    enabledBorder: _border(AppThemeColors.grey4, 1),
    focusedBorder: _border(AppThemeColors.primary, 1.5),
    errorBorder: _border(AppThemeColors.danger, 1),
    focusedErrorBorder: _border(AppThemeColors.danger, 1.5),
  );
}

const TextStyle kAuthLabelStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: AppThemeColors.titleText,
);

const TextStyle kAuthInputStyle = TextStyle(
  fontSize: 14,
  color: AppThemeColors.primaryText,
);

/// Judul halaman auth: garis aksen + judul + deskripsi.
class AuthPageTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthPageTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: AppThemeColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppThemeColors.titleText,
            height: 1.15,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppThemeColors.blackPrimary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

/// Kartu putih transparan dengan bayangan coklat, seperti kartu login.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppThemeColors.brown.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Tombol gradasi, sama dengan tombol "Masuk" di halaman login.
/// [onTap] null = tombol nonaktif.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onTap == null;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppThemeColors.primary, AppThemeColors.yellow5],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppThemeColors.yellow5.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: disabled ? null : onTap,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(icon, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
