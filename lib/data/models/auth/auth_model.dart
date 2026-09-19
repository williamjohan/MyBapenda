import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/auth/auth_entity.dart';

part 'auth_model.g.dart';

@JsonSerializable(createFactory: false)
class AuthRequestModel {
  final String nip;
  final String password;

  const AuthRequestModel({required this.nip, required this.password});

  Map<String, dynamic> toJson() => _$AuthRequestModelToJson(this);
}

@JsonSerializable()
class AuthResponseModel {
  @JsonKey(name: 'token')
  final String? token;
  @JsonKey(name: 'isResetPassword', defaultValue: false)
  final bool isResetPassword;

  const AuthResponseModel({this.token, required this.isResetPassword});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

extension AuthResponseModelX on AuthResponseModel {
  AuthResponseEntity toEntity() =>
      AuthResponseEntity(token: token ?? '', isResetPassword: isResetPassword);
}
