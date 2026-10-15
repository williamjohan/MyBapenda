// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'va_qris_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VaQrisState {
  VaQrisStatus get status => throw _privateConstructorUsedError;
  List<TaxTypeEntity> get taxTypes => throw _privateConstructorUsedError;
  TaxTypeEntity? get selectedTaxType => throw _privateConstructorUsedError;
  TaxBillingEntity? get billing => throw _privateConstructorUsedError;

  /// Jumlah masa terlama yang dipilih (lihat PeriodSelectionLogic).
  int get selectedCount => throw _privateConstructorUsedError;
  bool get confirming => throw _privateConstructorUsedError;
  PaymentSessionEntity? get session => throw _privateConstructorUsedError;
  PaymentSessionStatus get sessionStatus => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VaQrisStateCopyWith<VaQrisState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaQrisStateCopyWith<$Res> {
  factory $VaQrisStateCopyWith(
    VaQrisState value,
    $Res Function(VaQrisState) then,
  ) = _$VaQrisStateCopyWithImpl<$Res, VaQrisState>;
  @useResult
  $Res call({
    VaQrisStatus status,
    List<TaxTypeEntity> taxTypes,
    TaxTypeEntity? selectedTaxType,
    TaxBillingEntity? billing,
    int selectedCount,
    bool confirming,
    PaymentSessionEntity? session,
    PaymentSessionStatus sessionStatus,
    String? errorMessage,
  });
}

/// @nodoc
class _$VaQrisStateCopyWithImpl<$Res, $Val extends VaQrisState>
    implements $VaQrisStateCopyWith<$Res> {
  _$VaQrisStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? taxTypes = null,
    Object? selectedTaxType = freezed,
    Object? billing = freezed,
    Object? selectedCount = null,
    Object? confirming = null,
    Object? session = freezed,
    Object? sessionStatus = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as VaQrisStatus,
            taxTypes: null == taxTypes
                ? _value.taxTypes
                : taxTypes // ignore: cast_nullable_to_non_nullable
                      as List<TaxTypeEntity>,
            selectedTaxType: freezed == selectedTaxType
                ? _value.selectedTaxType
                : selectedTaxType // ignore: cast_nullable_to_non_nullable
                      as TaxTypeEntity?,
            billing: freezed == billing
                ? _value.billing
                : billing // ignore: cast_nullable_to_non_nullable
                      as TaxBillingEntity?,
            selectedCount: null == selectedCount
                ? _value.selectedCount
                : selectedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            confirming: null == confirming
                ? _value.confirming
                : confirming // ignore: cast_nullable_to_non_nullable
                      as bool,
            session: freezed == session
                ? _value.session
                : session // ignore: cast_nullable_to_non_nullable
                      as PaymentSessionEntity?,
            sessionStatus: null == sessionStatus
                ? _value.sessionStatus
                : sessionStatus // ignore: cast_nullable_to_non_nullable
                      as PaymentSessionStatus,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VaQrisStateImplCopyWith<$Res>
    implements $VaQrisStateCopyWith<$Res> {
  factory _$$VaQrisStateImplCopyWith(
    _$VaQrisStateImpl value,
    $Res Function(_$VaQrisStateImpl) then,
  ) = __$$VaQrisStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VaQrisStatus status,
    List<TaxTypeEntity> taxTypes,
    TaxTypeEntity? selectedTaxType,
    TaxBillingEntity? billing,
    int selectedCount,
    bool confirming,
    PaymentSessionEntity? session,
    PaymentSessionStatus sessionStatus,
    String? errorMessage,
  });
}

