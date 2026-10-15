import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/env_config/env_config.dart';

/// URL penuh foto jejak (`GET foto?key=`), dimuat lewat `BapendaImage`
/// supaya tetap memakai Dio (DoH + sertifikat host BASE_URL).
String pengirimanFotoUrl(String key) {
  final base = EnvConfig.baseUrl.endsWith('/')
      ? EnvConfig.baseUrl.substring(0, EnvConfig.baseUrl.length - 1)
      : EnvConfig.baseUrl;
  return '$base${ApiEndpoints.pengirimanFoto}'
      '?key=${Uri.encodeQueryComponent(key)}';
}
