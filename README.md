# SleepInsight

A minimal iOS app that decodes your Apple Sleep Score and provides personalized sleep insights.

## Overview

SleepInsight is a SwiftUI-based iPhone app that helps you understand your sleep patterns by analyzing HealthKit sleep data. It provides three core MVP features:

1. **Sleep Score Decoder** - Breaks down your Apple Sleep Score into three components
2. **Daily Tip Generator** - Provides actionable advice based on your lowest-scoring component
3. **Morning Readiness Score** - Shows your energy level for the day ahead

## Features

### Sleep Score Decoder
- Reads yesterday's Apple Sleep Score from HealthKit
- Parses and displays the three scoring components:
  - Duration Score (0-50 points)
  - Bedtime Consistency Score (0-30 points)
  - Interruptions Score (0-20 points)
- Provides plain-language explanations for each component
- Highlights your lowest-scoring area for improvement

### Daily Tip Generator
- Analyzes your sleep score to identify your weakest area
- Generates one actionable, personalized tip:
  - Duration-focused tips for low sleep duration
  - Bedtime consistency tips for irregular schedules
  - Sleep hygiene tips for frequent interruptions

### Morning Readiness Score
- Calculates a 1-10 readiness score based on your total sleep score
- Displays:
  - Readiness score with emoji indicator
  - Category label (Peak Performance, High Readiness, etc.)
  - Short description of your expected energy level
  - Visual progress bar

## Requirements

- iOS 17.0+
- iPhone only
- Apple Watch with sleep tracking
- HealthKit access

## Setup Instructions

### 1. Open in Xcode
1. Navigate to the project folder
2. Double-click `SleepInsight.xcodeproj`
3. Wait for Xcode to load the project

### 2. Configure Signing
1. Select the **SleepInsight** project in the Project Navigator
2. Select the **SleepInsight** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** from the dropdown
5. Xcode will automatically manage signing

### 3. Enable HealthKit Capability
The project is already configured with HealthKit entitlements, but verify:
1. In **Signing & Capabilities** tab, you should see **HealthKit** capability
2. If not present, click **+ Capability** and add **HealthKit**

### 4. Build and Run
1. Select your iPhone device or simulator from the scheme selector
2. Click the **Run** button (⌘R)
3. The app will build and launch

### 5. Grant HealthKit Permissions
1. On first launch, tap **Connect to HealthKit**
2. Grant permission to read Sleep data
3. The app will automatically fetch yesterday's sleep data

## Project Structure

```
SleepInsight/
├── SleepInsight.xcodeproj/
│   └── project.pbxproj
├── SleepInsight/
│   ├── SleepInsightApp.swift          # App entry point
│   ├── ContentView.swift              # Main view coordinator
│   ├── SleepInsight.entitlements      # HealthKit permissions
│   ├── Models/
│   │   ├── SleepScoreModel.swift      # Sleep score data model
│   │   ├── DailyTipModel.swift        # Daily tip generator
│   │   └── ReadinessModel.swift       # Readiness score calculator
│   ├── Services/
│   │   ├── HealthKitService.swift     # HealthKit integration
│   │   └── SleepAnalyzer.swift        # Sleep data analysis
│   ├── Views/
│   │   ├── SleepScoreView.swift       # Sleep score breakdown UI
│   │   ├── DailyTipView.swift         # Daily tip display
│   │   └── ReadinessView.swift        # Readiness score UI
│   └── Assets.xcassets/               # App assets
└── README.md
```

## Technical Details

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Target Device**: iPhone
- **Bundle ID**: com.tjtechnologies.sleepinsight
- **HealthKit Framework**: Sleep analysis data
- **Architecture**: MVVM pattern

## How It Works

### Sleep Score Calculation

The app analyzes HealthKit sleep samples to calculate component scores:

**Duration Score (0-50 points)**
- 7-9 hours of sleep: 45-50 points
- 6-7 or 9-10 hours: 35-44 points
- Less than 6 or more than 10 hours: 0-34 points

**Bedtime Consistency Score (0-30 points)**
- Based on how close your bedtime is to the ideal range (9pm-11pm)
- Consistent bedtime patterns score higher

**Interruptions Score (0-20 points)**
- 0-1 interruptions: 18-20 points
- 2-3 interruptions: 14-17 points
- 4-5 interruptions: 10-13 points
- More than 5: 0-9 points

### Readiness Calculation
```swift
readiness = totalSleepScore / 10 (rounded, clamped to 1-10)
```

## Troubleshooting

### No Sleep Data Found
- Ensure you wore your Apple Watch to bed last night
- Check that Sleep tracking is enabled on your Apple Watch
- Verify HealthKit permissions are granted

### HealthKit Not Available
- This app requires a physical device with HealthKit support
- Simulators have limited HealthKit functionality

### Build Errors
- Ensure you're running Xcode 15.0 or later
- Verify your deployment target is set to iOS 17.0+
- Clean build folder (⌘⇧K) and rebuild

## Future Enhancements (Not in MVP)

The following features are intentionally excluded from this MVP:
- Trend charts and historical data
- Apple Watch companion app
- Push notifications
- User settings and customization
- Cloud sync
- Analytics

## GitHub Repository

https://github.com/tejasjuthani/SleepInsight

## License

Created by TJ Technologies
