import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Jam HH:mm:ss yang berdetak tiap detik (jam HP, hanya tampilan).
/// Waktu absen yang tercatat tetap jam server.
class LiveClock extends StatefulWidget {
  final TextStyle style;
  const LiveClock({super.key, required this.style});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('HH:mm:ss').format(_now),
      style: widget.style.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
