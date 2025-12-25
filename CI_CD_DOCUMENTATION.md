# 🚀 CI/CD Pipeline Documentation

This project uses **GitHub Actions** for continuous integration and continuous deployment (CI/CD).

## 📋 Overview

We have two main workflows:

### 1. **CI/CD Pipeline** (`.github/workflows/ci.yml`)
**Triggers**: Push or PR to `master` or `main` branch

**Jobs**:
- ✅ **Test & Analyze**: Code formatting, analysis, and unit tests
- 📦 **Build Android APK**: Builds release APK for all architectures
- 📦 **Build App Bundle**: Builds Android App Bundle for Play Store
- 🍎 **Build iOS**: Builds iOS app (macOS runner)

### 2. **Quick Check** (`.github/workflows/quick-check.yml`)
**Triggers**: Push to any branch, PR to `master`/`main`

**Jobs**:
- ⚡ **Quick Analysis & Tests**: Fast validation (formatting, analysis, tests)

---

## 🔄 Workflow Details

### CI/CD Pipeline (Full Build)

#### Job 1: Test & Analyze
```yaml
Steps:
1. Checkout code
2. Setup Java 17
3. Setup Flutter 3.35.1
4. Install dependencies
5. Verify code formatting
6. Analyze code (flutter analyze)
7. Generate code (build_runner)
8. Run unit tests with coverage
9. Upload coverage to Codecov (optional)
```

**Duration**: ~5-7 minutes

#### Job 2: Build Android APK
```yaml
Steps:
1. Checkout code
2. Setup Java & Flutter
3. Install dependencies
4. Generate code
5. Build APK (split per ABI)
6. Upload artifacts (armeabi-v7a, arm64-v8a, x86_64)
```

**Output**: 3 APK files (one per architecture)
**Duration**: ~8-10 minutes

#### Job 3: Build App Bundle
```yaml
Steps:
1. Checkout code
2. Setup Java & Flutter
3. Install dependencies
4. Generate code
5. Build App Bundle
6. Upload artifact
```

**Output**: `app-release.aab` (for Play Store)
**Duration**: ~8-10 minutes

#### Job 4: Build iOS
```yaml
Steps:
1. Checkout code
2. Setup Flutter
3. Install dependencies
4. Generate code
5. Build iOS (no codesign)
6. Upload artifact
```

**Output**: `Runner.app` (iOS build)
**Duration**: ~10-12 minutes
**Note**: Runs on macOS (slower, but necessary for iOS)

---

## 📊 Workflow Visualization

```
Push to master/main
        ↓
┌───────────────────┐
│  Test & Analyze   │ ← Runs first (required)
└───────────────────┘
        ↓ (if successful)
┌───────────────────────────────────────┐
│  Parallel Builds:                     │
│  ├─ Build Android APK                 │
│  ├─ Build Android App Bundle          │
│  └─ Build iOS                         │
└───────────────────────────────────────┘
        ↓
    Artifacts uploaded
```

---

## 🎯 Usage

### Automatic Triggers

The workflows run automatically when you:

```bash
# Push to master/main
git push origin master

# Create a pull request to master/main
gh pr create --base master
```

### Manual Trigger

You can also trigger workflows manually from GitHub:

1. Go to **Actions** tab
2. Select the workflow
3. Click **Run workflow**
4. Choose the branch
5. Click **Run workflow**

---

## 📦 Artifacts

After successful builds, you can download artifacts:

1. Go to **Actions** tab
2. Click on the workflow run
3. Scroll to **Artifacts** section
4. Download:
   - `android-apk` (3 APK files)
   - `android-appbundle` (AAB file)
   - `ios-build` (iOS app)

**Retention**: Artifacts are kept for **30 days**

---

## 🔧 Configuration

### Flutter Version

Current: `3.35.1` (stable)

To change:
```yaml
# In .github/workflows/ci.yml
flutter-version: '3.35.1'  # Change this
```

### Java Version

Current: `17` (Zulu distribution)

To change:
```yaml
# In .github/workflows/ci.yml
java-version: '17'  # Change this
```

### Branches

Current triggers: `master`, `main`

To add more branches:
```yaml
on:
  push:
    branches: [ master, main, develop ]  # Add here
```

---

## 📈 Code Coverage

### Setup Codecov (Optional)

