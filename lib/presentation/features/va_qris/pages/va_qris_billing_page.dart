
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../../../domain/entities/va_qris/payment_method.dart';
import '../../../../domain/entities/va_qris/tax_billing_entity.dart';
import '../../../../domain/entities/va_qris/tax_period_entity.dart';
import '../../../../routes/app_routes.dart';
import '../logic/period_selection_logic.dart';
import '../mock/va_qris_mock_data.dart';
import '../widgets/billing/billing_tab_bar.dart';
import '../widgets/billing/billing_total_bar.dart';
import '../widgets/billing/paid_period_list.dart';
import '../widgets/billing/payment_method_sheet.dart';
import '../widgets/billing/taxpayer_summary_card.dart';
import '../widgets/billing/unpaid_period_list.dart';
import '../widgets/common/va_qris_app_bar.dart';
import '../widgets/common/va_qris_hero_header.dart';

/// Langkah 2-4: tagihan NOP, pilih masa pajak (berurutan), konfirmasi.
class VaQrisBillingPage extends StatefulWidget {
  const VaQrisBillingPage({super.key, required this.billing});

  final TaxBillingEntity billing;

  @override
  State<VaQrisBillingPage> createState() => _VaQrisBillingPageState();
}

class _VaQrisBillingPageState extends State<VaQrisBillingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<TaxPeriodEntity> _unpaid;
  late final List<TaxPeriodEntity> _paid;

  // TODO(tech-debt): pindahkan ke VaQrisState.selectedCount.
  late int _selectedCount;

  @override
  void initState() {
    super.initState();
    _unpaid = widget.billing.unpaidPeriods;
    _paid = widget.billing.paidPeriodsThisYear;
    _selectedCount = PeriodSelectionLogic.defaultSelectedCount(_unpaid.length);

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaxPeriodEntity> get _selected => _unpaid.take(_selectedCount).toList();

  int get _principal => _selected.fold(0, (sum, p) => sum + p.principal);
  int get _penalty => _selected.fold(0, (sum, p) => sum + p.penalty);

  void _onToggle(int index) {
    setState(() {
      _selectedCount = PeriodSelectionLogic.toggle(
        selectedCount: _selectedCount,
        index: index,
      );
    });
  }

  Future<void> _onConfirm() async {
    final method = await PaymentMethodSheet.show(
      context,
      total: _principal + _penalty,
      periodCount: _selectedCount,
    );
    if (method == null || !mounted) return;

    // TODO(tech-debt): ganti dengan VaQrisCubit.confirmPayment(method).
    final session = VaQrisMockData.createSession(
      billing: widget.billing,
      selectedPeriods: _selected,
      method: method,
    );

    context.push(
      method == PaymentMethod.qris ? AppRoutes.qris : AppRoutes.va,
      extra: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTotalBar = _tabController.index == 0 && _unpaid.isNotEmpty;

    return Scaffold(
      backgroundColor: AppThemeColors.defaultBackground,
      appBar: const VaQrisAppBar(title: 'Tagihan pajak'),
      body: Column(
        children: [
          VaQrisHeroHeader(
            child: TaxpayerSummaryCard(billing: widget.billing),
          ),
          BillingTabBar(
            controller: _tabController,
            unpaidCount: _unpaid.length,
            paidCount: _paid.length,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                UnpaidPeriodList(
                  periods: _unpaid,
                  selectedCount: _selectedCount,
                  onToggle: _onToggle,
                ),
                PaidPeriodList(periods: _paid),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: showTotalBar
          ? BillingTotalBar(
              selectedCount: _selectedCount,
              principal: _principal,
              penalty: _penalty,
              onConfirm: _onConfirm,
            )
          : null,
    );
  }
}
