# 知味 (ZhiWei)

A food ingredient knowledge app for iOS/macOS built with SwiftUI.

## Features

- Browse ingredient categories (vegetables, fruits, meats, etc.)
- Detailed ingredient information including seasonality and storage tips
- Cooking tips and substitution suggestions
- Built-in knowledge base with extensive ingredient data
- Hierarchical category navigation

## Tech Stack

- **Language:** Swift 5.9
- **Framework:** SwiftUI
- **Platform:** iOS 17+ / macOS 14+

## Project Structure

```
Sources/ZhiWei/
  Models/      — Ingredient data models
  Services/    — Knowledge base and storage services
  ViewModels/  — View models for UI state management
  Views/       — SwiftUI views
Tests/ZhiWeiTests/
```

## Development

```bash
# Build
swift build

# Test
swift test

# Lint
swiftlint

# Generate Xcode project
xcodegen
```
