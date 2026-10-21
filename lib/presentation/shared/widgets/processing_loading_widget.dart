import 'package:mybapenda/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ProcessingLoadingWidget extends StatefulWidget {
  final String message;
  const ProcessingLoadingWidget({super.key, this.message = "Memproses"});

  @override
  State<ProcessingLoadingWidget> createState() =>
      _ProcessingLoadingWidgetState();
}

class _ProcessingLoadingWidgetState extends State<ProcessingLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Efek memudar bolak-balik (gelap-terang)
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return FadeTransition(
                // Mengatur delay setiap titik agar berjalan berurutan
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    index * 0.2,
                    0.6 + (index * 0.2),
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
