# Cloud Dragon Studio (Native iOS)

A calm, 100% original creative dress-up and makeover studio for kids aged 4–9, built natively for iOS 16.0+ using SwiftUI, Core Graphics, StoreKit 2, and AVFoundation.

## Build & Run (macOS / Xcode 15+)

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen):
   ```bash
   brew install xcodegen
   ```
2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
3. Open `CloudDragonStudio.xcodeproj` in Xcode 15+, select the `CloudDragonStudio` scheme (with `CloudDragonStudio.storekit` attached for local StoreKit 2 testing), and run on an iPhone or iPad Simulator (`iOS 16.0+`).

## Command-Line Build & Tests
```bash
xcodebuild test -project CloudDragonStudio.xcodeproj -scheme CloudDragonStudio -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Unsigned IPA for Sideloadly (CI)
Every push to `main` triggers `.github/workflows/ios.yml` on `macos-15`, which generates the `.xcodeproj`, runs unit + UI tests on both iPhone and iPad simulators, captures simulator screenshots, archives unsigned, and packages `CloudDragonStudio.ipa` for Sideloadly.
