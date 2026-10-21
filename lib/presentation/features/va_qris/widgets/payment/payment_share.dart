import 'dart:io';

import 'package:mybapenda/core/utils/app_logger.dart';
import 'package:mybapenda/core/utils/app_share_utils.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_method.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../utils/va_qris_ui_helper.dart';
import 'qris_share_card.dart';

/// Bagikan kode bayar ke wajib pajak lewat menu share bawaan OS.
/// QRIS: gambar [QrisShareCard] (PNG) + teks; VA: teks berisi nomor VA.
abstract final class PaymentShare {
  static Future<void> share(
    BuildContext context,
    PaymentSessionEntity session,
  ) async {
    final caption = VaQrisUiHelper.teksBagikan(session);
    if (session.method == PaymentMethod.vaBankJatim) {
      await AppShareUtils.shareText(caption, subject: 'Pembayaran pajak');
      return;
    }

    try {
      final bytes = await ScreenshotController().captureFromWidget(
        QrisShareCard(session: session),
        context: context,
        pixelRatio: 3,
        delay: const Duration(milliseconds: 100),
      );
      final dir = await getTemporaryDirectory();
      final name = session.reference.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
      final file = File('${dir.path}/qris_$name.png');
      await file.writeAsBytes(bytes, flush: true);
      await AppShareUtils.shareFile(file.path, text: caption);
    } catch (e, st) {
      AppLogger.error('Gagal menyiapkan gambar QRIS untuk dibagikan', e, st);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Gagal menyiapkan gambar QRIS. Coba lagi.'),
          ),
        );
    }
  }
}
