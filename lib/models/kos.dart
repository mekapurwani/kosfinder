class Kos {
  const Kos({
    required this.id,
    required this.name,
    required this.addressArea,
    required this.monthlyPrice,
    this.description = '',
    this.whatsappNumber = '',
    this.status = 'Tersedia',
    this.ownerId,
  });

  final String id;
  final String name;
  final String addressArea;
  final num monthlyPrice;
  final String description;
  final String whatsappNumber;
  final String status;
  final String? ownerId;

  factory Kos.fromMap(Map<String, dynamic> map) {
    final rawPrice = map['monthly_price'];
    final price = rawPrice is num
        ? rawPrice
        : num.tryParse(rawPrice?.toString() ?? '') ?? 0;

    return Kos(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      addressArea: map['address_area']?.toString() ?? '',
      monthlyPrice: price,
      description: map['description']?.toString() ?? '',
      whatsappNumber: map['whatsapp_number']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Tersedia',
      ownerId: map['owner_id']?.toString(),
    );
  }

  Uri get whatsappUri {
    final digits = whatsappNumber.replaceAll(RegExp(r'\D'), '');
    return Uri.parse('https://wa.me/$digits');
  }
}
