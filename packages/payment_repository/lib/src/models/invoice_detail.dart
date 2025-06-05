import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

/// Represents an invoice detail in the system.
class InvoiceDetail extends Equatable {
  /// Unique invoice detail ID
  final String invoiceDetailId;
  
  /// Invoice ID this detail belongs to
  final String invoiceId;
  
  /// Pizza ID
  final String pizzaId;
  
  /// Pizza name at the time of purchase
  final String pizzaName;
  
  /// Pizza price at the time of purchase
  final double pizzaPrice;
  
  /// Discount percentage at the time of purchase
  final double discount;
  
  /// Quantity ordered
  final int quantity;
  
  /// Total price for this line item
  final double totalPrice;
  
  /// When this detail was created
  final DateTime createdAt;
  
  const InvoiceDetail({
    required this.invoiceDetailId,
    required this.invoiceId,
    required this.pizzaId,
    required this.pizzaName,
    required this.pizzaPrice,
    required this.discount,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
  });

  /// An empty invoice detail used as a default value.
  static final empty = InvoiceDetail(
    invoiceDetailId: '',
    invoiceId: '',
    pizzaId: '',
    pizzaName: '',
    pizzaPrice: 0.0,
    discount: 0.0,
    quantity: 0,
    totalPrice: 0.0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Creates a copy of this invoice detail with the given fields replaced.
  InvoiceDetail copyWith({
    String? invoiceDetailId,
    String? invoiceId,
    String? pizzaId,
    String? pizzaName,
    double? pizzaPrice,
    double? discount,
    int? quantity,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return InvoiceDetail(
      invoiceDetailId: invoiceDetailId ?? this.invoiceDetailId,
      invoiceId: invoiceId ?? this.invoiceId,
      pizzaId: pizzaId ?? this.pizzaId,
      pizzaName: pizzaName ?? this.pizzaName,
      pizzaPrice: pizzaPrice ?? this.pizzaPrice,
      discount: discount ?? this.discount,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns true if this invoice detail is empty (default values).
  bool get isEmpty => invoiceDetailId.isEmpty && invoiceId.isEmpty && pizzaId.isEmpty;

  /// Returns true if this invoice detail is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Calculates the discounted unit price.
  double get discountedUnitPrice {
    return pizzaPrice - (pizzaPrice * (discount / 100));
  }

  /// Converts this invoice detail to an [InvoiceDetailEntity] for database storage.
  InvoiceDetailEntity toEntity() {
    return InvoiceDetailEntity(
      invoiceDetailId: invoiceDetailId,
      invoiceId: invoiceId,
      pizzaId: pizzaId,
      pizzaName: pizzaName,
      pizzaPrice: pizzaPrice,
      discount: discount,
      quantity: quantity,
      totalPrice: totalPrice,
      createdAt: createdAt,
    );
  }

  /// Creates an [InvoiceDetail] from an [InvoiceDetailEntity].
  static InvoiceDetail fromEntity(InvoiceDetailEntity entity) {
    return InvoiceDetail(
      invoiceDetailId: entity.invoiceDetailId,
      invoiceId: entity.invoiceId,
      pizzaId: entity.pizzaId,
      pizzaName: entity.pizzaName,
      pizzaPrice: entity.pizzaPrice,
      discount: entity.discount,
      quantity: entity.quantity,
      totalPrice: entity.totalPrice,
      createdAt: entity.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    invoiceDetailId, invoiceId, pizzaId, pizzaName, 
    pizzaPrice, discount, quantity, totalPrice, createdAt
  ];

  @override
  String toString() {
    return '''InvoiceDetail: {
      invoiceDetailId: $invoiceDetailId,
      invoiceId: $invoiceId,
      pizzaId: $pizzaId,
      pizzaName: $pizzaName,
      pizzaPrice: $pizzaPrice,
      discount: $discount,
      quantity: $quantity,
      totalPrice: $totalPrice,
      createdAt: $createdAt
    }''';
  }
}
