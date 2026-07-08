class MarketplaceCategory {
  const MarketplaceCategory({required this.id, required this.name, required this.nameBn});

  final String id;
  final String name;
  final String nameBn;

  factory MarketplaceCategory.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      nameBn: json['nameBn'] as String? ?? '',
    );
  }
}

class MarketplaceProduct {
  const MarketplaceProduct({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.category,
    required this.priceBdt,
    required this.stock,
    required this.sellerName,
    required this.rating,
    required this.deliveryDistricts,
    required this.deliveryFeeBdt,
    required this.imageEmoji,
    required this.description,
  });

  final String id;
  final String nameEn;
  final String nameBn;
  final String category;
  final int priceBdt;
  final int stock;
  final String sellerName;
  final double rating;
  final List<String> deliveryDistricts;
  final int deliveryFeeBdt;
  final String imageEmoji;
  final String description;

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameBn: json['nameBn'] as String? ?? '',
      category: json['category'] as String,
      priceBdt: (json['priceBdt'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
      sellerName: json['sellerName'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      deliveryDistricts: (json['deliveryDistricts'] as List<dynamic>).map((e) => e as String).toList(growable: false),
      deliveryFeeBdt: (json['deliveryFeeBdt'] as num?)?.toInt() ?? 0,
      imageEmoji: json['imageEmoji'] as String? ?? '🛍️',
      description: json['description'] as String? ?? '',
    );
  }

  bool deliversTo(String district) => deliveryDistricts.contains(district);
}

class MarketplaceData {
  const MarketplaceData({required this.categories, required this.products});

  final List<MarketplaceCategory> categories;
  final List<MarketplaceProduct> products;

  factory MarketplaceData.fromJson(Map<String, dynamic> json) {
    return MarketplaceData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => MarketplaceCategory.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      products: (json['products'] as List<dynamic>)
          .map((e) => MarketplaceProduct.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class CartItem {
  const CartItem({required this.product, this.qty = 1});

  final MarketplaceProduct product;
  final int qty;

  int get lineTotal => product.priceBdt * qty;

  CartItem copyWith({int? qty}) => CartItem(product: product, qty: qty ?? this.qty);
}

class CodOrder {
  const CodOrder({
    required this.id,
    required this.productName,
    required this.totalBdt,
    required this.status,
    required this.district,
  });

  final String id;
  final String productName;
  final int totalBdt;
  final String status;
  final String district;
}
