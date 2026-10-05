import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../core/utils/va_qris_constants.dart';

/// Countdown pembayaran yang tahan background/sleep.
///
/// - Jangkar absolut ([_targetAbsoluteEndTime]) dihitung sekali di awal.
/// - Saat app tampil, sisa waktu dihitung dari Stopwatch (monotonic).
/// - Saat app kembali dari background, waktu disinkron ulang ke jam dinding
///   lalu UI langsung diperbarui (tanpa menunggu tick berikutnya).
/// - [onTimeout] dijamin hanya terpanggil SEKALI ([_timeoutFired]).
///
/// Widget ini dibuat ulang (ganti `key`) untuk memulai countdown baru.
class PaymentCountdownTimer extends StatefulWidget {
  const PaymentCountdownTimer({
    super.key,
    required this.duration,
    this.onTimeout,
  });

  final Duration duration;
  final VoidCallback? onTimeout;

  @override
  State<PaymentCountdownTimer> createState() => _PaymentCountdownTimerState();
}

class _PaymentCountdownTimerState extends State<PaymentCountdownTimer>
    with WidgetsBindingObserver {
  late DateTime _targetAbsoluteEndTime;
  late Duration _syncedRemainingTime;
  Duration _currentDisplayTime = Duration.zero;

  final Stopwatch _foregroundStopwatch = Stopwatch();
  Timer? _timer;

  /// Guard idempoten: tanpa ini onTimeout bisa terpanggil berkali-kali
  /// saat user resume app berulang setelah waktu sebenarnya habis.
  bool _timeoutFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _targetAbsoluteEndTime = DateTime.now().add(widget.duration);
    _syncedRemainingTime = widget.duration;
    _currentDisplayTime = widget.duration;

    _foregroundStopwatch.start();
    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && !_timeoutFired) {
      _syncWithAbsoluteWallClock();
      _evaluateTick();
    }
  }

  void _syncWithAbsoluteWallClock() {
    final now = DateTime.now();
    if (now.isBefore(_targetAbsoluteEndTime)) {
      _syncedRemainingTime = _targetAbsoluteEndTime.difference(now);
    } else {
      _syncedRemainingTime = Duration.zero;
    }
    _foregroundStopwatch
      ..reset()
      ..start();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _evaluateTick());
  }

  void _evaluateTick() {
    if (!mounted) return;

    final remaining = _syncedRemainingTime - _foregroundStopwatch.elapsed;

    if (remaining.inSeconds > 0) {
      setState(() => _currentDisplayTime = remaining);
      return;
    }

    _timer?.cancel();
    _foregroundStopwatch.stop();
    setState(() => _currentDisplayTime = Duration.zero);

    if (!_timeoutFired) {
      _timeoutFired = true;
      widget.onTimeout?.call();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _foregroundStopwatch.stop();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _currentDisplayTime == Duration.zero;
    final isWarning =
        !isExpired && _currentDisplayTime.inSeconds <= kCountdownWarningSeconds;
    final isAlert = isExpired || isWarning;

    final background = isAlert
        ? AppThemeColors.dangerSoft
        : Colors.white.withValues(alpha: 0.16);
    final foreground = isAlert ? AppThemeColors.danger : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            isExpired
                ? 'Waktu pembayaran habis'
                : 'Berlaku ${_format(_currentDisplayTime)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: foreground,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
