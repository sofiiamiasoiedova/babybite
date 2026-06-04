import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_address.dart';

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);
const _kGreyText = Color(0xFF8DA5C4);

class AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final ValueChanged<DeliveryAddress> onUpdate;

  const AddressCard({
    super.key,
    required this.address,
    required this.onUpdate,
  });

  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: address.recipientName);
    final phoneCtrl = TextEditingController(text: address.phone);
    final streetCtrl = TextEditingController(text: address.street);
    final cityCtrl = TextEditingController(text: address.cityPostcode);
    final noteCtrl = TextEditingController(text: address.note);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Address',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w800,
            color: _kDarkBlue,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Recipient name', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _field(phoneCtrl, 'Phone number', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _field(streetCtrl, 'Street', Icons.signpost_outlined),
              const SizedBox(height: 12),
              _field(cityCtrl, 'City / Postcode', Icons.location_city_outlined),
              const SizedBox(height: 12),
              _field(noteCtrl, 'Note (optional)', Icons.notes_rounded,
                  maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.quicksand(
                  color: _kGreyText, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              onUpdate(DeliveryAddress(
                recipientName: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                street: streetCtrl.text.trim(),
                cityPostcode: cityCtrl.text.trim(),
                note: noteCtrl.text.trim(),
              ));
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Save',
              style: GoogleFonts.quicksand(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.quicksand(color: _kGreyText, fontSize: 13),
        prefixIcon: Icon(icon, color: _kGreyText, size: 20),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kSoftBlue),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditDialog(context),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _kSoftBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.home_rounded, color: _kPrimary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.recipientName,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _kDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 13, color: _kGreyText),
                      const SizedBox(width: 4),
                      Text(
                        address.phone,
                        style: GoogleFonts.quicksand(
                            fontSize: 12, color: _kGreyText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.street,
                    style:
                        GoogleFonts.quicksand(fontSize: 12, color: _kGreyText),
                  ),
                  Text(
                    address.cityPostcode,
                    style:
                        GoogleFonts.quicksand(fontSize: 12, color: _kGreyText),
                  ),
                  if (address.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes_rounded,
                            size: 13, color: _kGreyText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address.note,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: _kGreyText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: _kPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_location_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
