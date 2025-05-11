#!/bin/bash

# Script to build Android release
echo "Building E-Commerce Android Release App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing Flutter..."
    sudo snap install flutter --classic
    echo "Flutter installed successfully."
fi

# Navigate to project root
cd "$(dirname "$0")"

# Fix dependency conflicts before building
echo "Fixing dependency conflicts..."
flutter pub add intl:^0.20.2

# Clean the project
echo "Cleaning project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build Android release
echo "Building Android release APK..."
flutter build apk --release

# Build App Bundle for Play Store
echo "Building Android App Bundle for Play Store..."
flutter build appbundle --release

echo "Build completed successfully!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo "AAB location: build/app/outputs/bundle/release/app-release.aab"