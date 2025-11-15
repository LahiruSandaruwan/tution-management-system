/**
 * Configuration file for RFID Gate System
 * Copy this file and update with your settings
 */

#ifndef CONFIG_H
#define CONFIG_H

// WiFi Configuration
#define WIFI_SSID "YOUR_WIFI_SSID"           // Your WiFi network name
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"   // Your WiFi password

// API Configuration
#define API_BASE_URL "http://192.168.1.100:8000/api"  // Replace with your server IP
#define API_VERIFY_ENDPOINT "/gate/verify"
#define API_LOG_ENDPOINT "/gate/log"
#define API_KEY "your-secure-api-key-here"  // Must match GATE_API_KEY in .env

// Device Configuration
#define DEVICE_ID "GATE_001"  // Unique identifier for this gate device

// Pin Definitions (ESP32)
#define RFID_SS_PIN 5      // SDA
#define RFID_RST_PIN 22    // RST
#define RELAY_PIN 26       // Relay control
#define LED_RED_PIN 25     // Red LED
#define LED_GREEN_PIN 33   // Green LED
#define LED_BLUE_PIN 32    // Blue LED
#define BUZZER_PIN 27      // Buzzer

// Timing Configuration (in milliseconds)
#define GATE_OPEN_DURATION 3000     // How long to keep gate open (3 seconds)
#define CARD_READ_DELAY 2000        // Delay between reads of same card (2 seconds)
#define WIFI_TIMEOUT 30000          // WiFi connection timeout (30 seconds)
#define HTTP_TIMEOUT 5000           // HTTP request timeout (5 seconds)

// Feature Flags
#define ENABLE_SERIAL_DEBUG true    // Enable/disable serial debugging
#define ENABLE_OFFLINE_MODE false   // Allow offline operation (not implemented yet)
#define ENABLE_BUZZER true          // Enable/disable buzzer sounds
#define ENABLE_LED_FEEDBACK true    // Enable/disable LED feedback

#endif
