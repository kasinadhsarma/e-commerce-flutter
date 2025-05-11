import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';

// Class for checkout screen to use if not using the main CartItem model
class CheckoutCartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final Map<String, dynamic> options;
  final String? imageUrl;

  CheckoutCartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.options = const {},
    this.imageUrl,
  });

  // For total price calculation
  double get total => price * quantity;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Shipping form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  String _deliveryOption = 'standard';

  // Cart data (mock)
  late List<CheckoutCartItem> cartItems;
  double subtotal = 0;
  double tax = 0;
  double deliveryFee = 4.99;
  double total = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCartData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // TODO: Load actual user data from provider
    // Mock user data based on the real UserModel structure
    final userData = UserModel(
      id: 'u1',
      email: 'john.doe@example.com',
      displayName: 'John Doe',
      phoneNumber: '555-123-4567',
      addresses: ['123 Main St, Anytown, CA 12345'],
      createdAt: DateTime.now(),
    );

    _nameController.text = userData.displayName ?? '';
    _phoneController.text = userData.phoneNumber ?? '';

    // Parse address if available
    if (userData.addresses.isNotEmpty) {
      final addressParts = userData.addresses.first.split(',');
      if (addressParts.isNotEmpty) {
        _addressController.text = addressParts[0].trim();

        if (addressParts.length > 1) {
          final cityStateParts = addressParts[1].trim().split(' ');
          if (cityStateParts.isNotEmpty) {
            _cityController.text = cityStateParts[0];

            if (cityStateParts.length > 1) {
              _stateController.text = cityStateParts[1];
            }
          }

          if (addressParts.length > 2) {
            _zipController.text = addressParts[2].trim();
          }
        }
      }
    }
  }

  Future<void> _loadCartData() async {
    // TODO: Replace with actual cart data from provider

    // Mock cart data
    cartItems = [
      CheckoutCartItem(
        id: '1',
        productId: 'p1',
        name: 'Classic Cheeseburger',
        price: 7.99,
        quantity: 2,
        options: {
          'size': 'Regular',
          'bun': 'Sesame',
          'extras': ['Extra Cheese']
        },
        imageUrl: 'assets/images/burger1.jpg',
      ),
      CheckoutCartItem(
        id: '2',
        productId: 'p2',
        name: 'French Fries',
        price: 3.99,
        quantity: 1,
        options: {'size': 'Large'},
        imageUrl: 'assets/images/fries.jpg',
      ),
      CheckoutCartItem(
        id: '3',
        productId: 'p3',
        name: 'Chocolate Shake',
        price: 4.99,
        quantity: 1,
        options: {'size': 'Regular'},
        imageUrl: 'assets/images/shake.jpg',
      ),
    ];

    _calculateTotals();
  }

  void _calculateTotals() {
    subtotal =
        cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    tax = subtotal * 0.08; // 8% tax

    // Adjust delivery fee based on delivery option
    if (_deliveryOption == 'express') {
      deliveryFee = 9.99;
    } else if (_deliveryOption == 'standard') {
      deliveryFee = 4.99;
    } else {
      deliveryFee = 0; // For pickup
    }

    total = subtotal + tax + deliveryFee;
  }

  void _updateDeliveryOption(String option) {
    setState(() {
      _deliveryOption = option;
      _calculateTotals();
    });
  }

  void _continueToPayment() {
    if (_currentStep == 0) {
      // Validate shipping info form
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 1) {
      // Validate order review (always valid)
      setState(() {
        isLoading = true;
      });

      // Simulate API call to process order
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamed(context, '/payment', arguments: {
          'total': total,
          'items': cartItems.length,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              controlsBuilder: (context, controlDetails) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _continueToPayment,
                          child: Text(_currentStep == 0
                              ? 'Continue to Review'
                              : 'Proceed to Payment'),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep = 0;
                              });
                            },
                            child: const Text('Back'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              onStepTapped: (step) {
                if (step < _currentStep) {
                  setState(() {
                    _currentStep = step;
                  });
                } else if (step > _currentStep && _currentStep == 0) {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _currentStep = step;
                    });
                  }
                }
              },
              steps: [
                Step(
                  title: const Text('Shipping Information'),
                  content: _buildShippingForm(),
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Review Order'),
                  content: _buildOrderReview(),
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),
    );
  }

  Widget _buildShippingForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact information
          const Text(
            'Contact Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              filled: true,
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Phone field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              filled: true,
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Delivery address
          const Text(
            'Delivery Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // Street address
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Street Address',
              border: OutlineInputBorder(),
              filled: true,
              prefixIcon: Icon(Icons.home_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your street address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // City, State, Zip
          Row(
            children: [
              // City
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              // State
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Zip code
              Expanded(
                child: TextFormField(
                  controller: _zipController,
                  decoration: const InputDecoration(
                    labelText: 'Zip',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 5) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Delivery options
          const Text(
            'Delivery Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Standard delivery
          _buildDeliveryOption(
            'standard',
            'Standard Delivery',
            '2-3 days',
            '\$4.99',
            Icons.local_shipping_outlined,
          ),

          // Express delivery
          _buildDeliveryOption(
            'express',
            'Express Delivery',
            'Next day',
            '\$9.99',
            Icons.delivery_dining_outlined,
          ),

          // Pickup
          _buildDeliveryOption(
            'pickup',
            'Pickup',
            'Ready in 30 min',
            'Free',
            Icons.store_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(
    String value,
    String title,
    String subtitle,
    String price,
    IconData icon,
  ) {
    final isSelected = _deliveryOption == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _updateDeliveryOption(value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Radio<String>(
                value: value,
                groupValue: _deliveryOption,
                onChanged: (newValue) {
                  if (newValue != null) {
                    _updateDeliveryOption(newValue);
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shipping address summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentStep = 0;
                        });
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_addressController.text),
                Text(
                    '${_cityController.text}, ${_stateController.text} ${_zipController.text}'),
                const SizedBox(height: 4),
                Text('Phone: ${_phoneController.text}'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Delivery method summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _deliveryOption == 'pickup'
                          ? Icons.store_outlined
                          : _deliveryOption == 'express'
                              ? Icons.delivery_dining_outlined
                              : Icons.local_shipping_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Delivery Method',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentStep = 0;
                        });
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  _deliveryOption == 'pickup'
                      ? 'Pickup (Ready in 30 min)'
                      : _deliveryOption == 'express'
                          ? 'Express Delivery (Next day)'
                          : 'Standard Delivery (2-3 days)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _deliveryOption == 'pickup'
                      ? 'Free'
                      : _deliveryOption == 'express'
                          ? '\$9.99'
                          : '\$4.99',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Order items summary
        const Text(
          'Order Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        // List of items
        ...cartItems.map((item) => _buildOrderItem(item)),

        const SizedBox(height: 20),

        // Order totals
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('\$${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax'),
                    Text('\$${tax.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Fee'),
                    Text('\$${deliveryFee.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(CheckoutCartItem item) {
    // Use FakeStore API for product images if the imageUrl is not provided
    final imageUrl = item.imageUrl ??
        'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.options.isNotEmpty)
                    Text(
                      item.options.entries
                          .map((e) =>
                              '${e.key}: ${e.value is List ? (e.value as List).join(', ') : e.value}')
                          .join(' • '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

            // Price and quantity
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
