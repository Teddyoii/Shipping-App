# 📦 Shipping Tracker - Flutter App

A modern, real-time shipping tracking application for merchants built with Flutter and Firebase. Track orders, manage deliveries, and receive instant notifications - all on the FREE Firebase plan.


## ✨ Features

- 🔐 **Authentication** - Secure email/password login with Firebase Auth
- 📊 **Dashboard** - Real-time statistics with interactive charts
- 📦 **Order Management** - Create, view, filter, and update orders
- 🗺️ **Live Tracking** - Google Maps integration for delivery tracking
- 🔔 **Push Notifications** - Real-time order status updates
- 📥 **Excel Export** - Export orders to Excel files
- 💬 **Remarks System** - Add notes and comments to orders
- 🎨 **Modern UI** - Clean Material Design interface

## 📱 Screenshots


<img width="108" height="240" alt="Screenshot_1774683753" src="https://github.com/user-attachments/assets/0d83fd46-5dae-4fe9-b4a7-cc7675985292" />
<img width="108" height="240" alt="Screenshot_1774683744" src="https://github.com/user-attachments/assets/fd141842-2f12-445d-b1fe-47c4997cd176" />
<img width="108" height="240" alt="Screenshot_1774683903" src="https://github.com/user-attachments/assets/130ac2e4-9ab5-42c3-bc20-abd35af02998" />
<img width="108" height="240" alt="Screenshot_1774683856" src="https://github.com/user-attachments/assets/e29423db-c8ad-46a1-8793-4a3b43ba5842" />
<img width="108" height="240" alt="Screenshot_1774683844" src="https://github.com/user-attachments/assets/049a5805-b3db-4a75-8d1b-ee4ba3f7fb76" />
<img width="108" height="240" alt="Screenshot_1774683839" src="https://github.com/user-attachments/assets/1d83cab0-1a18-43c6-ae6e-5dfbd533b9f6" />
<img width="108" height="240" alt="Screenshot_1774683787" src="https://github.com/user-attachments/assets/cdff926d-9567-44af-b221-95c78e378ee1" />
<img width="108" height="240" alt="Screenshot_1774683760" src="https://github.com/user-attachments/assets/2cec03e4-f829-4ffb-a1d0-2d84ae405f0f" />
<img width="108" height="240" alt="Screenshot_1774683757" src="https://github.com/user-attachments/assets/d7f41e24-606d-4e50-95af-0e18781c0431" />



## 🏗️ Architecture

This project follows **Clean Architecture** principles with **BLoC** state management pattern.

```
lib/
├── core/                          # Core utilities
│   ├── di/                        # Dependency injection
│   ├── services/                  # Shared services
│   └── theme/                     # App theming
│
├── domain/                        # Business logic layer
│   └── entities/                  # Domain models
│       ├── user.dart
│       ├── order.dart
│       └── dashboard_stats.dart
│
└── features/                      # Feature modules
    ├── auth/                      # Authentication
    │   ├── data/
    │   │   ├── datasources/       # Firebase Auth API
    │   │   └── repositories/      # Repository implementation
    │   └── presentation/
    │       ├── bloc/              # Auth BLoC
    │       └── pages/             # Login, Loading pages
    │
    ├── dashboard/                 # Dashboard
    │   ├── data/
    │   │   ├── datasources/       # Firestore queries
    │   │   └── repositories/
    │   └── presentation/
    │       ├── bloc/              # Dashboard BLoC
    │       ├── pages/             # Dashboard page
    │       └── widgets/           # Stat cards, charts
    │
    ├── orders/                    # Order management
    │   ├── data/
    │   │   ├── datasources/       # CRUD operations
    │   │   └── repositories/
    │   └── presentation/
    │       ├── bloc/              # Orders BLoC
    │       ├── pages/             # Orders list, details
    │       └── widgets/           # Order cards, filters
    │
    └── tracking/                  # Location tracking
        └── presentation/
            └── pages/             # Maps tracking page
```

### Architecture Layers

#### 1️⃣ **Presentation Layer**
- **BLoC** for state management
- **Pages** for screens
- **Widgets** for reusable UI components

#### 2️⃣ **Domain Layer**
- **Entities** - Pure business models
- Independent of external frameworks

#### 3️⃣ **Data Layer**
- **Repositories** - Abstract data sources
- **DataSources** - Firebase/API implementations

### Design Patterns Used

