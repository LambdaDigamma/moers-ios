# Button Styles

This directory contains reusable button styles for the CityOS application, now adapted to use the Liquid Glass design pattern.

## Overview

The button styles have been updated to provide a modern appearance with support for iOS 18+ features while maintaining backward compatibility with iOS 16-17.

## Available Button Styles

### LiquidGlassButtonStyle

The core button style that implements the Liquid Glass design pattern. This style provides:

- **iOS 18+**: Uses modern materials like `.ultraThinMaterial` for secondary buttons, providing a glass-like translucent effect
- **iOS 16-17**: Falls back to solid colors with the same visual appearance

**Usage:**

```swift
Button("Click Me") {
    // Action
}
.buttonStyle(LiquidGlassButtonStyle(prominence: .primary))

// Or use convenience extensions
Button("Click Me") {
    // Action
}
.liquidGlassPrimary()

Button("Cancel") {
    // Action
}
.liquidGlassSecondary()
```

### PrimaryButtonStyle

Primary action button with yellow background and black text. Now uses `LiquidGlassButtonStyle` internally.

**Usage:**

```swift
Button("Save Changes") {
    // Action
}
.buttonStyle(PrimaryButtonStyle())
```

### SecondaryButtonStyle

Secondary action button with yellow text and translucent background (glass effect on iOS 18+). Now uses `LiquidGlassButtonStyle` internally.

**Usage:**

```swift
Button("Cancel") {
    // Action
}
.buttonStyle(SecondaryButtonStyle())
```

### EfaPrimaryButtonStyle

Custom button style for EFA (transit) features with configurable accent colors via environment values. Enhanced with Liquid Glass design pattern.

**Usage:**

```swift
Button("Activate Trip") {
    // Action
}
.buttonStyle(EfaPrimaryButtonStyle())
.efaAccentColor(.blue)
.efaOnAccentColor(.white)
```

## Design Principles

### Liquid Glass Design

The Liquid Glass design pattern emphasizes:

1. **Translucency**: Using materials like `.ultraThinMaterial` on iOS 18+ for secondary buttons
2. **Depth**: Visual hierarchy through backgrounds and opacity
3. **Responsiveness**: Visual feedback on press (opacity changes)
4. **Consistency**: Unified appearance across the application

### iOS Version Support

All button styles now support:

- **iOS 18+**: Modern materials and effects
- **iOS 16-17**: Compatible fallback implementations

The styles automatically detect the iOS version and apply the appropriate implementation.

## Migration Guide

Existing code using `PrimaryButtonStyle` and `SecondaryButtonStyle` will automatically benefit from the Liquid Glass design without any code changes.

If you want to use the new `LiquidGlassButtonStyle` directly:

```swift
// Before
Button("Action") { }
.buttonStyle(PrimaryButtonStyle())

// After (alternative, more explicit)
Button("Action") { }
.liquidGlassPrimary()
```

## Customization

To create a custom button style with the Liquid Glass pattern, you can:

1. Use `LiquidGlassButtonStyle` directly with custom prominence
2. Create a new `ButtonStyle` that uses `LiquidGlassButtonStyle` internally (like `PrimaryButtonStyle` and `SecondaryButtonStyle`)
3. Implement your own version checking and material usage

## Examples

See the preview providers in each button style file for visual examples and code samples.
