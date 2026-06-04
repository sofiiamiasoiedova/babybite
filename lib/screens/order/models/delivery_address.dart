class DeliveryAddress {
  String recipientName;
  String phone;
  String street;
  String cityPostcode;
  String note;

  DeliveryAddress({
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.cityPostcode,
    this.note = '',
  });
}
