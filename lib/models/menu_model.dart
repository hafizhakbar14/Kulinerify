class Menu {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String name;
  final String description;
  final int price;
  final String imageUrl;

  Menu({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    int parsedPrice = 0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toInt();
    } else if (rawPrice != null) {
      parsedPrice =
          int.tryParse(rawPrice.toString()) ??
          (double.tryParse(rawPrice.toString())?.toInt() ?? 0);
    }

    // Jika backend menyertakan objek nested 'restaurants' atau 'restaurant'
    final nestedRestaurant = json['restaurants'] ?? json['restaurant'];
    final nestedName = nestedRestaurant is Map<String, dynamic>
        ? nestedRestaurant['name']
        : null;

    return Menu(
      id: (json['id'] ?? '').toString(),
      restaurantId: (json['restaurant_id'] ?? json['restaurantId'] ?? '')
          .toString(),
      restaurantName:
          (json['restaurant_name'] ??
                  json['restaurantName'] ??
                  nestedName ??
                  '')
              .toString(),
      name: (json['name'] ?? 'Menu Tanpa Nama').toString(),
      description: (json['description'] ?? '').toString(),
      price: parsedPrice,
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
