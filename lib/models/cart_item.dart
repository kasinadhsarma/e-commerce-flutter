import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final List<SelectedCustomization> customizations;
  final String? specialInstructions;
  
  CartItem({
    required this.product,
    this.quantity = 1,
    this.customizations = const [],
    this.specialInstructions,
  });

  // Calculate total price including customizations
  double get total {
    double basePrice = product.price * quantity;
    double customizationsPrice = 0.0;
    
    for (var customization in customizations) {
      for (var choice in customization.selectedChoices) {
        if (choice.additionalPrice != null) {
          customizationsPrice += choice.additionalPrice! * quantity;
        }
      }
    }
    
    return basePrice + customizationsPrice;
  }
  
  // Check if this cart item has the same product and customizations as another
  bool isSameConfiguration(CartItem other) {
    if (product.id != other.product.id) return false;
    if (customizations.length != other.customizations.length) return false;
    
    // Compare each customization
    for (var i = 0; i < customizations.length; i++) {
      var thisCustomization = customizations[i];
      
      // Find matching customization in other item
      var otherMatchingCustomization = other.customizations.firstWhere(
        (c) => c.option.name == thisCustomization.option.name,
        orElse: () => SelectedCustomization(
          option: ProductCustomizationOption(
            name: '', 
            choices: []
          ),
          selectedChoices: []
        ),
      );
      
      // If no matching customization was found, or choices differ
      if (otherMatchingCustomization.option.name.isEmpty ||
          !_areChoiceListsEqual(thisCustomization.selectedChoices, otherMatchingCustomization.selectedChoices)) {
        return false;
      }
    }
    
    return specialInstructions == other.specialInstructions;
  }
  
  // Helper to compare two lists of customization choices
  bool _areChoiceListsEqual(List<CustomizationChoice> list1, List<CustomizationChoice> list2) {
    if (list1.length != list2.length) return false;
    
    for (var choice1 in list1) {
      bool foundMatch = false;
      for (var choice2 in list2) {
        if (choice1.name == choice2.name) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) return false;
    }
    
    return true;
  }
  
  // Create a copy of this cart item with updated properties
  CartItem copyWith({
    Product? product,
    int? quantity,
    List<SelectedCustomization>? customizations,
    String? specialInstructions,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'customizations': customizations.map((c) => c.toJson()).toList(),
      'specialInstructions': specialInstructions,
    };
  }
}

// Class to store the selected customizations for a cart item
class SelectedCustomization {
  final ProductCustomizationOption option;
  final List<CustomizationChoice> selectedChoices;
  
  SelectedCustomization({
    required this.option,
    required this.selectedChoices,
  });
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'optionName': option.name,
      'selectedChoices': selectedChoices.map((c) => c.name).toList(),
    };
  }
}