# ESP32 RFID Gate Access Control System

An automated gate access control system using ESP32, RFID-RC522 reader, and Laravel backend integration for student attendance tracking and payment verification.

## Features

- **RFID Card Reading**: Automatic detection and reading of RFID cards
- **Real-time Verification**: Online verification with Laravel backend API
- **Payment Validation**: Denies access to students with overdue payments
- **Visual Feedback**: RGB LED indicators for system status
- **Audio Feedback**: Buzzer for access granted/denied notifications
- **Access Logging**: Automatic logging of all access attempts
- **WiFi Connectivity**: Wireless communication with backend server
- **Relay Control**: Controls electronic lock or gate mechanism

## Hardware Requirements

### Components

1. **ESP32 Development Board** (1x)
   - Any ESP32 board with WiFi support
   - Recommended: ESP32 DevKit V1 or NodeMCU-32S

2. **MFRC522 RFID Reader Module** (1x)
   - Operating frequency: 13.56 MHz
   - Reading distance: 0-6 cm

3. **Relay Module** (1x)
   - 5V single channel relay module
   - For controlling gate lock/magnetic lock

4. **RGB LED** (1x) or 3x separate LEDs
   - Common cathode or common anode

5. **Buzzer** (1x)
   - 5V active buzzer

6. **Power Supply**
   - 5V 2A power adapter for ESP32
   - Separate power for lock if needed

7. **Miscellaneous**
   - Breadboard or PCB
   - Jumper wires
   - Resistors (220Ω for LEDs)

## Wiring Diagram

### MFRC522 RFID Reader to ESP32

```
MFRC522    ->    ESP32
--------------------------
SDA (SS)   ->    GPIO 5
SCK        ->    GPIO 18
MOSI       ->    GPIO 23
MISO       ->    GPIO 19
IRQ        ->    Not connected
GND        ->    GND
RST        ->    GPIO 22
3.3V       ->    3.3V
```

### Other Components to ESP32

```
Component       ->    ESP32
--------------------------
Relay Module IN ->    GPIO 26
LED Red         ->    GPIO 25 (via 220Ω resistor)
LED Green       ->    GPIO 33 (via 220Ω resistor)
LED Blue        ->    GPIO 32 (via 220Ω resistor)
Buzzer          ->    GPIO 27
Common GND      ->    GND
```

### Power Connections

```
- ESP32 VIN: 5V from power adapter
- ESP32 GND: GND from power adapter
- Relay VCC: 5V
- Relay GND: GND
- MFRC522 3.3V: ESP32 3.3V output
```

## Software Requirements

- Arduino IDE (1.8.x or higher) or PlatformIO
- ESP32 Board Package
- Required Libraries:
  - WiFi (included with ESP32 core)
  - HTTPClient (included with ESP32 core)
  - ArduinoJson (6.x)
  - SPI (included with Arduino)
  - MFRC522 (by GithubCommunity)

## Installation

### 1. Install Arduino IDE

Download and install Arduino IDE from: https://www.arduino.cc/en/software

### 2. Install ESP32 Board Support

1. Open Arduino IDE
2. Go to File > Preferences
3. Add to "Additional Board Manager URLs":
   ```
   https://dl.espressif.com/dl/package_esp32_index.json
   ```
4. Go to Tools > Board > Boards Manager
5. Search for "esp32" and install "esp32 by Espressif Systems"

### 3. Install Required Libraries

Go to Sketch > Include Library > Manage Libraries and install:

1. **ArduinoJson** by Benoit Blanchon (version 6.x)
2. **MFRC522** by GithubCommunity

### 4. Configure the System

1. Open `config.h` file
2. Update WiFi credentials:
   ```cpp
   #define WIFI_SSID "Your_WiFi_Name"
   #define WIFI_PASSWORD "Your_WiFi_Password"
   ```

3. Update API configuration:
   ```cpp
   #define API_BASE_URL "http://192.168.1.100:8000/api"
   #define API_KEY "your-gate-api-key"  // From backend .env GATE_API_KEY
   ```

4. Update device ID:
   ```cpp
   #define DEVICE_ID "GATE_001"  // Unique ID for this gate
   ```

### 5. Upload the Code

1. Connect ESP32 to computer via USB
2. Select board: Tools > Board > ESP32 Dev Module
3. Select port: Tools > Port > (your ESP32 COM port)
4. Click Upload button

## Backend API Setup

Ensure your Laravel backend is configured:

1. Set `GATE_API_KEY` in `.env` file:
   ```
   GATE_API_KEY=your-secure-random-api-key
   ```

