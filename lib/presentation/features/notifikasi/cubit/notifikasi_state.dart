import 'package:equatable/equatable.dart';

import '../../../../domain/entities/notifikasi/notifikasi_entity.dart';

enum NotifikasiStatus { initial, loading, success, failure }

class NotifikasiState extends Equatable {
  final NotifikasiStatus status;
  final List<NotifikasiEntity> items;
  final int page;
  final bool adaLagi;
  final bool memuatLagi;
  final String? pesan;

  const NotifikasiState({
    this.status = NotifikasiStatus.initial,
    this.items = const [],
    this.page = 0,
    this.adaLagi = false,
    this.memuatLagi = false,
    this.pesan,
  });

  bool get adaBelumDibaca => items.any((n) => !n.dibaca);

  NotifikasiState copyWith({
    NotifikasiStatus? status,
    List<NotifikasiEntity>? items,
    int? page,
    bool? adaLagi,
    bool? memuatLagi,
    String? pesan,
  }) => NotifikasiState(
    status: status ?? this.status,
    items: items ?? this.items,
    page: page ?? this.page,
    adaLagi: adaLagi ?? this.adaLagi,
    memuatLagi: memuatLagi ?? this.memuatLagi,
    pesan: pesan,
  );

  @override
  List<Object?> get props => [status, items, page, adaLagi, memuatLagi, pesan];
}
