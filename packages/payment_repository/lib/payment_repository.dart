/// A Flutter package for handling payment operations and invoice management.
///
/// This package provides functionality for processing payments via VNPAY,
/// managing invoices and invoice details with Firebase Firestore integration.
///
/// Main classes:
/// - [PaymentRepository]: Abstract interface for payment operations
/// - [FirebasePaymentRepository]: Firestore implementation
/// - [VNPayService]: VNPAY payment service
/// - [Invoice]: Model representing an invoice
/// - [InvoiceDetail]: Model representing invoice details
library payment_repository;

export 'src/payment_repo.dart';
export 'src/firebase_payment_repo.dart';
export 'src/vnpay_service.dart';
export 'src/models/models.dart';
export 'src/entities/entities.dart';
