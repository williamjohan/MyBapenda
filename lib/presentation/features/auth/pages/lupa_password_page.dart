// lib/presentation/features/auth/pages/lupa_password_page.dart
import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/auth/lupa_password_metode.dart';
import '../cubit/lupa_password_cubit.dart';
import '../cubit/lupa_password_state.dart';
import '../widgets/auth_form_widgets.dart';

/// Isi NIP, pilih email / WhatsApp, lalu kirim permintaan reset key.
class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final nipController = TextEditingController();
  final tujuanController = TextEditingController();

  LupaPasswordMetode _metode = LupaPasswordMetode.email;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    nipController.dispose();
    tujuanController.dispose();
    super.dispose();
  }

  void _onMetodeChanged(LupaPasswordMetode metode) {
    if (metode == _metode) return;
    setState(() {
      _metode = metode;
      // Isi email tidak relevan untuk WhatsApp, begitu juga sebaliknya.
      tujuanController.clear();
    });
  }

  String? _validateTujuan(String? value) {
    final v = value?.trim() ?? '';
    if (_metode == LupaPasswordMetode.email) {
      if (v.isEmpty) return 'Email wajib diisi';
      if (!_emailRegex.hasMatch(v)) return 'Format email tidak valid';
      return null;
    }
    if (v.isEmpty) return 'Nomor WhatsApp wajib diisi';
    if (!v.startsWith('08') && !v.startsWith('62')) {
      return 'Nomor diawali 08 atau 62';
    }
    if (v.length < 10 || v.length > 15) return 'Nomor WhatsApp tidak valid';
    return null;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();

    context.read<LupaPasswordCubit>().submit(
      nip: nipController.text.trim(),
      metode: _metode,
      tujuan: tujuanController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: kAuthCanvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: BlocConsumer<LupaPasswordCubit, LupaPasswordState>(
        listener: (context, state) {
          if (state is LupaPasswordFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppThemeColors.danger,
                  content: Text(state.message),
                ),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state is LupaPasswordLoading;

          return PopScope(
            canPop: !isLoading,
            child: Scaffold(
              backgroundColor: kAuthCanvas,
              body: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SafeArea(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: isLoading ? null : () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppThemeColors.titleText,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AuthPageTitle(
                          title: 'Lupa kata sandi',
                          subtitle:
                              'Masukkan NIP Anda, lalu pilih ke mana reset key dikirim.',
                        ),
                        const SizedBox(height: 24),
                        if (state is LupaPasswordSuccess)
                          _SuccessCard(
                            metode: _metode,
                            tujuan: state.tujuan,
                            onBack: () => context.pop(),
                          )
                        else
                          _LupaPasswordCard(
                            formKey: _formKey,
                            nipController: nipController,
                            tujuanController: tujuanController,
                            metode: _metode,
                            isLoading: isLoading,
                            onMetodeChanged: _onMetodeChanged,
                            validateTujuan: _validateTujuan,
                            onSubmit: _submit,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LupaPasswordCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nipController;
  final TextEditingController tujuanController;
  final LupaPasswordMetode metode;
  final bool isLoading;
  final ValueChanged<LupaPasswordMetode> onMetodeChanged;
  final FormFieldValidator<String> validateTujuan;
  final VoidCallback onSubmit;

  const _LupaPasswordCard({
    required this.formKey,
    required this.nipController,
    required this.tujuanController,
    required this.metode,
    required this.isLoading,
    required this.onMetodeChanged,
    required this.validateTujuan,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isEmail = metode == LupaPasswordMetode.email;

    return AuthCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('NIP', style: kAuthLabelStyle),
            const SizedBox(height: 10),
            TextFormField(
              controller: nipController,
              enabled: !isLoading,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: kAuthInputStyle,
              decoration: authInputDecoration(
                'Masukkan NIP Anda',
                Icons.person_outline_rounded,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'NIP wajib diisi'
                  : null,
            ),
            const SizedBox(height: 18),
            const Text('Kirim melalui', style: kAuthLabelStyle),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final m in LupaPasswordMetode.values) ...[
                  if (m != LupaPasswordMetode.values.first)
                    const SizedBox(width: 12),
                  Expanded(
                    child: _MetodeOption(
                      metode: m,
                      selected: m == metode,
                      onTap: isLoading ? null : () => onMetodeChanged(m),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Text(isEmail ? 'Email' : 'Nomor WhatsApp', style: kAuthLabelStyle),
            const SizedBox(height: 10),
            TextFormField(
              // Key per metode supaya pesan error metode sebelumnya hilang.
              key: ValueKey(metode),
              controller: tujuanController,
              enabled: !isLoading,
              keyboardType: isEmail
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              inputFormatters: isEmail
                  ? null
                  : [FilteringTextInputFormatter.digitsOnly],
              style: kAuthInputStyle,
              decoration: authInputDecoration(
                isEmail ? 'contoh@email.com' : '08xxxxxxxxxx',
                isEmail ? Icons.mail_outline_rounded : Icons.chat_outlined,
              ),
              validator: validateTujuan,
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Kirim',
              icon: Icons.send_rounded,
              isLoading: isLoading,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetodeOption extends StatelessWidget {
  final LupaPasswordMetode metode;
  final bool selected;
  final VoidCallback? onTap;

  const _MetodeOption({
    required this.metode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppThemeColors.yellow5 : AppThemeColors.blackPrimary;

    return Material(
      color: selected ? AppThemeColors.primarySoft : AppThemeColors.grey3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppThemeColors.primary : AppThemeColors.grey4,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                metode == LupaPasswordMetode.email
                    ? Icons.mail_outline_rounded
                    : Icons.chat_outlined,
                size: 20,
                color: fg,
              ),
              const SizedBox(width: 6),
              // Flexible supaya teks menyusut (bukan overflow) di layar sempit.
              Flexible(
                child: Text(
                  metode.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final LupaPasswordMetode metode;
  final String tujuan;
  final VoidCallback onBack;

  const _SuccessCard({
    required this.metode,
    required this.tujuan,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppThemeColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppThemeColors.success,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Reset key terkirim',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.titleText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reset key dikirim ke ${metode.label} $tujuan. '
            'Masuk memakai NIP dan reset key tersebut sebagai kata sandi, '
            'lalu buat kata sandi baru.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppThemeColors.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'Kembali ke halaman masuk',
            icon: Icons.arrow_forward_rounded,
            onTap: onBack,
          ),
        ],
      ),
    );
  }
}
