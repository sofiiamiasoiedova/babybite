import 'cart_item.dart';
import 'delivery_address.dart';
import 'delivery_time.dart';

enum OrderStatus {
  received,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.received:
        return 'Order Received';
      case OrderStatus.preparing:
        return 'Preparing Food';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get sublabel {
    switch (this) {
      case OrderStatus.received:
        return 'Your order has been confirmed';
      case OrderStatus.preparing:
        return 'Our kitchen is preparing your baby\'s meal';
      case OrderStatus.outForDelivery:
        return 'Your order is on the way';
      case OrderStatus.delivered:
        return 'Enjoy your meal!';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
    }
  }

  int get index {
    switch (this) {
      case OrderStatus.received:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isFinal =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}

class Order {
  final String orderId;
  final List<CartItem> items;
  final double total;
  final DeliveryAddress address;
  final DeliveryTime deliveryTime;
  final DateTime createdAt;
  OrderStatus status;

  Order({
    required this.orderId,
    required this.items,
    required this.total,
    required this.address,
    required this.deliveryTime,
    required this.createdAt,
    this.status = OrderStatus.received,
  });

  String get formattedDate {
    final d = createdAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
