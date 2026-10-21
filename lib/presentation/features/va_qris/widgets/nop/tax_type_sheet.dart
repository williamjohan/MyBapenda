import 'package:mybapenda/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_kit.dart';
import 'tax_type_option_tile.dart';

/// Bottom sheet pilihan jenis pajak. Mengembalikan [TaxTypeEntity] yang
/// dipilih, atau `null` jika ditutup.
class TaxTypeSheet extends StatelessWidget {
  const TaxTypeSheet({super.key, required this.taxTypes, this.selected});

  final List<TaxTypeEntity> taxTypes;
  final TaxTypeEntity? selected;

  static Future<TaxTypeEntity?> show(
    BuildContext context, {
    required List<TaxTypeEntity> taxTypes,
    TaxTypeEntity? selected,
  }) {
    return showModalBottomSheet<TaxTypeEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surfaceMuted,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TaxTypeSheet(taxTypes: taxTypes, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;
    final palette = context.palette;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                'Pilih jenis pajak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                'Nomor yang dicari mengikuti jenis pajak yang dipilih.',
                style: TextStyle(fontSize: 13, color: palette.textSecondary),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: taxTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final type = taxTypes[i];
                  return TaxTypeOptionTile(
                    type: type,
                    isSelected: type.id == selected?.id,
                    onTap: () => Navigator.of(context).pop(type),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
