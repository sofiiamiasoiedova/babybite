import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/order_service.dart';
import 'models/order.dart';
import 'widgets/cart_item_widget.dart' show buildDietaryTags;

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);
const _kGreyText = Color(0xFF8DA5C4);
const _kGreen = Color(0xFF7AC96A);

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  /// true = came from OrderHistoryScreen (just pop back)
  /// false = came from OrderConfirmationScreen (go to home)
  final bool fromHistory;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.fromHistory = false,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    OrderService.instance.addListener(_onOrderChanged);
  }

  void _onOrderChanged() => setState(() {});

  @override
  void dispose() {
    _pulseController.dispose();
    OrderService.instance.removeListener(_onOrderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = OrderService.instance.findById(widget.orderId);
    if (order == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAF5FF),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const Expanded(
                child: Center(
                  child: Text('Order not found'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  children: [
                    _buildOrderIdCard(order),
                    const SizedBox(height: 20),
                    if (order.status != OrderStatus.cancelled)
                      _buildTimeline(order),
                    if (order.status != OrderStatus.cancelled)
                      const SizedBox(height: 20),
                    _buildCurrentStatusCard(order),
                    const SizedBox(height: 16),
                    _buildDeliveryInfoCard(order),
                    const SizedBox(height: 16),
                    _buildItemsCard(order),
                    if (order.status == OrderStatus.received) ...[
                      const SizedBox(height: 20),
                      _buildCancelButton(context, order),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.fromHistory) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/home', (route) => false);
              }
            },
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
              'Track Order',
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

  // ────────────────────────────────────────────────────────
  // ORDER ID CARD
  // ────────────────────────────────────────────────────────
  Widget _buildOrderIdCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _kSoftBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tag_rounded, color: _kPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order',
                    style: GoogleFonts.quicksand(
                        fontSize: 12, color: _kGreyText)),
                Text(
                  '#${order.orderId}',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kDarkBlue,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(order.formattedDate,
                  style: GoogleFonts.quicksand(
                      fontSize: 11, color: _kGreyText)),
              const SizedBox(height: 4),
              _statusBadge(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    final Color color = status == OrderStatus.delivered
        ? _kGreen
        : status == OrderStatus.cancelled
            ? const Color(0xFFE57373)
            : _kPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // TIMELINE
  // ────────────────────────────────────────────────────────
  Widget _buildTimeline(Order order) {
    const steps = OrderStatus.values;
    final currentIndex = order.status.index;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(),
      child: Column(
        children: List.generate(steps.length, (i) {
          final isDone = i <= currentIndex;
          final isCurrent = i == currentIndex;
          final isLast = i == steps.length - 1;
          return _timelineStep(
            status: steps[i],
            isDone: isDone,
            isCurrent: isCurrent,
            isLast: isLast,
            currentOrder: order,
          );
        }),
      ),
    );
  }

  Widget _timelineStep({
    required OrderStatus status,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
    required Order currentOrder,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle + connecting line
        Column(
          children: [
            _stepCircle(isDone: isDone, isCurrent: isCurrent,
                isDelivered: status == OrderStatus.delivered && isDone),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone && !isCurrent
                      ? _kGreen.withValues(alpha: .5)
                      : _kSoftBlue,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Text
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDone ? _kDarkBlue : _kGreyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status.sublabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: isCurrent ? _kPrimary : _kGreyText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepCircle({
    required bool isDone,
    required bool isCurrent,
    required bool isDelivered,
  }) {
    if (isDelivered) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _kGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _kGreen.withValues(alpha: .4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded,
            size: 18, color: Colors.white),
      );
    }
    if (isCurrent) {
      return ScaleTransition(
        scale: _pulseAnim,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _kPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: .45),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.radio_button_checked_rounded,
              size: 18, color: Colors.white),
        ),
      );
    }
    if (isDone) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _kGreen.withValues(alpha: .2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded,
            size: 18, color: _kGreen.withValues(alpha: .7)),
      );
    }
    // Future step
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _kSoftBlue,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.circle_outlined,
          size: 16, color: _kGreyText),
    );
  }

  // ────────────────────────────────────────────────────────
  // CURRENT STATUS CARD
  // ────────────────────────────────────────────────────────
  Widget _buildCurrentStatusCard(Order order) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final isDelivered = order.status == OrderStatus.delivered;

    final Color accent = isCancelled
        ? const Color(0xFFE57373)
        : isDelivered
            ? _kGreen
            : _kPrimary;

    final List<Color> gradientColors = isCancelled
        ? [const Color(0xFFFFF0F0), const Color(0xFFFFF5F5)]
        : isDelivered
            ? [const Color(0xFFE4F8DF), const Color(0xFFF0FBF0)]
            : [const Color(0xFFDCEEFB), const Color(0xFFEAF4FF)];

    final IconData statusIcon = isCancelled
        ? Icons.cancel_rounded
        : isDelivered
            ? Icons.check_circle_rounded
            : Icons.local_shipping_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: GoogleFonts.quicksand(
                      fontSize: 11, color: _kGreyText),
                ),
                Text(
                  order.status.label,
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                Text(
                  order.status.sublabel,
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

  // ────────────────────────────────────────────────────────
  // CANCEL BUTTON
  // ────────────────────────────────────────────────────────
  Widget _buildCancelButton(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Cancel order?',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _kDarkBlue,
              ),
            ),
            content: Text(
              'Are you sure you want to cancel order #${order.orderId}? This cannot be undone.',
              style: GoogleFonts.quicksand(
                  fontSize: 14, color: _kGreyText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Keep order',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w700, color: _kPrimary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Cancel order',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE57373)),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          OrderService.instance.cancelOrder(order.orderId);
        }
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFFCDD2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE57373).withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined,
                color: Color(0xFFE57373), size: 20),
            const SizedBox(width: 8),
            Text(
              'Cancel Order',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE57373),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // DELIVERY INFO
  // ────────────────────────────────────────────────────────
  Widget _buildDeliveryInfoCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Info',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.home_rounded, 'Address',
              '${order.address.street}, ${order.address.cityPostcode}'),
          const SizedBox(height: 8),
          _infoRow(
            order.deliveryTime.isAsap
                ? Icons.bolt_rounded
                : Icons.calendar_month_rounded,
            'Time',
            order.deliveryTime.displayLabel,
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.person_rounded, 'Recipient',
              order.address.recipientName),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _kSoftBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _kPrimary, size: 16),
        ),
        const SizedBox(width: 10),
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
  // ITEMS CARD
  // ────────────────────────────────────────────────────────
  Widget _buildItemsCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items Ordered',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.imagePath,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kDarkBlue,
                            ),
                          ),
                          buildDietaryTags(item.isHalal, item.isKosher),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('x${item.quantity}',
                        style: GoogleFonts.quicksand(
                            fontSize: 13, color: _kGreyText)),
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
                'Total',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _kDarkBlue,
                ),
              ),
              Text(
                '€${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
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

  BoxDecoration _cardDeco() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: _kPrimary.withValues(alpha: .12),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