- ✅ **BLoC Pattern** - Separates business logic from UI
- ✅ **Repository Pattern** - Abstracts data sources
- ✅ **Dependency Injection** - Uses GetIt for DI
- ✅ **Observer Pattern** - Real-time Firestore listeners
- ✅ **Singleton Pattern** - Service instances

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase account (FREE plan)
- Google Maps API key
- Android Studio / VS Code

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/shipping-tracker.git
cd shipping-tracker
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your Firebase project
flutterfire configure
```

4. **Add Google Maps API Key**

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS:** `ios/Runner/AppDelegate.swift`
```swift
import GoogleMaps
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

5. **Update Merchant ID in main.dart**
```dart
// Replace with your actual merchant ID from Firestore
NotificationService().startListeningToOrders('YOUR_MERCHANT_ID');
```

6. **Run the app**
```bash
flutter run
```

## 🔧 Firebase Setup

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com)
- Create new project
- Select FREE Spark plan

### 2. Enable Services
- ✅ Authentication (Email/Password)
- ✅ Cloud Firestore
- ✅ Cloud Messaging (FCM)
- ✅ Storage (optional)

### 3. Firestore Structure

```
merchants/
  └── {merchantId}
      ├── email: string
      ├── merchantName: string
      └── createdAt: timestamp

orders/
  └── {orderId}
      ├── merchantId: string
      ├── customerName: string
      ├── customerPhone: string
      ├── deliveryAddress: string
      ├── status: string
      ├── totalAmount: number
      ├── orderDate: timestamp
      ├── items: array
      ├── remarks: array
      └── currentLocation: map
```

### 4. Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /merchants/{merchantId} {
      allow read, write: if request.auth != null && request.auth.uid == merchantId;
    }
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📦 Key Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| flutter_bloc | State management | ^8.1.3 |
| firebase_core | Firebase SDK | ^2.24.2 |
| cloud_firestore | Database | ^4.13.6 |
| firebase_auth | Authentication | ^4.15.3 |
| google_maps_flutter | Maps | ^2.5.0 |
| syncfusion_flutter_xlsio | Excel export | ^23.2.7 |
| fl_chart | Charts | ^0.65.0 |

[See complete dependencies](pubspec.yaml)

## 🎯 Usage

### Login
```
Email: demo@merchant.com
Password: demo123
```

### Update Order Status
1. Navigate to Orders
2. Select an order
3. Tap Edit icon (✏️)
4. Choose new status
5. Notification triggers automatically

### Export Orders
1. Go to Orders page
2. Tap Download icon (⬇️)
3. Excel file saved to device

### Track Delivery
1. Open order details
2. Tap Map icon (🗺️)
3. View real-time location

## 🔔 Push Notifications

### How It Works

1. **Firestore Listener** monitors order changes
2. When status updates → **Local notification** shows
3. Works on **FREE Firebase plan** (no Cloud Functions needed)

### Test Notifications

**Method 1: Update in App**
- Change order status in app
- Notification appears instantly

**Method 2: Firebase Console**
- Update order in Firestore
- App detects change
- Notification shows

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 📱 Build & Deploy

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Open ios/Runner.xcworkspace in Xcode
```

## 🐛 Troubleshooting

### Common Issues

**Issue: Firebase not initialized**
```bash
flutterfire configure
```

**Issue: Google Maps not showing**
- Verify API key in AndroidManifest.xml
- Check API is enabled in Google Cloud Console

**Issue: Notifications not working**
- Verify merchant ID matches Firestore
- Check notification permissions granted

**Issue: Build fails**
```bash
flutter clean
flutter pub get
flutter run
```

## 📊 Performance

- **App Size:** ~35 MB (Android APK)
- **Cold Start:** < 2 seconds
- **Hot Reload:** < 500ms
- **Database Queries:** Real-time with Firestore
- **Offline Support:** Firestore caching enabled

## 🔒 Security

- ✅ Firebase Authentication
- ✅ Firestore Security Rules
- ✅ Secure API keys (not in source code)
- ✅ Input validation
- ✅ Error handling

## 🚦 Roadmap

- [ ] Multi-language support (i18n)
- [ ] Dark mode theme
- [ ] Customer-facing app
- [ ] SMS notifications
- [ ] Advanced analytics
- [ ] Offline mode
- [ ] Payment integration

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Alhan**


## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Firebase](https://firebase.google.com) - Backend services
- [BLoC Library](https://bloclibrary.dev) - State management
- [Syncfusion](https://www.syncfusion.com/flutter-widgets) - Excel export
- [FL Chart](https://github.com/imaNNeo/fl_chart) - Charts

## 📞 Support

If you find this project helpful, please ⭐ star the repository!

For issues and questions:
- Open an [Issue](https://github.com/yourusername/shipping-tracker/issues)
- Check [Documentation](docs/)
- Join [Discussions](https://github.com/yourusername/shipping-tracker/discussions)

---

**Built with ❤️ using Flutter**

Made with 🚀 by Alhan
