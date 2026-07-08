import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/core/utils/validators.dart';
import 'package:flutter_template/features/marketplace/data/models/marketplace_models.dart';
import 'package:flutter_template/features/marketplace/presentation/cubit/marketplace_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/shared/widgets/app_text_field.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MarketplaceCubit>().load());
  }

  void _openCheckout(MarketplaceProduct product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _CheckoutSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puja Marketplace · COD'),
        actions: [
          BlocBuilder<MarketplaceCubit, MarketplaceState>(
            buildWhen: (p, c) => p.cartCount != c.cartCount,
            builder: (context, state) {
              if (state.cartCount == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  avatar: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text('${state.cartCount}'),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<MarketplaceCubit, MarketplaceState>(
        listenWhen: (p, c) => p.lastOrder?.id != c.lastOrder?.id || p.error != c.error,
        listener: (context, state) {
          if (state.lastOrder != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('COD order ${state.lastOrder!.id} placed — ${state.lastOrder!.status}')),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.load == MarketplaceLoad.loading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = state.data;
          if (data == null) {
            return Center(child: FilledButton.tonal(onPressed: () => context.read<MarketplaceCubit>().load(), child: Text(t.retry)));
          }
          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: state.categoryFilter == null,
                      onSelected: (_) => context.read<MarketplaceCubit>().setCategory(null),
                    ),
                    ...data.categories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(c.name),
                          selected: state.categoryFilter == c.id,
                          onSelected: (_) => context.read<MarketplaceCubit>().setCategory(c.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.filteredProducts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = state.filteredProducts[i];
                    return _ProductCard(product: p, onBuy: () => _openCheckout(p), onCart: () => context.read<MarketplaceCubit>().addToCart(p));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onBuy, required this.onCart});

  final MarketplaceProduct product;
  final VoidCallback onBuy;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.imageEmoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.nameEn, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(product.nameBn, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text('৳${product.priceBdt} · ${product.sellerName}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brandPrimary)),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.brandTertiary),
                      Text(' ${product.rating}'),
                      const SizedBox(width: 8),
                      Text('Stock: ${product.stock}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Text(
                    'Delivers to: ${product.deliveryDistricts.take(3).join(', ')}${product.deliveryDistricts.length > 3 ? '…' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(onPressed: onCart, icon: const Icon(Icons.add_shopping_cart_outlined)),
                FilledButton(onPressed: onBuy, child: const Text('COD')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({required this.product});

  final MarketplaceProduct product;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _district = 'Dhaka';
  int _qty = 1;
  String? _addrErr;
  String? _phoneErr;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    setState(() {
      _addrErr = Validators.deliveryAddress(_addressCtrl.text);
      _phoneErr = Validators.codPhone(_phoneCtrl.text);
    });
    if (_addrErr != null || _phoneErr != null) return;
    if (!widget.product.deliversTo(_district)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not deliverable to your area')));
      return;
    }
    final order = await context.read<MarketplaceCubit>().checkout(
          product: widget.product,
          qty: _qty,
          address: _addressCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          district: _district,
        );
    if (order != null && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fee = widget.product.deliveryFeeBdt;
    final total = widget.product.priceBdt * _qty + fee;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cash on Delivery', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          Text(widget.product.nameEn),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Qty'),
              IconButton(onPressed: _qty > 1 ? () => setState(() => _qty--) : null, icon: const Icon(Icons.remove)),
              Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w800)),
              IconButton(onPressed: _qty < widget.product.stock ? () => setState(() => _qty++) : null, icon: const Icon(Icons.add)),
            ],
          ),
          DropdownMenu<String>(
            initialSelection: _district,
            expandedInsets: EdgeInsets.zero,
            label: const Text('Delivery district'),
            dropdownMenuEntries: widget.product.deliveryDistricts
                .map((d) => DropdownMenuEntry<String>(value: d, label: d))
                .toList(growable: false),
            onSelected: (v) {
              if (v == null) return;
              setState(() => _district = v);
            },
          ),
          const SizedBox(height: 10),
          AppTextField(controller: _addressCtrl, label: 'Delivery address', errorText: _addrErr, maxLines: 2),
          const SizedBox(height: 10),
          AppTextField(controller: _phoneCtrl, label: 'Phone', keyboardType: TextInputType.phone, errorText: _phoneErr),
          const SizedBox(height: 12),
          Text('Total: ৳$total (incl. delivery ৳$fee)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 16),
          FilledButton(onPressed: _place, child: const Text('Place COD order')),
        ],
      ),
    );
  }
}
