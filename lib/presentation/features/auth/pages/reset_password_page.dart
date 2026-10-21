// lib/presentation/features/auth/pages/reset_password_page.dart
import 'package:mybapenda/core/constants/app_colors_new.dart';
import 'package:mybapenda/core/utils/app_password_validator_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';
import '../widgets/auth_form_widgets.dart';

/// Wajib dibuka setelah login dengan reset key (isResetPassword = true).
/// Tidak bisa di-back; pilihannya simpan kata sandi baru atau keluar.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  PasswordValidationStatus _status = const PasswordValidationStatus();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_revalidate);
    confirmController.addListener(_revalidate);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _revalidate() {
    setState(() {
      _status = AppPasswordValidatorUtils.validate(
        passwordController.text,
        confirmController.text,
      );
    });
  }

  void _submit() {
    if (!_status.isValid) return;

    FocusScope.of(context).unfocus();

    context.read<ResetPasswordCubit>().submit(
      newPassword: passwordController.text,
      confirmationPassword: confirmController.text,
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          content: Text(message),
        ),
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
      child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordFailure) {
            _showSnack(state.message, AppThemeColors.danger);
          }
          if (state is ResetPasswordSuccess) {
            _showSnack('Kata sandi berhasil diubah', AppThemeColors.success);
            // Router otomatis pindah ke home begitu state AuthAuthenticated.
            context.read<AuthCubit>().passwordResetCompleted();
          }
        },
        builder: (context, state) {
          final isLoading =
              state is ResetPasswordLoading || state is ResetPasswordSuccess;

          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: kAuthCanvas,
              body: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SafeArea(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthPageTitle(
                          title: 'Buat kata sandi baru',
                          subtitle:
                              'Anda masuk memakai reset key. Buat kata sandi baru untuk melanjutkan.',
                        ),
                        const SizedBox(height: 24),
                        AuthCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Kata sandi baru',
                                style: kAuthLabelStyle,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: passwordController,
                                enabled: !isLoading,
                                obscureText: obscurePassword,
                                style: kAuthInputStyle,
                                decoration: authInputDecoration(
                                  'Masukkan kata sandi baru',
                                  Icons.lock_outline_rounded,
                                  suffix: _ObscureToggle(
                                    obscure: obscurePassword,
                                    onTap: () => setState(
                                      () => obscurePassword = !obscurePassword,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Konfirmasi kata sandi',
                                style: kAuthLabelStyle,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: confirmController,
                                enabled: !isLoading,
                                obscureText: obscureConfirm,
                                style: kAuthInputStyle,
                                decoration: authInputDecoration(
                                  'Ulangi kata sandi baru',
                                  Icons.lock_reset_rounded,
                                  suffix: _ObscureToggle(
                                    obscure: obscureConfirm,
                                    onTap: () => setState(
                                      () => obscureConfirm = !obscureConfirm,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _PasswordRules(status: _status),
                              const SizedBox(height: 24),
                              AuthPrimaryButton(
                                label: 'Simpan kata sandi',
                                icon: Icons.check_rounded,
                                isLoading: isLoading,
                                onTap: _status.isValid ? _submit : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.read<AuthCubit>().logout(),
                            child: const Text(
                              'Batal dan keluar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.secondaryText,
                              ),
                            ),
                          ),
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

class _ObscureToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;

  const _ObscureToggle({required this.obscure, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppThemeColors.blackPrimary,
        size: 22,
      ),
      onPressed: onTap,
    );
  }
}

/// Checklist aturan kata sandi, ikut berubah saat mengetik.
class _PasswordRules extends StatelessWidget {
  final PasswordValidationStatus status;

  const _PasswordRules({required this.status});

  @override
  Widget build(BuildContext context) {
    final rules = <(String, bool)>[
      ('Minimal 8 karakter', status.hasMinLength),
      ('Huruf besar (A-Z)', status.hasUppercase),
      ('Huruf kecil (a-z)', status.hasLowercase),
      ('Angka (0-9)', status.hasNumber),
      ('Karakter khusus (!@#...)', status.hasSpecialChar),
      ('Tanpa spasi', status.hasNoSpace),
      ('Konfirmasi kata sandi sama', status.isMatch),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.grey3,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, ok) in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(
                    ok
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: ok
                        ? AppThemeColors.success
                        : AppThemeColors.tertiaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: ok
                            ? AppThemeColors.primaryText
                            : AppThemeColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
