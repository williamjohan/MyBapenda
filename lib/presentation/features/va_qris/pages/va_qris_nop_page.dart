import 'package:mybapenda/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/theme/theme_kit.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/va_qris_cubit.dart';
import '../cubit/va_qris_state.dart';
import '../widgets/common/va_qris_app_bar.dart';
import '../widgets/common/va_qris_hero_header.dart';
import '../widgets/common/va_qris_info_banner.dart';
import '../widgets/common/va_qris_primary_button.dart';
import '../widgets/nop/nop_input_card.dart';
import '../widgets/nop/recent_reference_section.dart';
import '../widgets/nop/reference_mask_formatter.dart';
import '../widgets/nop/tax_object_search_sheet.dart';

/// Langkah 1: petugas memilih jenis pajak dan memasukkan No SKPD / NOP.
class VaQrisNopPage extends StatefulWidget {
  const VaQrisNopPage({super.key});

  @override
  State<VaQrisNopPage> createState() => _VaQrisNopPageState();
}

class _VaQrisNopPageState extends State<VaQrisNopPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    context.read<VaQrisCubit>().clearError();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  bool _isValid(VaQrisState state) {
    final type = state.selectedTaxType;
    final text = _controller.text.trim();
    if (type == null || text.isEmpty) return false;
    final length = type.referenceLength;
    if (length == null) return true;
    // NOP bermask: hitung digitnya saja (titik boleh ada / tidak)
    final counted = type.mask != null || type.digitsOnly
        ? ReferenceMaskFormatter.digitsOf(text).length
        : text.length;
    return counted == length;
  }

  void _search() {
    final cubit = context.read<VaQrisCubit>();
    if (!_isValid(cubit.state)) return;
    FocusScope.of(context).unfocus();
    cubit.searchBilling(_controller.text.trim());
  }

  /// Dari "Cari objek pajak" / riwayat: isi NOP (tanpa titik) lalu langsung
  /// cari tagihan.
  void _pickReference(int taxTypeId, String referenceNumber) {
    FocusScope.of(context).unfocus();
    final cubit = context.read<VaQrisCubit>();
    final type = cubit.state.taxTypes.where((t) => t.id == taxTypeId);
    _controller.text = type.isEmpty
        ? referenceNumber
        : type.first.cleanReference(referenceNumber);
    cubit.pickReference(taxTypeId: taxTypeId, referenceNumber: referenceNumber);
  }

  Future<void> _openObjectSearch() async {
    FocusScope.of(context).unfocus();
    final pick = await TaxObjectSearchSheet.show(
      context,
      recent: context.read<VaQrisCubit>().state.recent,
    );
    if (pick == null || !mounted) return;
    _pickReference(pick.taxTypeId, pick.referenceNumber);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VaQrisCubit, VaQrisState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status && curr.status == VaQrisStatus.loaded,
      listener: (context, state) {
        final billing = state.billing;
        if (billing != null) context.push(AppRoutes.billing, extra: billing);
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: context.palette.surfaceMuted,
          appBar: const VaQrisAppBar(title: 'Create VA & QRIS'),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const VaQrisHeroHeader(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: _NopIntro(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: BlocBuilder<VaQrisCubit, VaQrisState>(
                    builder: (context, state) {
                      if (state.taxTypes.isEmpty) {
                        return _TaxTypeLoader(
                          state: state,
                          controller: _controller,
                        );
                      }

                      final isLoading = state.status == VaQrisStatus.searching;
                      return Column(
                        children: [
                          NopInputCard(
                            controller: _controller,
                            taxTypes: state.taxTypes,
                            selectedTaxType: state.selectedTaxType,
                            onTaxTypeChanged: (type) {
                              _controller.clear();
                              context.read<VaQrisCubit>().selectTaxType(type);
                            },
                            errorText: state.status == VaQrisStatus.failure
                                ? state.errorMessage
                                : null,
                            enabled: !isLoading,
                            onSubmitted: _search,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: isLoading ? null : _openObjectSearch,
                              style: TextButton.styleFrom(
                                foregroundColor: context.palette.accent,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              icon: const Icon(
                                Icons.manage_search_rounded,
                                size: 17,
                              ),
                              label: const Text(
                                'Tidak tahu NOP? Cari objek pajak',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const VaQrisInfoBanner(
                            message:
                                'No SKPD tertera pada SKPD reklame; NOP tertera '
                                'pada SPPT atau bukti pendaftaran wajib pajak.',
                            icon: Icons.lightbulb_outline_rounded,
                          ),
                          const SizedBox(height: 20),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (context, _, __) => VaQrisPrimaryButton(
                              label: 'Cari tagihan',
                              icon: Icons.search_rounded,
                              isLoading: isLoading,
                              onPressed: _isValid(state) ? _search : null,
                            ),
                          ),
                          if (state.recent.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            RecentReferenceSection(
                              items: state.recent.take(5).toList(),
                              onSelected: isLoading
                                  ? (_) {}
                                  : (r) => _pickReference(
                                      r.taxTypeId,
                                      r.referenceNumber,
                                    ),
                              onClear: context.read<VaQrisCubit>().clearRecent,
                            ),
                          ],
                        ],
                      );
                    },
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

/// Saat daftar jenis pajak belum ada: kartu input bayangan (skeleton), atau
/// gagal + tombol ulang.
class _TaxTypeLoader extends StatelessWidget {
  const _TaxTypeLoader({required this.state, required this.controller});

  final VaQrisState state;
  final TextEditingController controller;

  static const _placeholder = TaxTypeEntity(
    id: 0,
    name: 'Pajak Placeholder',
    referenceLabel: 'Nomor referensi',
    hint: 'Masukkan nomor referensi',
    digitsOnly: true,
  );

  @override
  Widget build(BuildContext context) {
    if (state.status != VaQrisStatus.failure) {
      return Skeletonizer(
        child: NopInputCard(
          controller: controller,
          taxTypes: const [_placeholder],
          selectedTaxType: _placeholder,
          onTaxTypeChanged: (_) {},
          enabled: false,
          onSubmitted: () {},
        ),
      );
    }

    return Column(
      children: [
        VaQrisInfoBanner(
          message: state.errorMessage ?? 'Gagal memuat jenis pajak.',
          icon: Icons.error_outline_rounded,
        ),
        const SizedBox(height: 16),
        VaQrisPrimaryButton(
          label: 'Coba lagi',
          icon: Icons.refresh_rounded,
          onPressed: () => context.read<VaQrisCubit>().init(),
        ),
      ],
    );
  }
}

class _NopIntro extends StatelessWidget {
  const _NopIntro();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tagih di lapangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Pilih jenis pajak, lalu masukkan No SKPD atau NOP untuk '
                'membuat QRIS atau Virtual Account.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
