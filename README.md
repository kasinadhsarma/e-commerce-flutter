# Flutter E-Commerce App

A complete e-commerce mobile application built with Flutter featuring product listings, shopping cart, search functionality, and user profiles.

## Features

- **Product Catalog:** Browse products with filtering by categories
- **Shopping Cart:** Add, remove, and update quantities of products
- **Product Search:** Search for products by name, description, or category
- **User Profile:** View account information and order history
- **Product Details:** View detailed information about products
- **Checkout Process:** Simple checkout flow

## Screenshots

(Screenshots will be added after running the app)

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or VS Code
- Android emulator or physical device

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/kasinadhsarma/e-commerce-flutter.git
   ```

2. Navigate to the project directory:
   ```
   cd e-commerce-flutter
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Architecture

The app follows a clean architecture approach with:

- **Models:** Data models (Product, CartItem)
- **Providers:** State management using Provider package
- **Screens:** UI screens for different app features
- **Widgets:** Reusable UI components
- **Services:** API and other service integrations

## Dependencies

- **provider:** For state management
- **http:** For API calls
- **cached_network_image:** For efficient image loading and caching
- **shared_preferences:** For local storage
- **flutter_rating_bar:** For product ratings
- **badges:** For cart badge indicator

## API

This app uses the Fake Store API (https://fakestoreapi.com/) for product data.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
