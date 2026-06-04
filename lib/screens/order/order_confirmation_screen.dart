import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/cart_item.dart';
import 'models/delivery_address.dart';
import 'models/delivery_time.dart';
import 'order_tracking_screen.dart';

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);
const _kGreyText = Color(0xFF8DA5C4);
const _kGreen = Color(0xFF7AC96A);

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final List<CartItem> items;
  final double total;
  final DeliveryAddress address;
  final DeliveryTime deliveryTime;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.items,
    required this.total,
    required this.address,
    required this.deliveryTime,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _trackOrder() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) =>
            OrderTrackingScreen(orderId: widget.orderId),
        transitionsBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _backToHome() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              _buildSuccessHero(),
              const SizedBox(height: 24),
              _buildOrderIdCard(),
              const SizedBox(height: 16),
              _buildItemsCard(),
              const SizedBox(height: 16),
              _buildDeliveryCard(),
              const SizedBox(height: 28),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // SUCCESS HERO
  // ────────────────────────────────────────────────────────
  Widget _buildSuccessHero() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: _kGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order Confirmed!',
            style: GoogleFonts.fredoka(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your baby meal is being prepared',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              color: _kGreyText,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // ORDER ID CARD
  // ────────────────────────────────────────────────────────
  Widget _buildOrderIdCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _kSoftBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.tag_rounded, color: _kPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID',
                  style: GoogleFonts.quicksand(
                      fontSize: 12, color: _kGreyText),
                ),
                Text(
                  '#${widget.orderId}',
                  style: GoogleFonts.quicksand(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kDarkBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Confirmed',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // ITEMS + TOTAL CARD
  // ────────────────────────────────────────────────────────
  Widget _buildItemsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.imagePath,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kDarkBlue,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: GoogleFonts.quicksand(
                          fontSize: 13, color: _kGreyText),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.totalPriceLabel,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _kDarkBlue,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(color: _kSoftBlue, height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total paid',
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _kDarkBlue,
                ),
              ),
              Text(
                '€${widget.total.toStringAsFixed(2)}',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // DELIVERY CARD
  // ────────────────────────────────────────────────────────
  Widget _buildDeliveryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Info',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.home_rounded,
            'Address',
            '${widget.address.street}, ${widget.address.cityPostcode}',
          ),
          const SizedBox(height: 10),
          _infoRow(
            widget.deliveryTime.isAsap
                ? Icons.bolt_rounded
                : Icons.calendar_month_rounded,
            'Delivery',
            widget.deliveryTime.displayLabel,
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.person_rounded,
            'Recipient',
            '${widget.address.recipientName}  •  ${widget.address.phone}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _kSoftBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _kPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.quicksand(
                      fontSize: 11, color: _kGreyText)),
              Text(
                value,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kDarkBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // ACTION BUTTONS
  // ────────────────────────────────────────────────────────
  Widget _buildBackButton() {
    return Column(
      children: [
        // Track Order
        GestureDetector(
          onTap: _trackOrder,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Track Order',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Back to Home
        GestureDetector(
          onTap: _backToHome,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFCCE4F7)),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: .12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_rounded, color: _kPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Back to Home',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kDarkBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
