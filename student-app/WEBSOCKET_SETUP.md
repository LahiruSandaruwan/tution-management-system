# WebSocket Real-time Updates Setup

## Overview

The app now supports real-time updates via WebSocket connections. This enables instant notifications for:
- New notifications
- Dashboard statistics updates
- Attendance changes
- Payment updates
- Grade publications

## Backend Requirements

Your backend must implement a WebSocket server that:

1. **Accepts connections at `/ws` endpoint**
2. **Supports authentication via query parameter or initial message**
3. **Sends messages in JSON format**

### Expected Message Format

```json
{
  "type": "notification|dashboard_update|attendance_update|payment_update|grade_update",
  "data": {
    // Your data here
  }
}
```

## Backend Implementation Examples

### Node.js (using Socket.IO)

```javascript
const io = require('socket.io')(server, {
  path: '/ws',
  cors: {
    origin: '*',
  }
});

io.use(async (socket, next) => {
  const token = socket.handshake.query.token || socket.handshake.auth.token;

  try {
    const user = await verifyToken(token);
    socket.userId = user.id;
    socket.studentId = user.student_id;
    next();
  } catch (error) {
    next(new Error('Authentication error'));
  }
});

io.on('connection', (socket) => {
  console.log(`Student ${socket.studentId} connected`);

  // Join student-specific room
  socket.join(`student.${socket.studentId}`);

  // Handle authentication
  socket.on('auth', (data) => {
    console.log('Auth received');
    socket.emit('auth_success', { message: 'Authenticated' });
  });

  // Handle ping/pong for keepalive
  socket.on('ping', () => {
    socket.emit('pong', { timestamp: Date.now() });
  });

  // Handle subscribe/unsubscribe
  socket.on('subscribe', (data) => {
    socket.join(data.channel);
  });

  socket.on('unsubscribe', (data) => {
    socket.leave(data.channel);
  });

  socket.on('disconnect', () => {
    console.log(`Student ${socket.studentId} disconnected`);
  });
});

// Example: Send notification to specific student
function sendNotificationToStudent(studentId, notification) {
  io.to(`student.${studentId}`).emit('notification', {
    type: 'notification',
    data: notification
  });
}

// Example: Send dashboard update
function sendDashboardUpdate(studentId, stats) {
  io.to(`student.${studentId}`).emit('dashboard_update', {
    type: 'dashboard_update',
    data: stats
  });
}
```

### Laravel (using laravel-websockets or soketi)

```php
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

class StudentWebSocket implements MessageComponentInterface {
    protected $clients;
    protected $studentClients = [];

    public function __construct() {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn) {
        // Parse token from query string
        parse_str($conn->httpRequest->getUri()->getQuery(), $query);
        $token = $query['token'] ?? null;

        if ($token && $student = $this->authenticateToken($token)) {
            $conn->studentId = $student->id;
            $this->studentClients[$student->id] = $conn;
            $this->clients->attach($conn);

            echo "Student {$student->id} connected\n";
        } else {
            $conn->close();
        }
    }

    public function onMessage(ConnectionInterface $from, $msg) {
        $data = json_decode($msg, true);

        switch ($data['type'] ?? '') {
            case 'ping':
                $from->send(json_encode(['type' => 'pong']));
                break;
            case 'auth':
                // Handle authentication
                break;
        }
    }

    public function onClose(ConnectionInterface $conn) {
        $this->clients->detach($conn);
        if (isset($conn->studentId)) {
            unset($this->studentClients[$conn->studentId]);
            echo "Student {$conn->studentId} disconnected\n";
        }
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
        echo "Error: {$e->getMessage()}\n";
        $conn->close();
    }

    // Send to specific student
    public function sendToStudent($studentId, $type, $data) {
        if (isset($this->studentClients[$studentId])) {
            $this->studentClients[$studentId]->send(json_encode([
                'type' => $type,
                'data' => $data
            ]));
        }
    }
}
```

## Message Types

### 1. Notification
```json
{
  "type": "notification",
  "data": {
    "id": 123,
    "title": "Payment Reminder",
    "message": "Your payment is due tomorrow",
    "type": "payment_reminder",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### 2. Dashboard Update
```json
{
  "type": "dashboard_update",
  "data": {
    "total_classes": 45,
    "attended": 42,
    "attendance_rate": 93.3
  }
}
```

### 3. Attendance Update
```json
{
  "type": "attendance_update",
  "data": {
    "date": "2024-01-15",
    "status": "present",
    "class_name": "Mathematics"
  }
}
```

### 4. Payment Update
```json
{
  "type": "payment_update",
  "data": {
    "payment_id": 456,
    "amount": 5000,
    "status": "paid",
    "paid_at": "2024-01-15T10:30:00Z"
  }
}
```

### 5. Grade Update
```json
{
  "type": "grade_update",
  "data": {
    "subject": "Mathematics",
    "exam": "Term 1 Exam",
    "grade": "A",
    "marks": 85
  }
}
```

## Testing WebSocket Locally

Use a WebSocket testing tool or browser console:

```javascript
const ws = new WebSocket('ws://localhost:8000/ws?token=YOUR_TOKEN');

ws.onopen = () => {
  console.log('Connected');
  ws.send(JSON.stringify({ type: 'ping' }));
};

ws.onmessage = (event) => {
  console.log('Message:', JSON.parse(event.data));
};

// Send test notification
ws.send(JSON.stringify({
  type: 'notification',
  data: {
    id: 123,
    title: 'Test',
    message: 'Test message'
  }
}));
```

## Features

- **Auto-reconnection**: Automatically reconnects with exponential backoff (1s, 2s, 4s, 8s, 16s)
- **Heartbeat**: Sends ping every 30 seconds to keep connection alive
- **Authentication**: Sends token on connection
- **Room subscription**: Can subscribe to specific channels
- **Type-safe messages**: Filters messages by type in providers

## Usage in App

The WebSocket service is automatically initialized. To listen for updates:

```dart
// Listen for notifications
ref.listen(realtimeNotificationProvider, (previous, next) {
  next.whenData((notification) {
    // Handle new notification
    print('New notification: ${notification['title']}');
  });
});

// Listen for dashboard updates
ref.listen(realtimeDashboardProvider, (previous, next) {
  next.whenData((update) {
    // Refresh dashboard
    ref.invalidate(dashboardStatsProvider);
  });
});
```

## Security Considerations

1. **Always authenticate WebSocket connections**
2. **Validate tokens on every connection**
3. **Limit message rate to prevent abuse**
4. **Use WSS (WebSocket Secure) in production**
5. **Implement proper CORS policies**
6. **Log connection attempts for monitoring**

## Production Deployment

For production, consider using:
- **AWS API Gateway WebSocket** - Fully managed
- **Pusher** - Hosted WebSocket service
- **Soketi** - Self-hosted Pusher alternative
- **Socket.IO with Redis** - For horizontal scaling
- **Laravel Echo Server** - For Laravel apps
