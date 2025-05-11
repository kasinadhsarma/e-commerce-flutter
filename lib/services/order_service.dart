import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all orders for the current user
  Stream<List<Order>> getUserOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    });
  }

  // Get a specific order by ID
  Future<Order?> getOrderById(String orderId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return null;
    }

    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) {
      return null;
    }

    // Verify that the order belongs to the current user
    final order = Order.fromFirestore(doc);
    if (order.userId != userId) {
      return null;
    }

    return order;
  }

  // Create a new order
  Future<String> createOrder({
    required List<CartItem> items,
    required DeliveryMethod deliveryMethod,
    required PaymentMethod paymentMethod,
    required double subtotal,
    required double tax,
    required double deliveryFee,
    required double discount,
    required double total,
    DateTime? scheduledFor,
    String? promoCode,
    int? loyaltyPointsUsed,
    String? deliveryAddress,
    String? deliveryInstructions,
    String? storeId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Calculate loyalty points earned (assuming 1 point per dollar spent)
    final loyaltyPointsEarned = total.round();

    final orderData = {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'scheduledFor':
          scheduledFor != null ? Timestamp.fromDate(scheduledFor) : null,
      'status': OrderStatus.pending.toString().split('.').last,
      'deliveryMethod': deliveryMethod.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': PaymentStatus.pending.toString().split('.').last,
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'promoCode': promoCode,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
      'storeId': storeId,
      'paymentDetails': paymentDetails,
    };

    final doc = await _firestore.collection('orders').add(orderData);
    return doc.id;
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get the order to verify it belongs to the current user
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) {
      throw Exception('Order not found');
    }

    final orderData = doc.data() as Map<String, dynamic>;
    if (orderData['userId'] != userId) {
      throw Exception('Unauthorized access to order');
    }

    // Check if the order can be canceled (only pending or confirmed orders)
    final currentStatus = OrderStatus.values.firstWhere(
      (s) => s.toString() == 'OrderStatus.${orderData['status']}',
      orElse: () => OrderStatus.pending,
    );

    if (![OrderStatus.pending, OrderStatus.confirmed].contains(currentStatus)) {
      throw Exception('Order cannot be canceled at this stage');
    }

    // Cancel the order
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.canceled.toString().split('.').last,
    });
  }

  // Reorder from a previous order
  Future<String> reorder(String previousOrderId) async {
    final order = await getOrderById(previousOrderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Create a new order with the same items
    return createOrder(
      items: order.items,
      deliveryMethod: order.deliveryMethod,
      paymentMethod: order.paymentMethod,
      subtotal: order.subtotal,
      tax: order.tax,
      deliveryFee: order.deliveryFee,
      discount: 0, // New discount may apply
      total:
          order.subtotal + order.tax + order.deliveryFee, // Recalculate total
      deliveryAddress: order.deliveryAddress,
      deliveryInstructions: order.deliveryInstructions,
      storeId: order.storeId,
    );
  }
}
