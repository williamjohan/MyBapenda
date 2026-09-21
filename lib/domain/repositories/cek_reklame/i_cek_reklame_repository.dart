import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';

abstract class CekReklameRepository {
  Future<Either<Failure, bool>> uploadReklame({
    required File file,
    required String latitude,
    required String longitude,
    required String alamat,
  });
}