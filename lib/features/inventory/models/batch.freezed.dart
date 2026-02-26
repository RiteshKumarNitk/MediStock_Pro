// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Batch _$BatchFromJson(Map<String, dynamic> json) {
  return _Batch.fromJson(json);
}

/// @nodoc
mixin _$Batch {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get batchNo => throw _privateConstructorUsedError;
  DateTime get expiryDate => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double? get purchasePrice => throw _privateConstructorUsedError;
  double? get mrp => throw _privateConstructorUsedError;
  double? get sellingPrice => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Batch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Batch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchCopyWith<Batch> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchCopyWith<$Res> {
  factory $BatchCopyWith(Batch value, $Res Function(Batch) then) =
      _$BatchCopyWithImpl<$Res, Batch>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String productId,
    String batchNo,
    DateTime expiryDate,
    int quantity,
    double? purchasePrice,
    double? mrp,
    double? sellingPrice,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$BatchCopyWithImpl<$Res, $Val extends Batch>
    implements $BatchCopyWith<$Res> {
  _$BatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Batch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? productId = null,
    Object? batchNo = null,
    Object? expiryDate = null,
    Object? quantity = null,
    Object? purchasePrice = freezed,
    Object? mrp = freezed,
    Object? sellingPrice = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
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
            purchasePrice: freezed == purchasePrice
                ? _value.purchasePrice
                : purchasePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            mrp: freezed == mrp
                ? _value.mrp
                : mrp // ignore: cast_nullable_to_non_nullable
                      as double?,
            sellingPrice: freezed == sellingPrice
                ? _value.sellingPrice
                : sellingPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchImplCopyWith<$Res> implements $BatchCopyWith<$Res> {
  factory _$$BatchImplCopyWith(
    _$BatchImpl value,
    $Res Function(_$BatchImpl) then,
  ) = __$$BatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String productId,
    String batchNo,
    DateTime expiryDate,
    int quantity,
    double? purchasePrice,
    double? mrp,
    double? sellingPrice,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$BatchImplCopyWithImpl<$Res>
    extends _$BatchCopyWithImpl<$Res, _$BatchImpl>
    implements _$$BatchImplCopyWith<$Res> {
  __$$BatchImplCopyWithImpl(
    _$BatchImpl _value,
    $Res Function(_$BatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Batch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? productId = null,
    Object? batchNo = null,
    Object? expiryDate = null,
    Object? quantity = null,
    Object? purchasePrice = freezed,
    Object? mrp = freezed,
    Object? sellingPrice = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$BatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
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
        purchasePrice: freezed == purchasePrice
            ? _value.purchasePrice
            : purchasePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        mrp: freezed == mrp
            ? _value.mrp
            : mrp // ignore: cast_nullable_to_non_nullable
                  as double?,
        sellingPrice: freezed == sellingPrice
            ? _value.sellingPrice
            : sellingPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchImpl implements _Batch {
  const _$BatchImpl({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.batchNo,
    required this.expiryDate,
    required this.quantity,
    this.purchasePrice,
    this.mrp,
    this.sellingPrice,
    this.createdAt,
  });

  factory _$BatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String productId;
  @override
  final String batchNo;
  @override
  final DateTime expiryDate;
  @override
  final int quantity;
  @override
  final double? purchasePrice;
  @override
  final double? mrp;
  @override
  final double? sellingPrice;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Batch(id: $id, tenantId: $tenantId, productId: $productId, batchNo: $batchNo, expiryDate: $expiryDate, quantity: $quantity, purchasePrice: $purchasePrice, mrp: $mrp, sellingPrice: $sellingPrice, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.batchNo, batchNo) || other.batchNo == batchNo) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.purchasePrice, purchasePrice) ||
                other.purchasePrice == purchasePrice) &&
            (identical(other.mrp, mrp) || other.mrp == mrp) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    productId,
    batchNo,
    expiryDate,
    quantity,
    purchasePrice,
    mrp,
    sellingPrice,
    createdAt,
  );

  /// Create a copy of Batch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchImplCopyWith<_$BatchImpl> get copyWith =>
      __$$BatchImplCopyWithImpl<_$BatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchImplToJson(this);
  }
}

abstract class _Batch implements Batch {
  const factory _Batch({
    required final String id,
    required final String tenantId,
    required final String productId,
    required final String batchNo,
    required final DateTime expiryDate,
    required final int quantity,
    final double? purchasePrice,
    final double? mrp,
    final double? sellingPrice,
    final DateTime? createdAt,
  }) = _$BatchImpl;

  factory _Batch.fromJson(Map<String, dynamic> json) = _$BatchImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get productId;
  @override
  String get batchNo;
  @override
  DateTime get expiryDate;
  @override
  int get quantity;
  @override
  double? get purchasePrice;
  @override
  double? get mrp;
  @override
  double? get sellingPrice;
  @override
  DateTime? get createdAt;

  /// Create a copy of Batch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchImplCopyWith<_$BatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
