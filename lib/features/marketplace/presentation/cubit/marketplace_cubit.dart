import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/marketplace/data/models/marketplace_models.dart';
import 'package:flutter_template/features/marketplace/data/repositories/marketplace_repository.dart';

enum MarketplaceLoad { initial, loading, success, failure, ordering }

final class MarketplaceState extends Equatable {
  const MarketplaceState({
    this.load = MarketplaceLoad.initial,
    this.data,
    this.cart = const [],
    this.categoryFilter,
    this.lastOrder,
    this.error,
  });

  final MarketplaceLoad load;
  final MarketplaceData? data;
  final List<CartItem> cart;
  final String? categoryFilter;
  final CodOrder? lastOrder;
  final String? error;

  List<MarketplaceProduct> get filteredProducts {
    final products = data?.products ?? const [];
    if (categoryFilter == null) return products;
    return products.where((p) => p.category == categoryFilter).toList(growable: false);
  }

  int get cartCount => cart.fold(0, (s, c) => s + c.qty);
  int get cartTotal => cart.fold(0, (s, c) => s + c.lineTotal);

  MarketplaceState copyWith({
    MarketplaceLoad? load,
    MarketplaceData? data,
    List<CartItem>? cart,
    String? categoryFilter,
    CodOrder? lastOrder,
    String? error,
    bool clearCategory = false,
    bool clearOrder = false,
    bool clearError = false,
  }) {
    return MarketplaceState(
      load: load ?? this.load,
      data: data ?? this.data,
      cart: cart ?? this.cart,
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      lastOrder: clearOrder ? null : (lastOrder ?? this.lastOrder),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, data, cart, categoryFilter, lastOrder, error];
}

class MarketplaceCubit extends Cubit<MarketplaceState> {
  MarketplaceCubit(this._repo) : super(const MarketplaceState());

  final MarketplaceRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(load: MarketplaceLoad.loading, clearError: true));
    try {
      final data = await _repo.fetchProducts();
      emit(state.copyWith(load: MarketplaceLoad.success, data: data));
    } catch (e) {
      emit(state.copyWith(load: MarketplaceLoad.failure, error: e.toString()));
    }
  }

  void setCategory(String? cat) {
    if (cat == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(categoryFilter: cat));
    }
  }

  void addToCart(MarketplaceProduct product) {
    final list = [...state.cart];
    final idx = list.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(qty: list[idx].qty + 1);
    } else {
      list.add(CartItem(product: product));
    }
    emit(state.copyWith(cart: list));
  }

  void removeFromCart(String productId) {
    emit(state.copyWith(cart: state.cart.where((c) => c.product.id != productId).toList(growable: false)));
  }

  Future<CodOrder?> checkout({
    required MarketplaceProduct product,
    required int qty,
    required String address,
    required String phone,
    required String district,
  }) async {
    emit(state.copyWith(load: MarketplaceLoad.ordering, clearError: true));
    try {
      final order = await _repo.placeCodOrder(
        product: product,
        qty: qty,
        address: address,
        phone: phone,
        district: district,
      );
      emit(state.copyWith(load: MarketplaceLoad.success, lastOrder: order));
      return order;
    } catch (e) {
      emit(state.copyWith(load: MarketplaceLoad.success, error: e.toString()));
      return null;
    }
  }
}
