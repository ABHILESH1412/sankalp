# 🎯 Sankalp - Social Media Shorts Blocker 🚀

Sankalp is an Android app designed to help users **block addictive short video content** like **YouTube Shorts, Instagram Reels, Snapchat Spotlight, and more**. This app uses **Android Accessibility Services** to detect and block these distractions, helping users stay focused and productive.

## 📌 Features

✅ **Block YouTube Shorts, Instagram Reels, Snapchat Spotlight, Snapchat Stories, TikTok, LinkedIn Clips, and X (Twitter) Videos**\
✅ **The app automatically detects videos playing on the home feed and mutes them for a seamless, distraction-free experience.**\
✅ **Auto-detection using Accessibility Services**\
✅ **Easy Start/Stop Toggle**\
✅ **Lightweight and Battery Efficient**

## 🚀 Getting Started

Follow these steps to **download, set up, and run the project** on your local machine.

### **1️⃣ Prerequisites**

Before you begin, ensure you have the following installed:

- **Flutter** (Latest stable version) → [Download Flutter](https://flutter.dev/docs/get-started/install)
- **Android Studio** (or Visual Studio Code with Flutter plugin)
- **Java JDK** (for Android development)

Check your setup by running:

```
flutter doctor
```

Ensure there are no critical errors before proceeding.

### **2️⃣ Clone the Repository**

Run the following command in your terminal to download the project:

```
git clone https://github.com/ABHILESH1412/sankalp.git
cd sankalp
```

### **3️⃣ Install Dependencies**

Inside the project folder, install the required Flutter packages:

```
flutter pub get
```

### **4️⃣ Run the App on an Emulator or Physical Device**

**📱 For Debug Mode (During Development)** Connect your Android device (or start an emulator) and run:

```
flutter run
```

**📦 For Building an APK (To Share \& Install)** To generate a debug APK:

```
flutter build apk
```

For a release APK (optimized for users):

```
flutter build apk --release
```

The APK will be in the `build/app/outputs/flutter-apk/` folder.

## 📲 Installing the APK

Download the latest `Sankalp.apk` from the [Releases page](https://github.com/ABHILESH1412/sankalp/releases/latest) (direct link: `https://github.com/ABHILESH1412/sankalp/releases/latest/download/Sankalp.apk`) and open it on your phone.

> **Upgrading from v1.0.0?** Uninstall v1.0.0 first. It was signed with a different key, so Android won't install newer versions over it. You only need to do this once.

### ⚠️ If Google Play Protect blocks the install

If Google Play Protect blocks the install ("App blocked" / "unsafe app"), it's because sankalp isn't from the Play Store. To install it anyway:

1. Open the Play Store, tap your profile icon (top right) → **Play Protect**.
2. Turn off **Scan apps with Play Protect**.
3. Open the APK again and install it.
4. Go back to the same setting and turn **Scan apps with Play Protect** on again.
5. **Allow restricted settings.** Long-press the sankalp icon → **App info** → **⋮** (top right) → **Allow restricted settings**. Android requires this for every app from outside the Play Store before its accessibility service can be switched on.

After that, open the app and enable its accessibility service when asked.

## 🔄 Automatic updates

The app checks GitHub for a new release every few hours and installs it automatically.

- Turn it on or off from the menu (☰ → **Auto-update**). It is on by default.
- Use **Check for updates** in the same menu to update right away.
- The first time, Android asks you to allow Sankalp to **install unknown apps**. Allow it so updates can install.
- On Android 12 and newer, updates install silently. On older versions, you'll get a notification. Tap it to confirm the install.

## 🚢 Releasing (maintainers)

Releases are built on GitHub Actions, so nothing heavy runs on your computer. Every release is a GitHub Release with a signed `Sankalp.apk`, and installed apps auto-update to it.

### One-time setup: signing key

Every release **must be signed with the same key**, otherwise Android refuses to install the update. Create a key once and **back it up somewhere safe**: if you lose it, existing users can't update anymore.

```
keytool -genkeypair -v -keystore ~/sankalp-release.jks -alias sankalp -keyalg RSA -keysize 4096 -validity 10000
```

Then store it as repository secrets (run inside this repo; you'll be prompted for the passwords):

```
base64 -w0 ~/sankalp-release.jks | gh secret set ANDROID_KEYSTORE_BASE64
gh secret set ANDROID_KEYSTORE_PASSWORD
gh secret set ANDROID_KEY_ALIAS --body sankalp
gh secret set ANDROID_KEY_PASSWORD
```

To build signed APKs locally as well, create `android/key.properties` (it's git-ignored):

```
storeFile=/home/you/sankalp-release.jks
storePassword=...
keyAlias=sankalp
keyPassword=...
```

### Publishing a release

Push your changes to `main`, then run:

```
scripts/release.sh          # patch: 1.2.3 -> 1.2.4
scripts/release.sh minor    # minor: 1.2.3 -> 1.3.0
scripts/release.sh major    # major: 1.2.3 -> 2.0.0
```

The script starts the **Release** workflow and waits for it to finish. The workflow bumps the version in `pubspec.yaml`, runs the tests, builds and signs the APK, commits the bump and the `vX.Y.Z` tag to `main`, and publishes the release. Run `git pull` afterwards to get the version bump commit. You can also start it from the **Actions** tab → **Release** → **Run workflow**.

## 📜 License

This project is **open-source**. Feel free to modify and use it for **personal** or **educational** purposes.

## 🙌 Support \& Feedback

If you like this project, please ⭐ star the repository! Have suggestions or issues? Open an issue on GitHub.

📩 Contact: \[three1412@proton.me\]

## Made with ❤️ for Digital Well-being 🚀
