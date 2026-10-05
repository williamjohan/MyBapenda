// lib/presentation/features/reklame/constants/survey_options.dart
// TODO: semua opsi ini dari master data API (id -> nama)
class SurveyOptions {
  SurveyOptions._();

  static const Map<int, String> lokasiTertentu = {
    1: 'Bukan Lokasi Tertentu',
    2: 'Taman Kota',
    3: 'Jembatan',
  };
  static const Map<int, String> letakReklame = {
    1: 'Tepi Jalan',
    2: 'Median Jalan',
    3: 'Di Atas Bangunan',
  };
  static const Map<int, String> statusTanah = {
    1: 'Tanah Pemkot',
    2: 'Tanah Swasta',
    3: 'Tanah Negara',
  };
  static const Map<int, String> jenisReklame = {
    1: 'Billboard / Baliho',
    2: 'Neon Box',
    3: 'Megatron',
  };
  static const Map<int, String> jenisProduk = {
    1: 'Komersial',
    2: 'Non-Komersial',
    3: 'Layanan Masyarakat',
  };
  static const Map<int, String> sudutPandang = {
    1: 'Arah Utama Jalan',
    2: 'Arah Berlawanan',
    3: 'Persimpangan',
  };

  // --- Informasi survey (dummy, ganti dari master API) ---
  static const Map<int, String> kecamatan = {
    1: 'Genteng',
    2: 'Tambaksari',
    3: 'Gubeng',
  };

  /// key = id kecamatan, value = {id kelurahan: nama}
  static const Map<int, Map<int, String>> kelurahan = {
    1: {
      11: 'Genteng',
      12: 'Embong Kaliasin',
      13: 'Kapasari',
      14: 'Ketabang',
      15: 'Peneleh',
    },
    2: {
      21: 'Tambaksari',
      22: 'Gading',
      23: 'Pacarkeling',
      24: 'Pacarkembang',
      25: 'Ploso',
      26: 'Rangkah',
    },
    3: {
      31: 'Airlangga',
      32: 'Barata Jaya',
      33: 'Gubeng',
      34: 'Kertajaya',
      35: 'Mojo',
      36: 'Pucang Sewu',
    },
  };

  static const Map<int, String> timSurvey = {
    1: 'Tim A',
    2: 'Tim B',
    3: 'Tim C',
  };

  static String kelurahanName(dynamic kecId, dynamic kelId) =>
      kelurahan[kecId]?[kelId] ?? '-';

  // --- Helper ---

  /// 5.0 -> "5", 2.5 -> "2.5"
  static String fmtNum(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// 05 Oktober 2026
  static String fmtTanggal(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_bulan[d.month - 1]} ${d.year}';

  /// 2026-10-05
  static String isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static const Map<int, String> jenisPengajuan = {
    1: 'Pendaftaran Baru',
    2: 'Perubahan Data',
    3: 'Pemecahan',
  };
  static const Map<int, String> jenisBangunan = {
    1: 'Rumah Tinggal',
    2: 'Ruko',
    3: 'Gedung Perkantoran',
  };
  static const Map<int, String> namaJalan = {
    1: 'Jl. Basuki Rahmat',
    2: 'Jl. Raya Darmo',
    3: 'Jl. Ahmad Yani',
  };
}
