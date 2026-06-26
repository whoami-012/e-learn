import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../services/payment_service.dart';
import '../../providers/enrollment_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class MockPaymentScreen extends StatefulWidget {
  final Course course;

  const MockPaymentScreen({super.key, required this.course});

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  final _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _error;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // 1. Create Order
      final order = await _paymentService.createOrder(widget.course.id);

      // Simulate network delay / UI interaction for Razorpay
      await Future.delayed(const Duration(seconds: 2));

      // 2. Verify Payment (Mock success)
      await _paymentService.verifyPayment(order.orderId, 'pay_mock_${order.orderId}');

      if (!mounted) return;

      // 3. Update Enrollment status in provider
      await context.read<EnrollmentProvider>().checkEnrollment(widget.course.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful! You are now enrolled.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true); // Return true indicating success
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Secure Checkout'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.pastelMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, size: 52, color: AppColors.success),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Checkout',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.course.title,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      '₹${widget.course.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.pastelPink,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Pay Now'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'This is a mock payment screen. No real money will be charged.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
