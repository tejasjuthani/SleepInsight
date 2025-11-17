# SleepInsight

**Advanced sleep analytics powered by HealthKit** — Decode your Apple Sleep Score, understand what affects your sleep, and get actionable daily tips.

## Overview

SleepInsight is a comprehensive iOS app that transforms your HealthKit sleep data into meaningful insights. Unlike basic sleep trackers, SleepInsight provides dual-layer scoring, behavioral insights, and personalized action plans to help you improve your sleep quality.

## Features

### 1. Dual Sleep Scoring System

**Apple Sleep Score (0-100)**
- Raw score based on direct summation of components
- Duration (0-50) + Bedtime (0-30) + Interruptions (0-20)

**SleepInsight Adjusted Score (0-100)**
- Weighted formula that prioritizes sleep quality
- Duration: 50% weight
- Bedtime Consistency: 30% weight
- Sleep Interruptions: 20% weight
- Helps you understand which factors matter most

### 2. Component Breakdown

Detailed analysis of three sleep quality factors:

**Duration (0-50 points)**
- Tracks total sleep time
- Optimal range: 7-9 hours
- Shows formatted sleep time (e.g., "8h 15m")
- Color-coded progress bars

**Bedtime Consistency (0-30 points)**
- Evaluates regularity of bedtime
- Ideal window: 9:00 PM - 11:00 PM
- Displays actual bedtime
- Highlights impact on circadian rhythm

**Sleep Continuity (0-20 points)**
- Counts nighttime interruptions
- Minimal interruptions = better quality
- Shows wake-up frequency
- Identifies sleep fragmentation issues

### 3. Behavioral Insights Engine

**What Helped Your Score**
- Identifies positive sleep factors
- Example: "Excellent Sleep Duration — You slept 8h 15m, which is in the optimal 7-9 hour range"
- Impact levels: High, Medium, Low
- Green-highlighted positive factors

**What Hurt Your Score**
- Pinpoints specific problem areas
- Example: "Irregular Bedtime — You went to bed at 11:47 PM, which is later than optimal. You lost 8 points."
- Orange-highlighted negative factors
- Quantifies point loss

**Score Adjustment Explanation**
- Explains why Apple and SleepInsight scores differ
- Shows which weighting formula was applied
- Helps users understand the "why" behind scores

### 4. Daily Action Plan

**Intelligent Tip Generation**
- ONE actionable tip per day
- Based on your lowest-scoring component
- Three priority levels:
  - 🔴 Critical (score <40%)
  - 🟠 High Priority (score <70%)
  - 🟡 Medium Priority (score ≥70%)

**Tip Structure**
- **Why**: Explanation of the problem
- **What To Do**: Specific, measurable action
- **Focus Area**: Component being addressed

**Example Tips**
- Duration: "Go to bed 60 minutes earlier tonight to reach 7h 30m"
- Bedtime: "Set a wind-down alarm for 9:30 PM and aim to be in bed by 10:00 PM"
- Interruptions: "Limit fluids 2 hours before bed and reduce screen time 30 minutes before sleep"

### 5. Morning Readiness Score

**1-10 Scale**
- Calculated from adjusted sleep score: `readiness = score / 10 (rounded)`
- Visual 10-bar progress indicator
- Emoji indicators (🚀 💪 😊 😐 😴)

**Readiness Categories**
- **9-10**: Peak Performance — "Great for hard workouts and challenging tasks"
- **7-8**: High Readiness — "Energy levels are solid for a productive day"
- **5-6**: Moderate Readiness — "Pace yourself and prioritize important tasks"
- **3-4**: Low Energy — "Consider light activities and prioritize rest tonight"
- **1-2**: Recovery Needed — "Take it easy today and focus on sleep tonight"

## Technical Architecture

### Models
- `SleepScoreModel.swift` — Dual scoring with raw metrics
- `InsightModel.swift` — Behavioral insight factors
- `DailyTipModel.swift` — Action plan tips
- `ReadinessModel.swift` — Morning readiness calculator

### Services
- `HealthKitService.swift` — HealthKit integration
- `SleepAnalyzer.swift` — Dual scoring engine
- `InsightEngine.swift` — Behavioral analysis
- `TipEngine.swift` — Daily tip generator

### Views
- `MainDashboardView.swift` — Unified scroll view
- `SleepScoreView.swift` — Dual score display
- `InsightBreakdownView.swift` — What helped/hurt
- `DailyTipView.swift` — Action plan
- `ReadinessView.swift` — Morning readiness

## Sleep Scoring Algorithm

### Apple Sleep Score (Simple Sum)
```
appleSleepScore = durationScore + bedtimeScore + interruptionsScore
```

### SleepInsight Adjusted Score (Weighted)
```
adjustedScore = (durationScore × 0.50) +
                (bedtimeScore × 0.30) +
                (interruptionsScore × 0.20)
```

