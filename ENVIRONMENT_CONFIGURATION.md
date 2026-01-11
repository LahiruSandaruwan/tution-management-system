# Environment Configuration Guide

## Overview
All Flutter apps (student-app, teacher-app, admin-web) now support environment-based configuration to avoid hardcoding API URLs.

## Setup Instructions

### 1. Student App & Teacher App (Mobile)

Create a `.env` file in the root of each app directory:

```bash
# Navigate to app directory
cd student-app  # or teacher-app

# Copy the example file
cp .env.example .env

# Edit with your configuration
nano .env  # or use your preferred editor
```

**Important Notes:**
- `.env` files are git-ignored for security
- **Android Emulator**: Use `10.0.2.2` to access host machine's localhost
- **iOS Simulator**: Use `localhost` or `127.0.0.1`
- **Physical Device**: Use your computer's local IP (e.g., `192.168.1.100`)

### 2. Admin Web App

Similar to mobile apps:

```bash
cd admin-web
cp .env.example .env
# Edit with your API URL
```

### 3. Running with Different Environments

#### Development (default)
```bash
flutter run
# Uses default value from AppConstants
```

#### Custom API URL
```bash
# Method 1: Using --dart-define
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api

# Method 2: For production build
flutter build apk --dart-define=API_BASE_URL=https://api.yourproduction.com/api
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `API_BASE_URL` | Backend API base URL | `http://10.0.2.2:8000/api` |

## Platform-Specific URLs

### Android Emulator
```env
API_BASE_URL=http://10.0.2.2:8000/api
```

### iOS Simulator
```env
API_BASE_URL=http://localhost:8000/api
```

### Physical Device (Same WiFi Network)
```env
# Replace with your computer's IP address
API_BASE_URL=http://192.168.1.100:8000/api
```

### Production
```env
API_BASE_URL=https://api.yourproduction.com/api
```

## Troubleshooting

### Cannot Connect to API

1. **Check backend is running:**
   ```bash
   cd backend
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **Verify network connectivity:**
   - Mobile device and computer must be on same WiFi network
   - Firewall might be blocking connections

3. **Check API URL format:**
   - Must include `/api` at the end
   - Must include protocol (`http://` or `https://`)
   - No trailing slash

### Getting Default URL Instead of Custom

- Ensure you're using `--dart-define` flag when running
- Check that AppConstants is reading from environment correctly
- Verify `.env` file is in the correct location (app root directory)

## Security Notes

- **Never commit `.env` files** to version control
- `.env.example` is committed as documentation only
- For production, use secure HTTPS URLs
- Store sensitive credentials in secure environment variables
