// lib/domain/usecases/my_task/my_task_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_checkin_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_detail_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';
import 'package:mybapenda/domain/repositories/my_task/i_my_task_repository.dart';

@lazySingleton
class MyTaskUseCase {
  final IMyTaskRepository _repository;

  MyTaskUseCase(this._repository);

  // 1. GET HEADER: daftar tugas + ringkasan
  Future<Either<Failure, MyTaskHeaderEntity>> getHeader({
    int page = 1,
    int pageSize = 50,
  }) {
    return _repository.getHeader(page: page, pageSize: pageSize);
  }

  // 2. GET HEADER DETAIL
  Future<Either<Failure, MyTaskDetailEntity>> getHeaderDetail({
    required String jenis,
    required String key,
  }) {
    return _repository.getHeaderDetail(jenis: jenis, key: key);
  }

  Future<Either<Failure, bool>> checkin(MyTaskCheckinRequestEntity request) {
    return _repository.checkin(request);
  }
}