### Component Calculations

**Duration Score (0-50)**
- 7-9 hours: 45-50 points (optimal)
- 6-7 or 9-10 hours: 30-44 points (good)
- <6 or >10 hours: 0-29 points (poor)

**Bedtime Score (0-30)**
- 9-11 PM: 30 points (perfect)
- 8-9 PM or 11 PM-midnight: 21-24 points (good)
- Other times: 9-18 points (fair to poor)

**Interruptions Score (0-20)**
- 0-1 interruptions: 18-20 points
- 2-3 interruptions: 14-16 points
- 4-5 interruptions: 10-12 points
- >5 interruptions: 0-9 points

## UI/UX Design

### Clean Apple-Style Layout

**Gradient Background**
- Dark purple/indigo gradient
- Professional, calming aesthetic
- Consistent with sleep theme

**Card-Based Design**
- White rounded cards with shadows
- Clear visual hierarchy
- Easy to scan

**Color Coding**
- 🟢 Green: 80-100 (excellent)
- 🔵 Blue: 60-79 (good)
- 🟠 Orange: 40-59 (fair)
- 🔴 Red: 0-39 (poor)

### Single Scroll Layout

1. **Yesterday's Sleep Scores** (Dual display)
2. **Component Breakdown** (3 bars with metrics)
3. **What Helped / What Hurt** (Insight cards)
4. **Morning Readiness** (1-10 scale)
5. **Daily Action Plan** (ONE tip)

## Requirements

- iOS 17.0+
- iPhone only (portrait)
- Apple Watch with Sleep tracking
- HealthKit access

## Setup Instructions

### 1. Open in Xcode
```bash
open SleepInsight.xcodeproj
```

### 2. Configure Signing
1. Select **SleepInsight** project
2. Select **SleepInsight** target
3. **Signing & Capabilities** → Select your Team
4. Verify **HealthKit** capability is present

### 3. Build & Run
- Select iPhone device or simulator
- Press ⌘R
- Grant HealthKit permissions on first launch

## How It Works

1. **Data Collection**
   - Reads yesterday's sleep samples from HealthKit
   - Extracts duration, bedtime, and interruptions

2. **Dual Scoring**
   - Calculates Apple score (simple sum)
   - Calculates SleepInsight score (weighted formula)

3. **Insight Generation**
   - Analyzes each component's performance
   - Identifies positive and negative factors
   - Explains score differences

4. **Tip Generation**
   - Determines lowest-scoring component
   - Selects appropriate tip category
   - Assigns priority level
   - Provides specific action item

5. **Readiness Calculation**
   - Converts adjusted score to 1-10 scale
   - Displays energy forecast

## Privacy & Data

- **100% On-Device Processing**
- No external servers
- No cloud sync
- No analytics
- All data stays in HealthKit

## Project Structure

```
SleepInsight/
├── SleepInsight.xcodeproj/
├── SleepInsight/
│   ├── SleepInsightApp.swift
│   ├── ContentView.swift
│   ├── SleepInsight.entitlements
│   ├── Models/
│   │   ├── SleepScoreModel.swift
│   │   ├── DailyTipModel.swift
│   │   ├── ReadinessModel.swift
│   │   └── InsightModel.swift
│   ├── Services/
│   │   ├── HealthKitService.swift
│   │   ├── SleepAnalyzer.swift
│   │   ├── InsightEngine.swift
│   │   └── TipEngine.swift
│   ├── Views/
│   │   ├── MainDashboardView.swift
│   │   ├── SleepScoreView.swift
│   │   ├── InsightBreakdownView.swift
│   │   ├── DailyTipView.swift
│   │   └── ReadinessView.swift
│   └── Assets.xcassets/
└── README.md
```

## Technical Specifications

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Target Device**: iPhone (portrait only)
- **Bundle ID**: com.tjtechnologies.sleepinsight
- **Architecture**: MVVM pattern
- **Dependencies**: None (HealthKit only)

## Troubleshooting

### No Sleep Data Found
- Ensure Apple Watch was worn to bed
- Check Sleep tracking is enabled
- Verify HealthKit permissions granted

### HealthKit Not Available
- Requires physical device with HealthKit
- Simulators have limited functionality

### Build Errors
- Xcode 15.0+ required
- iOS 17.0+ deployment target
- Clean build folder (⌘⇧K) and rebuild

## Future Enhancements (Not in MVP)

The following features are intentionally excluded:
- Historical trends and charts
- Apple Watch companion app
- Push notifications
- User settings customization
- Cloud sync
- Export/sharing features
- Sleep goals and tracking

## GitHub Repository

https://github.com/tejasjuthani/SleepInsight

## License

Created by TJ Technologies

---

**Ready to understand your sleep better?** Open SleepInsight.xcodeproj in Xcode and start improving your sleep tonight.
