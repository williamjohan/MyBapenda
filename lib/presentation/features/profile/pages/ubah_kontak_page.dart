// lib/presentation/features/profile/pages/ubah_kontak_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/profile/jenis_kontak.dart';
import '../../../../domain/usecases/profile/profile_usecase.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/section_label.dart';
import '../cubit/ubah_kontak_cubit.dart';
import '../cubit/ubah_kontak_state.dart';

/// Ubah / verifikasi email atau no WA lewat OTP.
/// Pop dengan `KontakProfilEntity` terbaru bila berhasil.
class UbahKontakPage extends StatefulWidget {
  const UbahKontakPage({super.key});

  @override
  State<UbahKontakPage> createState() => _UbahKontakPageState();
}

class _UbahKontakPageState extends State<UbahKontakPage> {
  late final TextEditingController _tujuanCtrl;
  final _kodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tujuanCtrl = TextEditingController(
      text: context.read<UbahKontakCubit>().state.nilaiSekarang,
    );
  }

  @override
  void dispose() {
    _tujuanCtrl.dispose();
    _kodeCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(msg)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocConsumer<UbahKontakCubit, UbahKontakState>(
      listenWhen: (prev, curr) =>
          (curr.error != null && curr.error != prev.error) ||
          (curr.info != null && curr.info != prev.info) ||
          (curr.step != prev.step),
      listener: (context, state) {
        if (state.step == UbahKontakStep.selesai) {
          context.pop(state.hasil);
          return;
        }
        if (state.step == UbahKontakStep.input) _kodeCtrl.clear();
        final msg = state.error ?? state.info;
        if (msg != null) _snack(msg);
      },
      builder: (context, state) {
        final label = state.kontak.label;
        return Scaffold(
          backgroundColor: palette.background,
          body: CustomScrollView(
            slivers: [
              BapendaSliverHeader(
                title: state.nilaiSekarang.isEmpty
                    ? 'Tambah $label'
                    : 'Ubah $label',
                showBackButton: true,
                subtitle: const Text('Verifikasi dengan kode OTP'),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.list(
                  children: [
                    if (state.step == UbahKontakStep.otp)
                      _OtpStep(state: state, kodeCtrl: _kodeCtrl)
                    else
                      _InputStep(state: state, tujuanCtrl: _tujuanCtrl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

InputDecoration _decoration(BuildContext context, String hint, IconData icon) {
  final palette = context.palette;
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: 1.2),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: palette.textTertiary, fontSize: 14),
    prefixIcon: Icon(icon, color: palette.textSecondary, size: 20),
    counterText: '',
    filled: true,
    fillColor: palette.surfaceMuted,
    border: border(palette.border),
    enabledBorder: border(palette.border),
    focusedBorder: border(palette.accent),
  );
}

class _InputStep extends StatelessWidget {
  final UbahKontakState state;
  final TextEditingController tujuanCtrl;

  const _InputStep({required this.state, required this.tujuanCtrl});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEmail = state.kontak == JenisKontak.email;
    final cubit = context.read<UbahKontakCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: state.kontak.label,
          icon: isEmail ? Icons.mail_outline_rounded : Icons.phone_outlined,
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEmail
                    ? 'Masukkan email baru, atau biarkan email sekarang untuk '
                          'memverifikasinya. Kode OTP akan dikirim ke email tersebut.'
                    : 'Masukkan no. WhatsApp baru (08xx), atau biarkan nomor '
                          'sekarang untuk memverifikasinya. Kode OTP akan '
                          'dikirim lewat WhatsApp.',
                style: TextStyle(
                  fontSize: 13,
                  color: palette.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: tujuanCtrl,
                enabled: !state.mengirim,
                keyboardType: isEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                inputFormatters: isEmail
                    ? null
                    : [FilteringTextInputFormatter.digitsOnly],
                maxLength: isEmail ? 100 : 14,
                textInputAction: TextInputAction.done,
                onSubmitted: cubit.kirimOtp,
                style: TextStyle(color: palette.textPrimary, fontSize: 14),
                decoration: _decoration(
                  context,
                  isEmail ? 'nama@email.com' : '08xxxxxxxxxx',
                  isEmail
                      ? Icons.alternate_email_rounded
                      : Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 16),
              Button(
                label: 'Kirim kode OTP',
                icon: Icons.send_rounded,
                isLoading: state.mengirim,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  cubit.kirimOtp(tujuanCtrl.text);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  final UbahKontakState state;
  final TextEditingController kodeCtrl;

  const _OtpStep({required this.state, required this.kodeCtrl});

  static String _mmss(int detik) =>
      '${detik ~/ 60}:${(detik % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<UbahKontakCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Kode OTP', icon: Icons.lock_outline_rounded),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.textSecondary,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Masukkan ${ProfileUseCase.panjangOtp} digit kode '
                          'yang dikirim ke ',
                    ),
                    TextSpan(
                      text: state.tujuanTampil,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: kodeCtrl,
                enabled: !state.memverifikasi,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: ProfileUseCase.panjangOtp,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                onSubmitted: cubit.verifikasi,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 10,
                ),
                decoration: _decoration(context, '••••••', Icons.pin_outlined),
              ),
              const SizedBox(height: 16),
              Button(
                label: 'Verifikasi',
                icon: Icons.verified_outlined,
                isLoading: state.memverifikasi,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  cubit.verifikasi(kodeCtrl.text);
                },
              ),
              const SizedBox(height: 8),
              // Wrap: label "Ganti no. whatsapp" + hitung mundur tidak muat
              // satu baris di layar sempit (overflow).
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: state.memverifikasi ? null : cubit.ubahTujuan,
                    style: TextButton.styleFrom(
                      foregroundColor: palette.textSecondary,
                    ),
                    child: Text('Ganti ${state.kontak.label.toLowerCase()}'),
                  ),
                  TextButton(
                    onPressed: state.bolehKirimUlang ? cubit.kirimUlang : null,
                    style: TextButton.styleFrom(
                      foregroundColor: palette.accent,
                    ),
                    child: Text(
                      state.mengirim
                          ? 'Mengirim...'
                          : state.sisaJedaDetik > 0
                          ? 'Kirim ulang (${_mmss(state.sisaJedaDetik)})'
                          : 'Kirim ulang kode',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
