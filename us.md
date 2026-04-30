# ShrinkPic - iOS Development Guide

## Executive Summary

ShrinkPic is a photo compression utility app designed for the US and global English-speaking market. It addresses the critical pain point of iPhone storage exhaustion caused by accumulated photos and screenshots. Unlike competitors that crash on batch processing or force subscriptions, ShrinkPic offers:

- **Stable batch compression** of 500+ photos without crashes
- **One-time purchase** at $2.99 — no subscription ever
- **Screenshot-specific optimization** — no competitor offers this
- **Storage analysis dashboard** — see exactly what's using your space
- **100% local processing** — zero data collection, complete privacy
- **Before/after comparison** — verify quality before committing

**Target Audience**: iPhone users running low on storage, screenshot hoarders, content creators who need smaller images for sharing, privacy-conscious users.

**Key Differentiator**: The only photo compressor that combines stable batch processing, screenshot specialization, and a one-time purchase model.

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Compress Photos & Pictures (MWM) | 4.5 rating, unlimited batch | Forced subscription, complex UI | One-time purchase, simpler UI |
| Photo Compress - Shrink Pics | Free, HEIC conversion | Tracks user data, ads | Zero tracking, no ads |
| AI Photo Compressor: Cleanup | Auto scheduling, cloud backup | Subscription required | One-time purchase, offline |
| PhotoCompress Pro | Fast, local processing | Limited features, new app | More features, storage dashboard |
| Simple Photo Compressor | 4.2 rating, no login | Basic features only | Advanced batch + screenshot mode |

## Apple Design Guidelines Compliance

- **HIG Photo & Video**: App uses PhotosUI framework for native photo picking experience
- **HIG Privacy**: All processing is on-device; no data leaves the device. Privacy policy clearly states zero collection
- **HIG Storage**: App accesses photo library only with explicit user permission via PHPhotoLibrary
- **HIG In-App Purchase**: One-time non-consumable purchase, no dark patterns, clear pricing
- **HIG Navigation**: TabView with clear sections — Home, Compress, History, Settings
- **HIG Dark Mode**: All colors use semantic system colors; materials adapt automatically
- **HIG Accessibility**: Dynamic Type support, VoiceOver labels on all interactive elements
- **Liquid Glass Icons**: App icon designed with clear foreground element on gradient background

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), PhotosUI, Photos framework
- **Data**: SwiftData (iOS 17+ native ORM)
- **Compression**: Native Image I/O framework (CGImageDestination, CGImageSource)
- **IAP**: StoreKit 2 (non-consumable)
- **Architecture**: MVVM with @Observable macro
- **Concurrency**: Swift async/await, @MainActor for UI updates
- **No third-party dependencies**: All compression uses Apple native APIs for maximum stability and App Store compliance

## Module Structure

```
ShrinkPic/
├── ShrinkPicApp.swift
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Compression/
│   │   ├── PhotoPickerView.swift
│   │   ├── CompressionSettingsView.swift
│   │   ├── CompressionProgressView.swift
│   │   └── CompressionResultView.swift
│   ├── Compare/
│   │   └── BeforeAfterCompareView.swift
│   ├── History/
│   │   └── HistoryView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   └── Components/
│       ├── StorageBar.swift
│       └── QualitySlider.swift
├── ViewModels/
│   ├── CompressionViewModel.swift
│   ├── StorageViewModel.swift
│   └── PurchaseViewModel.swift
├── Models/
│   ├── CompressionResult.swift
│   └── StorageCategory.swift
├── Services/
│   ├── CompressionEngine.swift
│   ├── PhotoLibraryService.swift
│   └── StorageAnalyzer.swift
└── Extensions/
    ├── Color+Hex.swift
    └── Int64+Format.swift
```

## Implementation Flow

1. Set up Xcode project with SwiftData, configure Bundle ID and deployment target
2. Create data models (CompressionResult with SwiftData @Model)
3. Implement CompressionEngine using native Image I/O APIs
4. Implement PhotoLibraryService for photo access and saving
5. Implement StorageAnalyzer for photo library analysis
6. Build HomeView with storage dashboard and quick actions
7. Build PhotoPickerView using PhotosPicker
8. Build CompressionSettingsView with quality/format/size options
9. Build CompressionProgressView with batch progress tracking
10. Build CompressionResultView with save/share/delete options
11. Build BeforeAfterCompareView with slider comparison
12. Build HistoryView with SwiftData query
13. Implement PurchaseViewModel with StoreKit 2
14. Build SettingsView with policy links and purchase restore
15. Build ContactSupportView with feedback submission
16. Test on iPhone and iPad simulators
17. Generate app icon and configure asset catalog
18. Create policy pages and deploy to GitHub Pages

## UI/UX Design Specifications

- **Color Scheme**: 
  - Primary: System Blue (#007AFF)
  - Success: System Green (#34C759)
  - Danger: System Red (#FF3B30)
  - Background: System grouped background
  - Cards: Ultra thin material (.ultraThinMaterial)
- **Typography**: SF Pro, Dynamic Type support
  - Large Title: 34pt bold (navigation)
  - Headline: 17pt bold (section headers)
  - Body: 17pt regular (content)
  - Caption: 12pt regular (metadata)
- **Layout**: 
  - Content max width 720pt for iPad
  - 16pt horizontal padding
  - 12pt spacing between items
  - Rounded rectangle cards with 16pt corner radius
- **Animations**:
  - Compression start: circular expand (0.3s)
  - Progress update: number counter animation (0.2s)
  - Compression complete: confetti effect (1.0s)
  - Before/after: real-time slider drag
  - Delete original: fade out + scale down (0.3s)

## Code Generation Rules

1. All async operations use async/await; UI updates use @MainActor
2. All views use SwiftUI — no UIKit mixing
3. SwiftData for iOS 17+ persistence
4. Zero third-party analytics SDK — all stats stored locally
5. Batch processing uses chunked approach with autoreleasepool to prevent memory overflow
6. Error handling uses Swift native throws/try/catch
7. Follow Swift API Design Guidelines for naming
8. Each file under 300 lines
9. No code comments unless explicitly requested
10. Native Image I/O for compression — no third-party compression libraries

## Build & Deployment Checklist

- [ ] Bundle ID: com.zzoutuo.ShrinkPic
- [ ] Deployment Target: iOS 17.0
- [ ] Swift Language Version: 5.0
- [ ] App Icon configured in Asset Catalog
- [ ] Photo Library usage description in Info.plist
- [ ] StoreKit 2 configuration file for IAP testing
- [ ] Build succeeds on iPhone simulator
- [ ] Build succeeds on iPad simulator
- [ ] App launches and core features work
- [ ] Policy pages deployed to GitHub Pages
- [ ] App Store metadata prepared (keytext.md)
- [ ] Screenshots captured for App Store
