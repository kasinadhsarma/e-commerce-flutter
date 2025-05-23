import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wishlist_screen.dart';

// Enhanced main entry point with proper initialization
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web-specific error handling
  if (kIsWeb) {
    // Catch Flutter web errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Log to console in web environment
      if (kDebugMode) {
        print('Flutter web error: ${details.exception}');
        print('Stack trace: ${details.stack}');
      }
    };
  }
  
  // For Dart errors in both platforms
  runZonedGuarded(
    () => runApp(const MyApp()),
    (error, stackTrace) {
      if (kDebugMode) {
        print('Unhandled error: $error');
        print('Stack trace: $stackTrace');
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ProductProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'E-Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const EShopApp(),
      ),
    );
  }
}

// Main app scaffolding
class EShopApp extends StatefulWidget {
  const EShopApp({super.key});

  @override
  State<EShopApp> createState() => _EShopAppState();
}

class _EShopAppState extends State<EShopApp> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fetch products
    _loadData();
  }
  
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // Fetch products
      await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      // Load wishlist
      await Provider.of<WishlistProvider>(context, listen: false).loadWishlist();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading initial data: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'E-Shop',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
