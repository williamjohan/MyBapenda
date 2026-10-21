import 'package:mybapenda/domain/entities/va_qris/recent_reference_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_object_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/theme_kit.dart';
import '../../cubit/tax_object_search_cubit.dart';
import '../../cubit/tax_object_search_state.dart';
import 'recent_reference_section.dart';
import 'reference_option_tile.dart';
import 'tax_type_visual.dart';

/// Objek pajak yang dipilih dari sheet: jenis pajak + NOP berformat.
typedef ReferencePick = ({int taxTypeId, String referenceNumber});

/// Bottom sheet "Cari objek pajak" untuk petugas yang tidak hafal NOP.
/// Cari berdasarkan nama / alamat objek atau sebagian NOP (tombol Cari),
/// atau pilih dari riwayat [recent]. Mengembalikan [ReferencePick] atau
/// `null` bila ditutup.
class TaxObjectSearchSheet extends StatefulWidget {
  const TaxObjectSearchSheet({super.key, this.recent = const []});

  final List<RecentReferenceEntity> recent;

  static Future<ReferencePick?> show(
    BuildContext context, {
    List<RecentReferenceEntity> recent = const [],
  }) {
    return showModalBottomSheet<ReferencePick>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surfaceMuted,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => getIt<TaxObjectSearchCubit>(),
        child: TaxObjectSearchSheet(recent: recent),
      ),
    );
  }

  @override
  State<TaxObjectSearchSheet> createState() => _TaxObjectSearchSheetState();
}

class _TaxObjectSearchSheetState extends State<TaxObjectSearchSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    context.read<TaxObjectSearchCubit>().search(_controller.text);
  }

  void _pick(int taxTypeId, String referenceNumber) {
    Navigator.of(context).pop<ReferencePick>((
      taxTypeId: taxTypeId,
      referenceNumber: referenceNumber,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final height = MediaQuery.sizeOf(context).height * 0.88;

    return Padding(
      // Ikut naik saat keyboard muncul
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                'Cari objek pajak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Cari berdasarkan nama atau alamat objek, atau sebagian NOP. '
                'Objek reklame dicari lewat No SKPD.',
                style: TextStyle(fontSize: 13, color: palette.textSecondary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _SearchBar(controller: _controller, onSearch: _search),
            ),
            Expanded(
              child: BlocBuilder<TaxObjectSearchCubit, TaxObjectSearchState>(
                builder: (context, state) {
                  final body = _buildBody(context, state);
                  if (state.status == TaxObjectSearchStatus.initial ||
                      state.typeCounts.isEmpty) {
                    return body;
                  }
                  return Column(
                    children: [
                      _TypeFilterBar(
                        state: state,
                        onSelected: context.read<TaxObjectSearchCubit>().filter,
                      ),
                      Expanded(child: body),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaxObjectSearchState state) {
    final palette = context.palette;
    final cubit = context.read<TaxObjectSearchCubit>();

    switch (state.status) {
      case TaxObjectSearchStatus.initial:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            if (state.errorMessage != null) ...[
              Text(
                state.errorMessage!,
                style: TextStyle(fontSize: 12.5, color: palette.danger),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.recent.isNotEmpty)
              RecentReferenceSection(
                items: widget.recent,
                onSelected: (r) => _pick(r.taxTypeId, r.referenceNumber),
              )
            else
              const _Message(
                icon: Icons.manage_search_rounded,
                title: 'Cari objek pajak',
                message: 'Ketik nama atau alamat objek pajak, lalu tekan Cari.',
              ),
          ],
        );

      case TaxObjectSearchStatus.loading:
        return Skeletonizer(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: _placeholders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _tile(_placeholders[i], onTap: () {}),
          ),
        );

      case TaxObjectSearchStatus.failure:
        return _Message(
          icon: Icons.cloud_off_rounded,
          title: 'Gagal mencari',
          message: state.errorMessage ?? 'Terjadi kesalahan. Coba lagi.',
          isError: true,
          onRetry: cubit.retry,
        );

      case TaxObjectSearchStatus.success:
        if (state.items.isEmpty) {
          return _Message(
            icon: Icons.search_off_rounded,
            title: 'Objek pajak tidak ditemukan',
            message:
                'Tidak ada objek pajak aktif dengan kata "${state.keyword}". '
                'Coba kata lain atau sebagian NOP.',
          );
        }

        final items = state.visibleItems;
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 300) cubit.loadMore();
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: items.length + 2,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Text(
                  '${state.visibleTotal} objek pajak ditemukan',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                );
              }
              if (i == items.length + 1) {
                return _LoadMoreFooter(state: state, onLoad: cubit.loadMore);
              }
              final item = items[i - 1];
              return _tile(item, onTap: () => _pick(item.taxTypeId, item.nop));
            },
          ),
        );
    }
  }

  Widget _tile(TaxObjectEntity item, {required VoidCallback onTap}) {
    return ReferenceOptionTile(
      taxTypeId: item.taxTypeId,
      taxTypeName: item.taxTypeName,
      referenceNumber: item.nop,
      name: item.name,
      address: item.address,
      onTap: onTap,
    );
  }

  /// Bentuk kartu bayangan (skeleton) selama mencari.
  static final _placeholders = List.generate(
    4,
    (i) => TaxObjectEntity(
      taxTypeId: 0,
      taxTypeName: 'Jenis',
      nop: '35.78.000.000.000.0000$i',
      name: 'Nama Objek Pajak Placeholder',
      address: 'Jl. Placeholder No. 1, Surabaya',
    ),
  );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => onSearch(),
            style: TextStyle(fontSize: 14.5, color: palette.textPrimary),
            decoration: InputDecoration(
              hintText: 'Nama / alamat objek / NOP',
              hintStyle: TextStyle(fontSize: 14, color: palette.textTertiary),
              isDense: true,
              filled: true,
              fillColor: palette.surface,
              prefixIcon: Icon(Icons.search_rounded, color: palette.accent),
              border: border(palette.borderStrong),
              enabledBorder: border(palette.borderStrong),
              focusedBorder: border(palette.brand, width: 1.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.brand,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Cari'),
          ),
        ),
      ],
    );
  }
}

