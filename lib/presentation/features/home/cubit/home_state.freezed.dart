// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomeState {
  bool get isCheckingUpdate => throw _privateConstructorUsedError;
  UpdateInfo? get updateInfo => throw _privateConstructorUsedError;
  HomeAction? get action => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get userRole => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {bool isCheckingUpdate,
      UpdateInfo? updateInfo,
      HomeAction? action,
      String userName,
      String userRole});
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCheckingUpdate = null,
    Object? updateInfo = freezed,
    Object? action = freezed,
    Object? userName = null,
    Object? userRole = null,
  }) {
    return _then(_value.copyWith(
      isCheckingUpdate: null == isCheckingUpdate
          ? _value.isCheckingUpdate
          : isCheckingUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      updateInfo: freezed == updateInfo
          ? _value.updateInfo
          : updateInfo // ignore: cast_nullable_to_non_nullable
              as UpdateInfo?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as HomeAction?,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userRole: null == userRole
          ? _value.userRole
          : userRole // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
          _$HomeStateImpl value, $Res Function(_$HomeStateImpl) then) =
      __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isCheckingUpdate,
      UpdateInfo? updateInfo,
      HomeAction? action,
      String userName,
      String userRole});
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
      _$HomeStateImpl _value, $Res Function(_$HomeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCheckingUpdate = null,
    Object? updateInfo = freezed,
    Object? action = freezed,
    Object? userName = null,
    Object? userRole = null,
  }) {
    return _then(_$HomeStateImpl(
      isCheckingUpdate: null == isCheckingUpdate
          ? _value.isCheckingUpdate
          : isCheckingUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      updateInfo: freezed == updateInfo
          ? _value.updateInfo
          : updateInfo // ignore: cast_nullable_to_non_nullable
              as UpdateInfo?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as HomeAction?,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userRole: null == userRole
          ? _value.userRole
          : userRole // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl(
      {this.isCheckingUpdate = false,
      this.updateInfo,
      this.action,
      this.userName = 'Memuat...',
      this.userRole = ''});

  @override
  @JsonKey()
  final bool isCheckingUpdate;
  @override
  final UpdateInfo? updateInfo;
  @override
  final HomeAction? action;
  @override
  @JsonKey()
  final String userName;
  @override
  @JsonKey()
  final String userRole;

  @override
  String toString() {
    return 'HomeState(isCheckingUpdate: $isCheckingUpdate, updateInfo: $updateInfo, action: $action, userName: $userName, userRole: $userRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.isCheckingUpdate, isCheckingUpdate) ||
                other.isCheckingUpdate == isCheckingUpdate) &&
            (identical(other.updateInfo, updateInfo) ||
                other.updateInfo == updateInfo) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isCheckingUpdate, updateInfo, action, userName, userRole);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState(
      {final bool isCheckingUpdate,
      final UpdateInfo? updateInfo,
      final HomeAction? action,
      final String userName,
      final String userRole}) = _$HomeStateImpl;

  @override
  bool get isCheckingUpdate;
  @override
  UpdateInfo? get updateInfo;
  @override
  HomeAction? get action;
  @override
  String get userName;
  @override
  String get userRole;
  @override
  @JsonKey(ignore: true)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
