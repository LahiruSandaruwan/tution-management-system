# Firebase Setup Instructions

## Prerequisites
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app to the Firebase project

## Android Setup

1. **Download google-services.json**
   - In Firebase Console, go to Project Settings
   - Download `google-services.json`
   - Place it in `android/app/` directory

2. **Update android/build.gradle**
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```

3. **Update android/app/build.gradle**
   ```gradle
   apply plugin: 'com.google.gms.google-services'

   android {
     defaultConfig {
       minSdkVersion 21  // FCM requires min SDK 21
     }
   }
   ```

## iOS Setup

1. **Download GoogleService-Info.plist**
   - In Firebase Console, go to Project Settings
   - Download `GoogleService-Info.plist`
   - Add it to `ios/Runner/` directory in Xcode

2. **Update ios/Runner/AppDelegate.swift**
   ```swift
   import UIKit
   import Flutter
   import Firebase

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       FirebaseApp.configure()
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

3. **Enable Push Notifications**
   - Open project in Xcode
   - Go to Signing & Capabilities
   - Add "Push Notifications" capability
   - Add "Background Modes" capability and enable "Remote notifications"

## Testing Notifications

1. **Get FCM Token**
   - Run the app
   - Check console logs for "FCM Token: xxx"

2. **Send Test Notification**
   - Go to Firebase Console > Cloud Messaging
   - Click "Send your first message"
   - Enter notification details
   - Select your app
   - Send test message

## Backend Integration

Update your backend to send notifications:

```javascript
// Example using Firebase Admin SDK (Node.js)
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Send to specific device
const message = {
  token: 'DEVICE_FCM_TOKEN',
  notification: {
    title: 'New Notification',
    body: 'You have a new message'
  },
  data: {
    type: 'payment_reminder',
    payload: JSON.stringify({id: 123})
  }
};

admin.messaging().send(message)
  .then(response => console.log('Successfully sent message:', response))
  .catch(error => console.log('Error sending message:', error));
```

## Notification Types

The app handles these notification types:
- `payment_reminder` - Payment due reminders
- `payment_overdue` - Overdue payment alerts
- `exam_notification` - Upcoming exam notifications
- `grade_published` - New grades available
- `class_cancellation` - Class cancellation alerts
- `announcement` - General announcements

## Troubleshooting

1. **Token not received**: Check Firebase configuration files are properly added
2. **Notifications not showing**: Verify notification permissions are granted
3. **Background notifications not working**: Check background modes are enabled (iOS)
