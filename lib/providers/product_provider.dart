import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get items {
    if (_items.isEmpty && !_isLoading && _error.isEmpty) {
      // If items is empty and we're not loading and there's no error,
      // return some sample data
      return sampleProducts;
    }
    return [..._items];
  }

  bool get isLoading {
    return _isLoading;
  }

  String get error {
    return _error;
  }

  // Method for testing - allows setting products directly instead of API fetch
  void setProductsForTest(List<Product> testProducts) {
    _items = testProducts;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }

  Product findById(int id) {
    try {
      return _items.firstWhere((product) => product.id == id);
    } catch (e) {
      // Return a sample product if the ID is not found
      return sampleProducts.first;
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final List<dynamic> productsData = json.decode(response.body);
        _items = productsData
            .map((productData) => Product.fromJson(productData))
            .toList();
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      // Use sample data if API fails
      _items = sampleProducts;
      notifyListeners();
      debugPrint("Error fetching products: $error");
    }
  }

  List<Product> getProductsByCategory(String category) {
    return _items.where((product) => product.category == category).toList();
  }

  List<String> get categories {
    return _items
        .map((product) => product.category)
        .toSet()
        .toList();
  }
  
  // Sample product data to use if API fails
  final List<Product> sampleProducts = [
    Product(
      id: 1,
      title: 'Fjallraven - Foldsack No. 1 Backpack',
      price: 109.95,
      description: 'Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday',
      category: 'men\'s clothing',
      image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
      rating: 4.5,
      ratingCount: 120,
    ),
    Product(
      id: 2,
      title: 'Mens Casual Premium Slim Fit T-Shirts',
      price: 22.3,
      description: 'Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing.',
      category: 'men\'s clothing',
      image: 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
      rating: 4.1,
      ratingCount: 259,
    ),
    Product(
      id: 3,
      title: 'WD 2TB Elements Portable External Hard Drive',
      price: 64.0,
      description: 'USB 3.0 and USB 2.0 Compatibility Fast data transfers Improve PC Performance High Capacity; Compatibility Formatted NTFS for Windows 10, Windows 8.1, Windows 7',
      category: 'electronics',
      image: 'https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_.jpg',
      rating: 3.9,
      ratingCount: 203,
    ),
    Product(
      id: 4,
      title: 'Samsung 49-Inch CHG90 144Hz Curved Gaming Monitor',
      price: 999.99,
      description: '49 INCH SUPER ULTRAWIDE 32:9 CURVED GAMING MONITOR with dual 27 inch screen side by side QUANTUM DOT (QLED) TECHNOLOGY, HDR support and factory calibration',
      category: 'electronics',
      image: 'https://fakestoreapi.com/img/81Zt42ioCgL._AC_SX679_.jpg',
      rating: 4.8,
      ratingCount: 140,
    ),
  ];
}