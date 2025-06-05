import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payment_repository/payment_repository.dart';

class PaidInvoiceScreen extends StatelessWidget {
  final String invoiceId;
  final String userId;
  const PaidInvoiceScreen({super.key, required this.invoiceId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thanh toán'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Information
            _buildInvoiceInfo(),
            const SizedBox(height: 20),
            
            // VNPAY Response Information
            _buildVNPayInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceInfo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('invoices')
          .doc(invoiceId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Không tìm thấy thông tin hóa đơn'),
            ),
          );
        }

        final invoiceData = snapshot.data!.data() as Map<String, dynamic>;
        final invoice = Invoice.fromEntity(InvoiceEntity.fromDocument(invoiceData));

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông tin hóa đơn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(),
                _buildInfoRow('Mã hóa đơn:', invoice.invoiceId),
                _buildInfoRow('Tổng tiền:', '\$${invoice.totalAmount.toStringAsFixed(2)}'),
                _buildInfoRow('Tương đương:', '₫${(invoice.totalAmount * 25000).toStringAsFixed(0)}'),
                _buildInfoRow('Trạng thái:', invoice.paymentStatus.toUpperCase()),
                _buildInfoRow('Phương thức:', invoice.paymentMethod),
                _buildInfoRow('Ngày tạo:', _formatDateTime(invoice.createdAt)),
                _buildInfoRow('Cập nhật:', _formatDateTime(invoice.updatedAt)),
              ],
            ),
          ),
        );
      },
    );
  }  Widget _buildVNPayInfo() {
    print('PaidInvoiceScreen - Looking for VNPay data with invoiceId: $invoiceId, userId: $userId');
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vn_payment_responses')
          .doc(invoiceId)
          .snapshots(),
      builder: (context, snapshot) {
        print('PaidInvoiceScreen - StreamBuilder state: ${snapshot.connectionState}');
        print('PaidInvoiceScreen - Has data: ${snapshot.hasData}');
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          print('PaidInvoiceScreen - Doc data: $data');
        }
        if (snapshot.hasError) {
          print('PaidInvoiceScreen - Error: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Không tìm thấy thông tin VNPAY'),
                  const SizedBox(height: 8),
                  Text('Invoice ID: $invoiceId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('User ID: $userId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        }        final data = snapshot.data!.data() as Map<String, dynamic>;
        final vnpResponseRaw = data['vnpResponse'];
        Map<String, dynamic> vnpResponse = {};
        
        if (vnpResponseRaw is Map<String, dynamic>) {
          vnpResponse = vnpResponseRaw;
        } else if (vnpResponseRaw is Map) {
          vnpResponse = Map<String, dynamic>.from(vnpResponseRaw);
        }

        if (vnpResponse.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Không có dữ liệu phản hồi từ VNPAY.'),
            ),
          );
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông tin VNPAY',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(),
                _buildVNPayInfoRows(vnpResponse),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVNPayInfoRows(Map<String, dynamic> vnpResponse) {
    final importantFields = {
      'vnp_TransactionNo': 'Mã giao dịch',
      'vnp_BankCode': 'Ngân hàng',
      'vnp_CardType': 'Loại thẻ',
      'vnp_Amount': 'Số tiền (VND)',
      'vnp_OrderInfo': 'Thông tin đơn hàng',
      'vnp_PayDate': 'Thời gian thanh toán',
      'vnp_ResponseCode': 'Mã phản hồi',
      'vnp_TransactionStatus': 'Trạng thái giao dịch',
    };

    return Column(
      children: [
        // Important fields first
        ...importantFields.entries.map((entry) {
          final value = vnpResponse[entry.key];
          if (value != null) {
            String displayValue = value.toString();
            
            // Format specific fields
            if (entry.key == 'vnp_Amount') {
              final amount = int.tryParse(displayValue) ?? 0;
              displayValue = '₫${(amount / 100).toStringAsFixed(0)}';
            } else if (entry.key == 'vnp_PayDate') {
              displayValue = _formatVNPayDate(displayValue);
            } else if (entry.key == 'vnp_ResponseCode') {
              displayValue = '$displayValue (${_getResponseCodeDescription(displayValue)})';
            }
            
            return _buildInfoRow(entry.value, displayValue);
          }
          return const SizedBox.shrink();
        }).toList(),
        
        const SizedBox(height: 16),
        
        // Expandable section for all fields
        ExpansionTile(
          title: const Text('Xem tất cả thông tin VNPAY'),
          children: vnpResponse.entries
              .where((entry) => !importantFields.containsKey(entry.key))
              .map((entry) => _buildInfoRow(entry.key, entry.value.toString()))
              .toList(),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatVNPayDate(String vnpDate) {
    if (vnpDate.length == 14) {
      // Format: yyyyMMddHHmmss
      final year = vnpDate.substring(0, 4);
      final month = vnpDate.substring(4, 6);
      final day = vnpDate.substring(6, 8);
      final hour = vnpDate.substring(8, 10);
      final minute = vnpDate.substring(10, 12);
      final second = vnpDate.substring(12, 14);
      return '$day/$month/$year $hour:$minute:$second';
    }
    return vnpDate;
  }

  String _getResponseCodeDescription(String code) {
    switch (code) {
      case '00':
        return 'Thành công';
      case '07':
        return 'Trừ tiền thành công';
      case '09':
        return 'Thẻ/Tài khoản không đúng';
      case '10':
        return 'Thẻ/Tài khoản không đúng quá 3 lần';
      case '11':
        return 'Đã hết hạn chờ thanh toán';
      case '12':
        return 'Thẻ/Tài khoản bị khóa';
      case '13':
        return 'Sai mật khẩu';
      case '24':
        return 'Khách hàng hủy giao dịch';
      case '51':
        return 'Tài khoản không đủ số dư';
      case '65':
        return 'Tài khoản vượt quá hạn mức';
      case '75':
        return 'Ngân hàng bảo trì';
      case '79':
        return 'Sai mật khẩu quá số lần';
      case '99':
        return 'Lỗi không xác định';
      default:
        return 'Không xác định';
    }
  }
}
