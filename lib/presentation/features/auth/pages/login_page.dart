import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/core/di/injection.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final nipController = TextEditingController();
  final passwordController = TextEditingController();
  final _secureStorage = getIt<AppSecureStorage>();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final nip = await _secureStorage.getRememberMeNip();
    final password = await _secureStorage.getRememberMePassword();

    if (!mounted) return;

    if (nip != null &&
        nip.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      nipController.text = nip;
      passwordController.text = password;

      setState(() {
        rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    nipController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();

    final authCubit = context.read<AuthCubit>();

    await authCubit.login(nipController.text.trim(), passwordController.text);

    final state = authCubit.state;

    if (state is AuthAuthenticated) {
      if (rememberMe) {
        await _secureStorage.saveRememberMeCredentials(
          nip: nipController.text.trim(),
          password: passwordController.text,
        );
      } else {
        await _secureStorage.clearRememberMeCredentials();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.defaultBackground,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
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
          // Navigasi ke home otomatis lewat redirect di GoRouter
          // begitu state jadi AuthAuthenticated.
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ConstrainedBox + SingleChildScrollView: content centers on
              // tall screens, and scrolls instead of overflowing on short
              // screens or when the keyboard opens.
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 56,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Brandmark(),
                      const SizedBox(height: 28),
                      Text(
                        'Selamat datang kembali',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.titleText,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk untuk melanjutkan menggunakan aplikasi',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppThemeColors.secondaryText,
                          height: 1.4,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),
                      _LoginCard(
                        formKey: _formKey,
                        nipController: nipController,
                        passwordController: passwordController,
                        obscurePassword: obscurePassword,

                        rememberMe: rememberMe,
                        onRememberMeChanged: (value) {
                          setState(() {
                            rememberMe = value;
                          });
                        },

                        onToggleObscure: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },

                        onSubmit: _submit,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '©Bapenda Kota Surabaya',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppThemeColors.secondaryText.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Brandmark extends StatelessWidget {
  const _Brandmark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 76,
        width: 76,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeColors.defaultSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppThemeColors.defaultBorder),
          boxShadow: [
            BoxShadow(
              color: AppThemeColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logosby.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.account_balance_outlined,
            color: AppThemeColors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nipController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onToggleObscure;
  final Future<void> Function() onSubmit;

  const _LoginCard({
    required this.formKey,
    required this.nipController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppThemeColors.secondaryText,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppThemeColors.secondaryText, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppThemeColors.defaultBackground,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: _border(AppThemeColors.defaultBorder, 1),
      enabledBorder: _border(AppThemeColors.defaultBorder, 1),
      focusedBorder: _border(AppThemeColors.gold, 1.5),
      errorBorder: _border(AppThemeColors.danger, 1),
      focusedErrorBorder: _border(AppThemeColors.danger, 1.5),
    );
  }

  TextStyle _label() => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.titleText,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.defaultBorder),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NIP', style: _label()),
            const SizedBox(height: 8),
            TextFormField(
              controller: nipController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppThemeColors.primaryText,
              ),
              decoration: _decoration('Masukkan NIP', Icons.badge_outlined),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'NIP wajib diisi'
                  : null,
            ),
            const SizedBox(height: 18),
            Text('Kata sandi', style: _label()),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppThemeColors.primaryText,
              ),
              decoration: _decoration(
                'Masukkan kata sandi',
                Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppThemeColors.secondaryText,
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Kata sandi wajib diisi'
                  : null,
            ),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: rememberMe,
                    onChanged: (value) {
                      onRememberMeChanged(value ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      'Ingat saya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppThemeColors.secondaryText,
                      ),
                    ),
                    activeColor: AppThemeColors.primary,
                  ),
                ),
                
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            onSubmit();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeColors.primary,
                      disabledBackgroundColor: AppThemeColors.primary
                          .withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Masuk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
