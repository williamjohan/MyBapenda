import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _brand = Color(0xFFB8680F);

@immutable
class BtSelectData<T> {
  final Map<T, String> items;
  final bool loading;
  final String? error;

  const BtSelectData({required this.items, this.loading = false, this.error});

  @override
  bool operator ==(Object other) =>
      other is BtSelectData<T> &&
      other.loading == loading &&
      other.error == error &&
      mapEquals(other.items, items);

  @override
  int get hashCode => Object.hash(loading, error, items.length);
}

class BtSelectSource<T> {
  final BtSelectData<T> Function() read;
  final Stream<BtSelectData<T>> changes;
  final VoidCallback? onOpen;
  final VoidCallback? onRetry;

  const BtSelectSource({
    required this.read,
    required this.changes,
    this.onOpen,
    this.onRetry,
  });
}

Future<T?> showSelectSheet<T>(
  BuildContext context, {
  required String title,
  required Map<T, String> items,
  T? value,
  bool? searchable,
  String searchHint = 'Cari...',
  BtSelectSource<T>? source,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _SelectSheet<T>(
      title: title,
      items: items,
      value: value,
      searchable: searchable,
      searchHint: searchHint,
      source: source,
    ),
  );
}

class _SelectSheet<T> extends StatefulWidget {
  final String title;
  final Map<T, String> items;
  final T? value;
  final bool? searchable;
  final String searchHint;
  final BtSelectSource<T>? source;

  const _SelectSheet({
    required this.title,
    required this.items,
    required this.value,
    required this.searchable,
    required this.searchHint,
    required this.source,
  });

  @override
  State<_SelectSheet<T>> createState() => _SelectSheetState<T>();
}

class _SelectSheetState<T> extends State<_SelectSheet<T>> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<MapEntry<T, String>> _filtered(Map<T, String> items) {
    final q = _q.trim().toLowerCase();
    final all = items.entries.toList();
    if (q.isEmpty) return all;
    return all.where((e) => e.value.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.source;

    if (source == null) {
      return _buildContent(context, BtSelectData<T>(items: widget.items));
    }

    return StreamBuilder<BtSelectData<T>>(
      stream: source.changes,
      initialData: source.read(),
      builder: (context, snap) =>
          _buildContent(context, snap.data ?? source.read()),
    );
  }

  Widget _buildContent(BuildContext context, BtSelectData<T> data) {
    final maxH = MediaQuery.sizeOf(context).height * 0.75;
    final list = _filtered(data.items);
    final showSearch = widget.searchable ?? data.items.length > 7;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DEE4),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF7B8794),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _q = v),
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9AA5B1),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9AA5B1),
                    ),
                    suffixIcon: _q.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => setState(() {
                              _ctrl.clear();
                              _q = '';
                            }),
                          ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F8),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            Flexible(child: _buildBody(context, data, list)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BtSelectData<T> data,
    List<MapEntry<T, String>> list,
  ) {
    if (data.items.isEmpty && data.loading) {
      return const _SheetLoading();
    }

    if (data.items.isEmpty && data.error != null) {
      return _SheetError(message: data.error!, onRetry: widget.source?.onRetry);
    }

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            data.items.isEmpty ? 'Belum ada pilihan' : 'Tidak ditemukan',
            style: const TextStyle(fontSize: 13, color: Color(0xFF7B8794)),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final e = list[i];
        final selected = e.key == widget.value;
        return Material(
          color: selected ? const Color(0xFFFFF3DC) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).pop(e.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected ? _brand : const Color(0xFF1F2933),
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_rounded, size: 20, color: _brand),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetLoading extends StatelessWidget {
  const _SheetLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: _brand),
            ),
            SizedBox(height: 14),
            Text(
              'Memuat pilihan...',
              style: TextStyle(fontSize: 13, color: Color(0xFF7B8794)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _SheetError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 34,
              color: Color(0xFF9AA5B1),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF52606D)),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba lagi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _brand,
                  side: const BorderSide(color: _brand),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BtSelectField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final Map<T, String> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final bool? searchable;
  final String? sheetTitle;
  final bool mandatory;
  final BtSelectSource<T>? source;

  const BtSelectField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint = 'Pilih',
    this.enabled = true,
    this.searchable,
    this.sheetTitle,
    this.mandatory = false,
    this.source,
  });

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();

    source?.onOpen?.call();

    final picked = await showSelectSheet<T>(
      context,
      title: sheetTitle ?? 'Pilih ${label.replaceAll('*', '').trim()}',
      items: items,
      value: value,
      searchable: searchable,
      searchHint: 'Cari ${label.replaceAll('*', '').trim().toLowerCase()}',
      source: source,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = items[value];
    final hasValue = text != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF52606D),
            ),
            children: [
              TextSpan(text: label),
              if (mandatory)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: enabled ? Colors.white : const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? () => _open(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD9DEE4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? text : hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: hasValue
                            ? const Color(0xFF1F2933)
                            : const Color(0xFF9AA5B1),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled
                        ? const Color(0xFF7B8794)
                        : const Color(0xFFCBD2D9),
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