1. Go to [codecov.io](https://codecov.io)
2. Sign in with GitHub
3. Add your repository
4. Get the upload token
5. Add to GitHub Secrets:
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Name: `CODECOV_TOKEN`
   - Value: Your token from Codecov
   - Click **Add secret**

### View Coverage

After setup, coverage reports will be available at:
```
https://codecov.io/gh/YOUR_USERNAME/currency_converter
```

---

## 🚨 Troubleshooting

### Build Fails on "Generate code"

**Problem**: `build_runner` fails

**Solution**:
```bash
# Run locally first
flutter pub run build_runner build --delete-conflicting-outputs

# Commit the generated files
git add lib/**/*.g.dart lib/**/*.config.dart
git commit -m "Add generated files"
git push
```

### Build Fails on "flutter analyze"

**Problem**: Code analysis errors

**Solution**:
```bash
# Run locally
flutter analyze

# Fix all issues
# Then commit and push
```

### iOS Build Fails

**Problem**: macOS runner issues

**Solution**:
- iOS builds require macOS runners (slower and more expensive)
- For free tier, consider removing iOS build or running it manually
- To disable iOS build, comment out the `build-ios` job

### Out of GitHub Actions Minutes

**Problem**: Free tier limit (2000 minutes/month)

**Solutions**:
1. **Use Quick Check workflow** for most pushes (faster)
2. **Disable iOS builds** (macOS runners use 10x minutes)
3. **Build only on master** (not on every branch)
4. **Use self-hosted runners** (free, but requires setup)

---

## ⚡ Performance Tips

### 1. Use Caching

Already enabled:
```yaml
- uses: subosito/flutter-action@v2
  with:
    cache: true  # ← Caches Flutter SDK
```

### 2. Skip iOS for PRs

```yaml
build-ios:
  if: github.event_name == 'push'  # Only on push, not PRs
```

### 3. Use Matrix Strategy

Build multiple versions in parallel:
```yaml
strategy:
  matrix:
    flutter-version: ['3.35.1', '3.27.0']
```

### 4. Conditional Jobs

Run expensive jobs only on master:
```yaml
build-appbundle:
  if: github.ref == 'refs/heads/master'
```

---

## 📊 Workflow Status Badges

Add to your README.md:

```markdown
## Build Status

[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/ci.yml)

[![Quick Check](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/quick-check.yml/badge.svg)](https://github.com/YOUR_USERNAME/currency_converter/actions/workflows/quick-check.yml)

[![codecov](https://codecov.io/gh/YOUR_USERNAME/currency_converter/branch/master/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/currency_converter)
```

---

## 🔐 Secrets Management

### Required Secrets

None required for basic builds!

### Optional Secrets

| Secret | Purpose | How to Get |
|--------|---------|------------|
| `CODECOV_TOKEN` | Upload coverage | [codecov.io](https://codecov.io) |
| `ANDROID_KEYSTORE` | Sign APK | Generate keystore |
| `KEYSTORE_PASSWORD` | Keystore password | Your password |
| `KEY_ALIAS` | Key alias | Your alias |
| `KEY_PASSWORD` | Key password | Your password |

### Adding Secrets

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Enter name and value
4. Click **Add secret**

---

## 🎨 Customization Examples

### Build Only APK (Skip App Bundle)

Comment out in `.github/workflows/ci.yml`:
```yaml
# build-appbundle:
#   name: Build Android App Bundle
#   ...
```

### Add Slack Notifications

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Deploy to Firebase App Distribution

```yaml
- name: Deploy to Firebase
  uses: wzieba/Firebase-Distribution-Github-Action@v1
  with:
    appId: ${{ secrets.FIREBASE_APP_ID }}
    token: ${{ secrets.FIREBASE_TOKEN }}
    file: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📝 Best Practices

### 1. **Run Tests Locally First**
```bash
flutter test
flutter analyze
dart format .
```

### 2. **Use Quick Check for Development**
- Faster feedback
- Uses fewer minutes
- Good for feature branches

### 3. **Use Full CI/CD for Releases**
- Comprehensive builds
- All platforms
- Production-ready artifacts

### 4. **Keep Workflows Updated**
- Update Flutter version regularly
- Update action versions (v3 → v4)
- Monitor deprecated features

### 5. **Monitor Usage**
- Check **Settings** → **Billing**
- Track minutes used
- Optimize slow jobs

---

## 🔄 Workflow Lifecycle

```
Developer pushes code
        ↓
GitHub triggers workflow
        ↓
Runner starts (Ubuntu/macOS)
        ↓
Checkout code
        ↓
Setup environment (Java, Flutter)
        ↓
Install dependencies
        ↓
Run checks (format, analyze)
        ↓
Generate code
        ↓
Run tests
        ↓
Build artifacts
        ↓
Upload artifacts
        ↓
Workflow completes ✅
```

---

## 📞 Support

### Workflow Fails?

1. **Check the logs**:
   - Go to Actions tab
   - Click on failed run
   - Expand failed step
   - Read error message

2. **Common fixes**:
   - Update dependencies: `flutter pub get`
   - Regenerate code: `flutter pub run build_runner build`
   - Fix analysis issues: `flutter analyze`
   - Format code: `dart format .`

3. **Still stuck?**
   - Check [GitHub Actions docs](https://docs.github.com/en/actions)
   - Search [Stack Overflow](https://stackoverflow.com/questions/tagged/github-actions)
   - Open an issue

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Codecov Documentation](https://docs.codecov.com)
- [Flutter Best Practices](https://docs.flutter.dev/testing/best-practices)

---

**Happy Building! 🚀**
