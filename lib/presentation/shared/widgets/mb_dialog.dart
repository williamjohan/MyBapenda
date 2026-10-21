
import 'dart:async';
import 'dart:math' as math;

import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Nuansa dialog: menentukan warna dan ikon bawaan.
enum BapendaDialogTone { success, error, warning, info, confirm }

/// Gaya tombol: utama (terisi), sekunder (garis tepi), atau teks saja.
enum BapendaDialogActionStyle { primary, secondary, text }

/// Susunan tombol. [auto]: dua tombol pendek berdampingan, selebihnya
/// bertumpuk.
enum BapendaDialogLayout { auto, vertical, horizontal }

/// Satu tombol di dialog.
class BapendaDialogAction<T> {
  /// Teks tombol.
  final String label;

  /// Nilai yang dikembalikan oleh `show()` ketika tombol ini ditekan.
  final T? result;

  final IconData? icon;
  final BapendaDialogActionStyle style;

  /// Dijalankan saat ditekan. Boleh async: tombol berputar selama berjalan.
  /// Kalau melempar error, dialog tetap terbuka dan menampilkan pesan.
  final FutureOr<void> Function()? onPressed;

  /// false = dialog tidak ditutup setelah [onPressed] selesai.
  final bool closeOnPressed;

  const BapendaDialogAction({
    required this.label,
    this.result,
    this.icon,
    this.style = BapendaDialogActionStyle.secondary,
    this.onPressed,
    this.closeOnPressed = true,
  });

  const BapendaDialogAction.primary({
    required this.label,
    this.result,
    this.icon,
    this.onPressed,
    this.closeOnPressed = true,
  }) : style = BapendaDialogActionStyle.primary;

  const BapendaDialogAction.secondary({
    required this.label,
    this.result,
    this.icon,
    this.onPressed,
    this.closeOnPressed = true,
  }) : style = BapendaDialogActionStyle.secondary;

  const BapendaDialogAction.text({
    required this.label,
    this.result,
    this.icon,
    this.onPressed,
    this.closeOnPressed = true,
  }) : style = BapendaDialogActionStyle.text;
}

/// Satu baris rincian (label di kiri, nilai di kanan).
class BapendaDialogDetail {
  final String label;
  final String value;

  /// true = nilai bisa diblok dan disalin (tekan lama).
  final bool selectable;

  const BapendaDialogDetail(this.label, this.value, {this.selectable = false});
}

/// Pengendali dialog loading dari [BapendaDialog.showLoading].
class BapendaLoadingController {
  BapendaLoadingController._(this._navigator);

  final NavigatorState _navigator;
  final ValueNotifier<_LoadingValue> _value = ValueNotifier(
    const _LoadingValue(),
  );
  Route<void>? _route;
  bool _closed = false;

  bool get isClosed => _closed;

  /// Ubah pesan dan/atau progres (0..1). Progres null = berputar tanpa angka.
  void update({String? message, double? progress}) {
    if (_closed) return;
    final v = _value.value;
    _value.value = _LoadingValue(
      message: message ?? v.message,
      progress: progress ?? v.progress,
    );
  }

  /// Tutup dialog loading. Aman dipanggil berkali-kali.
  void close() {
    if (_closed) return;
    _closed = true;
    final route = _route;
    if (route == null || !route.isActive) return;
    if (route.isCurrent) {
      _navigator.pop();
    } else {
      _navigator.removeRoute(route);
    }
  }
}

class _LoadingValue {
  final String? message;
  final double? progress;
  const _LoadingValue({this.message, this.progress});
}

// =============================================================================
// Pintu masuk
// =============================================================================

class BapendaDialog {
  BapendaDialog._();

  // ---- Dialog bebas ----

  /// Dialog serba bisa. Mengembalikan `result` tombol yang ditekan, atau null
  /// bila ditutup tanpa menekan tombol (ketuk di luar / tombol kembali).
  static Future<T?> show<T>(
    BuildContext context, {
    required BapendaDialogTone tone,
    required String title,
    required List<BapendaDialogAction<T>> actions,
    String? message,
    IconData? icon,
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    bool barrierDismissible = true,

    /// Tutup otomatis setelah durasi ini (ada garis hitung mundur di atas).
    Duration? autoCloseAfter,
    bool haptic = true,
    BapendaDialogLayout layout = BapendaDialogLayout.auto,
  }) {
    if (haptic) _haptic(tone);
    final navigator = Navigator.of(context, rootNavigator: true);
    return navigator.push<T>(
      _route<T>(
        dismissible: barrierDismissible,
        builder: (_) => _DialogCard<T>(
          tone: tone,
          title: title,
          message: message,
          icon: icon,
          details: details,
          content: content,
          actions: actions,
          dismissible: barrierDismissible,
          autoCloseAfter: autoCloseAfter,
          layout: layout,
        ),
      ),
    );
  }

