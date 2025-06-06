import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment_repository/payment_repository.dart';
import 'paid_invoice_screen.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        print('Current userId: ${user?.uid}'); // DEBUG: In ra userId hiện tại
        
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Bạn cần đăng nhập để xem lịch sử thanh toán.')),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lịch sử thanh toán'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('invoices')
                .where('userId', isEqualTo: user.uid)
                .where('paymentStatus', isEqualTo: 'paid')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('Lỗi: ${snapshot.error}'),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có giao dịch nào.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
                final invoices = snapshot.data!.docs;
              
              // Sort invoices by createdAt descending (newest first)
              invoices.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                
                try {
                  final aTimestamp = aData['createdAt'] as Timestamp?;
                  final bTimestamp = bData['createdAt'] as Timestamp?;
                  
                  if (aTimestamp == null && bTimestamp == null) return 0;
                  if (aTimestamp == null) return 1;
                  if (bTimestamp == null) return -1;
                  
                  return bTimestamp.compareTo(aTimestamp); // Descending order
                } catch (e) {
                  return 0; // Keep original order if comparison fails
                }
              });
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: invoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = invoices[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  try {
                    final invoice = Invoice.fromEntity(
                      InvoiceEntity.fromDocument(data),
                    );
                    
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.receipt_long, color: Colors.white),
                        ),
                        title: Text(
                          'Mã đơn: ${invoice.invoiceId.substring(0, 8)}...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng tiền: \$${invoice.totalAmount.toStringAsFixed(2)}'),
                            Text('Ngày: ${_formatDate(invoice.createdAt)}'),
                            if (invoice.vnpayTransactionCode != null)
                              Text('Mã GD: ${invoice.vnpayTransactionCode}'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaidInvoiceScreen(
                                invoiceId: invoice.invoiceId,
                                userId: invoice.userId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } catch (e) {
                    // Fallback nếu có lỗi parse data
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: const Text('Lỗi hiển thị hóa đơn'),
                        subtitle: Text('ID: ${doc.id}'),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
