# Google Sign-In platform setup

## Android

The app ID is `com.shopstack.elearn`, matching `android/app/google-services.json`.

1. In Firebase Console, add both debug and release SHA-1 and SHA-256 fingerprints.
2. Enable Google under **Authentication > Sign-in method**.
3. Re-download `google-services.json` after adding the fingerprints and replace `android/app/google-services.json`.
4. Copy the generated Web OAuth client ID into the backend `GOOGLE_CLIENT_ID` setting.
5. Pass that same value to Flutter when running or building:

```powershell
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

For a release build, provide both the current backend origin and Google Web client ID. Do not add a trailing slash to `API_BASE_URL`:

```powershell
flutter build apk --release `
  --dart-define=API_BASE_URL=https://YOUR-CURRENT-BACKEND-DOMAIN `
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

The values are compiled into the APK. If a free ngrok domain changes, rebuild and reinstall the APK with the new URL.

Get debug fingerprints with:

```powershell
cd android
./gradlew signingReport
```

The configured Web OAuth client ID is `949329981376-3h45u3mtb8n1j4bpdkn6qdtempj3hkrc.apps.googleusercontent.com`. The backend `GOOGLE_CLIENT_ID` must use this same value.

## iOS

Register the iOS bundle ID in Firebase, download `GoogleService-Info.plist`, and add it to `ios/Runner` through Xcode with the Runner target selected. Add the plist's `REVERSED_CLIENT_ID` as a `CFBundleURLSchemes` value in `ios/Runner/Info.plist`.

The Android `google-services.json` cannot be used to derive iOS credentials. iOS setup remains pending until the project-specific `GoogleService-Info.plist` is supplied.
