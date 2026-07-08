import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/marketplace/data/models/marketplace_models.dart';

abstract class MarketplaceRepository {
  Future<MarketplaceData> fetchProducts();
  Future<CodOrder> placeCodOrder({
    required MarketplaceProduct product,
    required int qty,
    required String address,
    required String phone,
    required String district,
  });
}

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  @override
  Future<MarketplaceData> fetchProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final text = await rootBundle.loadString('assets/mock/marketplace_products.json');
    return MarketplaceData.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }

  @override
  Future<CodOrder> placeCodOrder({
    required MarketplaceProduct product,
    required int qty,
    required String address,
    required String phone,
    required String district,
  }) async {
    if (!product.deliversTo(district)) {
      throw Exception('Not deliverable to your area');
    }
    if (qty < 1 || qty > product.stock) {
      throw Exception('Invalid quantity');
    }
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final total = product.priceBdt * qty + (product.deliveryFeeBdt > 0 ? product.deliveryFeeBdt : 0);
    return CodOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      productName: product.nameEn,
      totalBdt: total,
      status: 'PLACED',
      district: district,
    );
  }
}
