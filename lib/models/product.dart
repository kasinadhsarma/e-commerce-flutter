import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;
  final bool isAvailable;
  final List<String> tags;
  final bool isFeatured;
  final bool isSeasonalItem;
  final List<ProductCustomizationOption> customizationOptions;
  final Map<String, dynamic>? nutritionalInfo;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
    this.isAvailable = true,
    this.tags = const [],
    this.isFeatured = false,
    this.isSeasonalItem = false,
    this.customizationOptions = const [],
    this.nutritionalInfo,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<ProductCustomizationOption> options = [];
    if (json['customizationOptions'] != null) {
      options = (json['customizationOptions'] as List)
          .map((option) => ProductCustomizationOption.fromJson(option))
          .toList();
    }

    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'] is int 
          ? (json['price'] as int).toDouble() 
          : json['price'].toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: json['rating'] is Map 
          ? json['rating']['rate'].toDouble() 
          : (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating'] is Map 
          ? json['rating']['count'] 
          : (json['ratingCount'] ?? 0),
      isAvailable: json['isAvailable'] ?? true,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      isFeatured: json['isFeatured'] ?? false,
      isSeasonalItem: json['isSeasonalItem'] ?? false,
      customizationOptions: options,
      nutritionalInfo: json['nutritionalInfo'],
    );
  }

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    data['id'] = int.tryParse(doc.id) ?? 0;
    return Product.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating,
      'ratingCount': ratingCount,
      'isAvailable': isAvailable,
      'tags': tags,
      'isFeatured': isFeatured,
      'isSeasonalItem': isSeasonalItem,
      'customizationOptions': customizationOptions.map((option) => option.toJson()).toList(),
      'nutritionalInfo': nutritionalInfo,
    };
  }

  // Copy with method for easy cloning with modifications
  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    double? rating,
    int? ratingCount,
    bool? isAvailable,
    List<String>? tags,
    bool? isFeatured,
    bool? isSeasonalItem,
    List<ProductCustomizationOption>? customizationOptions,
    Map<String, dynamic>? nutritionalInfo,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isAvailable: isAvailable ?? this.isAvailable,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      isSeasonalItem: isSeasonalItem ?? this.isSeasonalItem,
      customizationOptions: customizationOptions ?? this.customizationOptions,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
    );
  }
}

// Model for product customization options (like size, type, extras, etc.)
class ProductCustomizationOption {
  final String name;
  final bool required;
  final SelectionType selectionType; // Single or multiple selection
  final List<CustomizationChoice> choices;
  final int? maxSelections; // For multiple selections, null means unlimited

  ProductCustomizationOption({
    required this.name,
    this.required = false,
    this.selectionType = SelectionType.single,
    required this.choices,
    this.maxSelections,
  });

  factory ProductCustomizationOption.fromJson(Map<String, dynamic> json) {
    return ProductCustomizationOption(
      name: json['name'],
      required: json['required'] ?? false,
      selectionType: SelectionType.values.firstWhere(
        (type) => type.toString() == 'SelectionType.${json['selectionType']}',
        orElse: () => SelectionType.single,
      ),
      choices: (json['choices'] as List)
          .map((choice) => CustomizationChoice.fromJson(choice))
          .toList(),
      maxSelections: json['maxSelections'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'required': required,
      'selectionType': selectionType.toString().split('.').last,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'maxSelections': maxSelections,
    };
  }
}

// Types of selection for customization options
enum SelectionType {
  single,  // Radio buttons (only one choice)
  multiple // Checkboxes (can select multiple choices)
}

// Individual choices within a customization option
class CustomizationChoice {
  final String name;
  final double? additionalPrice;
  final bool isDefault;
  final String? image;

  CustomizationChoice({
    required this.name,
    this.additionalPrice,
    this.isDefault = false,
    this.image,
  });

  factory CustomizationChoice.fromJson(Map<String, dynamic> json) {
    return CustomizationChoice(
      name: json['name'],
      additionalPrice: json['additionalPrice']?.toDouble(),
      isDefault: json['isDefault'] ?? false,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'additionalPrice': additionalPrice,
      'isDefault': isDefault,
      'image': image,
    };
  }
}