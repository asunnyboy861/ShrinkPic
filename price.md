# Pricing Configuration

## Monetization Model: Free + One-Time IAP

- **Price**: Free download with 5 photos/day free tier
- **IAP**: One-time non-consumable purchase ($2.99)
- **Subscription**: None — no subscription ever

## In-App Purchase Details

### Pro Unlock (Non-Consumable)
- **Reference Name**: ShrinkPic Pro
- **Product ID**: `com.zzoutuo.ShrinkPic.pro`
- **Price**: $2.99 (one-time purchase)
- **Display Name**: ShrinkPic Pro
- **Description**: Unlimited photo compression forever

### Free Tier Limits
- 5 photos per day
- All compression features available
- Storage dashboard available

### Pro Tier Benefits
- Unlimited batch compression (500+ photos)
- No daily limits
- Before/after comparison
- Delete originals after compression
- All future features included

## App Store Connect Pricing
- **Price Tier**: Free (with In-App Purchase)

## Policy Pages Required
- Support Page: ✅
- Privacy Policy: ✅
- Terms of Use: ❌ (Not needed for non-subscription apps)

## StoreKit Configuration
- Product ID: com.zzoutuo.ShrinkPic.pro
- Type: Non-Consumable
- StoreKit Testing: Enabled via .storekit configuration file
