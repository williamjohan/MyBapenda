enum MasterOptionType {
  lokasiTertentu,
  lokasiPenyelenggaraan,
  jenisReklame,
  jenisProduk,
  letakReklame,
  statusTanah,
  sudutPandang,
  jenisBangunan,
  kecamatan;

  String get label => switch (this) {
    lokasiTertentu => 'Lokasi Tertentu',
    lokasiPenyelenggaraan => 'Lokasi Penyelenggaraan',
    jenisReklame => 'Jenis Reklame',
    jenisProduk => 'Jenis Produk',
    letakReklame => 'Letak Reklame',
    statusTanah => 'Status Tanah',
    sudutPandang => 'Sudut Pandang',
    jenisBangunan => 'Jenis Bangunan',
    kecamatan => 'Kecamatan',
  };

  bool get usesIntegerId => switch (this) {
    lokasiTertentu ||
    lokasiPenyelenggaraan ||
    jenisReklame ||
    jenisProduk ||
    letakReklame ||
    statusTanah ||
    sudutPandang ||
    jenisBangunan => true,
    kecamatan => false,
  };
}
