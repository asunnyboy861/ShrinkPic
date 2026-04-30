# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Photo library access (compress photos) → Photo Library capability
- Save compressed photos to library → Photo Library write
- One-time in-app purchase ($2.99 Pro) → StoreKit capability
- 100% local processing → No network capability needed
- No push notifications mentioned
- No iCloud/sync mentioned
- No camera access needed
- No location services needed

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Photo Library Access | ✅ Configured | Info.plist NSPhotoLibraryUsageDescription |
| In-App Purchase | ✅ Configured | StoreKit 2 (no entitlement needed) |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| None | N/A | N/A |

## No Configuration Needed
- Push Notifications: Not required
- iCloud / CloudKit: Not required (100% local)
- HealthKit: Not required
- Camera: Not required
- Location Services: Not required
- Apple Watch: Not required
- Siri: Not required (Phase 2 feature)
- Background Modes: Not required
- Share Extension: Not required (Phase 2 feature)

## Info.plist Keys Required
- NSPhotoLibraryUsageDescription: "ShrinkPic needs access to your photo library to compress photos and free up storage space."

## Verification
- Build succeeded after configuration: Pending
- All entitlements correct: Pending
