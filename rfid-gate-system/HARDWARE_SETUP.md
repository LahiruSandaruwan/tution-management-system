# Hardware Setup Guide

## Bill of Materials (BOM)

| Component | Quantity | Specifications | Estimated Cost |
|-----------|----------|----------------|----------------|
| ESP32 DevKit V1 | 1 | WiFi/Bluetooth, 38-pin | $5-10 |
| MFRC522 RFID Reader | 1 | 13.56 MHz, SPI interface | $2-5 |
| 5V Relay Module | 1 | Single channel, opto-isolated | $1-3 |
| RGB LED (Common Cathode) | 1 | 5mm | $0.50 |
| Active Buzzer | 1 | 5V | $0.50 |
| Resistors 220Ω | 3 | For LEDs | $0.10 |
| Breadboard | 1 | 830 points (optional) | $2 |
| Jumper Wires | 1 set | Male-to-Male, Male-to-Female | $2 |
| 5V 2A Power Adapter | 1 | Micro USB or external | $3-5 |
| Electric Lock (optional) | 1 | 12V DC or magnetic lock | $10-30 |
| Enclosure Box | 1 | Waterproof if outdoor | $5-15 |
| RFID Cards/Tags | 10+ | 13.56 MHz compatible | $5 |

**Total Estimated Cost**: $40-80 (excluding lock and enclosure)

## Detailed Wiring Instructions

### Step 1: MFRC522 RFID Reader Connection

The MFRC522 uses SPI communication protocol.

```
MFRC522 Pin    ESP32 Pin      Description
-------------------------------------------------
SDA (SS)       GPIO 5         Chip Select
SCK            GPIO 18        SPI Clock
MOSI           GPIO 23        Master Out Slave In
MISO           GPIO 19        Master In Slave Out
IRQ            -              Not used (leave disconnected)
GND            GND            Ground
RST            GPIO 22        Reset
3.3V           3.3V           Power (3.3V only, NOT 5V!)
```

**Important**:
- MFRC522 operates at 3.3V ONLY
- Do NOT connect to 5V or you will damage the module
- Keep wires short to avoid communication issues

### Step 2: Relay Module Connection

```
Relay Pin      ESP32 Pin      Description
-------------------------------------------------
VCC            5V (VIN)       Power for relay (5V)
GND            GND            Ground
IN             GPIO 26        Control signal
COM            Lock +         Common (to lock positive)
NO             Power +        Normally Open (to power supply)
NC             -              Normally Closed (not used)
```

**Lock Wiring**:
```
Power Supply (+) → Relay NO
Relay COM → Electric Lock (+)
Electric Lock (-) → Power Supply (-)
```

**Safety Notes**:
- Use a separate power supply for high-current locks
- Ensure relay can handle lock's current (check datasheet)
- Add a flyback diode across lock coil for protection

### Step 3: RGB LED Connection

For Common Cathode RGB LED:

```
LED Pin        ESP32 Pin      Component
-------------------------------------------------
Red Anode      GPIO 25        Via 220Ω resistor
Green Anode    GPIO 33        Via 220Ω resistor
Blue Anode     GPIO 32        Via 220Ω resistor
Cathode        GND            Direct connection
```

**Circuit**:
```
GPIO 25 → [220Ω] → LED Red → GND
GPIO 33 → [220Ω] → LED Green → GND
GPIO 32 → [220Ω] → LED Blue → GND
```

For Common Anode RGB LED:
- Connect common anode to 3.3V
- Invert the LED control logic in code (HIGH = OFF, LOW = ON)

### Step 4: Buzzer Connection

```
Buzzer Pin     ESP32 Pin      Description
-------------------------------------------------
Positive (+)   GPIO 27        Signal
Negative (-)   GND            Ground
```

For active buzzers: Direct connection works
For passive buzzers: May need transistor driver for louder sound

### Step 5: Power Supply

**Option 1: USB Power (for testing)**
```
USB Cable → ESP32 Micro USB Port
```

**Option 2: External Power (for deployment)**
```
5V Power Supply (+) → ESP32 VIN pin
5V Power Supply (-) → ESP32 GND pin
```

**Option 3: Dual Power (for lock)**
```
5V Supply → ESP32 VIN + Relay VCC
12V Supply → Lock via Relay
Common GND for all components
```

## Assembly Instructions

### 1. Breadboard Prototype

1. **Mount ESP32** on breadboard center
2. **Connect MFRC522**:
   - Place MFRC522 on breadboard
   - Wire SPI pins (MOSI, MISO, SCK, SS, RST)
   - Connect 3.3V and GND
3. **Add Relay Module**:
   - Place relay module separately
   - Connect VCC to 5V, GND to GND, IN to GPIO 26
4. **Install RGB LED**:
   - Insert LED on breadboard
   - Add 220Ω resistors to each color pin
   - Wire to GPIOs 25, 33, 32
5. **Add Buzzer**:
   - Connect buzzer positive to GPIO 27
   - Connect negative to GND
