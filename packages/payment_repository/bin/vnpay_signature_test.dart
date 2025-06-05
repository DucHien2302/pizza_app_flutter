import 'package:payment_repository/src/vnpay_service.dart';

void main() {
  final params = {
    "vnp_Amount": "54000000",
    "vnp_Command": "pay",
    "vnp_CreateDate": "20250605130650",
    "vnp_CurrCode": "VND",
    "vnp_IpAddr": "192.168.1.1",
    "vnp_Locale": "vn",
    "vnp_OrderInfo": "Payment for Invoice 566ae952-3c9c-433e-adfa-cd7873a2cdd2 with \$21.6",
    "vnp_OrderType": "other",
    "vnp_ReturnUrl": "pizzaapp://payment_result",
    "vnp_TmnCode": "55OPLNAE",
    "vnp_TxnRef": "566ae952-3c9c-433e-adfa-cd7873a2cdd2",
    "vnp_Version": "2.1.0"
  };
  final secretKey = '0BS1E0TQPP5Z3IU93022F64U7ROYIJY6';
  final signature = VNPaySignature.createSignature(params, secretKey);
  print('Signature: $signature');
}
