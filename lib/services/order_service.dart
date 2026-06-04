import 'dart:async';
import 'package:flutter/foundation.dart';
import '../screens/order/models/order.dart';
import '../screens/order/models/cart_item.dart';
import '../screens/order/models/delivery_address.dart';
import '../screens/order/models/delivery_time.dart';
import 'notification_service.dart';

class OrderService extends ChangeNotifier {
  static final OrderService instance = OrderService._internal();
  OrderService._internal();

  final List<Order> _orders = [];
  final Map<String, List<Timer>> _timers = {};

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> get activeOrders =>
      _orders.where((o) => !o.status.isFinal).toList();

  /// Place a new order and start auto-progressing its status.
  Order placeOrder({
    required String orderId,
    required List<CartItem> items,
    required double total,
    required DeliveryAddress address,
    required DeliveryTime deliveryTime,
  }) {
    final order = Order(
      orderId: orderId,
      items: items,
      total: total,
      address: address,
      deliveryTime: deliveryTime,
      createdAt: DateTime.now(),
      status: OrderStatus.received,
    );
    _orders.insert(0, order);
    notifyListeners();
    _startProgressTimer(orderId);
    return order;
  }

  Order? findById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  /// Cancel an order if it is still in [OrderStatus.received].
  /// Returns true if cancelled successfully.
  bool cancelOrder(String orderId) {
    final order = findById(orderId);
    if (order == null || order.status != OrderStatus.received) return false;
    _cancelTimers(orderId);
    order.status = OrderStatus.cancelled;
    notifyListeners();
    NotificationService.instance.add(
      title: 'Order Cancelled',
      body: 'Order #$orderId has been cancelled',
      orderId: orderId,
    );
    return true;
  }

  void _cancelTimers(String orderId) {
    for (final t in _timers[orderId] ?? []) {
      t.cancel();
    }
    _timers.remove(orderId);
  }

  void _updateStatus(String orderId, OrderStatus status) {
    final order = findById(orderId);
    if (order == null || order.status.isFinal) return;
    order.status = status;
    notifyListeners();
    NotificationService.instance.add(
      title: status.label,
      body: 'Order #$orderId — ${status.sublabel}',
      orderId: orderId,
    );
  }

  /// Simulated progression: Received → Preparing → Out → Delivered
  void _startProgressTimer(String orderId) {
    final t1 = Timer(const Duration(seconds: 8), () {
      _updateStatus(orderId, OrderStatus.preparing);
    });
    final t2 = Timer(const Duration(seconds: 20), () {
      _updateStatus(orderId, OrderStatus.outForDelivery);
    });
    final t3 = Timer(const Duration(seconds: 38), () {
      _updateStatus(orderId, OrderStatus.delivered);
      _timers.remove(orderId);
    });
    _timers[orderId] = [t1, t2, t3];
  }
}
