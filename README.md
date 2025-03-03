# 🎯 Sankalp - Social Media Shorts Blocker 🚀  

Sankalp is an Android app designed to help users **block addictive short video content** like **YouTube Shorts, Instagram Reels, Snapchat Spotlight, and more**. This app uses **Android Accessibility Services** to detect and block these distractions, helping users stay focused and productive.  

## 📌 Features  
✅ **Block YouTube Shorts, Instagram Reels, Snapchat Spotlight, Snapchat Stories, TikTok, LinkedIn Clips, and X (Twitter) Videos**  
✅ **The app automatically detects videos playing on the home feed and mutes them for a seamless, distraction-free experience.**  
✅ **Auto-detection using Accessibility Services**  
✅ **Easy Start/Stop Toggle**  
✅ **Lightweight and Battery Efficient**  

## 🚀 Getting Started  

Follow these steps to **download, set up, and run the project** on your local machine.

### **1️⃣ Prerequisites**  
Before you begin, ensure you have the following installed:  
- **Flutter** (Latest stable version) → [Download Flutter](https://flutter.dev/docs/get-started/install)  
- **Android Studio** (or Visual Studio Code with Flutter plugin)  
- **Java JDK** (for Android development)  

Check your setup by running:  
```sh
flutter doctor
```
Ensure there are no critical errors before proceeding.

### **2️⃣ Clone the Repository**

Run the following command in your terminal to download the project:
```sh
git clone https://github.com/your-username/sankalp.git
cd sankalp
```

### **3️⃣ Install Dependencies**

Inside the project folder, install the required Flutter packages:
```sh
flutter pub get
```

### **4️⃣ Run the App on an Emulator or Physical Device**

**📱 For Debug Mode (During Development)**
Connect your Android device (or start an emulator) and run:
```sh
flutter run
```

**📦 For Building an APK (To Share & Install)**
To generate a debug APK:
```sh
flutter build apk
```

For a release APK (optimized for users):
```sh
flutter build apk --release
```

The APK will be in the `build/app/outputs/flutter-apk/` folder.

### **⚠️ Important Note: Enabling Accessibility Services (Android 13+)**

If you install the app directly from an APK file (sideloading), Android 13 and later versions may display a "Restricted Setting" message when you try to enable the app's accessibility service. This is a security feature. To enable the accessibility service, follow these steps:

1.  **Long-press the app icon.**
2.  **Select "App info"** (or the equivalent option on your device).
3.  **Tap the three-dot menu (⋮)** in the top-right corner of the app info screen.
4.  **Choose "Allow restricted settings"** (or a similarly worded option).
5.  **Authenticate** with your device's PIN, pattern, or fingerprint if prompted.
6.  **You're all set!** You can now enable the accessibility service for Sankalp in your device's settings and enjoy a distraction-free experience.

## 📜 License

This project is **open-source**. Feel free to modify and use it for **personal** or **educational** purposes.

## 🙌 Support & Feedback
If you like this project, please ⭐ star the repository!
Have suggestions or issues? Open an issue on GitHub.

📩 Contact: [three1412@proton.me]

## Made with ❤️ for Digital Well-being 🚀