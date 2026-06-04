import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cart_service.dart';
import 'models/delivery_address.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/address_card.dart';
import 'checkout_screen.dart';

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);
const _kGreyText = Color(0xFF8DA5C4);

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _cart = CartService.instance;

  DeliveryAddress _address = DeliveryAddress(
    recipientName: 'Anna Johnson',
    phone: '+32 470 000 000',
    street: 'Bergstraat 32',
    cityPostcode: '1000 Brussels',
    note: '',
  );

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
  }

  void _onCartChanged() => setState(() {});

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  Future<void> _confirmDelete(String mealId, String mealName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove item?',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w800,
            color: _kDarkBlue,
          ),
        ),
        content: Text(
          'Remove "$mealName" from your cart?',
          style: GoogleFonts.quicksand(fontSize: 14, color: _kGreyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.quicksand(
                  color: _kGreyText, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: GoogleFonts.quicksand(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _cart.removeItem(mealId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    final bool isEmpty = items.isEmpty;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCCE4F7), Color(0xFFEAF4FF), Color(0xFFF5FAFF)],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10),
                    _buildCustomerCard(),
                    const SizedBox(height: 16),
                    isEmpty ? _buildEmptyCart() : _buildCartItemsCard(items),
                    if (!isEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSummaryCard(),
                      const SizedBox(height: 20),
                      _buildOrderButton(context),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: AddressCard(
              address: _address,
              onUpdate: (updated) => setState(() => _address = updated),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 44,
            child: Icon(Icons.cloud, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Text(
              'Your Cart',
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

  // ---------- CUSTOMER INFO ----------
  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _kSoftBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.face_rounded, color: _kPrimary, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anna Johnson',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kDarkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Loyal customer',
                  style:
                      GoogleFonts.quicksand(fontSize: 12, color: _kGreyText),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: _kSoftBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: _kPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  // ---------- EMPTY STATE ----------
  Widget _buildEmptyCart() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _kSoftBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: _kPrimary,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add some meals to get started!',
            style: GoogleFonts.quicksand(fontSize: 13, color: _kGreyText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------- CART ITEMS ----------
  Widget _buildCartItemsCard(List items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            CartItemWidget(
              item: items[i],
              onDelete: () => _confirmDelete(items[i].mealId, items[i].name),
              onQuantityChanged: (qty) =>
                  _cart.updateQuantity(items[i].mealId, qty),
            ),
            if (i < items.length - 1)
              const Divider(color: _kSoftBlue, height: 22, thickness: 1),
          ],
        ],
      ),
    );
  }

  // ---------- SUMMARY ----------
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _summaryRow(
              'Subtotal', '€ ${_cart.subtotal.toStringAsFixed(2)}',
              highlight: true),
          const Divider(color: _kSoftBlue, height: 22, thickness: 1),
          _summaryRow(
              'Delivery fee',
              '€ ${CartService.deliveryFee.toStringAsFixed(2)}'),
          const Divider(color: _kSoftBlue, height: 22, thickness: 1),
          _summaryRow(
              'Total', '€ ${_cart.total.toStringAsFixed(2)}',
              large: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool highlight = false, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: large ? 17 : 14,
            fontWeight: large ? FontWeight.w800 : FontWeight.w600,
            color: large ? _kDarkBlue : _kGreyText,
          ),
        ),
        if (highlight)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: .15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _kDarkBlue,
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: large ? 18 : 15,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
      ],
    );
  }

  // ---------- CHECKOUT BUTTON ----------
  Widget _buildOrderButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CheckoutScreen(initialAddress: _address),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
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
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              'Proceed to Checkout',
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

  BoxDecoration _cardDecoration() {
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
