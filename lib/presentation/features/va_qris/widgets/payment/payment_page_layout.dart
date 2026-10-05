import 'package:bapendacore/core/utils/app_logger.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../routes/app_routes.dart';
import '../../mock/va_qris_mock_data.dart';
import '../common/va_qris_app_bar.dart';
import 'payment_action_bar.dart';
import 'payment_amount_header.dart';
import 'payment_countdown_timer.dart';
import 'payment_guide_section.dart';
import 'payment_summary_card.dart';

typedef PaymentCardBuilder = Widget Function(
  BuildContext context,
  PaymentSessionEntity session,
  bool isExpired,
  VoidCallback onRegenerate,
);

/// Kerangka bersama layar QRIS dan VA: header total, countdown, kartu utama
/// (QR/VA), rincian, panduan, dan aksi. Layar QRIS/VA hanya menyuplai
/// [cardBuilder] dan panduannya.
class PaymentPageLayout extends StatefulWidget {
  const PaymentPageLayout({
    super.key,
    required this.appBarTitle,
    required this.session,
    required this.cardBuilder,
    required this.guideTitle,
    required this.guideSteps,
    required this.shareLabel,
  });

  final String appBarTitle;
  final PaymentSessionEntity session;
  final PaymentCardBuilder cardBuilder;
  final String guideTitle;
  final List<String> guideSteps;
  final String shareLabel;

  @override
  State<PaymentPageLayout> createState() => _PaymentPageLayoutState();
}

class _PaymentPageLayoutState extends State<PaymentPageLayout> {
  late PaymentSessionEntity _session;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    // TODO(tech-debt): naikkan kecerahan layar & tahan layar tetap menyala
    // selama QR/VA tampil (screen_brightness + wakelock_plus), lalu pulihkan
    // di dispose().
  }

  void _handleTimeout() {
    if (!mounted) return;
    AppLogger.info('Sesi pembayaran ${_session.reference} kedaluwarsa');
    setState(() => _isExpired = true);
  }

  void _handleRegenerate() {
    // TODO(tech-debt): ganti dengan VaQrisCubit.regenerateSession().
    setState(() {
      _session = VaQrisMockData.regenerateSession(_session);
      _isExpired = false;
    });
  }

  void _handleShare() {
    // TODO(tech-debt): AppShareUtils saat ini hanya mendukung file. Tambah
    // AppShareUtils.shareText() atau render kartu QR ke gambar, lalu panggil
    // di sini.
    AppLogger.info('Bagikan ${_session.method.label} (placeholder)');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Fitur bagikan belum tersedia')),
      );
  }

  void _handleSimulateSuccess() {
    // TODO(tech-debt): navigasi sukses harus dipicu status "paid" dari backend.
    context.pushReplacement(AppRoutes.success, extra: _session);
  }

  Future<bool> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pembayaran?'),
        content: const Text(
          'Kode pembayaran ini akan ditutup. Wajib pajak belum bisa membayar '
          'sebelum Anda membuat ulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tetap di sini'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppThemeColors.danger),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = _isExpired ? true : await _confirmExit();
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppThemeColors.defaultBackground,
        appBar: VaQrisAppBar(
          title: widget.appBarTitle,
          subtitle: 'Tunjukkan ke wajib pajak',
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              PaymentAmountHeader(
                session: _session,
                countdown: PaymentCountdownTimer(
                  key: ValueKey(_session.reference),
                  duration: _session.validFor,
                  onTimeout: _handleTimeout,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    widget.cardBuilder(
                      context,
                      _session,
                      _isExpired,
                      _handleRegenerate,
                    ),
                    const SizedBox(height: 14),
                    PaymentSummaryCard(session: _session),
                    const SizedBox(height: 10),
                    PaymentGuideSection(
                      title: widget.guideTitle,
                      steps: widget.guideSteps,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: PaymentActionBar(
          shareLabel: widget.shareLabel,
          isExpired: _isExpired,
          onShare: _handleShare,
          onSimulateSuccess: _handleSimulateSuccess,
        ),
      ),
    );
  }
}
