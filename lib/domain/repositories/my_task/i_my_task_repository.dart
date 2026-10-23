// lib/domain/repositories/my_task/i_my_task_repository.dart
import 'package:dartz/dartz.dart';
import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_checkin_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_detail_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';

abstract class IMyTaskRepository {
  Future<Either<Failure, MyTaskHeaderEntity>> getHeader({
    int page = 1,
    int pageSize = 50,
  });

  Future<Either<Failure, MyTaskDetailEntity>> getHeaderDetail({
    required String jenis,
    required String key,
  });

  Future<Either<Failure, bool>> checkin(MyTaskCheckinRequestEntity request);
}
