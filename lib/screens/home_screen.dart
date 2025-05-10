import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_grid.dart';
import 'cart_screen.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isInit = true;
  var _selectedCategory = 'All';

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<ProductProvider>(context).fetchProducts();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Shop'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 8.0),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: -10, end: -12),
              showBadge: cartProvider.itemCount > 0,
              badgeContent: Text(
                cartProvider.itemCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const CartScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.error.isNotEmpty
              ? Center(child: Text('Error: ${productProvider.error}'))
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    // Category Filter
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: _selectedCategory == 'All',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = 'All';
                                });
                              },
                            ),
                          ),
                          ...productProvider.categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: FilterChip(
                                label: Text(category[0].toUpperCase() + category.substring(1)),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    // Product Grid
                    Expanded(
                      child: ProductGrid(
                        products: _selectedCategory == 'All'
                            ? productProvider.items
                            : productProvider.getProductsByCategory(_selectedCategory),
                      ),
                    ),
                  ],
                ),
    );
  }
}