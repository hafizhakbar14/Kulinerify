class Restaurant {
  final String id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final String imageUrl;
  final String mapsUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.mapsUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    double parsedRating = 0.0;
    if (rawRating is num) {
      parsedRating = rawRating.toDouble();
    } else if (rawRating != null) {
      parsedRating = double.tryParse(rawRating.toString()) ?? 0.0;
    }

    final name = (json['name'] ?? 'Tanpa Nama').toString();
    final address = (json['address'] ?? 'Tembalang, Semarang').toString();
    final rawMapsUrl = (json['maps_url'] ?? json['mapsUrl'] ?? '').toString();

    // Otomatis buat link pencarian Google Maps jika kolom maps_url di DB kosong
    final fallbackMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';

    return Restaurant(
      id: (json['id'] ?? '').toString(),
      name: name,
      category: (json['category'] ?? 'Umum').toString(),
      address: address,
      rating: parsedRating,
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      mapsUrl: rawMapsUrl.isNotEmpty ? rawMapsUrl : fallbackMapsUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'rating': rating,
      'image_url': imageUrl,
      'maps_url': mapsUrl,
    };
  }
}
