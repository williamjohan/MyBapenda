import 'package:mybapenda/presentation/shared/widgets/paged_select_field.dart';
import 'package:flutter/material.dart';
import '../cubit/paged_search_cubit.dart';

class MasterPagedSelectField<T, E> extends StatelessWidget {
  final PagedSearchCubit<E> cubit;
  final PagedOption<T> Function(E item) toOption;
  final bool Function(E item)? excludeWhere;

  final String label;
  final String hint;
  final String searchHint;
  final String? idleMessage;

  final T? value;
  final String? valueLabel;
  final void Function(T value, String label) onChanged;
  final bool mandatory;
  final bool showImage; 
  final PagedImageBuilder? imageBuilder;

  const MasterPagedSelectField({
    super.key,
    required this.cubit,
    required this.toOption,
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.onChanged,
    this.excludeWhere,
    this.hint = 'Pilih',
    this.searchHint = 'Cari...',
    this.idleMessage,
    this.mandatory = true,
    this.showImage = false,
    this.imageBuilder
  });

  PagedSelectData<T> _toData(PagedSearchState<E> s) {
    final exclude = excludeWhere;
    final items = exclude == null
        ? s.items
        : s.items.where((e) => !exclude(e)).toList();

    return PagedSelectData<T>(
      items: items.map(toOption).toList(),
      loading: s.status == PagedStatus.loading,
      loadingMore: s.loadingMore,
      loadMoreFailed: s.loadMoreFailed,
      totalData: s.totalData,
      error: s.status == PagedStatus.failure ? s.error : null,
      emptyMessage: s.status == PagedStatus.idle ? idleMessage : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PagedSelectField<T>(
      label: label,
      hint: hint,
      searchHint: searchHint,
      mandatory: mandatory,
      showImage: showImage,
      imageBuilder: imageBuilder,
      value: value,
      valueLabel: valueLabel,
      onChanged: onChanged,
      source: PagedSelectSource<T>(
        read: () => _toData(cubit.state),
        changes: cubit.stream.map(_toData).distinct(),
        onOpen: cubit.open,
        onQueryChanged: cubit.onQueryChanged,
        onLoadMore: cubit.loadMore,
        onRetry: cubit.retry,
        onRetryLoadMore: cubit.retryLoadMore,
      ),
    );
  }
}
