import 'task_status.dart';
import 'task_type.dart';


/// Satu tugas lapangan hasil fetch dari BE.
///
/// TODO(tech-debt): DUMMY ENTITY. Final-kan field setelah kontrak payload
/// disepakati dengan tim BE. [extraAttributes] disiapkan untuk properti yang
/// berbeda antar jenis tugas (tampil di halaman detail).
class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.taskNumber,
    required this.type,
    required this.status,
    required this.nop,
    required this.taxpayerName,
    required this.objectName,
    required this.address,
    required this.taxType,
    required this.assignedAt,
    required this.deadline,
    this.instruction,
    this.objectLatitude,
    this.objectLongitude,
    this.completedAt,
    this.extraAttributes = const {},
  });

  final String id;
  final String taskNumber;
  final TaskType type;
  final TaskStatus status;
  final String nop;
  final String taxpayerName;
  final String objectName;
  final String address;

  /// Jenis pajak objek (satu NOP = satu jenis pajak). Dipakai sebagai
  /// kondisi "IF" pada TaskFormConfig.
  final String taxType;
  final DateTime assignedAt;
  final DateTime deadline;
  final String? instruction;

  /// Koordinat objek pajak, untuk validasi radius check-in kelak.
  final double? objectLatitude;
  final double? objectLongitude;
  final DateTime? completedAt;
  final Map<String, String> extraAttributes;

  TaskEntity copyWith({TaskStatus? status, DateTime? completedAt}) {
    return TaskEntity(
      id: id,
      taskNumber: taskNumber,
      type: type,
      status: status ?? this.status,
      nop: nop,
      taxpayerName: taxpayerName,
      objectName: objectName,
      address: address,
      taxType: taxType,
      assignedAt: assignedAt,
      deadline: deadline,
      instruction: instruction,
      objectLatitude: objectLatitude,
      objectLongitude: objectLongitude,
      completedAt: completedAt ?? this.completedAt,
      extraAttributes: extraAttributes,
    );
  }
}
