// lib/presentation/features/balai_rw/constants/balai_rw_dummy.dart
// TODO: hapus file ini kalau master, form, dan simpan sudah dari API

class BalaiRwDummy {
  BalaiRwDummy._();

  // TODO: master kecamatan dari API
  static const Map<int, String> kecamatan = {
    1: 'Simokerto',
    2: 'Genteng',
    3: 'Tambaksari',
  };

  // TODO: master kelurahan dari API. key = id kecamatan
  static const Map<int, Map<int, String>> kelurahan = {
    1: {
      11: 'Kapasan',
      12: 'Simolawang',
      13: 'Tambakrejo',
      14: 'Sidodadi',
      15: 'Simokerto',
    },
    2: {
      21: 'Genteng',
      22: 'Embong Kaliasin',
      23: 'Kapasari',
      24: 'Ketabang',
      25: 'Peneleh',
    },
    3: {
      31: 'Tambaksari',
      32: 'Gading',
      33: 'Pacarkeling',
      34: 'Pacarkembang',
      35: 'Ploso',
      36: 'Rangkah',
    },
  };

  // TODO: form dari API. Semua field berupa input teks.
  // 'title' di section opsional (kalau null tampil "Bagian A")
  static const List<Map<String, dynamic>> formSections = [
    {
      'code': 'A',
      'fields': [
        {'code': 'A.1', 'label': 'Stunting'},
        {'code': 'A.2', 'label': 'Gizi buruk'},
        {'code': 'A.3', 'label': 'Ibu hamil risiko tinggi'},
      ],
    },
    {
      'code': 'B',
      'fields': [
        {'code': 'B.1', 'label': 'Usia produktif belum bekerja'},
        {'code': 'B.2', 'label': 'Anak putus sekolah'},
        {'code': 'B.3', 'label': 'Pendapatan per keluarga'},
      ],
    },
    {
      'code': 'C',
      'fields': [
        {
          'code': 'C.1',
          'label': 'Warga miskin/desil 1-5 dan ketepatan bantuan',
        },
        {
          'code': 'C.2',
          'label': 'Warga mampu yang membantu warga miskin di RW sendiri',
        },
      ],
    },
    {
      'code': 'D',
      'fields': [
        {'code': 'D.1', 'label': 'Rumah tangga yang sudah memilah sampah'},
        {
          'code': 'D.2',
          'label': 'Program Rp5 juta/bulan untuk Gen Z: realisasi dan dampak',
        },
      ],
    },
    {
      'code': 'E',
      'fields': [
        {'code': 'E.1', 'label': 'Aduan warga yang belum terselesaikan'},
      ],
    },
  ];

  static const Map<String, dynamic> penugasan = {
    'kecamatan': 'Simokerto',
    'kelurahan': 'Kapasan',
    'balaiRw': 'Balai RW 05',
    'petugas': 'Staf Bapenda',
    'role': 'koordinator', // ganti 'staf' untuk tes mode lihat saja
  };

  static bool get isKoordinator => penugasan['role'] == 'koordinator';
}

class BalaiRwStore {
  BalaiRwStore._();

  static final Map<String, Map<String, dynamic>> _byDate = {};

  static Map<String, dynamic>? of(String isoDate) => _byDate[isoDate];

  static void patch(String isoDate, Map<String, dynamic> patch) {
    _byDate[isoDate] = {
      ...?_byDate[isoDate],
      ...patch,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
