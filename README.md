# FixMosselBay - Smart Service Reporting App

## Overview

FixMosselBay is an iOS application that enables residents to quickly and transparently report municipal issues (potholes, water leaks, broken streetlights, illegal dumping, power outages).

## Features

### Core Features
- **Issue Reporting**: Report municipal issues with photos, descriptions, and GPS location
- **Issue Tracking**: Track status updates (Logged → In Progress → Resolved)
- **Interactive Map**: View all issues on a map with filtering
- **Photo Capture**: Take photos or select from library
- **Location Services**: Automatic GPS coordinate capture
- **Unique Tracking IDs**: Each issue gets a unique identifier

### Issue Categories
- Pothole
- Water Leak
- Streetlight
- Illegal Dumping
- Power Outage

## Technical Details

- **Platform**: iOS 15.2+
- **Framework**: SwiftUI + Core Data
- **Location**: CoreLocation + MapKit
- **Photos**: PhotosUI + Camera access
- **Data**: Core Data with CloudKit support

## Setup

1. Open `FixSmart.xcodeproj` in Xcode
2. Build and run on device or simulator
3. Grant necessary permissions (location, camera, photos)

## Project Structure

- `MainTabView.swift` - Main navigation
- `ReportIssueView.swift` - Issue reporting
- `TrackIssuesView.swift` - Issue tracking
- `MapView.swift` - Interactive map
- `SettingsView.swift` - App settings
- `LocationManager.swift` - Location services

## Permissions

- Location access for GPS coordinates
- Camera access for photos
- Photo library access for image selection
