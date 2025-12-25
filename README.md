# Currency Converter Application 💱

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/ci.yml)
[![Quick Check](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/quick-check.yml/badge.svg)](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/quick-check.yml)

A production-ready Flutter currency converter application built with **Clean Architecture**, **Bloc pattern**, and **offline-first** approach.


## 📱 Features

- ✅ **Real-time Currency Conversion** - Convert between 150+ currencies
- ✅ **Offline-First** - Works without internet after first launch
- ✅ **Historical Exchange Rates** - View 7-day exchange rate charts
- ✅ **Smart Search** - Quickly find currencies by code or name
- ✅ **Popular Currencies** - Quick access to frequently used currencies
- ✅ **Dark Mode Support** - Automatic theme switching
- ✅ **Debounced Input** - Optimized API calls while typing
- ✅ **Currency Swap** - Quick swap between source and target currencies

## 🏗️ Architecture

This project follows **Clean Architecture** principles with three distinct layers:

```
lib/
├── core/                    # Shared utilities and configurations
│   ├── database/           # SQLite database setup
│   ├── di/                 # Dependency injection configuration
│   ├── network/            # API client and error handling
│   └── utils/              # Shared utilities, colors, widgets
│
├── features/               # Feature modules
│   ├── currency/          # Currency list feature
│   │   ├── data/          # Data sources, models, repositories
│   │   ├── domain/        # Entities, use cases, repository interfaces
│   │   └── presentation/  # UI, Bloc, widgets
│   │
│   ├── home/              # Currency conversion feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── exchange_history/  # Historical rates feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── config/                # App-wide configuration
    ├── routes/            # Navigation setup
    └── theme/             # Theme configuration
```

### Layer Responsibilities

#### 1. **Presentation Layer** (`presentation/`)
- **Responsibility**: UI components and state management
- **Components**: Pages, Widgets, Bloc/Cubit
- **Dependencies**: Domain layer only
- **Example**: `CurrencyBloc`, `HomePage`, `CurrencyListItem`

#### 2. **Domain Layer** (`domain/`)
- **Responsibility**: Business logic and rules
- **Components**: Entities, Use Cases, Repository Interfaces
- **Dependencies**: None (pure Dart)
- **Example**: `Currency` entity, `GetCurrencies` use case

#### 3. **Data Layer** (`data/`)
- **Responsibility**: Data management and external communication
- **Components**: Models, Data Sources, Repository Implementations
- **Dependencies**: Domain layer
- **Example**: `CurrencyModel`, `CurrencyRemoteDataSource`, `CurrencyRepositoryImpl`

### Why Clean Architecture?

| Benefit | Description |
|---------|-------------|
| **Testability** | Business logic is isolated from frameworks, making unit testing straightforward |
| **Maintainability** | Clear separation of concerns makes code easier to understand and modify |
| **Scalability** | New features can be added without affecting existing code |
| **Independence** | UI, database, and external APIs can be changed independently |
| **Team Collaboration** | Different team members can work on different layers simultaneously |

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: 3.9.2 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Git**

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/currency_converter.git
   cd currency_converter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   
   The `.env` file contains:
   ```env
   # API Configuration
   BASE_URL=https://api.exchangerate.host
   
   # Optional: Add your API key if using a paid tier
   # API_KEY=your_api_key_here
   ```

4. **Generate code**
   
   Generate dependency injection and model code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the application**
   
   For development:
   ```bash
   flutter run
   ```
   
   For specific device:
   ```bash
   flutter run -d <device_id>
   ```
   
   List available devices:
   ```bash
   flutter devices
   ```

### Building for Production

#### Android APK
```bash
flutter build apk --release --split-per-abi
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 🧪 Testing

This project includes comprehensive unit tests for all layers.

### Run all tests
```bash
flutter test
```

### Run tests with coverage
```bash
flutter test --coverage
```

### View coverage report
```bash
# Install lcov (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### Test Structure

```
test/
├── features/
│   ├── currency/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       └── bloc/
│   ├── home/
│   └── exchange_history/
```

**Test Coverage:**
- ✅ Data Sources (Local & Remote)
- ✅ Models & Entities
- ✅ Repositories
- ✅ Use Cases
- ✅ Bloc/Cubit State Management

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language

### State Management
- **flutter_bloc** (^9.1.1): BLoC pattern implementation
- **Why?**: Predictable state management, excellent testability, clear separation of business logic

