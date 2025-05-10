// This is a basic Flutter widget test for our e-commerce app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myapp/main.dart';
import 'package:myapp/providers/product_provider.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/providers/wishlist_provider.dart';
import 'package:myapp/models/product.dart';

void main() {
  // Mocked products for testing
  final mockedProducts = [
    Product(
      id: 1,
      title: 'Test Product 1',
      price: 19.99,
      description: 'Test description 1',
      category: 'test category',
      image: 'https://example.com/test1.jpg',
      rating: 4.5,
      ratingCount: 10,
    ),
    Product(
      id: 2,
      title: 'Test Product 2',
      price: 29.99,
      description: 'Test description 2',
      category: 'test category',
      image: 'https://example.com/test2.jpg',
      rating: 4.0,
      ratingCount: 20,
    ),
  ];

  testWidgets('E-commerce app smoke test', (WidgetTester tester) async {
    // Create a mock ProductProvider that doesn't make real API calls
    final mockProductProvider = ProductProvider();
    // Set predefined products on the provider
    mockProductProvider.setProductsForTest(mockedProducts);

    // Build our app with mocked providers for testing
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>.value(value: mockProductProvider),
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => WishlistProvider()),
        ],
        child: const MaterialApp(
          home: EShopApp(),
        ),
      ),
    );

    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that we can find the app name in the app bar
    expect(find.text('E-Shop'), findsOneWidget);

    // Verify that we have products displayed
    expect(find.text('Test Product 1'), findsOneWidget);
    expect(find.text('Test Product 2'), findsOneWidget);

    // Find and tap on a product to navigate to details
    await tester.tap(find.text('Test Product 1'));
    await tester.pumpAndSettle();

    // Verify we're on the product details screen
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Test description 1'), findsOneWidget);

    // Test adding to cart
    await tester.tap(find.byIcon(Icons.add_shopping_cart));
    await tester.pumpAndSettle();

    // Verify success message appears
    expect(find.text('Added item to cart!'), findsOneWidget);

    // Navigate back to home
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Navigate to cart screen
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    // Verify cart has our item
    expect(find.text('Test Product 1'), findsOneWidget);
    expect(find.text('\$19.99'), findsOneWidget);
  });
}
