import 'package:bapendacore/core/utils/app_logger.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors_new.dart';
import '../../../../../routes/app_routes.dart';
import '../../cubit/va_qris_cubit.dart';
import '../../cubit/va_qris_state.dart';
import '../common/va_qris_app_bar.dart';
import 'payment_action_bar.dart';
import 'payment_amount_header.dart';
import 'payment_countdown_timer.dart';
import 'payment_guide_section.dart';
import 'payment_summary_card.dart';

typedef PaymentCardBuilder =
    Widget Function(
      BuildContext context,
      PaymentSessionEntity session,
      bool isExpired,
      VoidCallback onRegenerate,
    );

/// Kerangka bersama layar QRIS dan VA: header total, countdown, kartu utama
/// (QR/VA), rincian, panduan, dan aksi. Layar QRIS/VA hanya menyuplai
/// [cardBuilder] dan panduannya.
///
/// Sesi, kedaluwarsa, buat ulang, dan status lunas dikelola [VaQrisCubit]
/// (diisi route lewat `startSession`). [session] hanya nilai awal.
class PaymentPageLayout extends StatelessWidget {
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

  // TODO(tech-debt): naikkan kecerahan layar & tahan layar tetap menyala
  // selama QR/VA tampil (screen_brightness + wakelock_plus), lalu pulihkan
  // saat keluar.

  void _handleShare(BuildContext context, PaymentSessionEntity session) {
    // TODO(tech-debt): AppShareUtils saat ini hanya mendukung file. Tambah
    // AppShareUtils.shareText() atau render kartu QR ke gambar, lalu panggil
    // di sini.
    AppLogger.info('Bagikan ${session.method.label} (placeholder)');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Fitur bagikan belum tersedia')),
      );
  }

  Future<bool> _confirmExit(BuildContext context) async {
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
    return MultiBlocListener(
      listeners: [
        BlocListener<VaQrisCubit, VaQrisState>(
          listenWhen: (prev, curr) =>
              prev.sessionStatus != curr.sessionStatus &&
              curr.sessionStatus == PaymentSessionStatus.paid,
          listener: (context, state) => context.pushReplacement(
            AppRoutes.success,
            extra: state.session ?? session,
          ),
        ),
        BlocListener<VaQrisCubit, VaQrisState>(
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage &&
              curr.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          },
        ),
      ],
      child: BlocBuilder<VaQrisCubit, VaQrisState>(
        builder: (context, state) {
          final cubit = context.read<VaQrisCubit>();
          final current = state.session ?? session;
          final isExpired = state.isExpired;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final leave = isExpired ? true : await _confirmExit(context);
              if (leave && context.mounted) Navigator.of(context).pop();
            },
            child: Scaffold(
              backgroundColor: AppThemeColors.defaultBackground,
              appBar: VaQrisAppBar(
                title: appBarTitle,
                subtitle: 'Tunjukkan ke wajib pajak',
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    PaymentAmountHeader(
                      session: current,
                      countdown: PaymentCountdownTimer(
                        key: ValueKey(current.reference),
                        duration: current.validFor,
                        onTimeout: () {
                          AppLogger.info(
                            'Sesi pembayaran ${current.reference} kedaluwarsa',
                          );
                          cubit.markExpired();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        children: [
                          cardBuilder(
                            context,
                            current,
                            isExpired,
                            cubit.regenerateSession,
                          ),
                          const SizedBox(height: 14),
                          PaymentSummaryCard(session: current),
                          const SizedBox(height: 10),
                          PaymentGuideSection(
                            title: guideTitle,
                            steps: guideSteps,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: PaymentActionBar(
                shareLabel: shareLabel,
                isExpired: isExpired,
                onShare: () => _handleShare(context, current),
              ),
            ),
          );
        },
      ),
    );
  }
}
