// lib/presentation/features/balai_rw/cubit/balai_rw_form_state.dart
import 'package:bapendacore/domain/entities/balai_rw/kategori_pertanyaan_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/pertanyaan_entity.dart';
import 'package:equatable/equatable.dart';

enum BalaiRwFormStatus { initial, loading, success, failure }

class BalaiRwSection extends Equatable {
  final KategoriPertanyaanEntity kategori;
  final List<PertanyaanEntity> pertanyaan;

  const BalaiRwSection({required this.kategori, required this.pertanyaan});

  @override
  List<Object?> get props => [kategori, pertanyaan];
}

class BalaiRwFormState extends Equatable {
  final BalaiRwFormStatus status;
  final List<BalaiRwSection> sections;
  final String? error;

  const BalaiRwFormState({
    this.status = BalaiRwFormStatus.initial,
    this.sections = const [],
    this.error,
  });

  BalaiRwFormState copyWith({
    BalaiRwFormStatus? status,
    List<BalaiRwSection>? sections,
    String? error,
  }) => BalaiRwFormState(
    status: status ?? this.status,
    sections: sections ?? this.sections,
    error: error,
  );

  @override
  List<Object?> get props => [status, sections, error];
}
