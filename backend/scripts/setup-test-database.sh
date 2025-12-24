#!/bin/bash

###############################################################################
# Test Database Setup Script
# Description: Creates a separate MySQL database for running tests
# Usage: ./setup-test-database.sh
###############################################################################

# Configuration
DB_NAME="tuition_management_test"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Test Database Setup ===${NC}\n"

# Check if MySQL is running
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}Error: MySQL client not found. Please install MySQL.${NC}"
    exit 1
fi

echo "Creating test database: $DB_NAME"
echo "This database will be used exclusively for running automated tests."
echo ""

# Create database
if [ -n "$DB_PASS" ]; then
    mysql -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;" 2>/dev/null
else
    mysql -u"$DB_USER" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;" 2>/dev/null
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Test database created successfully: $DB_NAME${NC}"
else
    echo -e "${RED}✗ Failed to create test database${NC}"
    echo ""
    echo "Please create it manually:"
    echo "  mysql -u root -p"
    echo "  CREATE DATABASE tuition_management_test;"
    echo "  EXIT;"
    exit 1
fi

echo ""
echo -e "${YELLOW}=== Important Notes ===${NC}"
echo "• Test database: $DB_NAME"
echo "• This database will be refreshed (dropped and recreated) on each test run"
echo "• DO NOT use this database for production or development data"
echo "• Tests use the same credentials as your main database (from .env)"
echo ""
echo -e "${GREEN}✓ Setup complete! You can now run tests with:${NC}"
echo "  php artisan test"
echo ""
