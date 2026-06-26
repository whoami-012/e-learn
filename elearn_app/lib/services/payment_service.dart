import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/network/http_client.dart';
import '../models/payment.dart';

class PaymentService {
  Future<PaymentOrder> createOrder(String courseId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/payments/order/$courseId');
    final response = await ApiClient.post(url, withAuth: true);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PaymentOrder.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(response.statusCode, 'Failed to create payment order: ${response.body}');
    }
  }

  Future<PaymentResult> verifyPayment(String razorpayOrderId, String razorpayPaymentId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/payments/verify');
    final response = await ApiClient.post(url, withAuth: true, body: {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
    });

    if (response.statusCode == 200) {
      return PaymentResult.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(response.statusCode, 'Failed to verify payment: ${response.body}');
    }
  }

  Future<List<PaymentResult>> getMyPayments() async {
    final url = Uri.parse('${AppConstants.baseUrl}/payments/my');
    final response = await ApiClient.get(url, withAuth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PaymentResult.fromJson(e)).toList();
    } else {
      throw ServerException(response.statusCode, 'Failed to load payments: ${response.body}');
    }
  }
}
