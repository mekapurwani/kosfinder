class Kos {
  const Kos({
    required this.id,
    required this.name,
    required this.addressArea,
    required this.monthlyPrice,
  });

  final String id;
  final String name;
  final String addressArea;
  final num monthlyPrice;

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
    );
  }
}
