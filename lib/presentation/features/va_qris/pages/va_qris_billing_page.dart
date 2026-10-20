import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_kit.dart';
import '../../../../domain/entities/va_qris/payment_method.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/va_qris_cubit.dart';
import '../cubit/va_qris_state.dart';
import '../widgets/billing/billing_tab_bar.dart';
import '../widgets/billing/billing_total_bar.dart';
import '../widgets/billing/paid_period_list.dart';
import '../widgets/billing/payment_method_sheet.dart';
import '../widgets/billing/taxpayer_summary_card.dart';
import '../widgets/billing/unpaid_period_list.dart';
import '../widgets/common/va_qris_app_bar.dart';
import '../widgets/common/va_qris_hero_header.dart';

/// Langkah 2-4: tagihan, pilih masa pajak (bebas, ada "Pilih semua"),
/// konfirmasi.
/// Billing diisi route lewat [VaQrisCubit.loadBilling].
class VaQrisBillingPage extends StatefulWidget {
  const VaQrisBillingPage({super.key});

  @override
  State<VaQrisBillingPage> createState() => _VaQrisBillingPageState();
}

class _VaQrisBillingPageState extends State<VaQrisBillingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
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

  Future<void> _onConfirm(VaQrisState state) async {
    final cubit = context.read<VaQrisCubit>();
    final nominalCheck = await cubit.checkNominal();
    if (!mounted) return;

    final method = await PaymentMethodSheet.show(
      context,
      total: state.selectedTotal,
      periodCount: state.selectedCount,
      nominalCheck: nominalCheck,
    );
    if (method == null || !mounted) return;

    cubit.confirmPayment(method);
  }

  void _onSessionCreated(BuildContext context, VaQrisState state) {
    final session = state.session;
    if (session == null) return;
    context.push(
      session.method == PaymentMethod.qris ? AppRoutes.qris : AppRoutes.va,
      extra: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<VaQrisCubit, VaQrisState>(
          listenWhen: (prev, curr) =>
              prev.session != curr.session && curr.session != null,
          listener: _onSessionCreated,
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
          final billing = state.billing;
          if (billing == null) return const SizedBox.shrink();

          final unpaid = billing.unpaidPeriods;
          final showTotalBar = _tabController.index == 0 && unpaid.isNotEmpty;

          return Scaffold(
            backgroundColor: context.palette.surfaceMuted,
            appBar: const VaQrisAppBar(title: 'Tagihan pajak'),
            body: Column(
              children: [
                VaQrisHeroHeader(child: TaxpayerSummaryCard(billing: billing)),
                BillingTabBar(
                  controller: _tabController,
                  unpaidCount: unpaid.length,
                  paidCount: billing.paidPeriods.length,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      UnpaidPeriodList(
                        periods: unpaid,
                        selectedKeys: state.selectedKeys,
                        onToggle: context.read<VaQrisCubit>().togglePeriod,
                        onToggleAll: context
                            .read<VaQrisCubit>()
                            .toggleAllPeriods,
                      ),
                      PaidPeriodList(periods: billing.paidPeriods),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: showTotalBar
                ? BillingTotalBar(
                    selectedCount: state.selectedCount,
                    principal: state.selectedPrincipal,
                    penalty: state.selectedPenalty,
                    other: state.selectedOther,
                    otherLabel: state.selectedOtherLabel,
                    discount: state.selectedDiscount,
                    isLoading: state.confirming,
                    onConfirm: () => _onConfirm(state),
                  )
                : null,
          );
        },
      ),
    );
  }
}
