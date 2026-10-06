import 'package:bapendacore/domain/entities/my_task/task_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_status.dart';
import 'package:bapendacore/domain/entities/my_task/task_submission_entity.dart';
import 'package:bapendacore/domain/entities/my_task/task_type.dart';

/// TODO(tech-debt): SELURUH FILE INI DUMMY. Hapus setelah repository/usecase
/// dan Cubit tersedia.
///
/// Simulasi gagal kirim: isi keterangan dengan teks "#gagal".
abstract final class MyTaskMockData {
  static final Set<String> _submittedIds = {};

  static Future<List<TaskEntity>> fetchTasks() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();

    TaskEntity t({
      required String id,
      required TaskType type,
      required TaskStatus status,
      required String taxpayer,
      required String object,
      required String address,
      required String taxType,
      required Duration deadlineIn,
      String nop = '357801001001000101',
      String? instruction,
      DateTime? completedAt,
      Map<String, String> extra = const {},
    }) {
      return TaskEntity(
        id: id,
        taskNumber: 'TSK-2026-$id',
        type: type,
        status: status,
        nop: nop,
        taxpayerName: taxpayer,
        objectName: object,
        address: address,
        taxType: taxType,
        assignedAt: now.subtract(const Duration(days: 2)),
        deadline: now.add(deadlineIn),
        instruction: instruction,
        completedAt: completedAt,
        objectLatitude: -7.2575,
        objectLongitude: 112.7521,
        extraAttributes: extra,
      );
    }

    final tasks = <TaskEntity>[
      t(
        id: '000142',
        type: TaskType.himbauanPembayaran,
        status: TaskStatus.aktif,
        taxpayer: 'CV Maju Jaya Advertising',
        object: 'Reklame billboard 4 x 8 m',
        address: 'Jl. Raya Darmo No. 100, Wonokromo',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(hours: 5),
        instruction:
            'Serahkan surat himbauan langsung ke pengelola. Jika tidak ada orang, tempel di tempat yang terlihat dan foto letaknya.',
        extra: {'Tunggakan': 'Rp 3.750.000', 'Masa pajak': 'Jul - Sep 2026'},
      ),
      t(
        id: '000139',
        type: TaskType.silang,
        status: TaskStatus.aktif,
        taxpayer: 'PT Sinar Reklame Nusantara',
        object: 'Reklame megatron 3 x 6 m',
        address: 'Jl. Basuki Rahmat No. 45, Genteng',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(hours: -3),
        nop: '357801001001000102',
        instruction: 'Pasang silang sesuai berita acara. Foto sebelum dan sesudah pemasangan.',
      ),
      t(
        id: '000145',
        type: TaskType.bongkar,
        status: TaskStatus.aktif,
        taxpayer: 'Toko Sumber Rejeki',
        object: 'Reklame tiang 2 x 4 m',
        address: 'Jl. Ahmad Yani No. 210, Gayungan',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(days: 1, hours: 6),
        nop: '357801001001000103',
        extra: {'Dasar tugas': 'Surat perintah bongkar No. 12/2026'},
      ),
      t(
        id: '000148',
        type: TaskType.teguranPembayaran,
        status: TaskStatus.aktif,
        taxpayer: 'Hotel Bintang Timur',
        object: 'Hotel bintang 3',
        address: 'Jl. Embong Malang No. 7, Tegalsari',
        taxType: 'Pajak Hotel',
        deadlineIn: const Duration(days: 2, hours: 3),
        nop: '357801001001000104',
        extra: {'Tunggakan': 'Rp 18.400.000', 'Teguran ke': '2'},
      ),
      t(
        id: '000150',
        type: TaskType.unsilang,
        status: TaskStatus.aktif,
        taxpayer: 'Resto Rasa Nusantara',
        object: 'Reklame neon box 1 x 3 m',
        address: 'Jl. Mayjen Sungkono No. 88, Dukuh Pakis',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(days: 3, hours: 8),
        nop: '357801001001000105',
        instruction: 'Wajib pajak sudah melunasi. Lepas tanda silang.',
      ),
      t(
        id: '000151',
        type: TaskType.pengawasanExisting,
        status: TaskStatus.aktif,
        taxpayer: 'PT Media Outdoor Surabaya',
        object: 'Reklame billboard 5 x 10 m',
        address: 'Jl. Raya Gubeng No. 12, Gubeng',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(days: 4),
        nop: '357801001001000106',
        extra: {'Izin terdaftar': '4 x 8 m'},
      ),
      t(
        id: '000153',
        type: TaskType.pengawasanTemuanBaru,
        status: TaskStatus.aktif,
        taxpayer: 'Belum terdata',
        object: 'Reklame baru (laporan Cek Reklame)',
        address: 'Jl. Manyar Kertoarjo No. 3, Gubeng',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(days: 6),
        nop: '357801001001000107',
        instruction: 'Verifikasi temuan dari laporan Cek Reklame dan catat data objek.',
      ),
      t(
        id: '000130',
        type: TaskType.himbauanPembayaran,
        status: TaskStatus.selesai,
        taxpayer: 'Warung Kopi Pojok',
        object: 'Reklame neon box 1 x 2 m',
        address: 'Jl. Kertajaya No. 50, Gubeng',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(days: -1),
        nop: '357801001001000108',
        completedAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      t(
        id: '000128',
        type: TaskType.silang,
        status: TaskStatus.selesai,
        taxpayer: 'CV Cahaya Baru',
        object: 'Reklame banner 1 x 4 m',
        address: 'Jl. Pemuda No. 30, Genteng',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(days: -2),
        nop: '357801001001000109',
        completedAt: now.subtract(const Duration(days: 2, hours: 2)),
      ),
      t(
        id: '000120',
        type: TaskType.teguranPembayaran,
        status: TaskStatus.kedaluwarsa,
        taxpayer: 'Restoran Selera Kita',
        object: 'Restoran',
        address: 'Jl. Dharmahusada No. 15, Mulyorejo',
        taxType: 'Pajak Restoran',
        deadlineIn: const Duration(days: -5),
        nop: '357801001001000110',
      ),
      t(
        id: '000118',
        type: TaskType.pengawasanExisting,
        status: TaskStatus.kedaluwarsa,
        taxpayer: 'PT Visual Kota',
        object: 'Reklame videotron 3 x 5 m',
        address: 'Jl. Tunjungan No. 1, Genteng',
        taxType: 'Pajak Reklame',
        deadlineIn: const Duration(days: -8),
        nop: '357801001001000111',
      ),
    ];

    return [
      for (final task in tasks)
        _submittedIds.contains(task.id)
            ? task.copyWith(
                status: TaskStatus.selesai,
                completedAt: now,
              )
            : task,
    ];
  }

  static Future<void> submit(TaskSubmissionEntity submission) async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (submission.notes.toLowerCase().contains('#gagal')) {
      throw Exception('Simulasi gagal kirim');
    }
    _submittedIds.add(submission.taskId);
  }
}
