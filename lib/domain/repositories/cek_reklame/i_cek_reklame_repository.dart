import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../../data/models/cek_reklame/cek_reklame_model.dart';


abstract class CekReklameRepository {
  Future<Either<Failure, bool>> uploadReklame(CekReklameUploadRequest request);
}