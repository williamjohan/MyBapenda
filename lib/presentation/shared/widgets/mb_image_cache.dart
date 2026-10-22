import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../core/di/injection.dart';

class BapendaImageCache extends CacheManager with ImageCacheManager {
  static final BapendaImageCache instance = BapendaImageCache._();

  BapendaImageCache._()
    : super(
        Config(
          'bapendaFotoCache',
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 300,
          fileService: _DioFileService(_imageDio(getIt<Dio>())),
        ),
      );

  static Dio _imageDio(Dio base) {
    final dio = Dio(base.options.copyWith())
      ..httpClientAdapter = base
          .httpClientAdapter 
      ..transformer = base.transformer;
    dio.interceptors
      ..clear()
      ..addAll(base.interceptors.where((i) => i is! ChuckerDioInterceptor));
    return dio;
  }
}

class _DioFileService extends FileService {
  _DioFileService(this._dio) {
    concurrentFetches = 4; 
  }

  final Dio _dio;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final res = await _dio.get<ResponseBody>(
      url,
      options: Options(responseType: ResponseType.stream, headers: headers),
    );
    return _DioResponse(res);
  }
}

class _DioResponse implements FileServiceResponse {
  _DioResponse(this._res);

  final Response<ResponseBody> _res;
  final DateTime _received = DateTime.now();

  @override
  Stream<List<int>> get content => _res.data!.stream;

  @override
  int? get contentLength =>
      int.tryParse(_res.headers.value(Headers.contentLengthHeader) ?? '');

  @override
  int get statusCode => _res.statusCode ?? 0;

  @override
  DateTime get validTill => _received.add(const Duration(days: 30));

  @override
  String? get eTag => _res.headers.value('etag');

  @override
  String get fileExtension {
    final type = _res.headers.value('content-type') ?? '';
    if (type.contains('png')) return '.png';
    if (type.contains('webp')) return '.webp';
    return '.jpg';
  }
}
