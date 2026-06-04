import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/order_service.dart';
import 'models/order.dart';
import 'order_tracking_screen.dart';

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);
const _kGreyText = Color(0xFF8DA5C4);
const _kGreen = Color(0xFF7AC96A);
const _kRed = Color(0xFFE57373);

// ────────────────────────────────────────────────────────
// TAB DEFINITION
// ────────────────────────────────────────────────────────
enum _Tab {
  all,
  active,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case _Tab.all:
        return 'All';
      case _Tab.active:
        return 'Active';
      case _Tab.delivered:
        return 'Delivered';
      case _Tab.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case _Tab.all:
        return Icons.receipt_long_rounded;
      case _Tab.active:
        return Icons.local_shipping_rounded;
      case _Tab.delivered:
        return Icons.check_circle_rounded;
      case _Tab.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case _Tab.all:
        return _kPrimary;
      case _Tab.active:
        return _kPrimary;
      case _Tab.delivered:
        return _kGreen;
      case _Tab.cancelled:
        return _kRed;
    }
  }

  bool matches(OrderStatus status) {
    switch (this) {
      case _Tab.all:
        return true;
      case _Tab.active:
        return !status.isFinal;
      case _Tab.delivered:
        return status == OrderStatus.delivered;
      case _Tab.cancelled:
        return status == OrderStatus.cancelled;
    }
  }
}

// ────────────────────────────────────────────────────────
// SCREEN
// ────────────────────────────────────────────────────────
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _Tab.values.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    OrderService.instance.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _tabController.dispose();
    OrderService.instance.removeListener(_onChanged);
    super.dispose();
  }

  List<Order> _filtered(_Tab tab) {
    return OrderService.instance.orders
        .where((o) => tab.matches(o.status))
        .toList();
  }

  int _countFor(_Tab tab) => _filtered(tab).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 14),
            _buildTabBar(),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _Tab.values
                    .map((tab) => _OrderList(
                          orders: _filtered(tab),
                          tab: tab,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
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
              'My Orders',
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

  // ── TAB BAR ─────────────────────────────────────────────
  Widget _buildTabBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _Tab.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tab = _Tab.values[i];
          final isSelected = _tabController.index == i;
          final count = _countFor(tab);
          return _TabChip(
            tab: tab,
            isSelected: isSelected,
            count: count,
            onTap: () => _tabController.animateTo(i),
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// TAB CHIP
// ────────────────────────────────────────────────────────
class _TabChip extends StatelessWidget {
  final _Tab tab;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _TabChip({
    required this.tab,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = tab.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : _kSoftBlue,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: .3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 15,
              color: isSelected ? Colors.white : _kGreyText,
            ),
            const SizedBox(width: 6),
            Text(
              tab.label,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _kGreyText,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: .3)
                      : color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// ORDER LIST (per tab)
// ────────────────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final _Tab tab;

  const _OrderList({required this.orders, required this.tab});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return _buildEmpty();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
    );
  }

  Widget _buildEmpty() {
    final color = tab.color;
    final (String title, String sub) = switch (tab) {
      _Tab.all => ('No orders yet', 'Place your first meal order for your little one!'),
      _Tab.active => ('No active orders', 'Your ongoing orders will appear here'),
      _Tab.delivered => ('No delivered orders', 'Completed orders will appear here'),
      _Tab.cancelled => ('No cancelled orders', 'Cancelled orders will appear here'),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(tab.icon, size: 38, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              sub,
              style: GoogleFonts.quicksand(fontSize: 13, color: _kGreyText),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// ORDER CARD
// ────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancelled = order.status == OrderStatus.cancelled;
    final statusColor = isDelivered
        ? _kGreen
        : isCancelled
            ? _kRed
            : _kPrimary;

    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isCancelled
                        ? Icons.cancel_rounded
                        : isDelivered
                            ? Icons.check_circle_rounded
                            : Icons.receipt_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderId}',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _kDarkBlue,
                        ),
                      ),
                      Text(
                        order.formattedDate,
                        style: GoogleFonts.quicksand(
                            fontSize: 12, color: _kGreyText),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),
          // Items preview
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                SizedBox(
                  height: 36,
                  width: _stackWidth(order.items.length),
                  child: Stack(
                    children: [
                      for (int i = 0;
                          i < order.items.length && i < 3;
                          i++)
                        Positioned(
                          left: i * 22.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              order.items[i].imagePath,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.items.length == 1
                        ? order.items.first.name
                        : '${order.items.first.name} +${order.items.length - 1}',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kGreyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '€${order.total.toStringAsFixed(2)}',
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _kDarkBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _kSoftBlue),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, _) =>
                        OrderTrackingScreen(
                            orderId: order.orderId, fromHistory: true),
                    transitionsBuilder:
                        (context, animation, _, child) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCancelled
                          ? Icons.cancel_outlined
                          : isDelivered
                              ? Icons.visibility_rounded
                              : Icons.local_shipping_rounded,
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCancelled || isDelivered ? 'View Details' : 'Track Order',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _stackWidth(int count) {
    final n = count.clamp(1, 3);
    return 36.0 + (n - 1) * 22.0;
  }
}

// ────────────────────────────────────────────────────────
// STATUS BADGE
// ────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDelivered = status == OrderStatus.delivered;
    final isCancelled = status == OrderStatus.cancelled;
    final color = isDelivered
        ? _kGreen
        : isCancelled
            ? _kRed
            : _kPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
