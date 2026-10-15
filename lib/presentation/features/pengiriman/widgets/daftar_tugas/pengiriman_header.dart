import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';

/// Header gradient: kembali, judul, aksi (toggle tema, dst.) dan kolom cari.
/// [liveSearch] true: cari saat mengetik (debounce); false: saat dikirim.
class PengirimanHeader extends StatefulWidget {
  final String title;
  final String hintText;
  final bool liveSearch;
  final VoidCallback onBack;
  final ValueChanged<String> onSearch;

  /// Aksi tambahan di kanan judul (mis. indikator antrean).
  final List<Widget> actions;

  const PengirimanHeader({
    super.key,
    this.title = 'Pengiriman Surat',
    this.hintText = 'Cari no resi / nama WP',
    this.liveSearch = true,
    required this.onBack,
    required this.onSearch,
    this.actions = const [],
  });

  @override
  State<PengirimanHeader> createState() => _PengirimanHeaderState();
}

class _PengirimanHeaderState extends State<PengirimanHeader> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // tombol hapus
    _debounce?.cancel();
    if (!widget.liveSearch) return;
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => widget.onSearch(value),
    );
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    if (widget.liveSearch) widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(gradient: palette.headerLinearGradient),
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.paddingOf(context).top + 8,
        12,
        14,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...widget.actions,
              const SizedBox(width: 8),
              const ThemeToggleButton(),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                widget.onSearch(v);
              },
              textInputAction: TextInputAction.search,
              style: TextStyle(color: palette.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: palette.textTertiary, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: palette.textTertiary,
                ),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _clear,
                        icon: Icon(
                          Icons.close_rounded,
                          color: palette.textTertiary,
                        ),
                      ),
                filled: true,
                fillColor: palette.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
