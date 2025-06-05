import 'dart:convert';
import 'package:crypto/crypto.dart';

class VNPayConfig {
  final String version;
  final String command;
  final String currCode;
  final String locale;
  final String orderType;
  final String tmnCode;
  final String hashSecret;
  final String url;

  const VNPayConfig({
    required this.version,
    required this.command,
    required this.currCode,
    required this.locale,
    required this.orderType,
    required this.tmnCode,
    required this.hashSecret,
    required this.url,
  });
}

class VNPayService {
  final VNPayConfig config;
  VNPayService({required this.config});

  /// Tạo URL thanh toán VNPAY
  String createPaymentUrl({
    required String orderId,
    required double amount, // USD (sẽ đổi sang VND với 1 USD = 25,000 VND)
    required String orderInfo,
    required String returnUrl,
    String ipAddress = "192.168.1.1",
    DateTime? createDate,
  }) {
    final now = createDate ?? DateTime.now();
    final vnpCreateDate = _formatDate(now);
    final params = <String, String>{
      'vnp_Amount': (amount * 25000 * 100).toInt().toString(),
      'vnp_Command': config.command,
      'vnp_CreateDate': vnpCreateDate,
      'vnp_CurrCode': config.currCode,
      'vnp_IpAddr': ipAddress,
      'vnp_Locale': config.locale,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': config.orderType,
      'vnp_ReturnUrl': returnUrl,
      'vnp_TmnCode': config.tmnCode,
      'vnp_TxnRef': orderId,
      'vnp_Version': config.version,
    };

    // Tạo chữ ký VNPAY với logic đúng chuẩn
    final secureHash = VNPaySignature.createSignature(params, config.hashSecret);

    // Build query string cho URL: có encode
    final sortedKeys = params.keys.toList()..sort();
    final queryStringForUrl = sortedKeys
        .map((key) => '$key=${Uri.encodeQueryComponent(params[key]!)}')
        .join('&');

    // Build URL cuối cùng
    final paymentUrl = '${config.url}?$queryStringForUrl&vnp_SecureHash=$secureHash';

    return paymentUrl;
  }

  /// Validate response từ VNPAY
  bool validateResponse(Map<String, String> vnpParams) {
    try {
      final receivedHash = vnpParams['vnp_SecureHash'];
      if (receivedHash == null || receivedHash.isEmpty) return false;

      // Remove vnp_SecureHash và vnp_SecureHashType nếu có
      final params = Map<String, String>.from(vnpParams)
        ..remove('vnp_SecureHash')
        ..remove('vnp_SecureHashType');

      // Sử dụng VNPaySignature để verify chữ ký
      return VNPaySignature.verifySignature(params, config.hashSecret, receivedHash);
    } catch (e) {
      print('Error validating VNPay response: $e');
      return false;
    }
  }

  /// Format ngày theo yyyyMMddHHmmss
  static String _formatDate(DateTime dt) {
    // Đảm bảo lấy giờ theo múi giờ Việt Nam (UTC+7)
    final vnTime = dt.toUtc().add(const Duration(hours: 7));
    return '${vnTime.year.toString().padLeft(4, '0')}'
        '${vnTime.month.toString().padLeft(2, '0')}'
        '${vnTime.day.toString().padLeft(2, '0')}'
        '${vnTime.hour.toString().padLeft(2, '0')}'
        '${vnTime.minute.toString().padLeft(2, '0')}'
        '${vnTime.second.toString().padLeft(2, '0')}';
  }
}

// Class helper để tạo chữ ký VNPAY (có thể tái sử dụng)
class VNPaySignature {
  static String _quotePlus(String input) {
    // Encode giống quote_plus của Python
    return Uri.encodeQueryComponent(input).replaceAll('%20', '+');
  }

  static String createSignature(Map<String, String> params, String secretKey) {
    // Sắp xếp các tham số theo thứ tự alphabet
    var sortedKeys = params.keys.toList()..sort();
    
    // Tạo chuỗi query string với quote_plus
    List<String> queryParts = [];
    for (String key in sortedKeys) {
      String encodedValue = _quotePlus(params[key]!);
      queryParts.add('$key=$encodedValue');
    }
    String data = queryParts.join('&');
    
    // Tạo chữ ký HMAC SHA512
    var keyBytes = utf8.encode(secretKey);
    var bytes = utf8.encode(data);
    var hmacSha512 = Hmac(sha512, keyBytes);
    var digest = hmacSha512.convert(bytes);
    
    return digest.toString();
  }
  
  static bool verifySignature(Map<String, String> params, String secretKey, String signature) {
    String calculatedSignature = createSignature(params, secretKey);
    return calculatedSignature.toLowerCase() == signature.toLowerCase();
  }
}
