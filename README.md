# Bravia Remote

Sony Bravia TV Remote Control App with Text Input functionality.

## Features

- **Full Remote Control**: D-Pad navigation, volume, power, numbers
- **Text Input**: Type on your phone, send to TV (great for YouTube/Netflix search)
- **Quick Launch**: Netflix, YouTube buttons
- **Playback Controls**: Play, pause, stop, fast forward, rewind
- **Color Buttons**: Red, green, yellow, blue function keys

## Screenshots

The app features a dark theme with an intuitive remote control layout.

## TV Setup (Required)

Before using the app, configure your Sony Bravia TV:

1. Go to **Settings > Network > Home Network Setup > IP Control**
2. Enable **Remote device/Renderer**
3. Set **Simple IP Control** to **On**
4. Note your TV's IP address (Settings > Network > Network Status)
5. Enable **Remote device control** (Settings > Network & Internet > Remote device settings)
6. Enable **Remote start** if you want power-on to work while the TV is off

**That's it!** The app uses PIN pairing, so you don't need to configure PSK.

## App Setup (Easy PIN Pairing)

1. Open the app
2. Tap **Connect to TV**
3. (Optional) Tap **Auto Discover** to find your TV on Wi-Fi
4. Enter your **TV's IP Address** (e.g., 192.168.1.100)
5. Tap **Pair with PIN**
6. Look at your TV - it will show a 4-digit code
7. Enter the code in the app
8. Done! Tap **Save Settings**

On iOS, allow **Local Network** access when prompted so the app can reach
your TV on Wi-Fi.

## Using Text Input

1. On your TV, open a search box (YouTube, Netflix, browser, etc.)
2. In the app, tap the keyboard icon or **Text Input** button
3. Type your text
4. Tap **Send to TV**

The text will appear in the TV's active text field. Some custom app search boxes
may not accept text input unless the system keyboard is visible.

## Building

### Prerequisites

- Flutter SDK 3.x
- For iOS: macOS with Xcode (or use cloud build)
- For Android: Android SDK

### Local Build (Android)

```bash
flutter pub get
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

### Cloud Build (iOS without Mac)

This project includes configurations for:

1. **GitHub Actions** - Push to GitHub, download IPA from Actions artifacts
2. **Codemagic** - Connect repo to codemagic.io for automated builds

For iOS, the IPA is unsigned. Install it by re-signing with AltStore or
LiveContainer.

### Installing on iPhone (without App Store)

1. Build the IPA using GitHub Actions or Codemagic
2. Download the IPA file
3. Install using **LiveContainer** or **AltStore**

## Technical Details

### Sony Bravia API

The app uses Sony's REST API:

- **System Control**: `/sony/system` (power, info)
- **App Control**: `/sony/appControl` (text input, app launch)
- **IRCC**: `/sony/IRCC` (remote button presses via SOAP)
- **Audio**: `/sony/audio` (volume control)

Authentication uses Pre-Shared Key via `X-Auth-PSK` header.

### Text Input API

```json
POST http://<TV_IP>/sony/appControl
Header: X-Auth-PSK: <your-psk>
Content-Type: application/json

{
  "method": "setTextForm",
  "id": 1,
  "params": [{"text": "Hello World"}],
  "version": "1.0"
}
```

## Compatibility

- **TV**: Sony Bravia Android TV (2016 or newer)
- **Phone**: iOS 12+ or Android 5.0+

## References

- https://nwr-studio.com/zh/bravia-controller/how-to-use/

## License

MIT License

## Acknowledgments

- Sony Bravia IP Control Protocol documentation
- Flutter framework
