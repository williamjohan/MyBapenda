import 'dart:math' as math;

import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/core/di/injection.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

const Color _kCanvas = Color(0xFFFBF8F3);

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
    final screenWidth = MediaQuery.of(context).size.width;
    // Tinggi navigation bar (tombol back/home). Tetap terbaca walau keyboard
    // sedang terbuka.
    final bottomBarHeight = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        // false supaya background tidak ikut "mengecil" saat keyboard muncul.
        // Padding keyboard ditangani manual di SingleChildScrollView.
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: BlocListener<AuthCubit, AuthState>(
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
            child: Column(
              children: [
                // Area utama: background + konten. Berhenti tepat di atas
                // navigation bar, jadi ilustrasi tidak tembus ke bawahnya.
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _LoginBackground()),
                      SafeArea(
                        bottom: false,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // viewInsets.bottom sudah termasuk tinggi nav bar,
                            // sedangkan body kita sudah dipotong sebesar itu.
                            final keyboardInset = math.max(
                              0.0,
                              MediaQuery.of(context).viewInsets.bottom -
                                  bottomBarHeight,
                            );

                            return SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                16 + keyboardInset,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight * 0.03,
                                  ),
                                  const _Brandmark(),
                                  const SizedBox(height: 28),
                                  Container(
                                    width: 28,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppThemeColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: screenWidth * 0.68,
                                    ),
                                    child: const Text(
                                      'Selamat datang kembali',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: AppThemeColors.titleText,
                                        height: 1.15,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: screenWidth * 0.72,
                                    ),
                                    child: const Text(
                                      'Masuk untuk melanjutkan menggunakan aplikasi MyBapenda',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppThemeColors.blackPrimary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
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
                                  const SizedBox(height: 16),
                                  const Center(
                                    child: Text(
                                      '© Bapenda Kota Surabaya',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppThemeColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Strip putih setinggi navigation bar (tombol back/home).
                Container(height: bottomBarHeight, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Background dipecah jadi dua lapis supaya ilustrasi atas (tugu + patung)
/// menempel ke atas dan ilustrasi bawah (jembatan + gelombang) menempel ke
/// bawah. Bagian tengah gambar kosong, jadi tidak ada yang penting terpotong
/// di layar setinggi apa pun.
class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  /// Porsi tinggi gambar yang dipakai (0.0 - 1.0).
  /// Naikkan kalau ilustrasi terpotong, turunkan kalau dua lapis bertumpuk.
  static const double _topFactor = 0.42;
  static const double _bottomFactor = 0.36;

  Widget _image() {
    return Image.asset(
      'assets/images/login-background.png',
      width: double.infinity,
      fit: BoxFit.fitWidth,
      // Multiply: putih di gambar jadi krem hangat seperti di mockup.
      color: _kCanvas,
      colorBlendMode: BlendMode.multiply,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kCanvas,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _topFactor,
                child: _image(),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: _bottomFactor,
                child: _image(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Brandmark extends StatelessWidget {
  const _Brandmark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/surabayalogo_login.png',
      height: 56,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_outlined,
            color: AppThemeColors.primary,
            size: 40,
          ),
          SizedBox(width: 10),
          Text(
            'bapenda',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.titleText,
            ),
          ),
        ],
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
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color, width: width),
  );

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppThemeColors.tertiaryText,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppThemeColors.blackPrimary, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppThemeColors.grey3,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: _border(AppThemeColors.grey4, 1),
      enabledBorder: _border(AppThemeColors.grey4, 1),
      focusedBorder: _border(AppThemeColors.primary, 1.5),
      errorBorder: _border(AppThemeColors.danger, 1),
      focusedErrorBorder: _border(AppThemeColors.danger, 1.5),
    );
  }

  TextStyle _label() => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.titleText,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppThemeColors.brown.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NIP', style: _label()),
            const SizedBox(height: 10),
            TextFormField(
              controller: nipController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 14,
                color: AppThemeColors.primaryText,
              ),
              decoration: _decoration(
                'Masukkan NIP Anda',
                Icons.person_outline_rounded,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'NIP wajib diisi'
                  : null,
            ),
            const SizedBox(height: 18),
            Text('Kata sandi', style: _label()),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: const TextStyle(
                fontSize: 14,
                color: AppThemeColors.primaryText,
              ),
              decoration: _decoration(
                'Masukkan kata sandi',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppThemeColors.blackPrimary,
                    size: 22,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Kata sandi wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: () => onRememberMeChanged(!rememberMe),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: IgnorePointer(
                            child: Checkbox(
                              value: rememberMe,
                              onChanged: (_) {},
                              activeColor: AppThemeColors.yellow5,
                              checkColor: Colors.white,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: const BorderSide(
                                color: AppThemeColors.yellow5,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ingat saya',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppThemeColors.blackPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => context.push(AppRoutes.lupaPassword),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.yellow5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Opacity(
                  opacity: isLoading ? 0.75 : 1,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppThemeColors.primary,
                          AppThemeColors.yellow5,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeColors.yellow5.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isLoading
                            ? null
                            : () {
                                onSubmit();
                              },
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
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
          ],
        ),
      ),
    );
  }
}
