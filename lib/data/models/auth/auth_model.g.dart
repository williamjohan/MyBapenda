// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AuthRequestModelToJson(AuthRequestModel instance) =>
    <String, dynamic>{
      'nip': instance.nip,
      'password': instance.password,
    };

Map<String, dynamic> _$LupaPasswordRequestModelToJson(
        LupaPasswordRequestModel instance) =>
    <String, dynamic>{
      'nip': instance.nip,
      'channel': instance.channel,
      'tujuan': instance.tujuan,
    };

Map<String, dynamic> _$ResetPasswordRequestModelToJson(
        ResetPasswordRequestModel instance) =>
    <String, dynamic>{
      'newPassword': instance.newPassword,
      'confirmationPassword': instance.confirmationPassword,
    };

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      token: json['token'] as String?,
      isResetPassword: json['isResetPassword'] as bool? ?? false,
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'isResetPassword': instance.isResetPassword,
    };
