// lib/data/repositories/my_task/my_task_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/core/network/safe_api_call.dart';
import 'package:mybapenda/data/datasources/my_task/my_task_remote_datasource.dart';
import 'package:mybapenda/data/models/my_task/my_task_checkin_model.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_checkin_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_detail_entity.dart';
import 'package:mybapenda/domain/entities/my_task/my_task_header_entity.dart';
import 'package:mybapenda/domain/repositories/my_task/i_my_task_repository.dart';

@LazySingleton(as: IMyTaskRepository)
class MyTaskRepositoryImpl implements IMyTaskRepository {
  final IMyTaskRemoteDataSource _remoteDataSource;

  MyTaskRepositoryImpl(this._remoteDataSource);

  // ===========================================================================
  // 1. GET HEADER (Map Model -> Entity)
  // ===========================================================================
  @override
  Future<Either<Failure, MyTaskHeaderEntity>> getHeader({
    int page = 1,
    int pageSize = 50,
  }) {
    return executeSafeApiCall<MyTaskHeaderEntity>(() async {
      final model = await _remoteDataSource.getHeader(
        page: page,
        pageSize: pageSize,
      );
      return model.toEntity();
    });
  }

  // ===========================================================================
  // 2. GET HEADER DETAIL (Map Model -> Entity)
  // ===========================================================================
  @override
  Future<Either<Failure, MyTaskDetailEntity>> getHeaderDetail({
    required String jenis,
    required String key,
  }) {
    return executeSafeApiCall<MyTaskDetailEntity>(() async {
      final model = await _remoteDataSource.getHeaderDetail(
        jenis: jenis,
        key: key,
      );
      return model.toEntity();
    });
  }
  
  @override
  Future<Either<Failure, bool>> checkin(MyTaskCheckinRequestEntity request) {
    return executeSafeApiCall<bool>(
      () => _remoteDataSource.checkin(request.toModel()),
    );
  }
}
