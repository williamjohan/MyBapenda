import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _brand = Color(0xFFB8680F);

Future<T?> showSelectSheet<T>(
  BuildContext context, {
  required String title,
  required Map<T, String> items,
  T? value,
  bool? searchable,
  String searchHint = 'Cari...',
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
      searchable: searchable ?? items.length > 7,
      searchHint: searchHint,
    ),
  );
}

class _SelectSheet<T> extends StatefulWidget {
  final String title;
  final Map<T, String> items;
  final T? value;
  final bool searchable;
  final String searchHint;

  const _SelectSheet({
    required this.title,
    required this.items,
    required this.value,
    required this.searchable,
    required this.searchHint,
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

  List<MapEntry<T, String>> get _filtered {
    final q = _q.trim().toLowerCase();
    final all = widget.items.entries.toList();
    if (q.isEmpty) return all;
    return all.where((e) => e.value.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.75;
    final list = _filtered;

    return Padding(
      // naik mengikuti keyboard
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2933),
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
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _q = v),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF9AA5B1),
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
            Flexible(
              child: list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          widget.items.isEmpty
                              ? 'Belum ada pilihan'
                              : 'Tidak ditemukan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF7B8794),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final e = list[i];
                        final selected = e.key == widget.value;
                        return Material(
                          color: selected
                              ? const Color(0xFFFFF3DC)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(e.key),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? _brand
                                            : const Color(0xFF1F2933),
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: _brand,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
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
  });

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showSelectSheet<T>(
      context,
      title: sheetTitle ?? 'Pilih ${label.replaceAll('*', '').trim()}',
      items: items,
      value: value,
      searchable: searchable,
      searchHint: 'Cari ${label.replaceAll('*', '').trim().toLowerCase()}',
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
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF52606D),
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
                      style: GoogleFonts.plusJakartaSans(
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
