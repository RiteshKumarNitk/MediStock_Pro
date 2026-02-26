// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expiry_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExpiryAlert _$ExpiryAlertFromJson(Map<String, dynamic> json) {
  return _ExpiryAlert.fromJson(json);
}

/// @nodoc
mixin _$ExpiryAlert {
  String get tenantId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String get batchNo => throw _privateConstructorUsedError;
  DateTime get expiryDate => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  int get daysRemaining => throw _privateConstructorUsedError;

  /// Serializes this ExpiryAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpiryAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpiryAlertCopyWith<ExpiryAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpiryAlertCopyWith<$Res> {
  factory $ExpiryAlertCopyWith(
    ExpiryAlert value,
    $Res Function(ExpiryAlert) then,
  ) = _$ExpiryAlertCopyWithImpl<$Res, ExpiryAlert>;
  @useResult
  $Res call({
    String tenantId,
    String productName,
    String batchNo,
    DateTime expiryDate,
    int quantity,
    int daysRemaining,
  });
}

/// @nodoc
class _$ExpiryAlertCopyWithImpl<$Res, $Val extends ExpiryAlert>
    implements $ExpiryAlertCopyWith<$Res> {
  _$ExpiryAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpiryAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tenantId = null,
    Object? productName = null,
    Object? batchNo = null,
    Object? expiryDate = null,
    Object? quantity = null,
    Object? daysRemaining = null,
  }) {
    return _then(
      _value.copyWith(
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            batchNo: null == batchNo
                ? _value.batchNo
                : batchNo // ignore: cast_nullable_to_non_nullable
                      as String,
            expiryDate: null == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            daysRemaining: null == daysRemaining
                ? _value.daysRemaining
                : daysRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpiryAlertImplCopyWith<$Res>
    implements $ExpiryAlertCopyWith<$Res> {
  factory _$$ExpiryAlertImplCopyWith(
    _$ExpiryAlertImpl value,
    $Res Function(_$ExpiryAlertImpl) then,
  ) = __$$ExpiryAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String tenantId,
    String productName,
    String batchNo,
    DateTime expiryDate,
    int quantity,
    int daysRemaining,
  });
}

/// @nodoc
class __$$ExpiryAlertImplCopyWithImpl<$Res>
    extends _$ExpiryAlertCopyWithImpl<$Res, _$ExpiryAlertImpl>
    implements _$$ExpiryAlertImplCopyWith<$Res> {
  __$$ExpiryAlertImplCopyWithImpl(
    _$ExpiryAlertImpl _value,
    $Res Function(_$ExpiryAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpiryAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tenantId = null,
    Object? productName = null,
    Object? batchNo = null,
    Object? expiryDate = null,
    Object? quantity = null,
    Object? daysRemaining = null,
  }) {
    return _then(
      _$ExpiryAlertImpl(
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        batchNo: null == batchNo
            ? _value.batchNo
            : batchNo // ignore: cast_nullable_to_non_nullable
                  as String,
        expiryDate: null == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        daysRemaining: null == daysRemaining
            ? _value.daysRemaining
            : daysRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpiryAlertImpl implements _ExpiryAlert {
  const _$ExpiryAlertImpl({
    required this.tenantId,
    required this.productName,
    required this.batchNo,
    required this.expiryDate,
    required this.quantity,
    required this.daysRemaining,
  });

  factory _$ExpiryAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpiryAlertImplFromJson(json);

  @override
  final String tenantId;
  @override
  final String productName;
  @override
  final String batchNo;
  @override
  final DateTime expiryDate;
  @override
  final int quantity;
  @override
  final int daysRemaining;

  @override
  String toString() {
    return 'ExpiryAlert(tenantId: $tenantId, productName: $productName, batchNo: $batchNo, expiryDate: $expiryDate, quantity: $quantity, daysRemaining: $daysRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpiryAlertImpl &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.batchNo, batchNo) || other.batchNo == batchNo) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tenantId,
    productName,
    batchNo,
    expiryDate,
    quantity,
    daysRemaining,
  );

  /// Create a copy of ExpiryAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpiryAlertImplCopyWith<_$ExpiryAlertImpl> get copyWith =>
      __$$ExpiryAlertImplCopyWithImpl<_$ExpiryAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpiryAlertImplToJson(this);
  }
}

abstract class _ExpiryAlert implements ExpiryAlert {
  const factory _ExpiryAlert({
    required final String tenantId,
    required final String productName,
    required final String batchNo,
    required final DateTime expiryDate,
    required final int quantity,
    required final int daysRemaining,
  }) = _$ExpiryAlertImpl;

  factory _ExpiryAlert.fromJson(Map<String, dynamic> json) =
      _$ExpiryAlertImpl.fromJson;

  @override
  String get tenantId;
  @override
  String get productName;
  @override
  String get batchNo;
  @override
  DateTime get expiryDate;
  @override
  int get quantity;
  @override
  int get daysRemaining;

  /// Create a copy of ExpiryAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpiryAlertImplCopyWith<_$ExpiryAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