2. API endpoints should be accessible:
   - `POST /api/gate/verify` - Verify RFID card
   - `POST /api/gate/log` - Log access attempts

3. Make sure the backend is accessible from ESP32's network

## Testing

### Serial Monitor Testing

1. Open Serial Monitor (Tools > Serial Monitor)
2. Set baud rate to 115200
3. You should see:
   ```
   === RFID Gate System Starting ===
   RFID Reader Initialized
   Connecting to WiFi: YourWiFi
   WiFi Connected!
   IP Address: 192.168.1.xxx
   === System Ready ===
   ```

### RFID Card Testing

1. Place an RFID card near the reader
2. Serial Monitor should show:
   ```
   --- Card Detected ---
   UID: A1B2C3D4
   Sending verification request...
   ✓ ACCESS GRANTED
   Student: Student Name
   Gate OPENED
   Gate CLOSED
   ```

## LED Status Indicators

| Color  | Status                 |
|--------|------------------------|
| Blue   | Initializing/Processing|
| Yellow | WiFi Connecting        |
| Green  | Ready/Access Granted   |
| Red    | Error/Access Denied    |

## Buzzer Patterns

| Pattern         | Meaning           |
|-----------------|-------------------|
| 2 short beeps   | System ready      |
| 3 quick beeps   | WiFi connected    |
| 2 beeps         | Access granted    |
| 1 long beep     | Access denied     |

## Access Control Logic

The system verifies:
1. ✅ RFID card exists in database
2. ✅ RFID card is active
3. ✅ Student profile exists and is active
4. ✅ Student has no overdue payments
5. ✅ Student's institute is active

If all checks pass: Access GRANTED ✓
If any check fails: Access DENIED ✗

## Troubleshooting

### WiFi Connection Issues

**Problem**: ESP32 won't connect to WiFi

**Solutions**:
- Verify SSID and password in config.h
- Ensure WiFi is 2.4GHz (ESP32 doesn't support 5GHz)
- Check WiFi signal strength
- Restart router and ESP32

### RFID Reader Not Working

**Problem**: Cards not detected

**Solutions**:
- Check wiring connections (especially SDA, SCK, MOSI, MISO)
- Verify RFID module has 3.3V power
- Try different RFID cards (some may be incompatible)
- Check if RFID module LED lights up when card is near

### API Connection Errors

**Problem**: "Connection error" or "Server error"

**Solutions**:
- Verify API_BASE_URL is correct and accessible
- Check if Laravel backend is running
- Ensure API_KEY matches backend .env
- Verify firewall allows connections
- Test API endpoint with Postman

### Relay Not Working

**Problem**: Gate doesn't open/close

**Solutions**:
- Check relay wiring to GPIO 26
- Verify relay module has 5V power
- Test relay manually by connecting IN pin to GND
- Check if relay LED lights up when access granted
- Ensure relay can handle lock's power requirements

### Cards Not Verified

**Problem**: All cards show "ACCESS DENIED"

**Solutions**:
- Check if cards are registered in database
- Verify student has no overdue payments
- Check RFID card UID matches database
- Review Laravel logs for errors
- Test API endpoints with curl/Postman

## System Flow

```
1. Student taps RFID card
     ↓
2. ESP32 reads card UID
     ↓
3. Send UID to Laravel API (/gate/verify)
     ↓
4. API checks:
   - Card exists and is active?
   - Student exists and is active?
   - Payment status OK?
     ↓
5a. All OK → ACCESS GRANTED
   - Open relay (unlock gate)
   - Green LED + Success beep
   - Log access (granted)
   - Close relay after 3 seconds

5b. Failed check → ACCESS DENIED
   - Keep relay closed
   - Red LED + Error beep
   - Log access (denied + reason)
```

## Security Considerations

1. **API Key**: Keep API_KEY secret, don't commit to public repos
2. **HTTPS**: Use HTTPS for production (requires certificate)
3. **Network**: Place ESP32 on isolated network if possible
4. **Physical**: Secure ESP32 hardware in tamper-proof enclosure
5. **Backup Power**: Consider UPS for gate system

## Future Enhancements

- [ ] Offline mode with local card storage
- [ ] OLED display for student name and status
- [ ] Fingerprint scanner integration
- [ ] Multiple relay support for multiple gates
- [ ] Real-time WebSocket updates
- [ ] Over-the-air (OTA) firmware updates
- [ ] SD card logging for offline operation

## License

This project is part of the Tuition Management System.

## Support

For issues and questions:
1. Check troubleshooting section
2. Review Laravel backend logs
3. Check ESP32 Serial Monitor output
4. Test individual components separately
