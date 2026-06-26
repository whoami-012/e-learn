class PaymentOrder {
  final String paymentId;
  final String orderId;
  final double amount;
  final String currency;
  final String courseId;
  final String status;

  PaymentOrder({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.courseId,
    required this.status,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      paymentId: json['payment_id'],
      orderId: json['order_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      courseId: json['course_id'],
      status: json['status'],
    );
  }
}

class PaymentResult {
  final String id;
  final String userId;
  final String courseId;
  final double amount;
  final String status;
  final DateTime createdAt;

  PaymentResult({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
