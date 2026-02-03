import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/coupon_service.dart';
import '../../core/models/coupon_model.dart';

class CouponRedemptionTimerScreen extends StatefulWidget {
  final Coupon coupon;
  final String userId;
  final CouponRedemption redemption;

  const CouponRedemptionTimerScreen({
    super.key,
    required this.coupon,
    required this.userId,
    required this.redemption,
  });

  @override
  State<CouponRedemptionTimerScreen> createState() =>
      _CouponRedemptionTimerScreenState();
}

class _CouponRedemptionTimerScreenState
    extends State<CouponRedemptionTimerScreen> {
  late Timer _timer;
  late Duration _remainingTime;
  bool _hasExpired = false;
  bool _isRedeemed = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final expiryTime = widget.redemption.expiresAt!;

    if (now.isAfter(expiryTime)) {
      _remainingTime = Duration.zero;
      _hasExpired = true;
    } else {
      _remainingTime = expiryTime.difference(now);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);

        if (_remainingTime <= Duration.zero) {
          _hasExpired = true;
          _timer.cancel();
        }
      });
    });
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmRedemption() async {
    if (_remainingTime <= Duration.zero) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Time expired!')));
      return;
    }

    setState(() {
      _isRedeemed = true;
    });

    try {
      final success = await CouponService.confirmRedemption(
        couponId: widget.coupon.id,
        redemptionId: widget.redemption.id,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Coupon redeemed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Wait 2 seconds then navigate back
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isRedeemed = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to redeem coupon'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRedeemed = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isRedeemed && !_hasExpired) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancel Redemption'),
              content: const Text('Are you sure you want to cancel?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          return confirm ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Redeem Coupon'),
          automaticallyImplyLeading: !_isRedeemed,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_hasExpired)
                  _buildExpiredView()
                else if (_isRedeemed)
                  _buildSuccessView()
                else
                  _buildTimerView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 4),
          ),
          child: Text(
            _formatTime(_remainingTime),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          widget.coupon.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Code: ${widget.coupon.code}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.coupon.discount}% OFF',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child: const Text(
            'The vendor has 3 minutes to confirm the redemption. If they don\'t confirm within this time, the coupon will be returned to you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: _confirmRedemption,
            child: const Text(
              'Waiting for Vendor Confirmation...',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiredView() {
    return Column(
      children: [
        const Icon(Icons.timer_off, size: 80, color: Colors.red),
        const SizedBox(height: 24),
        const Text(
          'Time Expired',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'The 3-minute window has expired.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.coupon.title} has been returned to your available coupons.',
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'Coupon Redeemed!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.coupon.discount}% OFF at ${widget.coupon.title}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        const Text('Returning to home...'),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