### Dependency Injection
- **injectable** (^2.5.0): Code generation for dependency injection
- **get_it** (^9.2.0): Service locator
- **Why?**: Loose coupling, better testing, cleaner codebase

### Local Database
- **sqflite** (^2.4.1): SQLite plugin for Flutter
- **sqlite3_flutter_libs** (^0.5.20): Native SQLite libraries
- **Why?**: 
  - Lightweight and fast
  - Perfect for offline-first approach
  - Ideal for caching static data (currencies)
  - No external dependencies
  - Excellent performance for read-heavy operations

### Networking
- **dio** (^5.3.3): HTTP client
- **retrofit** (^4.0.3): Type-safe HTTP client
- **pretty_dio_logger** (^1.3.1): Request/response logging
- **Why?**: Type-safe API calls, interceptors, automatic serialization

### Image Caching
- **cached_network_image** (^3.4.1): Image caching library
- **Why?**:
  - Automatic disk and memory caching
  - Improved performance (no repeated downloads)
  - Offline support (cached images available offline)
  - Placeholder and error widget support
  - Reduces bandwidth usage

### UI & Navigation
- **go_router** (^16.0.0): Declarative routing
- **flutter_sizer** (^1.0.5): Responsive design utilities
- **syncfusion_flutter_charts** (^31.1.19): Beautiful charts for historical data

### Utilities
- **intl** (^0.20.2): Internationalization and number formatting
- **easy_localization** (^3.0.7+1): Localization support
- **flutter_dotenv** (^5.2.1): Environment variable management
- **shared_preferences** (^2.3.3): Key-value storage for user preferences

### Development Tools
- **build_runner** (^2.3.0): Code generation
- **injectable_generator** (^2.6.2): DI code generation
- **mocktail** (^1.0.4): Mocking for tests
- **bloc_test** (^10.0.0): BLoC testing utilities
- **flutter_lints** (^5.0.0): Recommended linting rules

## 🌐 API Integration

### Base API Provider: ExchangeRate.host

