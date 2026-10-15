// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_api_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseApiResponseModel<T> _$BaseApiResponseModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    BaseApiResponseModel<T>(
      isSuccess: json['isSuccess'] as bool? ?? false,
      title: json['title'] as String?,
      status: (json['status'] as num?)?.toInt() ?? 500,
      traceId: json['traceId'] as String?,
      errors: json['errors'],
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$BaseApiResponseModelToJson<T>(
  BaseApiResponseModel<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'title': instance.title,
      'status': instance.status,
      'traceId': instance.traceId,
      'errors': instance.errors,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
