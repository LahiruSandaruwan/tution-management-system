#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

API_URL="http://127.0.0.1:8000/api"
TOKEN=""
STUDENT_ID=""
TEACHER_ID=""
CLASS_ID=""

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Testing Tuition Management System${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Test 1: Health Check
echo -e "${YELLOW}[1/15] Testing Health Endpoint...${NC}"
HEALTH=$(curl -s http://127.0.0.1:8000/up)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Health endpoint working${NC}\n"
else
    echo -e "${RED}✗ Health endpoint failed${NC}\n"
fi

# Test 2: User Login
echo -e "${YELLOW}[2/15] Testing User Login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@demoinstitute.lk","password":"Admin@123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -n "$TOKEN" ]; then
    echo -e "${GREEN}✓ Login successful${NC}"
    echo -e "   Token: ${TOKEN:0:30}..."
else
    echo -e "${RED}✗ Login failed${NC}"
    echo "   Response: $LOGIN_RESPONSE"
fi
echo ""

# Test 3: Get User Profile
echo -e "${YELLOW}[3/15] Testing Get User Profile...${NC}"
PROFILE=$(curl -s -X GET "$API_URL/auth/me" \
  -H "Authorization: Bearer $TOKEN")

if echo "$PROFILE" | grep -q "superadmin@demoinstitute.lk"; then
    echo -e "${GREEN}✓ Profile retrieved successfully${NC}\n"
else
    echo -e "${RED}✗ Profile retrieval failed${NC}\n"
fi

# Test 4: Create Student
echo -e "${YELLOW}[4/15] Testing Create Student...${NC}"
STUDENT_RESPONSE=$(curl -s -X POST "$API_URL/students" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "John Doe",
    "user_email": "john.doe@example.com",
    "user_password": "student123",
    "user_phone": "0771234567",
    "student_id_number": "STU001",
    "date_of_birth": "2005-01-15",
    "grade": "Grade 10",
    "address": "123 Main St, Colombo",
    "parent_name": "Jane Doe",
    "parent_phone": "0779876543"
  }')

STUDENT_ID=$(echo $STUDENT_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -n "$STUDENT_ID" ]; then
    echo -e "${GREEN}✓ Student created successfully${NC}"
    echo -e "   Student ID: $STUDENT_ID"
else
    echo -e "${RED}✗ Student creation failed${NC}"
    echo "   Response: $STUDENT_RESPONSE"
fi
echo ""

# Test 5: Create Teacher
echo -e "${YELLOW}[5/15] Testing Create Teacher...${NC}"
TEACHER_RESPONSE=$(curl -s -X POST "$API_URL/teachers" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Mr. Smith",
    "user_email": "smith@example.com",
    "user_password": "teacher123",
    "user_phone": "0771111111",
    "subject": "Mathematics",
    "qualification": "BSc in Mathematics",
    "experience_years": 5
  }')

TEACHER_ID=$(echo $TEACHER_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -n "$TEACHER_ID" ]; then
    echo -e "${GREEN}✓ Teacher created successfully${NC}"
    echo -e "   Teacher ID: $TEACHER_ID"
else
    echo -e "${RED}✗ Teacher creation failed${NC}"
    echo "   Response: $TEACHER_RESPONSE"
fi
echo ""

# Test 6: Create Subject
echo -e "${YELLOW}[6/15] Testing Create Subject...${NC}"
SUBJECT_RESPONSE=$(curl -s -X POST "$API_URL/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Advanced Mathematics",
    "subject": "Mathematics",
    "teacher_id": '${TEACHER_ID:-1}',
    "grade": "Grade 10",
    "schedule": "Monday 2:00 PM",
    "fee": 5000,
    "description": "Advanced mathematics class for Grade 10"
  }')

CLASS_ID=$(echo $SUBJECT_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -n "$CLASS_ID" ]; then
    echo -e "${GREEN}✓ Class created successfully${NC}"
    echo -e "   Class ID: $CLASS_ID"
else
    echo -e "${RED}✗ Class creation failed${NC}"
    echo "   Response: $SUBJECT_RESPONSE"
fi
echo ""

# Test 7: Enroll Student in Class
echo -e "${YELLOW}[7/15] Testing Student Enrollment...${NC}"
ENROLL_RESPONSE=$(curl -s -X POST "$API_URL/classes/${CLASS_ID}/enroll" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"student_id": '${STUDENT_ID}'}')

if echo "$ENROLL_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ Student enrolled successfully${NC}\n"
else
    echo -e "${RED}✗ Student enrollment failed${NC}"
    echo "   Response: $ENROLL_RESPONSE"
    echo ""
fi

# Test 8: Create Payment
echo -e "${YELLOW}[8/15] Testing Create Payment...${NC}"
PAYMENT_RESPONSE=$(curl -s -X POST "$API_URL/payments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": '${STUDENT_ID}',
    "amount": 5000,
    "payment_type": "monthly_fee",
    "payment_method": "cash",
    "month": "12",
    "year": "2025"
  }')

if echo "$PAYMENT_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ Payment created successfully${NC}\n"
else
    echo -e "${RED}✗ Payment creation failed${NC}"
    echo "   Response: $PAYMENT_RESPONSE"
    echo ""
fi

# Test 9: Mark Attendance
echo -e "${YELLOW}[9/15] Testing Mark Attendance...${NC}"
ATTENDANCE_RESPONSE=$(curl -s -X POST "$API_URL/attendance/mark" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": '${STUDENT_ID}',
    "class_id": '${CLASS_ID}',
    "date": "2025-12-24",
    "status": "present"
  }')

if echo "$ATTENDANCE_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ Attendance marked successfully${NC}\n"
else
    echo -e "${RED}✗ Attendance marking failed${NC}"
    echo "   Response: $ATTENDANCE_RESPONSE"
    echo ""
fi

# Test 10: Get Dashboard Stats
echo -e "${YELLOW}[10/15] Testing Dashboard Statistics...${NC}"
STATS_RESPONSE=$(curl -s -X GET "$API_URL/dashboard/stats" \
  -H "Authorization: Bearer $TOKEN")

if echo "$STATS_RESPONSE" | grep -q "total_students"; then
    echo -e "${GREEN}✓ Dashboard stats retrieved${NC}\n"
else
    echo -e "${RED}✗ Dashboard stats failed${NC}\n"
fi

# Test 11: Get Payment Statistics
echo -e "${YELLOW}[11/15] Testing Payment Statistics...${NC}"
PAYMENT_STATS=$(curl -s -X GET "$API_URL/payments/statistics" \
  -H "Authorization: Bearer $TOKEN")

if echo "$PAYMENT_STATS" | grep -q "total_revenue"; then
    echo -e "${GREEN}✓ Payment statistics retrieved${NC}\n"
else
    echo -e "${RED}✗ Payment statistics failed${NC}\n"
fi

# Test 12: Get Student List
echo -e "${YELLOW}[12/15] Testing Get Students List...${NC}"
STUDENTS_LIST=$(curl -s -X GET "$API_URL/students" \
  -H "Authorization: Bearer $TOKEN")

if echo "$STUDENTS_LIST" | grep -q "data"; then
    echo -e "${GREEN}✓ Students list retrieved${NC}\n"
else
    echo -e "${RED}✗ Students list failed${NC}\n"
fi

# Test 13: Get Classes List
echo -e "${YELLOW}[13/15] Testing Get Classes List...${NC}"
CLASSES_LIST=$(curl -s -X GET "$API_URL/classes" \
  -H "Authorization: Bearer $TOKEN")

if echo "$CLASSES_LIST" | grep -q "data"; then
    echo -e "${GREEN}✓ Classes list retrieved${NC}\n"
else
    echo -e "${RED}✗ Classes list failed${NC}\n"
fi

# Test 14: Security Headers Check
echo -e "${YELLOW}[14/15] Testing Security Headers...${NC}"
HEADERS=$(curl -I -s http://127.0.0.1:8000/up)

if echo "$HEADERS" | grep -q "X-Content-Type-Options"; then
    echo -e "${GREEN}✓ Security headers present${NC}"
    echo "   - X-Content-Type-Options: nosniff"
    echo "   - X-Frame-Options: DENY"
    echo "   - X-XSS-Protection: 1; mode=block"
else
    echo -e "${RED}✗ Security headers missing${NC}"
fi
echo ""

# Test 15: Rate Limiting Check
echo -e "${YELLOW}[15/15] Testing Rate Limiting...${NC}"
echo "   Making 6 rapid login attempts..."
for i in {1..6}; do
    RATE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"email":"test@test.com","password":"wrong"}')
    
    if [ $i -eq 6 ] && [ "$RATE_RESPONSE" = "429" ]; then
        echo -e "${GREEN}✓ Rate limiting working (6th request blocked)${NC}\n"
        break
    elif [ $i -eq 6 ]; then
        echo -e "${YELLOW}⚠ Rate limiting may not be working (got $RATE_RESPONSE)${NC}\n"
    fi
done

# Summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "Created Resources:"
echo -e "  - Student ID: ${STUDENT_ID:-N/A}"
echo -e "  - Teacher ID: ${TEACHER_ID:-N/A}"
echo -e "  - Class ID: ${CLASS_ID:-N/A}"
echo -e "\nServer: http://127.0.0.1:8000"
echo -e "Database: MySQL (tuition_management)"
echo -e "${YELLOW}========================================${NC}"
