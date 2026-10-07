import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/design_system/tokens/app_palette.dart';
import 'home_feature_menu_item.dart';

class HomeBapendaCoreFeatureGrid extends StatelessWidget {
  const HomeBapendaCoreFeatureGrid({super.key, required this.items});

  final List<HomeFeatureMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Transform.translate(
      offset: const Offset(0, -10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          decoration: BoxDecoration(
            color: palette.surface,
            image: DecorationImage(
              image: const AssetImage('assets/images/pattern_type.png'),
              alignment: Alignment.topCenter,
              fit: BoxFit.fitWidth,
              opacity: palette.patternOpacity,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: palette.shadow.withValues(alpha: 0.03),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.apps_rounded, size: 16, color: palette.accent),
                  const SizedBox(width: 8),
                  Text(
                    'MENU LAYANAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      height: 1,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // 🚀 FIX 1: Sedikit ditinggikan untuk mengakomodasi teks 2 baris
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) =>
                    _FeatureCard(item: items[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.item});

  final HomeFeatureMenuItem item;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.item.enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final disabled = !item.enabled;
    final palette = context.palette;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              item.onTap?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: disabled ? palette.surfaceMuted : palette.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: disabled ? palette.borderStrong : palette.border,
            ),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: palette.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Padding(
                // 🚀 FIX 2: Kurangi padding atas/bawah dari 14 ke 12 agar area konten lebih luas
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: disabled
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  palette.accentSoft,
                                  palette.accentSoft.withValues(alpha: 0.6),
                                ],
                              ),
                        color: disabled ? palette.surfaceMuted : null,
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: disabled ? palette.textTertiary : palette.accent,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      item.title,
                      maxLines: 2, // 🚀 FIX 3: Batasi maksimal 2 baris
                      overflow: TextOverflow
                          .ellipsis, // 🚀 FIX 4: Potong dengan titik-titik jika lewat
                      style: TextStyle(
                        fontSize: 13.0, // Diturunkan sedikit dari 13.5
                        fontWeight: FontWeight.w600,
                        height: 1.15, // 🚀 FIX 5: Rapatkan spasi antar baris
                        color: disabled
                            ? palette.textSecondary
                            : palette.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ), // Diperbesar dari 2 ke 4 agar subtitle tidak terlalu dempet
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.textTertiary,
                            ),
                          ),
                        ),
                        if (!disabled) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: palette.accent,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (disabled)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.warningSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Segera',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: palette.warning,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
