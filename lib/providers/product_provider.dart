import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get items {
    return [..._items];
  }

  bool get isLoading {
    return _isLoading;
  }

  String get error {
    return _error;
  }

  Product findById(int id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsData = json.decode(response.body);
        _items = productsData
            .map((productData) => Product.fromJson(productData))
            .toList();
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      notifyListeners();
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
}