/// @nodoc
class __$$VaQrisStateImplCopyWithImpl<$Res>
    extends _$VaQrisStateCopyWithImpl<$Res, _$VaQrisStateImpl>
    implements _$$VaQrisStateImplCopyWith<$Res> {
  __$$VaQrisStateImplCopyWithImpl(
    _$VaQrisStateImpl _value,
    $Res Function(_$VaQrisStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? taxTypes = null,
    Object? selectedTaxType = freezed,
    Object? billing = freezed,
    Object? selectedCount = null,
    Object? confirming = null,
    Object? session = freezed,
    Object? sessionStatus = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$VaQrisStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as VaQrisStatus,
        taxTypes: null == taxTypes
            ? _value._taxTypes
            : taxTypes // ignore: cast_nullable_to_non_nullable
                  as List<TaxTypeEntity>,
        selectedTaxType: freezed == selectedTaxType
            ? _value.selectedTaxType
            : selectedTaxType // ignore: cast_nullable_to_non_nullable
                  as TaxTypeEntity?,
        billing: freezed == billing
            ? _value.billing
            : billing // ignore: cast_nullable_to_non_nullable
                  as TaxBillingEntity?,
        selectedCount: null == selectedCount
            ? _value.selectedCount
            : selectedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        confirming: null == confirming
            ? _value.confirming
            : confirming // ignore: cast_nullable_to_non_nullable
                  as bool,
        session: freezed == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as PaymentSessionEntity?,
        sessionStatus: null == sessionStatus
            ? _value.sessionStatus
            : sessionStatus // ignore: cast_nullable_to_non_nullable
                  as PaymentSessionStatus,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$VaQrisStateImpl extends _VaQrisState {
  const _$VaQrisStateImpl({
    this.status = VaQrisStatus.initial,
    final List<TaxTypeEntity> taxTypes = const <TaxTypeEntity>[],
    this.selectedTaxType,
    this.billing,
    this.selectedCount = 0,
    this.confirming = false,
    this.session,
    this.sessionStatus = PaymentSessionStatus.pending,
    this.errorMessage,
  }) : _taxTypes = taxTypes,
       super._();

  @override
  @JsonKey()
  final VaQrisStatus status;
  final List<TaxTypeEntity> _taxTypes;
  @override
  @JsonKey()
  List<TaxTypeEntity> get taxTypes {
    if (_taxTypes is EqualUnmodifiableListView) return _taxTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taxTypes);
  }

  @override
  final TaxTypeEntity? selectedTaxType;
  @override
  final TaxBillingEntity? billing;

  /// Jumlah masa terlama yang dipilih (lihat PeriodSelectionLogic).
  @override
  @JsonKey()
  final int selectedCount;
  @override
  @JsonKey()
  final bool confirming;
  @override
  final PaymentSessionEntity? session;
  @override
  @JsonKey()
  final PaymentSessionStatus sessionStatus;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'VaQrisState(status: $status, taxTypes: $taxTypes, selectedTaxType: $selectedTaxType, billing: $billing, selectedCount: $selectedCount, confirming: $confirming, session: $session, sessionStatus: $sessionStatus, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaQrisStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._taxTypes, _taxTypes) &&
            (identical(other.selectedTaxType, selectedTaxType) ||
                other.selectedTaxType == selectedTaxType) &&
            (identical(other.billing, billing) || other.billing == billing) &&
            (identical(other.selectedCount, selectedCount) ||
                other.selectedCount == selectedCount) &&
            (identical(other.confirming, confirming) ||
                other.confirming == confirming) &&
            (identical(other.session, session) || other.session == session) &&
            (identical(other.sessionStatus, sessionStatus) ||
                other.sessionStatus == sessionStatus) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    const DeepCollectionEquality().hash(_taxTypes),
    selectedTaxType,
    billing,
    selectedCount,
    confirming,
    session,
    sessionStatus,
    errorMessage,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VaQrisStateImplCopyWith<_$VaQrisStateImpl> get copyWith =>
      __$$VaQrisStateImplCopyWithImpl<_$VaQrisStateImpl>(this, _$identity);
}

abstract class _VaQrisState extends VaQrisState {
  const factory _VaQrisState({
    final VaQrisStatus status,
    final List<TaxTypeEntity> taxTypes,
    final TaxTypeEntity? selectedTaxType,
    final TaxBillingEntity? billing,
    final int selectedCount,
    final bool confirming,
    final PaymentSessionEntity? session,
    final PaymentSessionStatus sessionStatus,
    final String? errorMessage,
  }) = _$VaQrisStateImpl;
  const _VaQrisState._() : super._();

  @override
  VaQrisStatus get status;
  @override
  List<TaxTypeEntity> get taxTypes;
  @override
  TaxTypeEntity? get selectedTaxType;
  @override
  TaxBillingEntity? get billing;
  @override
  /// Jumlah masa terlama yang dipilih (lihat PeriodSelectionLogic).
  int get selectedCount;
  @override
  bool get confirming;
  @override
  PaymentSessionEntity? get session;
  @override
  PaymentSessionStatus get sessionStatus;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$VaQrisStateImplCopyWith<_$VaQrisStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
