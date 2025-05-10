import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _items = [];
  
  List<Product> get items {
    return [..._items];
  }
  
  bool isInWishlist(int productId) {
    return _items.any((product) => product.id == productId);
  }
  
  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      _items.add(product);
      _saveWishlistToPrefs();
      notifyListeners();
    }
  }
  
  void removeFromWishlist(int productId) {
    _items.removeWhere((product) => product.id == productId);
    _saveWishlistToPrefs();
    notifyListeners();
  }
  
  void toggleWishlistStatus(Product product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }
  
  // Save wishlist to SharedPreferences for persistence
  Future<void> _saveWishlistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistData = _items
        .map((product) => {
              'id': product.id,
              'title': product.title,
              'price': product.price,
              'description': product.description,
              'category': product.category,
              'image': product.image,
              'rating': {
                'rate': product.rating,
                'count': product.ratingCount,
              },
            })
        .toList();
    
    await prefs.setString('wishlist', json.encode(wishlistData));
  }
  
  // Load wishlist from SharedPreferences
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('wishlist')) {
      final wishlistData = json.decode(prefs.getString('wishlist') ?? '[]') as List<dynamic>;
      
      _items.clear();
      
      for (var item in wishlistData) {
        _items.add(
          Product.fromJson(item as Map<String, dynamic>),
        );
      }
      
      notifyListeners();
    }
  }
}