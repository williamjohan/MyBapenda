import 'package:mybapenda/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:mybapenda/presentation/shared/master_data/presentation/cubit/master_data_cubit.dart';
import 'package:mybapenda/presentation/shared/master_data/presentation/cubit/master_data_state.dart';
import 'package:mybapenda/presentation/shared/widgets/bt_select_fields.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dropdown untuk master data remote.
///
/// Opsinya baru di-fetch saat bottom sheet dibuka (kalau belum pernah dimuat).
/// Selama memuat, sheet menampilkan spinner; kalau gagal, tombol "Coba lagi".
class MasterSelectField<T> extends StatelessWidget {
  final MasterOptionType type;

  /// Ambil Map opsi dari state, mis. `(s) => s.intOptionsOf(type)`.
  final Map<T, String> Function(MasterDataState state) itemsOf;

  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String hint;
  final bool mandatory;
  final bool enabled;
  final bool? searchable;

  const MasterSelectField({
    super.key,
    required this.type,
    required this.itemsOf,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Pilih',
    this.mandatory = true,
    this.enabled = true,
    this.searchable,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MasterDataCubit>();
    final fieldLabel = label ?? type.label;

    BtSelectData<T> toData(MasterDataState s) => BtSelectData<T>(
      items: itemsOf(s),
      loading: s.isLoading(type),
      error: s.hasError(type)
          ? 'Gagal memuat ${fieldLabel.toLowerCase()}.\nPeriksa koneksi lalu coba lagi.'
          : null,
    );

    return BlocBuilder<MasterDataCubit, MasterDataState>(
      // Field hanya perlu rebuild kalau daftar opsinya berubah
      // (untuk menampilkan teks pilihan).
      buildWhen: (p, c) => !mapEquals(itemsOf(p), itemsOf(c)),
      builder: (context, state) {
        return BtSelectField<T>(
          label: fieldLabel,
          hint: hint,
          items: itemsOf(state),
          value: value,
          onChanged: onChanged,
          mandatory: mandatory,
          enabled: enabled,
          searchable: searchable,
          source: BtSelectSource<T>(
            read: () => toData(cubit.state),
            changes: cubit.stream.map(toData).distinct(),
            // Tidak fetch ulang kalau opsi ini sudah pernah dimuat.
            onOpen: () => cubit.loadOption(type),
            onRetry: () => cubit.loadOption(type, force: true),
          ),
        );
      },
    );
  }
}