/// Chip filter jenis pajak (geser ke samping) beserta jumlah hasilnya.
class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({required this.state, required this.onSelected});

  final TaxObjectSearchState state;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        children: [
          _FilterChip(
            label: 'Semua',
            count: state.totalAllTypes,
            selected: state.taxTypeFilter == null,
            onTap: () => onSelected(null),
          ),
          for (final c in state.typeCounts)
            _FilterChip(
              label: taxTypeShortName(c.taxTypeId, fallback: c.taxTypeName),
              count: c.count,
              selected: state.taxTypeFilter == c.taxTypeId,
              onTap: () => onSelected(c.taxTypeId),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = selected ? Colors.white : palette.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? palette.brand : palette.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? palette.brand : palette.borderStrong,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : palette.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bawah daftar: memuat halaman berikutnya, gagal + coba lagi, atau (saat
/// difilter dan hasil jenis itu belum termuat semua) tombol muat berikutnya.
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.state, required this.onLoad});

  final TaxObjectSearchState state;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (state.loadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: palette.brand,
            ),
          ),
        ),
      );
    }
    if (state.loadMoreFailed) {
      return Center(
        child: TextButton.icon(
          onPressed: onLoad,
          style: TextButton.styleFrom(foregroundColor: palette.accent),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Gagal memuat, coba lagi'),
        ),
      );
    }

    final shown = state.visibleItems.length;
    if (state.taxTypeFilter != null &&
        state.hasMore &&
        shown < state.visibleTotal) {
      return Column(
        children: [
          Text(
            'Menampilkan $shown dari ${state.visibleTotal}',
            style: TextStyle(fontSize: 12, color: palette.textTertiary),
          ),
          TextButton.icon(
            onPressed: onLoad,
            style: TextButton.styleFrom(foregroundColor: palette.accent),
            icon: const Icon(Icons.expand_more_rounded, size: 18),
            label: const Text('Muat berikutnya'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isError ? palette.dangerSoft : palette.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: isError ? palette.danger : palette.brandStrong,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: palette.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.accent,
                  side: BorderSide(color: palette.brand),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
