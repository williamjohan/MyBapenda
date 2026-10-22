import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mybapenda/core/constants/design_system/tokens/app_palette.dart';
import 'package:mybapenda/presentation/shared/widgets/mb_image_cache.dart';

class BapendaThumb extends StatelessWidget {
  final String url;
  final double size;

  const BapendaThumb({super.key, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: BapendaImageCache.instance,
      width: size,
      height: size,
      fit: BoxFit.cover,
      memCacheWidth: px, 
      maxWidthDiskCache: 240, 
      filterQuality: FilterQuality.low,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder: (context, _) =>
          _Kotak(size: size, icon: Icons.image_outlined),
      errorWidget: (context, _, __) =>
          _Kotak(size: size, icon: Icons.broken_image_outlined),
    );
  }
}

class _Kotak extends StatelessWidget {
  final double size;
  final IconData icon;

  const _Kotak({required this.size, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: context.palette.background,
      alignment: Alignment.center,
      child: Icon(icon, size: 22, color: context.palette.textTertiary),
    );
  }
}
