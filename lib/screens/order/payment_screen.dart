import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import 'models/cart_item.dart';
import 'models/delivery_address.dart';
import 'models/delivery_time.dart';
import 'order_confirmation_screen.dart';

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);
const _kGreyText = Color(0xFF8DA5C4);

class PaymentScreen extends StatefulWidget {
  final DeliveryAddress address;
  final DeliveryTime deliveryTime;

  const PaymentScreen({
    super.key,
    required this.address,
    required this.deliveryTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;

  static const _methods = [
    (icon: Icons.credit_card_rounded, label: 'Card ending in •••• 4242', sub: 'Visa'),
    (icon: Icons.smartphone_rounded, label: 'Apple Pay', sub: 'Touch ID'),
    (icon: Icons.payments_rounded, label: 'Cash on delivery', sub: 'Pay when delivered'),
  ];

  Future<void> _pay() async {
    setState(() => _isProcessing = true);
    // Simulate payment processing delay
    await Future.delayed(const Duration(milliseconds: 1400));

    final orderId =
        'BB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final total = CartService.instance.total;
    final items = List<CartItem>.from(CartService.instance.items);

    // Save order to history and start status progression
    OrderService.instance.placeOrder(
      orderId: orderId,
      items: items,
      total: total,
      address: widget.address,
      deliveryTime: widget.deliveryTime,
    );

    CartService.instance.clear();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderConfirmationScreen(
          orderId: orderId,
          items: items,
          total: total,
          address: widget.address,
          deliveryTime: widget.deliveryTime,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    _buildTotalCard(cart),
                    const SizedBox(height: 16),
                    _buildDeliveryCard(),
                    const SizedBox(height: 16),
                    _buildPaymentMethods(),
                    const SizedBox(height: 24),
                    _buildPayButton(cart),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: .2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: _kPrimary, size: 22),
            ),
          ),
          Expanded(
            child: Text(
              'Payment',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _kDarkBlue,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildTotalCard(CartService cart) {
    return _card(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _kSoftBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: _kPrimary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cart.totalCount} item${cart.totalCount != 1 ? 's' : ''}',
                  style: GoogleFonts.quicksand(
                      fontSize: 13, color: _kGreyText),
                ),
                Text(
                  'Total  €${cart.total.toStringAsFixed(2)}',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kDarkBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _kSoftBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              widget.deliveryTime.isAsap
                  ? Icons.bolt_rounded
                  : Icons.calendar_month_rounded,
              color: _kPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.address.street,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kDarkBlue,
                  ),
                ),
                Text(
                  widget.deliveryTime.displayLabel,
                  style: GoogleFonts.quicksand(
                      fontSize: 12, color: _kGreyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_methods.length, (i) {
            final m = _methods[i];
            final selected = _selectedMethod == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedMethod = i),
              child: Container(
                margin: EdgeInsets.only(bottom: i < _methods.length - 1 ? 10 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? _kPrimary.withValues(alpha: .1)
                      : const Color(0xFFF5FAFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? _kPrimary : _kSoftBlue,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(m.icon, color: _kPrimary, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.label,
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kDarkBlue,
                            ),
                          ),
                          Text(
                            m.sub,
                            style: GoogleFonts.quicksand(
                                fontSize: 12, color: _kGreyText),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? _kPrimary : _kGreyText,
                          width: 2,
                        ),
                        color:
                            selected ? _kPrimary : Colors.transparent,
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              size: 12, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPayButton(CartService cart) {
    return GestureDetector(
      onTap: _isProcessing ? null : _pay,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9BC8EE), Color(0xFF6BA4DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: .4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _isProcessing
            ? const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Pay  €${cart.total.toStringAsFixed(2)}',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: .12),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
