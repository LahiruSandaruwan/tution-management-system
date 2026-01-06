# Production Deployment Guide

This guide covers deploying the Tuition Management System to production using Docker.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Initial Server Setup](#initial-server-setup)
- [Docker Deployment](#docker-deployment)
- [Environment Configuration](#environment-configuration)
- [SSL/TLS Configuration](#ssltls-configuration)
- [Database Backup & Restore](#database-backup--restore)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [CI/CD with GitHub Actions](#cicd-with-github-actions)

## Prerequisites

### Server Requirements
- Ubuntu 22.04 LTS or newer
- Minimum 2GB RAM (4GB recommended)
- 20GB disk space
- Docker 24.0+ and Docker Compose 2.20+
- Domain name with DNS configured

### Local Requirements
- Git
- SSH access to production server
- Docker Hub account (for image registry)

## Initial Server Setup

### 1. Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Verify installation
docker --version
docker compose version
```

### 3. Configure Firewall
```bash
# Allow SSH, HTTP, HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 4. Create Application Directory
```bash
sudo mkdir -p /var/www/tuition-management
sudo chown $USER:$USER /var/www/tuition-management
cd /var/www/tuition-management
```

## Docker Deployment

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/tuition-management-system.git .
```

### 2. Configure Environment Variables
```bash
# Copy example environment file
cp backend/.env.example backend/.env

# Edit with production values
nano backend/.env
```

**Critical environment variables to set:**
```env
# Application
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Database (use strong passwords!)
DB_DATABASE=tuition_management
DB_USERNAME=tuition_user
DB_PASSWORD=CHANGE_TO_STRONG_PASSWORD
DB_ROOT_PASSWORD=CHANGE_TO_STRONG_ROOT_PASSWORD

# Redis
REDIS_PASSWORD=CHANGE_TO_STRONG_REDIS_PASSWORD

# Sanctum
SANCTUM_STATEFUL_DOMAINS=yourdomain.com

# CORS
CORS_ALLOWED_ORIGINS=https://yourdomain.com

# Session Security
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=strict
SESSION_DOMAIN=.yourdomain.com

# Gate API
GATE_API_KEY=GENERATE_32_CHAR_RANDOM_STRING

# Sentry (Error Monitoring)
SENTRY_LARAVEL_DSN=https://your-sentry-dsn@sentry.io/project-id
```

### 3. Generate Application Key
```bash
docker compose run --rm app php artisan key:generate
```

### 4. Create Required Directories
```bash
mkdir -p backups/database backups/storage
mkdir -p docker/nginx/ssl
chmod +x scripts/*.sh
```

### 5. Build and Start Services
```bash
# Build images
docker compose build

# Start services in detached mode
docker compose up -d

# Verify services are running
docker compose ps
```

### 6. Run Database Migrations
```bash
docker compose exec app php artisan migrate --force
```

### 7. Create Initial Admin User
```bash
docker compose exec app php artisan tinker

# In tinker console:
$user = App\Models\User::create([
    'name' => 'Admin User',
    'email' => 'admin@yourdomain.com',
    'password' => Hash::make('SECURE_PASSWORD_HERE'),
    'role' => 'admin',
    'institute_id' => 1
]);
```

### 8. Optimize Application
```bash
docker compose exec app php artisan config:cache
docker compose exec app php artisan route:cache
docker compose exec app php artisan view:cache
```

## Environment Configuration

### Docker Compose Environment Variables
Create `.env` in project root for Docker Compose:

```env
# Database
DB_DATABASE=tuition_management
DB_USERNAME=tuition_user
DB_PASSWORD=your_db_password
DB_ROOT_PASSWORD=your_root_password

# Redis
REDIS_PASSWORD=your_redis_password

# Application
APP_ENV=production
APP_DEBUG=false
```

## SSL/TLS Configuration

### Option 1: Using Let's Encrypt (Recommended)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Stop nginx temporarily
docker compose stop nginx

# Obtain certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem docker/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem docker/nginx/ssl/key.pem
sudo chown $USER:$USER docker/nginx/ssl/*.pem

# Restart nginx
docker compose start nginx
```

### Option 2: Using Custom SSL Certificate

```bash
# Copy your certificates
cp /path/to/certificate.crt docker/nginx/ssl/cert.pem
cp /path/to/private.key docker/nginx/ssl/key.pem
```

### Enable HTTPS in Nginx Configuration

Edit `docker/nginx/default.conf` and uncomment the HTTPS server block (lines 70-88):

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # ... rest of configuration
}
```

Restart nginx:
```bash
docker compose restart nginx
```

## Database Backup & Restore

### Automated Backups

Backups run automatically every 6 hours via the backup service. Backups are stored in:
- Database: `backups/database/`
- Storage: `backups/storage/`

Retention: 30 days (configurable in scripts)

### Manual Backup

```bash
# Database backup
./scripts/backup-database.sh

# Storage backup
./scripts/backup-storage.sh
```

### Restore from Backup

```bash
# List available backups
ls -lh backups/database/

# Restore database
./scripts/restore-database.sh backups/database/backup_20260106_120000.sql.gz
```

### Download Backups to Local Machine

```bash
# From your local machine
scp user@server:/var/www/tuition-management/backups/database/*.sql.gz ./local-backups/
```

## Monitoring & Maintenance

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f queue

# Laravel logs
docker compose exec app tail -f storage/logs/laravel.log
```

### Service Health Checks

```bash
# Check service status
docker compose ps

# Check application health
curl https://yourdomain.com/health

# Check database connection
docker compose exec app php artisan tinker
>>> DB::connection()->getPdo();
```

### Queue Management

```bash
# View queue workers
docker compose exec app php artisan queue:monitor

# Restart queue workers
docker compose exec app php artisan queue:restart

# Clear failed jobs
docker compose exec app php artisan queue:flush
```

### Cache Management

```bash
# Clear all caches
docker compose exec app php artisan cache:clear
docker compose exec app php artisan config:clear
docker compose exec app php artisan route:clear
docker compose exec app php artisan view:clear

# Rebuild caches
docker compose exec app php artisan config:cache
docker compose exec app php artisan route:cache
docker compose exec app php artisan view:cache
```

### Database Maintenance

```bash
# Run migrations
docker compose exec app php artisan migrate --force

# Rollback last migration
docker compose exec app php artisan migrate:rollback --step=1

# Optimize database
docker compose exec db mysql -u root -p -e "OPTIMIZE TABLE tuition_management.*"
```

### Security Updates

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker compose pull
docker compose up -d --force-recreate

# Update Composer dependencies
docker compose exec app composer update --no-dev
```

## CI/CD with GitHub Actions

### Setup GitHub Secrets

Navigate to your repository → Settings → Secrets and variables → Actions

Add the following secrets:

1. **DOCKER_USERNAME** - Your Docker Hub username
2. **DOCKER_PASSWORD** - Your Docker Hub access token
3. **PRODUCTION_HOST** - Server IP or domain
4. **PRODUCTION_USER** - SSH username
5. **PRODUCTION_PORT** - SSH port (usually 22)
6. **PRODUCTION_SSH_KEY** - Private SSH key for server access
7. **PRODUCTION_URL** - Full application URL (https://yourdomain.com)

### Generate SSH Key for GitHub Actions

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions

# Copy public key to server
ssh-copy-id -i ~/.ssh/github_actions.pub user@server

# Copy private key content for GitHub secret
cat ~/.ssh/github_actions
```

### Deployment Workflow

The deployment automatically runs when:
- Code is pushed to `main` or `production` branch
- Manual trigger via GitHub Actions UI

Workflow steps:
1. Run tests with MySQL and Redis
2. Build Docker image
3. Push to Docker Hub
4. Deploy to production server
5. Run migrations
6. Cache configuration
7. Restart services
8. Health check

### Manual Deployment Trigger

1. Go to GitHub repository → Actions
2. Select "Deploy Production" workflow
3. Click "Run workflow"
4. Select branch and click "Run workflow"

## Troubleshooting

### Application not accessible

```bash
# Check nginx logs
docker compose logs nginx

# Verify port binding
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Check firewall
sudo ufw status
```

### Database connection errors

```bash
# Verify database is running
docker compose ps db

# Check database logs
docker compose logs db

# Test connection
docker compose exec app php artisan tinker
>>> DB::connection()->getPdo();
```

### Permission errors

```bash
# Fix storage permissions
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
docker compose exec app chmod -R 775 storage bootstrap/cache
```

### High memory usage

```bash
# Check resource usage
docker stats

# Restart services
docker compose restart

# Optimize OPcache settings in docker/php/opcache.ini
```

### SSL certificate renewal

```bash
# Renew Let's Encrypt certificate
sudo certbot renew

# Copy renewed certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem docker/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem docker/nginx/ssl/key.pem

# Restart nginx
docker compose restart nginx
```

## Performance Optimization

### Enable OPcache Preloading (PHP 8.2)

Edit `docker/php/php.ini`:
```ini
opcache.preload=/var/www/preload.php
opcache.preload_user=www-data
```

Create `backend/preload.php`:
```php
<?php
require __DIR__ . '/vendor/autoload.php';
```

### Database Query Optimization

```bash
# Enable slow query log (already configured in docker/mysql/my.cnf)
docker compose exec db mysql -u root -p -e "
    SELECT * FROM mysql.slow_log
    ORDER BY query_time DESC
    LIMIT 10;
"
```

### Redis Persistence

Redis is configured with AOF (Append-Only File) persistence for data durability.

## Scaling Considerations

### Horizontal Scaling

To scale queue workers:
```bash
docker compose up -d --scale queue=4
```

### Load Balancing

For multiple application servers, configure nginx as reverse proxy or use external load balancer (AWS ELB, Cloudflare, etc.)

### Database Replication

Configure MySQL master-slave replication for read scaling. Update Laravel `config/database.php`:

```php
'mysql' => [
    'read' => [
        'host' => ['read-replica-1', 'read-replica-2'],
    ],
    'write' => [
        'host' => ['master-db'],
    ],
    // ... other settings
],
```

## Support & Resources

- Laravel Documentation: https://laravel.com/docs
- Docker Documentation: https://docs.docker.com
- Nginx Documentation: https://nginx.org/en/docs
- Sentry Documentation: https://docs.sentry.io

## Security Checklist

- [ ] Changed all default passwords
- [ ] Generated strong APP_KEY
- [ ] Configured SSL/TLS certificates
- [ ] Set APP_DEBUG=false
- [ ] Configured firewall rules
- [ ] Set up automated backups
- [ ] Configured Sentry error monitoring
- [ ] Restricted CORS origins
- [ ] Enabled session security settings
- [ ] Changed GATE_API_KEY
- [ ] Configured Redis password
- [ ] Limited database user permissions
- [ ] Set up regular security updates
- [ ] Reviewed file permissions
- [ ] Configured rate limiting

---

**Last Updated:** 2026-01-06
**Version:** 1.0.0
