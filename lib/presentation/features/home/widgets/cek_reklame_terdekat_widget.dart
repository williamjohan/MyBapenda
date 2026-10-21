import 'package:mybapenda/presentation/features/home/cubit/nearby_cubit.dart';
import 'package:mybapenda/presentation/features/home/cubit/nearby_state.dart';
import 'package:mybapenda/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NearbyBillboardCard extends StatelessWidget {
  const NearbyBillboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyCubit, NearbyState>(
      builder: (context, state) {
        // Variable Helper
        final isServiceEnabled = state.status != NearbyStatus.serviceDisabled;
        final isNoInternet = state.status == NearbyStatus.noInternet;

        // Loading hanya jika benar-benar awal dan bukan karena error internet
        final isLoading =
            state.status == NearbyStatus.loading ||
            state.status == NearbyStatus.initial;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.05,
                ), // withValues(alpha: 0.05) untuk Flutter 3.27+
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                // HANDLING TAP BERDASARKAN STATUS
                if (state.status == NearbyStatus.serviceDisabled) {
                  await showGpsDisabledModal(context);
                  if (context.mounted) context.read<NearbyCubit>().retry();
                } else if (state.status == NearbyStatus.permissionDenied) {
                  await showPermissionDeniedModal(context);
                  if (context.mounted) context.read<NearbyCubit>().retry();
                } else if (state.status == NearbyStatus.noInternet) {
                  // Jika internet mati, tap akan memaksa refresh (manual retry)
                  context.read<NearbyCubit>().retry();
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Layanan Lokasi",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        // Badge Status GPS (Tetap Hijau/Merah)
                        _buildStatusBadge(isServiceEnabled),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // --- MAP AREA / CONTENT ---
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _buildContent(state, isLoading, isNoInternet),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // --- FOOTER: COORDINATE / STATUS TEXT ---
                    _buildFooterText(state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Logic Pemilih Konten Utama (Map/Loading/Error)
  Widget _buildContent(NearbyState state, bool isLoading, bool isNoInternet) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state.status == NearbyStatus.serviceDisabled) {
      return _buildPlaceholder(
        "GPS Tidak Aktif",
        Icons.location_off_rounded,
        Colors.grey.shade400,
      );
    }

    if (state.status == NearbyStatus.permissionDenied) {
      return _buildPlaceholder(
        "Izin Lokasi Ditolak",
        Icons.block_rounded,
        Colors.redAccent,
      );
    }

    // 🔥 TAMPILAN KHUSUS NO INTERNET
    if (isNoInternet) {
      return _buildPlaceholder(
        "Koneksi Terputus",
        Icons.wifi_off_rounded,
        Colors.grey.shade400,
        subMessage: "Menunggu jaringan...",
      );
    }

    // Normal State (Map)
    if (state.mapImageUrl != null) {
      return Image.network(
        state.mapImageUrl!,
        fit: BoxFit.cover,
        // Error builder bawaan Image.network (fallback terakhir)
        errorBuilder: (_, __, ___) => _buildPlaceholder(
          "Gagal Memuat Peta",
          Icons.broken_image_rounded,
          Colors.grey,
        ),
      );
    }

    // Default Fallback
    return _buildPlaceholder(
      "Memuat Peta...",
      Icons.map_rounded,
      Colors.blueGrey,
    );
  }

  /// Helper untuk Placeholder (Error/Empty State)
  Widget _buildPlaceholder(
    String text,
    IconData icon,
    Color iconColor, {
    String? subMessage,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              subMessage,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? "Aktif" : "Mati",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText(NearbyState state) {
    // Jika No Internet, kita kasih info text yang relevan
    if (state.status == NearbyStatus.noInternet) {
      return Container(
        height: 40,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              Icons.sync_problem_rounded,
              size: 14,
              color: Colors.orange.shade300,
            ),
            const SizedBox(width: 6),
            const Text(
              'Offline Mode',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final pos = state.currentPosition;
    final hasData = pos != null;

    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 14,
            color: hasData ? const Color(0xFFE53935) : Colors.grey.shade400,
          ),
          const SizedBox(width: 6),
          Text(
            hasData
                ? 'Lat: ${pos.latitude.toStringAsFixed(4)}, Long: ${pos.longitude.toStringAsFixed(4)}'
                : 'Lat: ..., Long: ...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: hasData ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
