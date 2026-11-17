# Cloud Dragon Studio (Native iOS)

A calm, 100% original creative dress-up and makeover studio for kids aged 4–9, built natively for **iOS 16.0+** (iPhone + iPad Universal) using **SwiftUI, Core Graphics, StoreKit 2, and AVFoundation**, matching the visual charm and full gameplay of the Cloud Dragon Studio Android edition.

## Build & Run (macOS / Xcode 15+)

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen):
   ```bash
   brew install xcodegen
   ```
2. Generate `CloudDragonStudio.xcodeproj`:
   ```bash
   xcodegen generate
   ```
3. Open `CloudDragonStudio.xcodeproj` in Xcode 15+, select scheme `CloudDragonStudio` (configured with `CloudDragonStudio.storekit`), and run on an iPhone or iPad Simulator (`iOS 16.0+`).

## Features
- **6 Freely Accessible Areas**: `Scale Studio` (masked Core Graphics brush/gradient/rainbow/dots/stamps + unlimited Undo/Redo/Reset), `Wardrobe` (5 categories, 20 vector-thumbnail recolorable items with Hue Slider, 80% free), `Cloud Bath` (4-step spa with tappable bubbles), `Bake Nook` (5 cookie shapes, icing & sprinkles undo/redo, oven & dragon feeding), `Pet Garden` (Bunny, Cloud Fox, Butter Cat), `Photo Booth` (4 backdrops, Sit/Wave pose, stickers, in-app Album + add-only Apple Photos export).
- **3 Modes**: `Free Studio` (12 persistent save slots), `Daily Wish` (7 bilingual wishes, zero pass/fail grading), `Sticker Book` (always free).
- **Kids-Safe & App Store Compliance**: `PrivacyInfo.xcprivacy` (no tracking, no IDFA), `ParentalGateSheet` (adult multiplication OR 3-second hold), `MockAdService` (>= 180s transition cooldown, never during painting), `StoreKit 2` non-consumable Premium + Restore Purchases, EN/VI `Localizable.xcstrings`, Dynamic Type, VoiceOver, and Reduce Motion.
