/**
 * Simple RFID Reader Test
 *
 * This sketch tests the MFRC522 RFID reader independently
 * Use this to verify hardware connections before using the full gate system
 *
 * Hardware:
 * - ESP32 Development Board
 * - MFRC522 RFID Reader
 *
 * Connections:
 *   MFRC522 SDA  -> GPIO 5
 *   MFRC522 SCK  -> GPIO 18
 *   MFRC522 MOSI -> GPIO 23
 *   MFRC522 MISO -> GPIO 19
 *   MFRC522 RST  -> GPIO 22
 *   MFRC522 3.3V -> 3.3V
 *   MFRC522 GND  -> GND
 */

#include <SPI.h>
#include <MFRC522.h>

#define SS_PIN 5
#define RST_PIN 22

MFRC522 rfid(SS_PIN, RST_PIN);

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== RFID Reader Test ===");

  SPI.begin();
  rfid.PCD_Init();

  Serial.println("RFID Reader initialized successfully!");
  Serial.println("Ready to scan RFID cards...\n");

  // Show RFID reader details
  rfid.PCD_DumpVersionToSerial();
}

void loop() {
  // Look for new cards
  if (!rfid.PICC_IsNewCardPresent()) {
    return;
  }

  // Select one of the cards
  if (!rfid.PICC_ReadCardSerial()) {
    return;
  }

  // Print card details
  Serial.println("\n--- Card Detected ---");

  // Print UID
  Serial.print("Card UID: ");
  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    Serial.print(rfid.uid.uidByte[i] < 0x10 ? " 0" : " ");
    Serial.print(rfid.uid.uidByte[i], HEX);
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  Serial.println();

  // Print UID as string (without spaces)
  uid.toUpperCase();
  Serial.print("UID String: ");
  Serial.println(uid);

  // Print card type
  Serial.print("Card Type: ");
  MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);
  Serial.println(rfid.PICC_GetTypeName(piccType));

  // Check if card is writable
  if (piccType != MFRC522::PICC_TYPE_MIFARE_MINI &&
      piccType != MFRC522::PICC_TYPE_MIFARE_1K &&
      piccType != MFRC522::PICC_TYPE_MIFARE_4K) {
    Serial.println("Warning: This card may not be supported for read/write operations");
  }

  Serial.println("-------------------\n");

  // Halt PICC
  rfid.PICC_HaltA();
  // Stop encryption on PCD
  rfid.PCD_StopCrypto1();

  delay(1000);  // Prevent multiple reads
}
