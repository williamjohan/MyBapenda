import 'package:equatable/equatable.dart';
import 'package:mybapenda/core/constants/design_system/tokens/app_palette.dart';
import 'package:flutter/material.dart';

class PagedOption<T> extends Equatable {
  final T value;
  final String label;
  final String? subtitle;
  final String? imageUrl;

  const PagedOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [value, label, subtitle, imageUrl];
}

typedef PagedImageBuilder =
    Widget Function(BuildContext context, String url, double size);

class PagedSelectData<T> extends Equatable {
  final List<PagedOption<T>> items;

  final bool loading;
  final bool loadingMore;
  final bool loadMoreFailed;
  final int totalData;
  final String? error;
  final String? emptyMessage;

  const PagedSelectData({
    required this.items,
    this.loading = false,
    this.loadingMore = false,
    this.loadMoreFailed = false,
    this.totalData = 0,
    this.error,
    this.emptyMessage,
  });

  @override
  List<Object?> get props => [
    items,
    loading,
    loadingMore,
    loadMoreFailed,
    totalData,
    error,
    emptyMessage,
  ];
}

/// Jembatan antara widget dan sumber datanya (cubit, dll).
class PagedSelectSource<T> {
  final PagedSelectData<T> Function() read;
  final Stream<PagedSelectData<T>> changes;
  final VoidCallback onOpen;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final VoidCallback onRetryLoadMore;

  const PagedSelectSource({
    required this.read,
    required this.changes,
    required this.onOpen,
    required this.onQueryChanged,
    required this.onLoadMore,
    required this.onRetry,
    required this.onRetryLoadMore,
  });
}

String _fmtInt(int n) => n.toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+$)'),
  (m) => '${m[1]}.',
);

class PagedSelectField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final String? sheetTitle;
  final String searchHint;
  final T? value;

  final String? valueLabel;
  final void Function(T value, String label) onChanged;
  final PagedSelectSource<T> source;
  final bool mandatory;
  final bool enabled;
  final bool showImage;
  final PagedImageBuilder? imageBuilder;

  const PagedSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.onChanged,
    required this.source,
    this.hint = 'Pilih',
    this.sheetTitle,
    this.searchHint = 'Cari...',
    this.mandatory = false,
    this.enabled = true,
    this.showImage = false,
    this.imageBuilder,
  });

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    source.onOpen();

    final picked = await showModalBottomSheet<PagedOption<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PagedSheet<T>(
        title: sheetTitle ?? 'Pilih ${label.replaceAll('*', '').trim()}',
        searchHint: searchHint,
        value: value,
        source: source,
        showImage: showImage,
        imageBuilder: imageBuilder,
      ),
    );
    if (picked != null) onChanged(picked.value, picked.label);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final text = valueLabel ?? (hasValue ? 'ID $value' : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: context.palette.textSecondary,
            ),
            children: [
              TextSpan(text: label),
              if (mandatory)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: context.palette.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: enabled ? context.palette.surface : context.palette.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? () => _open(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.palette.borderStrong),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text ?? hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: text != null
                            ? context.palette.textPrimary
                            : context.palette.textTertiary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled
                        ? context.palette.textSecondary
                        : context.palette.borderStrong,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PagedSheet<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final T? value;
  final PagedSelectSource<T> source;
  final bool showImage;
  final PagedImageBuilder? imageBuilder;

  const _PagedSheet({
    required this.title,
    required this.searchHint,
    required this.value,
    required this.source,
    required this.showImage,
    required this.imageBuilder,
  });

  @override
  State<_PagedSheet<T>> createState() => _PagedSheetState<T>();
}

