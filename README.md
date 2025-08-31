# MZANSI MATHS - Math Learning App 📱➗✨

A comprehensive iOS math learning application that helps students solve math problems using their camera, voice, and handwriting recognition. Built with SwiftUI and powered by PhotoMath API.

![MZANSI MATHS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 🌟 Features

### 🎯 **Math Problem Solver**
- **Camera Integration**: Take photos of math problems using your device camera
- **Voice Input**: Speak math problems in multiple languages (English, Xhosa, Afrikaans)
- **Handwriting Recognition**: Draw math problems with finger/stylus
- **PhotoMath API**: Powered by advanced math recognition technology
- **Instant Solutions**: Get step-by-step solutions to complex math problems

### 📚 **Practice Problems**
- **Multiple Subjects**: Algebra, Geometry, Calculus, Trigonometry, Statistics
- **Difficulty Levels**: Easy, Medium, and Hard problems
- **Interactive Learning**: Submit answers and get immediate feedback
- **Score Tracking**: Monitor your progress with a comprehensive scoring system

### 📊 **Progress Analytics Dashboard**
- **Learning Progress Tracking**: Monitor your improvement over time
- **Subject-wise Performance**: Detailed breakdown by math subject
- **Weekly/Monthly Reports**: Track your study patterns and achievements
- **Learning Insights**: AI-powered recommendations for improvement

### 💾 **Problem Management**
- **Save Solutions**: Store solved problems for future reference
- **Organized Library**: Browse saved problems by subject and difficulty
- **Search & Filter**: Easily find specific problems in your collection
- **Share Solutions**: Export and share solutions with classmates

### 🌍 **Multi-Language Support**
- **English**: Primary interface language
- **Xhosa**: Local South African language support
- **Afrikaans**: Additional local language support
- **Voice Recognition**: Native language speech input

## 🏗️ Architecture

### **Framework & Technologies**
- **SwiftUI**: Modern iOS development framework
- **Core Data**: Local data persistence with CloudKit support
- **PhotoMath API**: Advanced math problem solving via RapidAPI
- **Speech Framework**: Multi-language voice recognition
- **PencilKit**: Handwriting recognition and drawing
- **AVFoundation**: Camera and media integration

### **Core Components**
- `ContentView`: Main tab-based navigation
- `MathSolverView`: Camera-based problem solver
- `VoiceInputView`: Multi-language speech recognition
- `HandwritingView`: Drawing and recognition interface
- `PracticeProblemsView`: Interactive practice sessions
- `ProgressDashboardView`: Analytics and performance tracking
- `SavedProblemsView`: Problem library management
- `SettingsView`: User preferences and app configuration

## 📱 Screenshots

*[Screenshots will be added here after app deployment]*

## 🚀 Getting Started

### **Prerequisites**
- Xcode 13.0 or later
- iOS 15.0 or later
- Active PhotoMath API key from RapidAPI

### **Installation**
1. Clone the repository
   ```bash
   git clone https://github.com/SonwabileLanga/Mzansi-Maths.git
   cd Mzansi-Maths
   ```

2. Open the project in Xcode
   ```bash
   open fix.xcodeproj
   ```

3. Build and run the project on your device or simulator

### **API Configuration**
The app is pre-configured with a PhotoMath API key. For production use:
1. Sign up for [RapidAPI](https://rapidapi.com)
2. Subscribe to [PhotoMath API](https://rapidapi.com/photomath1/api/photomath1)
3. Replace the API key in `ContentView.swift`

### **Required Permissions**
- Camera access for taking photos
- Photo library access for selecting images
- Microphone access for voice input
- Speech recognition for voice-to-text conversion

## 🎯 Usage Guide

### **Solving Math Problems**
1. Open the "Solve" tab
2. Choose your input method:
   - 📷 **Camera**: Take a photo of a math problem
   - 🎤 **Voice**: Speak the problem in your preferred language
   - ✏️ **Handwriting**: Draw the problem with your finger
   - 🖼️ **Photo Library**: Select an existing image
3. Tap "Solve Problem" to get the solution
4. Save the solution for future reference

### **Practice Sessions**
1. Navigate to the "Practice" tab
2. Select subject and difficulty level
3. Generate new problems
4. Submit answers and review solutions
5. Track your progress with the scoring system

### **Progress Monitoring**
1. Access the "Progress" tab
2. View your learning statistics
3. Analyze subject performance
4. Get personalized insights and recommendations

## 🔧 Development

### **Project Structure**
```
MZANSI MATHS/
├── fix/
│   ├── ContentView.swift          # Main app interface
│   ├── Assets.xcassets/           # App icons and images
│   ├── fix.xcdatamodeld/          # Core Data model
│   ├── Info.plist                 # App configuration
│   ├── LaunchScreen.storyboard    # Launch screen
│   └── Preview Content/           # SwiftUI previews
├── fixTests/                      # Unit tests
├── fixUITests/                    # UI tests
└── README.md                      # Project documentation
```

### **Core Data Model**
- `MathProblemEntity`: Stores math problems and solutions
- `Item`: Legacy entity (can be removed in future versions)

### **API Integration**
- **Endpoint**: `https://photomath1.p.rapidapi.com/maths/solve-problem`
- **Method**: POST with multipart form data
- **Authentication**: RapidAPI key in headers
- **Response**: JSON with solution details

## 🌟 Future Enhancements

### **Planned Features**
- **Video Tutorials**: Step-by-step video explanations
- **Social Learning**: Study groups and peer collaboration
- **Offline Mode**: Download problems for offline practice
- **Advanced Analytics**: Machine learning insights
- **Teacher Dashboard**: Classroom management tools

### **Technical Improvements**
- **Machine Learning**: Local problem recognition
- **Performance Optimization**: Faster image processing
- **Accessibility**: Enhanced support for users with disabilities
- **Internationalization**: Additional language support

## 🤝 Contributing

We welcome contributions to improve MZANSI MATHS:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Swift coding conventions
- Add comments for complex logic
- Test on multiple iOS versions
- Ensure accessibility compliance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **PhotoMath API**: Advanced math recognition technology
- **Apple**: SwiftUI, Core Data, and iOS frameworks
- **RapidAPI**: API marketplace and integration
- **MZANSI MATHS Team**: Development and testing

## 📞 Support

For technical support or feature requests:
- Create an issue in the repository
- Contact the development team
- Check the documentation for common solutions

## 🌍 About MZANSI MATHS

**MZANSI MATHS** is dedicated to making mathematics accessible to students across South Africa and beyond. Our mission is to provide innovative, engaging, and effective math learning tools that support diverse learning styles and languages.

---

**Made with ❤️ for South African students**

**MZANSI MATHS** - Making mathematics accessible, one problem at a time! 📱➗✨
