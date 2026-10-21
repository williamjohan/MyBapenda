import 'package:mybapenda/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:mybapenda/presentation/features/survey_baru/cubit/survey_list/survey_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';

Future<void> startSurvey(BuildContext context, SurveyPermohonanEntity e) async {
  final res = await context.read<SurveyListCubit>().fetchSisi(e);
  if (!context.mounted) return;

  void snack(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  if (res.error != null) return snack(res.error!);
  final sisi = res.sisi;
  if (sisi == null) return;
  if (sisi.isEmpty) return snack('Permohonan ini belum punya sisi.');

  context.pushNamed(
    AppRoutes.surveyInfo,
    extra: (nomor: e.noPelayanan, key: e.key, sisiList: sisi),
  );
}