class _PagedSheetState<T> extends State<_PagedSheet<T>> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    // Muat halaman berikutnya sebelum user benar-benar sampai dasar.
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      widget.source.onLoadMore();
    }
  }

  void _onQueryChanged(String v) {
    setState(() => _q = v);
    widget.source.onQueryChanged(v);
  }

  void _clearQuery() {
    _ctrl.clear();
    _onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.source;

    return StreamBuilder<PagedSelectData<T>>(
      stream: source.changes,
      initialData: source.read(),
      builder: (context, snap) =>
          _buildContent(context, snap.data ?? source.read()),
    );
  }

  Widget _buildContent(BuildContext context, PagedSelectData<T> data) {
    // Tinggi tetap supaya sheet tidak melompat saat daftar berganti.
    final height = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      // naik mengikuti keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.palette.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: context.palette.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: TextField(
                controller: _ctrl,
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: context.palette.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.palette.textTertiary,
                  ),
                  suffixIcon: _q.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: _clearQuery,
                        ),
                  filled: true,
                  fillColor: context.palette.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Pencarian baru sementara hasil lama masih tampil.
            SizedBox(
              height: 2,
              child: data.loading && data.items.isNotEmpty
                  ? LinearProgressIndicator(
                      color: context.palette.accent,
                      backgroundColor: Colors.transparent,
                    )
                  : null,
            ),
            if (!data.loading && data.totalData > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
                child: Text(
                  'Menampilkan ${_fmtInt(data.items.length)} '
                  'dari ${_fmtInt(data.totalData)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            Expanded(child: _buildBody(context, data)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PagedSelectData<T> data) {
    final source = widget.source;

    if (data.items.isEmpty) {
      if (data.loading) return const _Centered(child: _Loading());
      if (data.error != null) {
        return _Centered(
          child: _ErrorView(message: data.error!, onRetry: source.onRetry),
        );
      }
      return _Centered(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            data.emptyMessage ??
                (_q.trim().isEmpty ? 'Belum ada pilihan' : 'Tidak ditemukan'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.palette.textSecondary,
            ),
          ),
        ),
      );
    }

    final hasFooter = data.loadingMore || data.loadMoreFailed;

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: data.items.length + (hasFooter ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= data.items.length) {
          return _Footer(
            failed: data.loadMoreFailed,
            onRetry: source.onRetryLoadMore,
          );
        }

        final e = data.items[i];
        final selected = e.value == widget.value;
        return Material(
          color: selected ? context.palette.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).pop(e),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: widget.showImage ? 10 : 12,
              ),
              child: Row(
                children: [
                  if (widget.showImage) ...[
                    _OptionThumb(url: e.imageUrl, builder: widget.imageBuilder),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? context.palette.accent
                                : context.palette.textPrimary,
                          ),
                        ),
                        if (e.subtitle != null && e.subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            e.subtitle!,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.palette.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: context.palette.accent,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OptionThumb extends StatelessWidget {
  final String? url;
  final PagedImageBuilder? builder;

  const _OptionThumb({required this.url, required this.builder});

  static const double _size = 52;

  @override
  Widget build(BuildContext context) {
    final u = url;

    final Widget child;
    if (u == null || u.isEmpty) {
      child = const _ThumbPlaceholder();
    } else if (builder != null) {
      child = builder!(context, u, _size);
    } else {
      child = Image.network(
        u,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        cacheWidth: (_size * 3).round(),
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
        loadingBuilder: (_, image, progress) =>
            progress == null ? image : const _ThumbPlaceholder(),
        errorBuilder: (_, error, __) {
          debugPrint('FOTO GAGAL [$u] -> $error');
          return const _ThumbPlaceholder();
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: _size, height: _size, child: child),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.palette.background,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 22,
        color: context.palette.textTertiary,
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  final Widget child;

  const _Centered({required this.child});

  @override
  Widget build(BuildContext context) => Center(child: child);
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: context.palette.accent,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Memuat pilihan...',
          style: TextStyle(fontSize: 13, color: context.palette.textSecondary),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 34,
          color: context.palette.textTertiary,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.palette.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Coba lagi'),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.palette.accent,
            side: BorderSide(color: context.palette.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final bool failed;
  final VoidCallback onRetry;

  const _Footer({required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: failed
            ? TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Gagal memuat. Coba lagi'),
                style: TextButton.styleFrom(
                  foregroundColor: context.palette.accent,
                ),
              )
            : SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.palette.accent,
                ),
              ),
      ),
    );
  }
}
