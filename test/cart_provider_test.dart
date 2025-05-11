import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';

void main() {
  late CartProvider cartProvider;
  late Product testProduct1;
  late Product testProduct2;

  setUp(() {
    cartProvider = CartProvider();
    
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

  group('CartProvider', () {
    test('starts with empty cart', () {
      expect(cartProvider.items.isEmpty, true);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.totalAmount, 0.0);
    });

    test('can add item to cart', () {
      cartProvider.addItem(testProduct1);
      
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items[1]!.product.id, 1);
      expect(cartProvider.items[1]!.quantity, 1);
      expect(cartProvider.totalAmount, 19.99);
    });

    test('can increase quantity of existing item', () {
      cartProvider.addItem(testProduct1);
      cartProvider.addItem(testProduct1);
      
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items[1]!.quantity, 2);
      expect(cartProvider.totalAmount, 39.98);
    });

    test('can add multiple different items', () {
      cartProvider.addItem(testProduct1);
      cartProvider.addItem(testProduct2);
      
      expect(cartProvider.itemCount, 2);
      expect(cartProvider.items.length, 2);
      expect(cartProvider.totalAmount, 49.98);
    });

    test('can remove item from cart', () {
      cartProvider.addItem(testProduct1);
      cartProvider.addItem(testProduct2);
      
      cartProvider.removeItem(1);
      
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items[2]!.product.id, 2);
      expect(cartProvider.totalAmount, 29.99);
    });

    test('can remove single item from cart', () {
      cartProvider.addItem(testProduct1);
      cartProvider.addItem(testProduct1);
      
      cartProvider.removeSingleItem(1);
      
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items[1]!.quantity, 1);
      expect(cartProvider.totalAmount, 19.99);
      
      cartProvider.removeSingleItem(1);
      
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.items.isEmpty, true);
      expect(cartProvider.totalAmount, 0.0);
    });

    test('can clear cart', () {
      cartProvider.addItem(testProduct1);
      cartProvider.addItem(testProduct2);
      
      cartProvider.clear();
      
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.items.isEmpty, true);
      expect(cartProvider.totalAmount, 0.0);
    });
  });
}