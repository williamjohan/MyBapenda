import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/va_qris_cubit.dart';
import '../cubit/va_qris_state.dart';
import '../widgets/common/va_qris_app_bar.dart';
import '../widgets/common/va_qris_hero_header.dart';
import '../widgets/common/va_qris_info_banner.dart';
import '../widgets/common/va_qris_primary_button.dart';
import '../widgets/nop/nop_input_card.dart';
import '../widgets/nop/reference_mask_formatter.dart';

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
          backgroundColor: AppThemeColors.defaultBackground,
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
                        return _TaxTypeLoader(state: state);
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
                          const SizedBox(height: 12),
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

/// Saat daftar jenis pajak belum ada: loading, atau gagal + tombol ulang.
class _TaxTypeLoader extends StatelessWidget {
  const _TaxTypeLoader({required this.state});

  final VaQrisState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != VaQrisStatus.failure) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppThemeColors.primary),
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