**Official Documentation**: [https://exchangerate.host/documentation](https://exchangerate.host/documentation)

**Why ExchangeRate.host?**
- ✅ Free and reliable
- ✅ Well-documented API
- ✅ No rate limits for small projects
- ✅ Supports live, historical, and conversion endpoints
- ✅ No API key required for basic usage

### API Endpoints Used

#### 1. **Supported Currencies**
```http
GET https://api.exchangerate.host/list
```
**Purpose**: Fetch all supported currencies and their names

**Response Example**:
```json
{
  "success": true,
  "currencies": {
    "USD": "United States Dollar",
    "EUR": "Euro",
    "GBP": "British Pound Sterling"
  }
}
```

**Caching Strategy**: 
- Stored in local SQLite database
- Loaded from cache on subsequent app launches
- Manual refresh available via pull-to-refresh

#### 2. **Currency Conversion**
```http
GET https://api.exchangerate.host/convert?from=USD&to=EUR&amount=100
```
**Purpose**: Convert amount from one currency to another

**Response Example**:
```json
{
  "success": true,
  "query": {
    "from": "USD",
    "to": "EUR",
    "amount": 100
  },
  "info": {
    "rate": 0.92
  },
  "result": 92.0
}
```

**Optimization**: Debounced input (1 second delay) to reduce API calls

#### 3. **Historical Exchange Rates**
```http
GET https://api.exchangerate.host/timeseries?start_date=2025-12-18&end_date=2025-12-25&base=USD&symbols=EUR
```
**Purpose**: Fetch historical rates for chart visualization

**Response Example**:
```json
{
  "success": true,
  "timeseries": true,
  "start_date": "2025-12-18",
  "end_date": "2025-12-25",
  "base": "USD",
  "rates": {
    "2025-12-18": { "EUR": 0.92 },
    "2025-12-19": { "EUR": 0.93 }
  }
}
```

### Country Flags

Flags are loaded from **FlagCDN**:
```
https://flagcdn.com/w40/{country_code}.png
```

**Features**:
- Free CDN
- Fast delivery
- Supports ISO country codes
- Automatic caching via `cached_network_image`

## 🎨 UI/UX Design

### Material Design 3
- Uses Material 3 components
- Consistent color scheme (Cyan/Turquoise)
- Proper elevation and shadows
- Responsive layouts

### Theme Support
- ✅ Light theme
- ✅ Dark theme
- ✅ System theme detection

### Design Tokens
- Centralized color palette (`lib/core/utils/colors.dart`)
- Typography system
- Consistent spacing
- Reusable components

## 🔒 Offline-First Approach

### How it Works

1. **First Launch**:
   - Fetch currencies from API
   - Store in local SQLite database
   - Display to user

2. **Subsequent Launches**:
   - Load currencies from local database (instant)
   - App works fully offline
   - Optional: Pull-to-refresh to update data

3. **Conversion**:
   - Requires internet connection
   - Graceful error handling when offline
   - Clear error messages

### Benefits
- ⚡ Instant app startup
- 📱 Works without internet (for currency list)
- 💾 Reduced data usage
- 🚀 Better user experience

## 📊 State Management Pattern

### Bloc vs Cubit

| Feature | Bloc | Cubit |
|---------|------|-------|
| **Use Case** | Complex flows with events | Simple state changes |
| **Example** | `CurrencyBloc` | `ConvertCubit` |
| **Events** | Yes (LoadCurrencies, SearchCurrencies) | No (direct methods) |
| **Best For** | Multiple triggers, complex logic | Simple transformations |

### State Flow Example

```dart
// User types in search field
SearchCurrencies('USD') 
  ↓
CurrencyBloc processes event
  ↓
Filters currency list
  ↓
Emits CurrencyLoaded with filtered results
  ↓
UI rebuilds with filtered currencies
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# API Configuration
BASE_URL=https://api.exchangerate.host

# Optional: API Key (if using paid tier)
# API_KEY=your_api_key_here

# Optional: Enable debug logging
# DEBUG_MODE=true
```

### Customization

#### Change Default Currencies
Edit `lib/features/home/presentation/cubit/convert_cubit.dart`:
```dart
String _fromCurrency = 'USD';  // Change to your preferred default
String _toCurrency = 'EUR';    // Change to your preferred default
```

#### Modify Popular Currencies
Edit `lib/core/utils/conest.dart`:
```dart
const List<String> popularCurrencyCodes = [
  'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD',
  // Add your preferred currencies
];
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Build Runner Errors
```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Database Errors
```bash
# Clear app data
flutter clean
# Uninstall app from device
# Reinstall
flutter run
```

#### 3. Dependency Conflicts
```bash
# Update dependencies
flutter pub upgrade
# Check for conflicts
flutter pub outdated
```

## 📈 Performance Optimizations

- ✅ **Debounced API calls** (1 second delay on typing)
- ✅ **Image caching** (cached_network_image)
- ✅ **Database indexing** (SQLite primary keys)
- ✅ **Lazy loading** (BlocProvider)
- ✅ **Const constructors** (reduced rebuilds)
- ✅ **Efficient state management** (Bloc pattern)

## 🔄 CI/CD Pipeline

This project uses **GitHub Actions** for continuous integration and deployment.

### Workflows

#### 1. **CI/CD Pipeline** (`.github/workflows/ci.yml`)
Runs on push to `master`/`main`:
- ✅ Code formatting verification
- ✅ Static code analysis
- ✅ Unit tests with coverage
- 📦 Build Android APK (all architectures)
- 📦 Build Android App Bundle
- 🍎 Build iOS app

#### 2. **Quick Check** (`.github/workflows/quick-check.yml`)
Fast validation on every push:
- ⚡ Format check
- ⚡ Code analysis
- ⚡ Unit tests

### Build Artifacts

After successful builds, download artifacts from the **Actions** tab:
- `android-apk` - Release APKs (armeabi-v7a, arm64-v8a, x86_64)
- `android-appbundle` - App Bundle for Play Store
- `ios-build` - iOS build (unsigned)

**Retention**: 30 days

### Setup

The workflows run automatically. No configuration needed!

For detailed CI/CD documentation, see [CI_CD_DOCUMENTATION.md](CI_CD_DOCUMENTATION.md).

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Write tests for new features
- Update documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/your-profile)

## 🙏 Acknowledgments

- [ExchangeRate.host](https://exchangerate.host) for the free API
- [FlagCDN](https://flagcdn.com) for country flags
- Flutter community for excellent packages
- Clean Architecture principles by Robert C. Martin

## 📞 Support

If you have any questions or issues, please:
- Open an issue on GitHub
- Check existing issues for solutions
- Read the documentation

---

**Made with ❤️ using Flutter**
