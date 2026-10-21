import 'package:mybapenda/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class MasterDataState extends Equatable {
  /// Option yang sudah berhasil dimuat. Belum ada key = belum pernah dibuka.
  final Map<MasterOptionType, Map<String, String>> options;
  final Set<MasterOptionType> loading;
  final Set<MasterOptionType> failed;

  final Map<String, Map<String, String>> kelurahan;
  final String? kelurahanLoadingFor;
  final String? kelurahanErrorFor;

  const MasterDataState({
    this.options = const {},
    this.loading = const {},
    this.failed = const {},
    this.kelurahan = const {},
    this.kelurahanLoadingFor,
    this.kelurahanErrorFor,
  });

  // ---- Options ----

  Map<String, String> optionsOf(MasterOptionType type) =>
      options[type] ?? const <String, String>{};

  /// Untuk option ber-ID angka (lihat MasterOptionType.usesIntegerId).
  Map<int, String> intOptionsOf(MasterOptionType type) => {
    for (final e in optionsOf(type).entries)
      if (int.tryParse(e.key) != null) int.parse(e.key): e.value,
  };

  bool isLoaded(MasterOptionType type) => options.containsKey(type);
  bool isLoading(MasterOptionType type) => loading.contains(type);
  bool hasError(MasterOptionType type) => failed.contains(type);

  String optionName(MasterOptionType type, String? id) =>
      options[type]?[id] ?? '-';

  // ---- Kelurahan ----

  Map<String, String> kelurahanOf(String? kecamatanId) =>
      kelurahan[kecamatanId] ?? const <String, String>{};

  String kelurahanName(String? kecamatanId, String? kelurahanId) =>
      kelurahan[kecamatanId]?[kelurahanId] ?? '-';

  MasterDataState copyWith({
    Map<MasterOptionType, Map<String, String>>? options,
    Set<MasterOptionType>? loading,
    Set<MasterOptionType>? failed,
    Map<String, Map<String, String>>? kelurahan,
    ValueGetter<String?>? kelurahanLoadingFor,
    ValueGetter<String?>? kelurahanErrorFor,
  }) => MasterDataState(
    options: options ?? this.options,
    loading: loading ?? this.loading,
    failed: failed ?? this.failed,
    kelurahan: kelurahan ?? this.kelurahan,
    kelurahanLoadingFor: kelurahanLoadingFor != null
        ? kelurahanLoadingFor()
        : this.kelurahanLoadingFor,
    kelurahanErrorFor: kelurahanErrorFor != null
        ? kelurahanErrorFor()
        : this.kelurahanErrorFor,
  );

  @override
  List<Object?> get props => [
    options,
    loading,
    failed,
    kelurahan,
    kelurahanLoadingFor,
    kelurahanErrorFor,
  ];
}
