import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  canceled,
}

enum DeliveryMethod {
  pickup,
  delivery,
}

enum PaymentMethod {
  creditCard,
  debitCard,
  wallet,
  applePay,
  googlePay,
  loyaltyPoints,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final OrderStatus status;
  final DeliveryMethod deliveryMethod;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? promoCode;
  final int? loyaltyPointsUsed;
  final int? loyaltyPointsEarned;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final String? storeId;
  final Map<String, dynamic>? paymentDetails;
  
  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    this.scheduledFor,
    required this.status,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    this.promoCode,
    this.loyaltyPointsUsed,
    this.loyaltyPointsEarned,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.storeId,
    this.paymentDetails,
  });
  
  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    // Parse items
    final itemsList = (data['items'] as List? ?? []);
    
    // Since we can't directly convert to CartItem without products,
    // this is a simplified version that will need to be enhanced with 
    // additional product fetching logic in a real implementation
    List<CartItem> items = [];
    
    return Order(
      id: doc.id,
      userId: data['userId'],
      items: items, // Placeholder, needs product fetching logic
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledFor: data['scheduledFor'] != null 
          ? (data['scheduledFor'] as Timestamp).toDate() 
          : null,
      status: OrderStatus.values.firstWhere(
        (s) => s.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      deliveryMethod: DeliveryMethod.values.firstWhere(
        (d) => d.toString() == 'DeliveryMethod.${data['deliveryMethod']}',
        orElse: () => DeliveryMethod.pickup,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.toString() == 'PaymentMethod.${data['paymentMethod']}',
        orElse: () => PaymentMethod.creditCard,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (p) => p.toString() == 'PaymentStatus.${data['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      ),
      subtotal: (data['subtotal'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      deliveryFee: (data['deliveryFee'] as num).toDouble(),
      discount: (data['discount'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      promoCode: data['promoCode'],
      loyaltyPointsUsed: data['loyaltyPointsUsed'],
      loyaltyPointsEarned: data['loyaltyPointsEarned'],
      deliveryAddress: data['deliveryAddress'],
      deliveryInstructions: data['deliveryInstructions'],
      storeId: data['storeId'],
      paymentDetails: data['paymentDetails'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledFor': scheduledFor != null ? Timestamp.fromDate(scheduledFor!) : null,
      'status': status.toString().split('.').last,
      'deliveryMethod': deliveryMethod.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
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
  }
}