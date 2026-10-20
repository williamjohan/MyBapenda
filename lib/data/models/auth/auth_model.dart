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

/// Body POST lupa password.
@JsonSerializable(createFactory: false)
class LupaPasswordRequestModel {
  @JsonKey(name: 'nip')
  final String nip;

  /// `EChannelKodeReset`: 1 = Email, 2 = WhatsApp.
  @JsonKey(name: 'channel')
  final int channel;
  @JsonKey(name: 'tujuan')
  final String tujuan;

  const LupaPasswordRequestModel({
    required this.nip,
    required this.channel,
    required this.tujuan,
  });

  Map<String, dynamic> toJson() => _$LupaPasswordRequestModelToJson(this);
}

/// Body POST reset password (setelah login pakai reset key).
@JsonSerializable(createFactory: false)
class ResetPasswordRequestModel {
  @JsonKey(name: 'newPassword')
  final String newPassword;
  @JsonKey(name: 'confirmationPassword')
  final String confirmationPassword;

  const ResetPasswordRequestModel({
    required this.newPassword,
    required this.confirmationPassword,
  });

  Map<String, dynamic> toJson() => _$ResetPasswordRequestModelToJson(this);
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