  // ---- Jalan pintas ----

  /// Berhasil. Return true bila tombol utama ditekan.
  static Future<bool> showSuccess(
    BuildContext context, {
    required String title,
    String? message,
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    String primaryLabel = 'OK',
    IconData? primaryIcon,
    String? secondaryLabel,
    Duration? autoCloseAfter,
    bool barrierDismissible = true,
  }) => _simple(
    context,
    tone: BapendaDialogTone.success,
    title: title,
    message: message,
    details: details,
    content: content,
    primaryLabel: primaryLabel,
    primaryIcon: primaryIcon,
    secondaryLabel: secondaryLabel,
    autoCloseAfter: autoCloseAfter,
    barrierDismissible: barrierDismissible,
  );

  /// Peringatan. Return true bila tombol utama ditekan.
  static Future<bool> showWarning(
    BuildContext context, {
    required String title,
    String? message,
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    String primaryLabel = 'Mengerti',
    IconData? primaryIcon,
    String? secondaryLabel,
    bool barrierDismissible = true,
  }) => _simple(
    context,
    tone: BapendaDialogTone.warning,
    title: title,
    message: message,
    details: details,
    content: content,
    primaryLabel: primaryLabel,
    primaryIcon: primaryIcon,
    secondaryLabel: secondaryLabel,
    barrierDismissible: barrierDismissible,
  );

  /// Informasi. Return true bila tombol utama ditekan.
  static Future<bool> showInfo(
    BuildContext context, {
    required String title,
    String? message,
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    String primaryLabel = 'OK',
    IconData? primaryIcon,
    String? secondaryLabel,
    bool barrierDismissible = true,
  }) => _simple(
    context,
    tone: BapendaDialogTone.info,
    title: title,
    message: message,
    details: details,
    content: content,
    primaryLabel: primaryLabel,
    primaryIcon: primaryIcon,
    secondaryLabel: secondaryLabel,
    barrierDismissible: barrierDismissible,
  );

  /// Gagal. Isi [retryLabel] untuk menampilkan tombol coba lagi; return true
  /// bila tombol itu ditekan.
  static Future<bool> showError(
    BuildContext context, {
    required String title,
    String? message,
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    String? retryLabel,
    String closeLabel = 'Tutup',
    bool barrierDismissible = true,
  }) async {
    final result = await show<bool>(
      context,
      tone: BapendaDialogTone.error,
      title: title,
      message: message,
      details: details,
      content: content,
      barrierDismissible: barrierDismissible,
      actions: [
        if (retryLabel != null) ...[
          BapendaDialogAction<bool>.primary(
            label: retryLabel,
            icon: Icons.refresh_rounded,
            result: true,
          ),
          BapendaDialogAction<bool>.secondary(label: closeLabel, result: false),
        ] else
          BapendaDialogAction<bool>.primary(label: closeLabel, result: false),
      ],
    );
    return result ?? false;
  }

