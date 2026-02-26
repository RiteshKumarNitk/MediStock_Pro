// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SalesInvoice _$SalesInvoiceFromJson(Map<String, dynamic> json) {
  return _SalesInvoice.fromJson(json);
}

/// @nodoc
mixin _$SalesInvoice {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get invoiceNumber => throw _privateConstructorUsedError;
  String? get customerName => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  double get taxAmount => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  String get paymentMode =>
      throw _privateConstructorUsedError; // cash, card, upi
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SalesInvoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesInvoiceCopyWith<SalesInvoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesInvoiceCopyWith<$Res> {
  factory $SalesInvoiceCopyWith(
    SalesInvoice value,
    $Res Function(SalesInvoice) then,
  ) = _$SalesInvoiceCopyWithImpl<$Res, SalesInvoice>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String invoiceNumber,
    String? customerName,
    String? customerPhone,
    double totalAmount,
    double taxAmount,
    double discountAmount,
    String paymentMode,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$SalesInvoiceCopyWithImpl<$Res, $Val extends SalesInvoice>
    implements $SalesInvoiceCopyWith<$Res> {
  _$SalesInvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? invoiceNumber = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? totalAmount = null,
    Object? taxAmount = null,
    Object? discountAmount = null,
    Object? paymentMode = null,
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
            invoiceNumber: null == invoiceNumber
                ? _value.invoiceNumber
                : invoiceNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerPhone: freezed == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            taxAmount: null == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentMode: null == paymentMode
                ? _value.paymentMode
                : paymentMode // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$SalesInvoiceImplCopyWith<$Res>
    implements $SalesInvoiceCopyWith<$Res> {
  factory _$$SalesInvoiceImplCopyWith(
    _$SalesInvoiceImpl value,
    $Res Function(_$SalesInvoiceImpl) then,
  ) = __$$SalesInvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String invoiceNumber,
    String? customerName,
    String? customerPhone,
    double totalAmount,
    double taxAmount,
    double discountAmount,
    String paymentMode,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$SalesInvoiceImplCopyWithImpl<$Res>
    extends _$SalesInvoiceCopyWithImpl<$Res, _$SalesInvoiceImpl>
    implements _$$SalesInvoiceImplCopyWith<$Res> {
  __$$SalesInvoiceImplCopyWithImpl(
    _$SalesInvoiceImpl _value,
    $Res Function(_$SalesInvoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? invoiceNumber = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? totalAmount = null,
    Object? taxAmount = null,
    Object? discountAmount = null,
    Object? paymentMode = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$SalesInvoiceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        invoiceNumber: null == invoiceNumber
            ? _value.invoiceNumber
            : invoiceNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerPhone: freezed == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        taxAmount: null == taxAmount
            ? _value.taxAmount
            : taxAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentMode: null == paymentMode
            ? _value.paymentMode
            : paymentMode // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$SalesInvoiceImpl implements _SalesInvoice {
  const _$SalesInvoiceImpl({
    required this.id,
    required this.tenantId,
    required this.invoiceNumber,
    this.customerName,
    this.customerPhone,
    required this.totalAmount,
    required this.taxAmount,
    this.discountAmount = 0.0,
    required this.paymentMode,
    this.createdAt,
  });

  factory _$SalesInvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesInvoiceImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String invoiceNumber;
  @override
  final String? customerName;
  @override
  final String? customerPhone;
  @override
  final double totalAmount;
  @override
  final double taxAmount;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  final String paymentMode;
  // cash, card, upi
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'SalesInvoice(id: $id, tenantId: $tenantId, invoiceNumber: $invoiceNumber, customerName: $customerName, customerPhone: $customerPhone, totalAmount: $totalAmount, taxAmount: $taxAmount, discountAmount: $discountAmount, paymentMode: $paymentMode, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesInvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    invoiceNumber,
    customerName,
    customerPhone,
    totalAmount,
    taxAmount,
    discountAmount,
    paymentMode,
    createdAt,
  );

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesInvoiceImplCopyWith<_$SalesInvoiceImpl> get copyWith =>
      __$$SalesInvoiceImplCopyWithImpl<_$SalesInvoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesInvoiceImplToJson(this);
  }
}

abstract class _SalesInvoice implements SalesInvoice {
  const factory _SalesInvoice({
    required final String id,
    required final String tenantId,
    required final String invoiceNumber,
    final String? customerName,
    final String? customerPhone,
    required final double totalAmount,
    required final double taxAmount,
    final double discountAmount,
    required final String paymentMode,
    final DateTime? createdAt,
  }) = _$SalesInvoiceImpl;

  factory _SalesInvoice.fromJson(Map<String, dynamic> json) =
      _$SalesInvoiceImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get invoiceNumber;
  @override
  String? get customerName;
  @override
  String? get customerPhone;
  @override
  double get totalAmount;
  @override
  double get taxAmount;
  @override
  double get discountAmount;
  @override
  String get paymentMode; // cash, card, upi
  @override
  DateTime? get createdAt;

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesInvoiceImplCopyWith<_$SalesInvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SalesItem _$SalesItemFromJson(Map<String, dynamic> json) {
  return _SalesItem.fromJson(json);
}

/// @nodoc
mixin _$SalesItem {
  String get id => throw _privateConstructorUsedError;
  String get invoiceId => throw _privateConstructorUsedError;
  String get batchId => throw _privateConstructorUsedError;
  int get qty => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get taxableValue => throw _privateConstructorUsedError;
  double get cgst => throw _privateConstructorUsedError;
  double get sgst => throw _privateConstructorUsedError;
  double get igst => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SalesItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalesItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesItemCopyWith<SalesItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesItemCopyWith<$Res> {
  factory $SalesItemCopyWith(SalesItem value, $Res Function(SalesItem) then) =
      _$SalesItemCopyWithImpl<$Res, SalesItem>;
  @useResult
  $Res call({
    String id,
    String invoiceId,
    String batchId,
    int qty,
    double unitPrice,
    double taxableValue,
    double cgst,
    double sgst,
    double igst,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$SalesItemCopyWithImpl<$Res, $Val extends SalesItem>
    implements $SalesItemCopyWith<$Res> {
  _$SalesItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceId = null,
    Object? batchId = null,
    Object? qty = null,
    Object? unitPrice = null,
    Object? taxableValue = null,
    Object? cgst = null,
    Object? sgst = null,
    Object? igst = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            invoiceId: null == invoiceId
                ? _value.invoiceId
                : invoiceId // ignore: cast_nullable_to_non_nullable
                      as String,
            batchId: null == batchId
                ? _value.batchId
                : batchId // ignore: cast_nullable_to_non_nullable
                      as String,
            qty: null == qty
                ? _value.qty
                : qty // ignore: cast_nullable_to_non_nullable
                      as int,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            taxableValue: null == taxableValue
                ? _value.taxableValue
                : taxableValue // ignore: cast_nullable_to_non_nullable
                      as double,
            cgst: null == cgst
                ? _value.cgst
                : cgst // ignore: cast_nullable_to_non_nullable
                      as double,
            sgst: null == sgst
                ? _value.sgst
                : sgst // ignore: cast_nullable_to_non_nullable
                      as double,
            igst: null == igst
                ? _value.igst
                : igst // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$SalesItemImplCopyWith<$Res>
    implements $SalesItemCopyWith<$Res> {
  factory _$$SalesItemImplCopyWith(
    _$SalesItemImpl value,
    $Res Function(_$SalesItemImpl) then,
  ) = __$$SalesItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String invoiceId,
    String batchId,
    int qty,
    double unitPrice,
    double taxableValue,
    double cgst,
    double sgst,
    double igst,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$SalesItemImplCopyWithImpl<$Res>
    extends _$SalesItemCopyWithImpl<$Res, _$SalesItemImpl>
    implements _$$SalesItemImplCopyWith<$Res> {
  __$$SalesItemImplCopyWithImpl(
    _$SalesItemImpl _value,
    $Res Function(_$SalesItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceId = null,
    Object? batchId = null,
    Object? qty = null,
    Object? unitPrice = null,
    Object? taxableValue = null,
    Object? cgst = null,
    Object? sgst = null,
    Object? igst = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$SalesItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        invoiceId: null == invoiceId
            ? _value.invoiceId
            : invoiceId // ignore: cast_nullable_to_non_nullable
                  as String,
        batchId: null == batchId
            ? _value.batchId
            : batchId // ignore: cast_nullable_to_non_nullable
                  as String,
        qty: null == qty
            ? _value.qty
            : qty // ignore: cast_nullable_to_non_nullable
                  as int,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        taxableValue: null == taxableValue
            ? _value.taxableValue
            : taxableValue // ignore: cast_nullable_to_non_nullable
                  as double,
        cgst: null == cgst
            ? _value.cgst
            : cgst // ignore: cast_nullable_to_non_nullable
                  as double,
        sgst: null == sgst
            ? _value.sgst
            : sgst // ignore: cast_nullable_to_non_nullable
                  as double,
        igst: null == igst
            ? _value.igst
            : igst // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$SalesItemImpl implements _SalesItem {
  const _$SalesItemImpl({
    required this.id,
    required this.invoiceId,
    required this.batchId,
    required this.qty,
    required this.unitPrice,
    required this.taxableValue,
    this.cgst = 0.0,
    this.sgst = 0.0,
    this.igst = 0.0,
    this.createdAt,
  });

  factory _$SalesItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesItemImplFromJson(json);

  @override
  final String id;
  @override
  final String invoiceId;
  @override
  final String batchId;
  @override
  final int qty;
  @override
  final double unitPrice;
  @override
  final double taxableValue;
  @override
  @JsonKey()
  final double cgst;
  @override
  @JsonKey()
  final double sgst;
  @override
  @JsonKey()
  final double igst;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'SalesItem(id: $id, invoiceId: $invoiceId, batchId: $batchId, qty: $qty, unitPrice: $unitPrice, taxableValue: $taxableValue, cgst: $cgst, sgst: $sgst, igst: $igst, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.taxableValue, taxableValue) ||
                other.taxableValue == taxableValue) &&
            (identical(other.cgst, cgst) || other.cgst == cgst) &&
            (identical(other.sgst, sgst) || other.sgst == sgst) &&
            (identical(other.igst, igst) || other.igst == igst) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    invoiceId,
    batchId,
    qty,
    unitPrice,
    taxableValue,
    cgst,
    sgst,
    igst,
    createdAt,
  );

  /// Create a copy of SalesItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesItemImplCopyWith<_$SalesItemImpl> get copyWith =>
      __$$SalesItemImplCopyWithImpl<_$SalesItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesItemImplToJson(this);
  }
}

abstract class _SalesItem implements SalesItem {
  const factory _SalesItem({
    required final String id,
    required final String invoiceId,
    required final String batchId,
    required final int qty,
    required final double unitPrice,
    required final double taxableValue,
    final double cgst,
    final double sgst,
    final double igst,
    final DateTime? createdAt,
  }) = _$SalesItemImpl;

  factory _SalesItem.fromJson(Map<String, dynamic> json) =
      _$SalesItemImpl.fromJson;

  @override
  String get id;
  @override
  String get invoiceId;
  @override
  String get batchId;
  @override
  int get qty;
  @override
  double get unitPrice;
  @override
  double get taxableValue;
  @override
  double get cgst;
  @override
  double get sgst;
  @override
  double get igst;
  @override
  DateTime? get createdAt;

  /// Create a copy of SalesItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesItemImplCopyWith<_$SalesItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
