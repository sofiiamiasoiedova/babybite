import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cart_service.dart';
import 'widgets/cart_item_widget.dart' show buildDietaryTags;
import 'models/delivery_address.dart';
import 'models/delivery_time.dart';
import 'widgets/address_card.dart';
import 'payment_screen.dart';

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);
const _kGreyText = Color(0xFF8DA5C4);

class CheckoutScreen extends StatefulWidget {
  final DeliveryAddress initialAddress;

  const CheckoutScreen({super.key, required this.initialAddress});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late DeliveryAddress _address;
  bool _isAsap = true;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;

  static const _slots = [
    '9:00 - 11:00',
    '11:00 - 13:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
    '17:00 - 19:00',
  ];

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;
  }

  bool get _canProceed =>
      _isAsap || (_selectedSlot != null);

  void _proceedToPayment() {
    final deliveryTime = DeliveryTime(
      isAsap: _isAsap,
      scheduledDate: _isAsap ? null : _selectedDate,
      scheduledSlot: _isAsap ? null : _selectedSlot,
    );
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PaymentScreen(
          address: _address,
          deliveryTime: deliveryTime,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                    _buildOrderSummary(cart),
                    const SizedBox(height: 16),
                    _buildAddressSection(),
                    const SizedBox(height: 16),
                    _buildDeliveryTimeSection(),
                    const SizedBox(height: 24),
                    _buildProceedButton(),
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
              'Checkout',
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
  // ORDER SUMMARY
  // ────────────────────────────────────────────────────────
  Widget _buildOrderSummary(CartService cart) {
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
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      'x${item.quantity}',
                      style: GoogleFonts.quicksand(
                          fontSize: 13, color: _kGreyText),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.totalPriceLabel,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _kDarkBlue,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(color: _kSoftBlue, height: 20, thickness: 1),
          _summaryRow(
              'Subtotal', '€ ${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _summaryRow('Delivery fee',
              '€ ${CartService.deliveryFee.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kDarkBlue,
                ),
              ),
              Text(
                '€ ${cart.total.toStringAsFixed(2)}',
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

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                GoogleFonts.quicksand(fontSize: 13, color: _kGreyText)),
        Text(value,
            style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kDarkBlue)),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // ADDRESS
  // ────────────────────────────────────────────────────────
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Delivery Address',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
        ),
        AddressCard(
          address: _address,
          onUpdate: (updated) => setState(() => _address = updated),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // DELIVERY TIME
  // ────────────────────────────────────────────────────────
  Widget _buildDeliveryTimeSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Time',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          // ASAP toggle
          _timeOption(
            label: 'As soon as possible',
            sublabel: 'Est. 25–40 min',
            icon: Icons.bolt_rounded,
            selected: _isAsap,
            onTap: () => setState(() => _isAsap = true),
          ),
          const SizedBox(height: 10),
          // Schedule toggle
          _timeOption(
            label: 'Schedule delivery',
            sublabel: 'Pick a date & time slot',
            icon: Icons.calendar_month_rounded,
            selected: !_isAsap,
            onTap: () => setState(() => _isAsap = false),
          ),
          if (!_isAsap) ...[
            const SizedBox(height: 14),
            _buildDatePicker(),
            const SizedBox(height: 12),
            _buildSlotGrid(),
          ],
        ],
      ),
    );
  }

  Widget _timeOption({
    required String label,
    required String sublabel,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? _kPrimary.withValues(alpha: .12)
              : const Color(0xFFF5FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kPrimary : _kSoftBlue,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? _kPrimary : _kGreyText, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? _kDarkBlue : _kGreyText,
                    ),
                  ),
                  Text(
                    sublabel,
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
                color: selected ? _kPrimary : Colors.transparent,
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
  }

  Widget _buildDatePicker() {
    final formatted =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 14)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _kPrimary,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kSoftBlue),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: _kPrimary, size: 18),
            const SizedBox(width: 10),
            Text(
              'Date: $formatted',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kDarkBlue,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: _kGreyText, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _slots.map((slot) {
        final selected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? _kPrimary
                  : const Color(0xFFF5FAFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? _kPrimary : _kSoftBlue,
              ),
            ),
            child: Text(
              slot,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _kGreyText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ────────────────────────────────────────────────────────
  // PROCEED BUTTON
  // ────────────────────────────────────────────────────────
  Widget _buildProceedButton() {
    return GestureDetector(
      onTap: _canProceed ? _proceedToPayment : null,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: _canProceed
              ? const LinearGradient(
                  colors: [Color(0xFF9BC8EE), Color(0xFF6BA4DB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _canProceed ? null : _kSoftBlue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: _canProceed
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: .4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_rounded,
                color: _canProceed ? Colors.white : _kGreyText, size: 22),
            const SizedBox(width: 10),
            Text(
              'Proceed to Payment',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _canProceed ? Colors.white : _kGreyText,
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