  /// Konfirmasi. Return true bila dikonfirmasi.
  ///
  /// [destructive] = tindakan berbahaya (hapus dll): dialog dan tombol merah.
  /// [onConfirm] = proses async yang dijalankan di dalam dialog.
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    bool destructive = false,
    IconData? icon,
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    Future<void> Function()? onConfirm,
    bool barrierDismissible = true,
  }) async {
    final result = await show<bool>(
      context,
      tone: destructive ? BapendaDialogTone.error : BapendaDialogTone.confirm,
      title: title,
      message: message,
      icon:
          icon ??
          (destructive
              ? Icons.delete_outline_rounded
              : Icons.help_outline_rounded),
      details: details,
      content: content,
      barrierDismissible: barrierDismissible,
      actions: [
        BapendaDialogAction<bool>.primary(
          label: confirmLabel,
          result: true,
          onPressed: onConfirm,
        ),
        BapendaDialogAction<bool>.secondary(label: cancelLabel, result: false),
      ],
    );
    return result ?? false;
  }

  // ---- Loading ----

  /// Tampilkan dialog loading. Tutup lewat `controller.close()`.
  static BapendaLoadingController showLoading(
    BuildContext context, {
    String title = 'Mohon tunggu',
    String? message,

    /// true = ada tombol Batal. [onCancel] dipanggil saat ditekan.
    bool cancellable = false,
    VoidCallback? onCancel,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final controller = BapendaLoadingController._(navigator);
    controller._value.value = _LoadingValue(message: message);

    final route = _route<void>(
      dismissible: false,
      builder: (_) => _LoadingCard(
        title: title,
        controller: controller,
        cancellable: cancellable,
        onCancel: onCancel,
      ),
    );
    controller._route = route;
    navigator.push<void>(route).then((_) => controller._closed = true);
    return controller;
  }

  /// Tampilkan loading selama [task] berjalan, lalu tutup otomatis (juga saat
  /// error). Hasil atau error dari [task] diteruskan apa adanya.
  static Future<T> runWithLoading<T>(
    BuildContext context,
    Future<T> Function(BapendaLoadingController loading) task, {
    String title = 'Mohon tunggu',
    String? message,
  }) async {
    final loading = showLoading(context, title: title, message: message);
    try {
      return await task(loading);
    } finally {
      loading.close();
    }
  }

  // ---- Bagian dalam ----

  static Future<bool> _simple(
    BuildContext context, {
    required BapendaDialogTone tone,
    required String title,
    required String primaryLabel,
    String? message,
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    IconData? primaryIcon,
    String? secondaryLabel,
    Duration? autoCloseAfter,
    bool barrierDismissible = true,
  }) async {
    final result = await show<bool>(
      context,
      tone: tone,
      title: title,
      message: message,
      details: details,
      content: content,
      autoCloseAfter: autoCloseAfter,
      barrierDismissible: barrierDismissible,
      actions: [
        BapendaDialogAction<bool>.primary(
          label: primaryLabel,
          icon: primaryIcon,
          result: true,
        ),
        if (secondaryLabel != null)
          BapendaDialogAction<bool>.secondary(
            label: secondaryLabel,
            result: false,
          ),
      ],
    );
    return result ?? false;
  }

  static void _haptic(BapendaDialogTone tone) {
    switch (tone) {
      case BapendaDialogTone.success:
        HapticFeedback.lightImpact();
      case BapendaDialogTone.error:
      case BapendaDialogTone.warning:
        HapticFeedback.mediumImpact();
      case BapendaDialogTone.info:
      case BapendaDialogTone.confirm:
        break;
    }
  }

  /// Rute dialog: memudar + membesar halus, aman untuk keyboard dan notch.
  static RawDialogRoute<T> _route<T>({
    required bool dismissible,
    required WidgetBuilder builder,
  }) {
    return RawDialogRoute<T>(
      barrierDismissible: dismissible,
      barrierLabel: 'Tutup',
      barrierColor: AppThemeColors.blackPrimary.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, _, _) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: MediaQuery.viewInsetsOf(context),
        child: SafeArea(child: Center(child: builder(context))),
      ),
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
          child: ScaleTransition(
            scale: animation
                .drive(CurveTween(curve: Curves.easeOutBack))
                .drive(Tween<double>(begin: 0.88, end: 1)),
            child: child,
          ),
        );
      },
    );
  }
}

// =============================================================================
// Warna & ikon per nuansa
// =============================================================================

class _ToneStyle {
  final Color color;
  final Color soft;
  final IconData icon;
  const _ToneStyle(this.color, this.soft, this.icon);
}

_ToneStyle _styleOf(BapendaDialogTone tone) => switch (tone) {
  BapendaDialogTone.success => const _ToneStyle(
    AppThemeColors.success,
    AppThemeColors.successSoft,
    Icons.check_rounded,
  ),
  BapendaDialogTone.error => const _ToneStyle(
    AppThemeColors.danger,
    AppThemeColors.dangerSoft,
    Icons.priority_high_rounded,
  ),
  // `warning` (kuning terang) terlalu pucat untuk ikon & tombol putih, jadi
  // yang dipakai versi emas tuanya.
  BapendaDialogTone.warning => const _ToneStyle(
    AppThemeColors.gold,
    AppThemeColors.warningSoft,
    Icons.warning_amber_rounded,
  ),
  BapendaDialogTone.info => const _ToneStyle(
    AppThemeColors.information,
    AppThemeColors.informationSoft,
    Icons.info_outline_rounded,
  ),
  BapendaDialogTone.confirm => const _ToneStyle(
    AppThemeColors.primary,
    AppThemeColors.primarySoft,
    Icons.help_outline_rounded,
  ),
};

const _ink = AppThemeColors.titleText;
const _body = AppThemeColors.secondaryText;
// Label kecil & tombol teks: tetap secondaryText supaya terbaca jelas
// (tertiaryText terlalu pucat di ukuran 12).
const _muted = AppThemeColors.secondaryText;

// =============================================================================
// Kartu dialog
// =============================================================================

