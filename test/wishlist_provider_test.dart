import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/providers/wishlist_provider.dart';

void main() {
  late WishlistProvider wishlistProvider;
  late Product testProduct1;
  late Product testProduct2;

  setUp(() {
    wishlistProvider = WishlistProvider();
    
    testProduct1 = Product(
      id: 1,
      title: 'Test Product 1',
      price: 19.99,
      description: 'Test description 1',
      category: 'test category',
      image: 'https://example.com/test1.jpg',
      rating: 4.5,
      ratingCount: 10,
    );
    
    testProduct2 = Product(
      id: 2,
      title: 'Test Product 2',
      price: 29.99,
      description: 'Test description 2',
      category: 'test category',
      image: 'https://example.com/test2.jpg',
      rating: 4.0,
      ratingCount: 20,
    );
  });

  group('WishlistProvider', () {
    test('starts with empty wishlist', () {
      expect(wishlistProvider.items.isEmpty, true);
    });

    test('can add item to wishlist', () {
      wishlistProvider.addToWishlist(testProduct1);
      
      expect(wishlistProvider.items.length, 1);
      expect(wishlistProvider.isInWishlist(1), true);
      expect(wishlistProvider.isInWishlist(2), false);
    });

    test('adding same item twice has no effect', () {
      wishlistProvider.addToWishlist(testProduct1);
      wishlistProvider.addToWishlist(testProduct1);
      
      expect(wishlistProvider.items.length, 1);
    });

    test('can add multiple different items', () {
      wishlistProvider.addToWishlist(testProduct1);
      wishlistProvider.addToWishlist(testProduct2);
      
      expect(wishlistProvider.items.length, 2);
      expect(wishlistProvider.isInWishlist(1), true);
      expect(wishlistProvider.isInWishlist(2), true);
    });

    test('can remove item from wishlist', () {
      wishlistProvider.addToWishlist(testProduct1);
      wishlistProvider.addToWishlist(testProduct2);
      
      wishlistProvider.removeFromWishlist(1);
      
      expect(wishlistProvider.items.length, 1);
      expect(wishlistProvider.isInWishlist(1), false);
      expect(wishlistProvider.isInWishlist(2), true);
    });

    test('can toggle wishlist status', () {
      // Initial state - not in wishlist
      expect(wishlistProvider.isInWishlist(1), false);
      
      // Toggle adds to wishlist
      wishlistProvider.toggleWishlistStatus(testProduct1);
      expect(wishlistProvider.isInWishlist(1), true);
      
      // Toggle again removes from wishlist
      wishlistProvider.toggleWishlistStatus(testProduct1);
      expect(wishlistProvider.isInWishlist(1), false);
    });
  });
}