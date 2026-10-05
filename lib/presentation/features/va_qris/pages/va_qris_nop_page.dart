import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../../../routes/app_routes.dart';
import '../mock/va_qris_mock_data.dart';
import '../../../../core/utils/va_qris_constants.dart';
import '../widgets/common/va_qris_app_bar.dart';
import '../widgets/common/va_qris_hero_header.dart';
import '../widgets/common/va_qris_info_banner.dart';
import '../widgets/common/va_qris_primary_button.dart';
import '../widgets/nop/nop_input_card.dart';

/// Langkah 1: petugas memasukkan NOP wajib pajak.
class VaQrisNopPage extends StatefulWidget {
  const VaQrisNopPage({super.key});

  @override
  State<VaQrisNopPage> createState() => _VaQrisNopPageState();
}

class _VaQrisNopPageState extends State<VaQrisNopPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  bool get _isValid => _controller.text.length == kNopLength;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _errorText = null);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!_isValid || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO(tech-debt): ganti dengan VaQrisCubit.searchBilling(nop).
    final billing = await VaQrisMockData.fetchBilling(_controller.text);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (billing == null) {
        _errorText = 'NOP tidak ditemukan. Periksa kembali nomornya.';
      }
    });

    if (billing != null) {
      context.push(AppRoutes.billing, extra: billing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                child: Column(
                  children: [
                    NopInputCard(
                      controller: _controller,
                      errorText: _errorText,
                      enabled: !_isLoading,
                      onSubmitted: _search,
                    ),
                    const SizedBox(height: 12),
                    const VaQrisInfoBanner(
                      message:
                          'NOP tertera pada SPPT atau bukti pendaftaran wajib pajak.',
                      icon: Icons.lightbulb_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                    VaQrisPrimaryButton(
                      label: 'Cari tagihan',
                      icon: Icons.search_rounded,
                      isLoading: _isLoading,
                      onPressed: _isValid ? _search : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
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
                'Masukkan NOP untuk membuat QRIS atau Virtual Account.',
                style: TextStyle(fontSize: 13, height: 1.35, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
