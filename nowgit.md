# Git Repositories

## Main App (iOS Application + Policy Pages)

| Item | Value |
|------|-------|
| **Repository Name** | ShrinkPic |
| **Git URL** | git@github.com:asunnyboy861/ShrinkPic.git |
| **Repo URL** | https://github.com/asunnyboy861/ShrinkPic |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

### Deployed Pages

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/ShrinkPic/ | ✅ Active |
| Support | https://asunnyboy861.github.io/ShrinkPic/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/ShrinkPic/privacy.html | ✅ Active |

**Note**: Terms of Use not required for Free + One-Time IAP apps.

## Repository Structure

### Main App Repository
```
ShrinkPic/
├── ShrinkPic/                        # iOS App Source Code
│   ├── ShrinkPic.xcodeproj/          # Xcode Project
│   └── ShrinkPic/                    # Swift Source Files
│       ├── Views/
│       ├── Models/
│       ├── ViewModels/
│       ├── Services/
│       └── Extensions/
├── docs/                             # Policy Pages for GitHub Pages
│   ├── index.html                    # Landing Page
│   ├── support.html                  # Support Page
│   └── privacy.html                  # Privacy Policy
├── .github/workflows/                # GitHub Actions
│   └── deploy-pages.yml              # GitHub Pages deployment
├── us.md                             # English Development Guide
├── keytext.md                        # App Store Metadata
├── capabilities.md                   # Capabilities Configuration
├── icon.md                           # App Icon Details
├── price.md                          # Pricing Configuration
└── nowgit.md                         # This File
```
