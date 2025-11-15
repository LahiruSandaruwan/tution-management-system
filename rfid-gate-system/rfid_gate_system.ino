/**
 * RFID Gate Access Control System for ESP32
 *
 * Hardware Requirements:
 * - ESP32 Development Board
 * - MFRC522 RFID Reader Module
 * - Relay Module (for gate/lock control)
 * - RGB LED (for status indication)
 * - Buzzer (for audio feedback)
 *
 * Connections:
 * MFRC522:
 *   SDA  -> GPIO 5
 *   SCK  -> GPIO 18
 *   MOSI -> GPIO 23
 *   MISO -> GPIO 19
 *   RST  -> GPIO 22
 *
 * Relay Module:
 *   IN   -> GPIO 26
 *
 * RGB LED:
 *   R    -> GPIO 25
 *   G    -> GPIO 33
 *   B    -> GPIO 32
 *
 * Buzzer:
 *   PIN  -> GPIO 27
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <SPI.h>
#include <MFRC522.h>

// WiFi Configuration
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// API Configuration
const char* API_URL = "http://YOUR_API_URL/api/gate/verify";
const char* LOG_URL = "http://YOUR_API_URL/api/gate/log";
const char* API_KEY = "your-gate-api-key-from-env";

// Device Configuration
const char* DEVICE_ID = "GATE_001";

// Pin Definitions
#define SS_PIN 5
#define RST_PIN 22
#define RELAY_PIN 26
#define LED_RED_PIN 25
#define LED_GREEN_PIN 33
#define LED_BLUE_PIN 32
#define BUZZER_PIN 27

// Timing Configuration
#define GATE_OPEN_DURATION 3000  // 3 seconds
#define CARD_READ_DELAY 2000     // 2 seconds between reads of same card

// RFID Reader
MFRC522 rfid(SS_PIN, RST_PIN);
String lastCardUID = "";
unsigned long lastCardTime = 0;

// Status LEDs
void setLED(int r, int g, int b) {
  digitalWrite(LED_RED_PIN, r);
  digitalWrite(LED_GREEN_PIN, g);
  digitalWrite(LED_BLUE_PIN, b);
}

void beep(int duration = 100, int times = 1) {
  for (int i = 0; i < times; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(duration);
    digitalWrite(BUZZER_PIN, LOW);
    if (i < times - 1) delay(100);
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("\n\n=== RFID Gate System Starting ===");

  // Initialize pins
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(LED_RED_PIN, OUTPUT);
  pinMode(LED_GREEN_PIN, OUTPUT);
  pinMode(LED_BLUE_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  // Set initial states
  digitalWrite(RELAY_PIN, LOW);  // Gate closed
  setLED(0, 0, 1);  // Blue - Initializing

  // Initialize SPI and RFID
  SPI.begin();
  rfid.PCD_Init();
  Serial.println("RFID Reader Initialized");

  // Connect to WiFi
  connectWiFi();

  // Initialization complete
  setLED(0, 1, 0);  // Green - Ready
  beep(100, 2);
  Serial.println("=== System Ready ===\n");
}

void connectWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(WIFI_SSID);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    setLED(1, 1, 0);  // Yellow - Connecting
    delay(500);
    setLED(0, 0, 0);
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    setLED(0, 1, 0);  // Green - Connected
    beep(50, 3);
  } else {
    Serial.println("\nWiFi Connection Failed!");
    setLED(1, 0, 0);  // Red - Error
    beep(500, 2);
  }
}

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected. Reconnecting...");
    setLED(1, 1, 0);  // Yellow
    connectWiFi();
  }

  // Check for RFID card
  if (!rfid.PICC_IsNewCardPresent()) {
    return;
  }

  if (!rfid.PICC_ReadCardSerial()) {
    return;
  }

  // Read card UID
  String cardUID = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    cardUID += String(rfid.uid.uidByte[i], HEX);
  }
  cardUID.toUpperCase();

  // Prevent multiple reads of same card
  if (cardUID == lastCardUID && (millis() - lastCardTime) < CARD_READ_DELAY) {
    rfid.PICC_HaltA();
    return;
  }

  lastCardUID = cardUID;
  lastCardTime = millis();

  Serial.println("\n--- Card Detected ---");
  Serial.print("UID: ");
  Serial.println(cardUID);

  // Verify card with API
  verifyCard(cardUID);

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
}

void verifyCard(String cardUID) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("ERROR: No WiFi connection");
    accessDenied("No internet connection");
    return;
  }

  HTTPClient http;
  http.begin(API_URL);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("X-Gate-API-Key", API_KEY);

  // Prepare JSON payload
  StaticJsonDocument<256> doc;
  doc["card_uid"] = cardUID;
  doc["device_id"] = DEVICE_ID;

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  Serial.println("Sending verification request...");
  setLED(0, 0, 1);  // Blue - Processing

  int httpCode = http.POST(jsonPayload);

  if (httpCode > 0) {
    String response = http.getString();
    Serial.print("Response Code: ");
    Serial.println(httpCode);
    Serial.print("Response: ");
    Serial.println(response);

    if (httpCode == 200) {
      StaticJsonDocument<512> responseDoc;
      DeserializationError error = deserializeJson(responseDoc, response);

      if (!error) {
        bool success = responseDoc["success"];
        String message = responseDoc["message"];

        if (success) {
          JsonObject data = responseDoc["data"];
          String studentName = data["student_name"];
          String studentId = data["student_id_number"];

          Serial.println("✓ ACCESS GRANTED");
          Serial.print("Student: ");
          Serial.println(studentName);
          Serial.print("ID: ");
          Serial.println(studentId);

          accessGranted(studentName);
          logAccess(cardUID, studentName, "granted");
        } else {
          Serial.println("✗ ACCESS DENIED");
          Serial.print("Reason: ");
          Serial.println(message);

          accessDenied(message);
          logAccess(cardUID, "Unknown", "denied", message);
        }
      } else {
        Serial.println("ERROR: Failed to parse response");
        accessDenied("System error");
      }
    } else {
      Serial.println("ERROR: Invalid response from server");
      accessDenied("Server error");
    }
  } else {
    Serial.print("ERROR: HTTP request failed: ");
    Serial.println(http.errorToString(httpCode));
    accessDenied("Connection error");
  }

  http.end();
}

void accessGranted(String studentName) {
  // Visual feedback - Green LED
  setLED(0, 1, 0);

  // Audio feedback - Success beep
  beep(100, 2);

  // Open gate/unlock door
  digitalWrite(RELAY_PIN, HIGH);
  Serial.println("Gate OPENED");

  // Display on Serial
  Serial.println("================================");
  Serial.println("     WELCOME!");
  Serial.println(studentName);
  Serial.println("================================");

  // Keep gate open
  delay(GATE_OPEN_DURATION);

  // Close gate/lock door
  digitalWrite(RELAY_PIN, LOW);
  Serial.println("Gate CLOSED");

  // Return to ready state
  setLED(0, 1, 0);  // Green - Ready
}

void accessDenied(String reason) {
  // Visual feedback - Red LED blinking
  for (int i = 0; i < 3; i++) {
    setLED(1, 0, 0);
    delay(200);
    setLED(0, 0, 0);
    delay(200);
  }

  // Audio feedback - Error beep
  beep(500, 1);

  // Display on Serial
  Serial.println("================================");
  Serial.println("     ACCESS DENIED");
  Serial.println(reason);
  Serial.println("================================");

  // Return to ready state
  setLED(0, 1, 0);  // Green - Ready
}

void logAccess(String cardUID, String studentName, String status, String reason = "") {
  if (WiFi.status() != WL_CONNECTED) {
    return;
  }

  HTTPClient http;
  http.begin(LOG_URL);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("X-Gate-API-Key", API_KEY);

  StaticJsonDocument<512> doc;
  doc["device_id"] = DEVICE_ID;
  doc["card_uid"] = cardUID;
  doc["student_name"] = studentName;
  doc["access_status"] = status;
  doc["timestamp"] = String(millis() / 1000);
  if (reason != "") {
    doc["notes"] = reason;
  }

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  int httpCode = http.POST(jsonPayload);

  if (httpCode == 200 || httpCode == 201) {
    Serial.println("Access log saved successfully");
  } else {
    Serial.print("Failed to log access. HTTP Code: ");
    Serial.println(httpCode);
  }

  http.end();
}