class _DialogCard<T> extends StatefulWidget {
  final BapendaDialogTone tone;
  final String title;
  final String? message;
  final IconData? icon;
  final List<BapendaDialogDetail> details;
  final Widget? content;
  final List<BapendaDialogAction<T>> actions;
  final bool dismissible;
  final Duration? autoCloseAfter;
  final BapendaDialogLayout layout;

  const _DialogCard({
    required this.tone,
    required this.title,
    required this.message,
    required this.icon,
    required this.details,
    required this.content,
    required this.actions,
    required this.dismissible,
    required this.autoCloseAfter,
    required this.layout,
  });

  @override
  State<_DialogCard<T>> createState() => _DialogCardState<T>();
}

class _DialogCardState<T> extends State<_DialogCard<T>> {
  /// Indeks tombol yang sedang menjalankan proses (null = tidak ada).
  int? _busy;
  String? _error;
  Timer? _timer;
  bool _autoClosing = false;

  @override
  void initState() {
    super.initState();
    final after = widget.autoCloseAfter;
    if (after != null) {
      _autoClosing = true;
      _timer = Timer(after, () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handle(BapendaDialogAction<T> action, int index) async {
    if (_busy != null) return;

    // Pengguna sudah bertindak: batalkan tutup otomatis.
    _timer?.cancel();
    if (_autoClosing) setState(() => _autoClosing = false);

    final task = action.onPressed;
    if (task != null) {
      setState(() {
        _busy = index;
        _error = null;
      });
      try {
        await task();
      } catch (_) {
        if (mounted) {
          setState(() {
            _busy = null;
            _error = 'Terjadi kesalahan. Silakan coba lagi.';
          });
        }
        return;
      }
      if (!mounted) return;
    }

    if (action.closeOnPressed) {
      Navigator.of(context).pop(action.result);
    } else {
      setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleOf(widget.tone);
    final mq = MediaQuery.of(context);
    final message = widget.message;
    final content = widget.content;

    return MediaQuery(
      // Teks sistem yang sangat besar tidak boleh merusak dialog.
      data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.25)),
      child: PopScope(
        canPop: widget.dismissible && _busy == null,
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: widget.title,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 380,
                maxHeight: mq.size.height * 0.88,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppThemeColors.defaultSurface,
                  elevation: 14,
                  shadowColor: Colors.black38,
                  borderRadius: BorderRadius.circular(26),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_autoClosing)
                        _AutoCloseBar(
                          duration: widget.autoCloseAfter!,
                          style: style,
                        ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
                          child: Column(
                            children: [
                              _IconBadge(
                                tone: widget.tone,
                                style: style,
                                icon: widget.icon,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                  color: _ink,
                                ),
                              ),
                              if (message != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: _body,
                                  ),
                                ),
                              ],
                              if (widget.details.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                _DetailPanel(details: widget.details),
                              ],
                              if (content != null) ...[
                                const SizedBox(height: 16),
                                content,
                              ],
                              if (_error != null) ...[
                                const SizedBox(height: 14),
                                _InlineError(text: _error!),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                        child: _buildActions(style),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(_ToneStyle style) {
    int rank(BapendaDialogAction<T> a) => switch (a.style) {
      BapendaDialogActionStyle.primary => 0,
      BapendaDialogActionStyle.secondary => 1,
      BapendaDialogActionStyle.text => 2,
    };

    // Urutan tetap: utama dulu, lalu sekunder, lalu teks (sesuai urutan
    // pemanggil bila setara).
    final items =
        [
          for (var i = 0; i < widget.actions.length; i++)
            (i: i, a: widget.actions[i]),
        ]..sort((x, y) {
          final c = rank(x.a).compareTo(rank(y.a));
          return c != 0 ? c : x.i.compareTo(y.i);
        });

    final horizontal = switch (widget.layout) {
      BapendaDialogLayout.vertical => false,
      BapendaDialogLayout.horizontal => true,
      BapendaDialogLayout.auto =>
        items.length == 2 &&
            items.every(
              (e) =>
                  e.a.style != BapendaDialogActionStyle.text &&
                  e.a.label.length <= 16,
            ),
    };

    Widget button(({int i, BapendaDialogAction<T> a}) e) => _DialogButton(
      label: e.a.label,
      icon: e.a.icon,
      style: e.a.style,
      color: style.color,
      loading: _busy == e.i,
      enabled: _busy == null,
      onTap: () => _handle(e.a, e.i),
    );

    if (horizontal) {
      // Berdampingan: tombol utama di kanan.
      final ordered = items.reversed.toList();
      return Row(
        children: [
          for (var j = 0; j < ordered.length; j++) ...[
            if (j > 0) const SizedBox(width: 10),
            Expanded(child: button(ordered[j])),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var j = 0; j < items.length; j++) ...[
          if (j > 0) const SizedBox(height: 10),
          button(items[j]),
        ],
      ],
    );
  }
}

// =============================================================================
// Bagian-bagian kecil
// =============================================================================

/// Lingkaran ikon dengan animasi masuk satu kali. Pada dialog gagal, ikon
/// bergetar sebentar. Menghormati pengaturan "kurangi animasi" di HP.
class _IconBadge extends StatelessWidget {
  final BapendaDialogTone tone;
  final _ToneStyle style;
  final IconData? icon;

  const _IconBadge({
    required this.tone,
    required this.style,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 650),
      builder: (context, t, _) {
        final ring = Curves.easeOutCubic.transform(t);
        final core = Curves.easeOutBack.transform(
          ((t - 0.1) / 0.9).clamp(0.0, 1.0),
        );
        final shake = tone == BapendaDialogTone.error
            ? math.sin(t * math.pi * 5) * (1 - t) * 7
            : 0.0;

        return SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 0.6 + 0.4 * ring,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.soft,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(shake, 0),
                child: Transform.scale(
                  scale: core,
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: style.color,
                      boxShadow: [
                        BoxShadow(
                          color: style.color.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon ?? style.icon,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Garis hitung mundur di atas dialog yang tutup otomatis.
class _AutoCloseBar extends StatelessWidget {
  final Duration duration;
  final _ToneStyle style;

  const _AutoCloseBar({required this.duration, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: duration,
      builder: (context, v, _) => LinearProgressIndicator(
        value: v,
        minHeight: 3,
        color: style.color,
        backgroundColor: style.soft,
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final List<BapendaDialogDetail> details;

  const _DetailPanel({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppThemeColors.grey7,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppThemeColors.grey4),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details[i].label,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _value(details[i])),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _value(BapendaDialogDetail d) {
    const style = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: _ink,
    );
    return d.selectable
        ? SelectableText(d.value, textAlign: TextAlign.end, style: style)
        : Text(d.value, textAlign: TextAlign.end, style: style);
  }
}

class _InlineError extends StatelessWidget {
  final String text;

  const _InlineError({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppThemeColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppThemeColors.textDanger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final BapendaDialogActionStyle style;
  final Color color;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.style,
    required this.color,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = style == BapendaDialogActionStyle.primary;
    final isText = style == BapendaDialogActionStyle.text;
    final radius = BorderRadius.circular(14);

    final fg = isPrimary
        ? Colors.white
        : isText
        ? _muted
        : AppThemeColors.titleText;

    final Widget child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      // Tombol lain meredup saat satu tombol sedang memproses.
      opacity: (!enabled && !loading) ? 0.45 : 1,
      child: Material(
        color: isPrimary ? color : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: enabled ? onTap : null,
          child: Container(
            height: isText ? 42 : 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: style == BapendaDialogActionStyle.secondary
                ? BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: AppThemeColors.defaultBorder,
                      width: 1.2,
                    ),
                  )
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Dialog loading
// =============================================================================

class _LoadingCard extends StatelessWidget {
  final String title;
  final BapendaLoadingController controller;
  final bool cancellable;
  final VoidCallback? onCancel;

  const _LoadingCard({
    required this.title,
    required this.controller,
    required this.cancellable,
    required this.onCancel,
  });

  static const _accent = AppThemeColors.primary;
  static const _accentText = AppThemeColors.gold; // teks kecil: lebih gelap
  static const _soft = AppThemeColors.primarySoft;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return MediaQuery(
      data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.25)),
      child: PopScope(
        canPop: false, // loading tidak boleh ditutup dengan tombol kembali
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: title,
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Material(
              color: AppThemeColors.defaultSurface,
              elevation: 14,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: ValueListenableBuilder<_LoadingValue>(
                  valueListenable: controller._value,
                  builder: (context, v, _) {
                    final progress = v.progress?.clamp(0.0, 1.0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _soft,
                          ),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress, // null = berputar bebas
                                  strokeWidth: 4,
                                  strokeCap: StrokeCap.round,
                                  color: _accent,
                                  backgroundColor: progress == null
                                      ? null
                                      : AppThemeColors.brown2,
                                ),
                                if (progress != null)
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _accentText,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        if (v.message != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            v.message!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: _body,
                            ),
                          ),
                        ],
                        if (cancellable) ...[
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () {
                              onCancel?.call();
                              controller.close();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: _muted,
                              textStyle: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