6. **Power Up**:
   - Connect USB cable to ESP32
   - Verify all components light up briefly

### 2. PCB/Permanent Installation

For permanent installation:

1. **Design PCB** (optional)
   - Use KiCad or EasyEDA for PCB design
   - Include screw terminals for easy lock connection
   - Add fuse for lock power protection

2. **Solder Connections**
   - Solder ESP32 headers
   - Solder MFRC522 socket or headers
   - Solder all components
   - Double-check polarity!

3. **Enclosure Mounting**
   - Drill holes for:
     - RFID reader window (plastic window if metal box)
     - LED visibility
     - Buzzer sound holes
     - Cable entry
   - Use standoffs to mount PCB
   - Seal cable entries

### 3. Lock Installation

**Magnetic Lock Setup**:
```
1. Mount lock on door frame
2. Mount strike plate on door
3. Run wires to relay through conduit
4. Test alignment before final mounting
```

**Electric Strike Setup**:
```
1. Mount strike in door frame
2. Adjust keeper to align with latch
3. Wire to relay
4. Test door operation
```

## Testing Procedure

### Pre-Power Checks

1. **Visual Inspection**:
   - ☐ No short circuits
   - ☐ All connections secure
   - ☐ Correct polarity on all components
   - ☐ MFRC522 connected to 3.3V (NOT 5V!)

2. **Continuity Test** (with multimeter):
   - ☐ Check GND connections
   - ☐ Verify no shorts between VCC and GND
   - ☐ Test relay coil resistance (should be ~70-100Ω)

### Power-On Tests

1. **ESP32 Boot**:
   - ☐ Blue LED on ESP32 lights up
   - ☐ No smoke or unusual smell
   - ☐ ESP32 doesn't get hot

2. **Component Test**:
   - ☐ RGB LED shows blue during init
   - ☐ Buzzer beeps during startup
   - ☐ RFID reader LED lights up
   - ☐ WiFi connects (check serial monitor)

3. **RFID Test**:
   - ☐ Upload `test_rfid_reader.ino`
   - ☐ Scan an RFID card
   - ☐ Verify UID appears in serial monitor

4. **Relay Test**:
   - ☐ Manually trigger relay (modify code or use jumper wire)
   - ☐ Listen for relay click
   - ☐ Verify lock operates

5. **Full System Test**:
   - ☐ Upload main `rfid_gate_system.ino`
   - ☐ Register RFID card in backend
   - ☐ Scan card
   - ☐ Verify access granted
   - ☐ Check gate opens/closes

## Troubleshooting Hardware Issues

### RFID Reader Not Responding

**Check**:
1. SPI wiring (MOSI, MISO, SCK, SS)
2. 3.3V power (measure with multimeter)
3. Ground connection
4. Try different jumper wires (quality matters)
5. Reduce wire length (keep under 10cm if possible)

**Test**:
```cpp
// In setup(), after rfid.PCD_Init()
Serial.print("MFRC522 Version: ");
byte version = rfid.PCD_ReadRegister(MFRC522::VersionReg);
Serial.println(version, HEX);
// Should print 0x91 or 0x92 for genuine MFRC522
```

### Relay Not Clicking

**Check**:
1. 5V power to relay VCC
2. GPIO 26 connection to IN pin
3. Test relay manually (connect IN to GND)
4. Try external 5V power source

**Measure**:
- Relay coil voltage when triggered (should be ~5V)
- GPIO 26 output (should be 3.3V when HIGH)

### LED Not Lighting

**Check**:
1. LED polarity (long leg = positive)
2. Resistor value (should be 220Ω)
3. Common cathode vs common anode
4. Test LED with 3V battery

### Buzzer Silent

**Check**:
1. Buzzer polarity
2. Active vs passive buzzer type
3. GPIO 27 connection
4. Test with multimeter (should show voltage change)

### Lock Not Operating

**Check**:
1. Separate power supply for lock
2. Lock voltage rating (6V, 12V, 24V)
3. Relay contact rating (must exceed lock current)
4. Flyback diode across lock (if inductive)
5. Mechanical alignment

## Safety Warnings

⚠️ **ELECTRICAL SAFETY**
- Disconnect power before wiring
- Don't mix up 3.3V and 5V connections
- Use fuses for high-current locks
- Ensure proper wire gauge for current

⚠️ **PHYSICAL SAFETY**
- Test lock operation manually first
- Ensure door can be opened manually in emergency
- Add mechanical key override
- Don't trap yourself in/out during testing

⚠️ **FIRE SAFETY**
- Use proper enclosure ratings
- Don't exceed relay ratings
- Provide ventilation for components
- Use flame-retardant materials

## Recommended Tools

- Soldering iron and solder
- Wire strippers
- Multimeter
- Screwdrivers (Phillips and flat)
- Drill and drill bits
- Hot glue gun (for strain relief)
- Label maker (for wire identification)
- Heat shrink tubing
