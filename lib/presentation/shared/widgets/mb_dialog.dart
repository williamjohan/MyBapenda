import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum BapendaDialogTone { brand, success, warning, danger, info }

/// Baris ringkasan di dalam dialog.
typedef BapendaDialogDetail = ({String label, String value});

/// Hasil aksi async. Cocok dengan return SurveySubmitCubit.submit.
typedef BapendaSubmitResult = ({bool ok, String? error});

class BapendaDialog {
  BapendaDialog._();

  /// Konfirmasi biasa. Return true kalau user menekan tombol konfirmasi.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    BapendaDialogTone tone = BapendaDialogTone.brand,
    IconData? icon,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    bool dismissible = true,
  }) async {
    final r = await _show<bool>(
      context,
      _Config(
        title: title,
        message: message,
        tone: tone,
        icon: icon,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        details: details,
        content: content,
      ),
      dismissible: dismissible,
    );
    return r == true;
  }

  /// Pemberitahuan satu tombol (sukses, gagal, info).
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    BapendaDialogTone tone = BapendaDialogTone.info,
    IconData? icon,
    String buttonLabel = 'Mengerti',
  }) async {
    await _show<bool>(
      context,
      _Config(
        title: title,
        message: message,
        tone: tone,
        icon: icon,
        confirmLabel: buttonLabel,
        cancelLabel: null,
      ),
      dismissible: true,
    );
  }

  /// Konfirmasi + proses async di dalam dialog yang sama.
  /// Return true kalau proses sukses dan user menutup dialog sukses.
  static Future<bool> submit(
    BuildContext context, {
    required String title,
    String? message,
    required Future<BapendaSubmitResult> Function() onConfirm,
    BapendaDialogTone tone = BapendaDialogTone.brand,
    IconData? icon,
    String confirmLabel = 'Kirim',
    String cancelLabel = 'Cek Lagi',
    List<BapendaDialogDetail> details = const [],
    Widget? content,
    String loadingTitle = 'Mengirim data...',
    String loadingMessage = 'Mohon tunggu dan jangan tutup aplikasi.',
    String successTitle = 'Berhasil',
    String? successMessage,
    String successLabel = 'Selesai',
    String errorTitle = 'Gagal Mengirim',
  }) async {
    final r = await _show<bool>(
      context,
      _Config(
        title: title,
        message: message,
        tone: tone,
        icon: icon,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        details: details,
        content: content,
        onConfirm: onConfirm,
        loadingTitle: loadingTitle,
        loadingMessage: loadingMessage,
        successTitle: successTitle,
        successMessage: successMessage,
        successLabel: successLabel,
        errorTitle: errorTitle,
      ),
      dismissible: false,
    );
    return r == true;
  }

  static Future<T?> _show<T>(
    BuildContext context,
    _Config cfg, {
    required bool dismissible,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _DialogView(cfg: cfg),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

// ============================================================================
// Internal
// ============================================================================

class _Config {
  final String title;
  final String? message;
  final BapendaDialogTone tone;
  final IconData? icon;
  final String confirmLabel;
  final String? cancelLabel;
  final List<BapendaDialogDetail> details;
  final Widget? content;
  final Future<BapendaSubmitResult> Function()? onConfirm;
  final String loadingTitle;
  final String loadingMessage;
  final String successTitle;
  final String? successMessage;
  final String successLabel;
  final String errorTitle;

  const _Config({
    required this.title,
    required this.confirmLabel,
    this.message,
    this.tone = BapendaDialogTone.brand,
    this.icon,
    this.cancelLabel,
    this.details = const [],
    this.content,
    this.onConfirm,
    this.loadingTitle = '',
    this.loadingMessage = '',
    this.successTitle = '',
    this.successMessage,
    this.successLabel = 'Selesai',
    this.errorTitle = 'Gagal',
  });
}

typedef _ToneStyle = ({Color fg, Color bg, IconData icon});

_ToneStyle _styleOf(BapendaDialogTone t) => switch (t) {
  BapendaDialogTone.brand => (
    fg: AppThemeColors.primary,
    bg: AppThemeColors.primarySoft,
    icon: Icons.help_outline_rounded,
  ),
  BapendaDialogTone.success => (
    fg: AppThemeColors.success,
    bg: AppThemeColors.successSoft,
    icon: Icons.check_rounded,
  ),
  BapendaDialogTone.warning => (
    fg: AppThemeColors.warning,
    bg: AppThemeColors.warningSoft,
    icon: Icons.warning_amber_rounded,
  ),
  BapendaDialogTone.danger => (
    fg: AppThemeColors.danger,
    bg: AppThemeColors.dangerSoft,
    icon: Icons.delete_outline_rounded,
  ),
  BapendaDialogTone.info => (
    fg: AppThemeColors.information,
    bg: AppThemeColors.informationSoft,
    icon: Icons.info_outline_rounded,
  ),
};

enum _Phase { ask, loading, success, error }

class _DialogView extends StatefulWidget {
  final _Config cfg;
  const _DialogView({required this.cfg});

  @override
  State<_DialogView> createState() => _DialogViewState();
}

class _DialogViewState extends State<_DialogView> {
  _Phase _phase = _Phase.ask;
  String? _error;

  Future<void> _run() async {
    final run = widget.cfg.onConfirm;
    if (run == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _phase = _Phase.loading);

    BapendaSubmitResult res;
    try {
      res = await run();
    } catch (_) {
      res = (ok: false, error: null);
    }
    if (!mounted) return;

    res.ok ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();
    setState(() {
      _phase = res.ok ? _Phase.success : _Phase.error;
      _error = res.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cfg;

    final tone = switch (_phase) {
      _Phase.ask => c.tone,
      _Phase.loading => BapendaDialogTone.brand,
      _Phase.success => BapendaDialogTone.success,
      _Phase.error => BapendaDialogTone.danger,
    };
    final style = _styleOf(tone);

    final icon = switch (_phase) {
      _Phase.ask => c.icon ?? style.icon,
      _Phase.loading => Icons.cloud_upload_rounded,
      _Phase.success => Icons.check_rounded,
      _Phase.error => Icons.error_outline_rounded,
    };

    final title = switch (_phase) {
      _Phase.ask => c.title,
      _Phase.loading => c.loadingTitle,
      _Phase.success => c.successTitle,
      _Phase.error => c.errorTitle,
    };

    final message = switch (_phase) {
      _Phase.ask => c.message,
      _Phase.loading => c.loadingMessage,
      _Phase.success => c.successMessage,
      _Phase.error =>
        _error ?? 'Terjadi kesalahan. Periksa koneksi lalu coba lagi.',
    };

    return PopScope(
      canPop: _phase != _Phase.loading,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: AppThemeColors.defaultSurface,
              borderRadius: BorderRadius.circular(24),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Padding(
                    key: ValueKey(_phase),
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Badge(
                          style: style,
                          icon: icon,
                          spinning: _phase == _Phase.loading,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: AppThemeColors.titleText,
                          ),
                        ),
                        if (message != null && message.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: AppThemeColors.secondaryText,
                            ),
                          ),
                        ],
                        if (_phase == _Phase.ask) ...[
                          if (c.details.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _DetailBox(details: c.details),
                          ],
                          if (c.content != null) ...[
                            const SizedBox(height: 16),
                            c.content!,
                          ],
                        ],
                        if (_phase != _Phase.loading) ...[
                          const SizedBox(height: 22),
                          _buildActions(tone),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BapendaDialogTone tone) {
    final c = widget.cfg;
    final color = _styleOf(tone).fg;
    final brand = tone == BapendaDialogTone.brand;

    switch (_phase) {
      case _Phase.success:
        return _Btn(
          label: c.successLabel,
          color: color,
          onTap: () => Navigator.of(context).pop(true),
        );
      case _Phase.error:
        return Row(
          children: [
            Expanded(
              child: _Btn(
                label: 'Tutup',
                outlined: true,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Btn(
                label: 'Coba Lagi',
                color: AppThemeColors.primary,
                gradient: true,
                onTap: _run,
              ),
            ),
          ],
        );
      case _Phase.ask:
      case _Phase.loading:
        final confirm = _Btn(
          label: c.confirmLabel,
          color: color,
          gradient: brand,
          onTap: _run,
        );
        if (c.cancelLabel == null) return confirm;
        return Row(
          children: [
            Expanded(
              child: _Btn(
                label: c.cancelLabel!,
                outlined: true,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: confirm),
          ],
        );
    }
  }
}

class _Badge extends StatelessWidget {
  final _ToneStyle style;
  final IconData icon;
  final bool spinning;

  const _Badge({
    required this.style,
    required this.icon,
    required this.spinning,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cincin luar yang lembut.
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.fg.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: style.bg),
            child: Icon(icon, size: 30, color: style.fg),
          ),
          if (spinning)
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                color: style.fg,
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final List<BapendaDialogDetail> details;
  const _DetailBox({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppThemeColors.grey8,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.subtleBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    details[i].label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppThemeColors.tertiaryText,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: Text(
                    details[i].value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.titleText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final bool gradient;
  final Color color;

  const _Btn({
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.gradient = false,
    this.color = AppThemeColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Material(
      color: Colors.transparent,
      child: Ink(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: outlined ? Colors.white : (gradient ? null : color),
          gradient: (!outlined && gradient)
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppThemeColors.primary, AppThemeColors.yellow5],
                )
              : null,
          border: outlined
              ? Border.all(color: AppThemeColors.defaultBorder, width: 1.2)
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: outlined ? AppThemeColors.blackPrimary : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
