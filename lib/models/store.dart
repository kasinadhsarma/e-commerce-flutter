import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final Map<String, String> businessHours;
  final List<String> amenities;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final bool isActive;
  
  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.businessHours,
    this.amenities = const [],
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
  });
  
  factory Store.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return Store(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      businessHours: Map<String, String>.from(data['businessHours'] ?? {}),
      amenities: List<String>.from(data['amenities'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      latitude: (data['location']?['latitude'] ?? 0.0).toDouble(),
      longitude: (data['location']?['longitude'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'businessHours': businessHours,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'isActive': isActive,
    };
  }
  
  // Check if store is currently open
  bool get isOpen {
    final now = DateTime.now();
    final dayOfWeek = _getDayOfWeek(now.weekday);
    
    if (!businessHours.containsKey(dayOfWeek)) {
      return false;
    }
    
    final hoursString = businessHours[dayOfWeek] ?? '';
    if (hoursString.toLowerCase() == 'closed') {
      return false;
    }
    
    // Parse business hours (format: "9:00 AM - 10:00 PM")
    final parts = hoursString.split(' - ');
    if (parts.length != 2) {
      return false;
    }
    
    final openingTime = _parseTimeString(parts[0]);
    final closingTime = _parseTimeString(parts[1]);
    
    if (openingTime == null || closingTime == null) {
      return false;
    }
    
    final currentTime = DateTime(
      now.year, 
      now.month, 
      now.day, 
      now.hour, 
      now.minute
    );
    
    return currentTime.isAfter(openingTime) && 
           currentTime.isBefore(closingTime);
  }
  
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return '';
    }
  }
  
  DateTime? _parseTimeString(String timeString) {
    // Parse time strings like "9:00 AM" or "10:00 PM"
    final parts = timeString.trim().split(' ');
    if (parts.length != 2) {
      return null;
    }
    
    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) {
      return null;
    }
    
    int hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final period = parts[1].toUpperCase();
    
    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }
    
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}