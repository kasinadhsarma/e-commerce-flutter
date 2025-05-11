import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final int loyaltyPoints;
  final List<String> addresses;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.loyaltyPoints = 0,
    this.addresses = const [],
    this.preferences = const {},
    required this.createdAt,
    this.lastLoginAt,
  });

  // Create a UserModel from Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  // Create a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      addresses: List<String>.from(data['addresses'] ?? []),
      preferences: data['preferences'] ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'loyaltyPoints': loyaltyPoints,
      'addresses': addresses,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    int? loyaltyPoints,
    List<String>? addresses,
    Map<String, dynamic>? preferences,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      addresses: addresses ?? this.addresses,
      preferences: preferences ?? this.preferences,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}