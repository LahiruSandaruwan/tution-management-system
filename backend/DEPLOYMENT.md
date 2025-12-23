# Production Deployment Guide for Tuition Management System

## Prerequisites

- Ubuntu 20.04+ or similar Linux distribution
- - PHP 8.2+ with required extensions
  - - MySQL 8.0+
    - - Nginx or Apache
      - - Composer 2.x
        - - SSL certificate (Let's Encrypt recommended)
          - - Domain name
           
            - ## Server Setup
           
            - ### 1. Install Dependencies
           
            - ```bash
              # Update system
              sudo apt update && sudo apt upgrade -y

              # Install PHP and extensions
              sudo apt install php8.2 php8.2-fpm php8.2-mysql php8.2-mbstring \
                php8.2-xml php8.2-bcmath php8.2-curl php8.2-zip php8.2-gd \
                php8.2-sqlite3 -y

              # Install MySQL
              sudo apt install mysql-server -y
              sudo mysql_secure_installation

              # Install Nginx
              sudo apt install nginx -y

              # Install Composer
              curl -sS https://getcomposer.org/installer | php
              sudo mv composer.phar /usr/local/bin/composer
              ```

              ### 2. Configure MySQL

              ```bash
              sudo mysql -u root -p

              CREATE DATABASE tuition_management;
              CREATE USER 'tuition_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';
              GRANT ALL PRIVILEGES ON tuition_management.* TO 'tuition_user'@'localhost';
              FLUSH PRIVILEGES;
              EXIT;
              ```

              ### 3. Clone and Setup Application

              ```bash
              cd /var/www
              sudo git clone https://github.com/LahiruSandaruwan/tution-management-system.git
              cd tution-management-system/backend

              # Set permissions
              sudo chown -R www-data:www-data .
              sudo chmod -R 755 .

              # Install dependencies
              composer install --no-dev --optimize-autoloader

              # Configure environment
              cp .env.example .env
              nano .env  # Edit with production values
              ```

              ### 4. Setup Laravel

              ```bash
              php artisan key:generate
              php artisan migrate --force
              php artisan db:seed --class=DatabaseSeeder
              php artisan storage:link
              php artisan config:cache
              php artisan route:cache
              php artisan view:cache
              ```

              ### 5. Configure Nginx

              Create `/etc/nginx/sites-available/tuition-management`:

              ```nginx
              server {
                  listen 80;
                  listen [::]:80;
                  server_name your-domain.com;
                  return 301 https://$server_name$request_uri;
              }

              server {
                  listen 443 ssl http2;
                  listen [::]:443 ssl http2;
                  server_name your-domain.com;
                  root /var/www/tution-management-system/backend/public;
                  index index.php;

                  ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
                  ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
                  ssl_protocols TLSv1.2 TLSv1.3;
                  ssl_ciphers HIGH:!aNULL:!MD5;

                  add_header X-Frame-Options "SAMEORIGIN" always;
                  add_header X-Content-Type-Options "nosniff" always;
                  add_header X-XSS-Protection "1; mode=block" always;
                  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

                  access_log /var/log/nginx/tuition-access.log;
                  error_log /var/log/nginx/tuition-error.log;

                  location / {
                      try_files $uri $uri/ /index.php?$query_string;
                  }

                  location ~ \.php$ {
                      fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
                      fastcgi_index index.php;
                      fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
                      include fastcgi_params;
                      fastcgi_read_timeout 300;
                  }

                  location ~ /\.(?!well-known).* {
                      deny all;
                  }

                  client_max_body_size 10M;
              }
              ```

              Enable the site:

              ```bash
              sudo ln -s /etc/nginx/sites-available/tuition-management /etc/nginx/sites-enabled/
              sudo nginx -t
              sudo systemctl reload nginx
              ```

              ### 6. SSL Certificate Setup

              ```bash
              sudo apt install certbot python3-certbot-nginx -y
              sudo certbot --nginx -d your-domain.com
              ```

              ### 7. Setup Queue Worker

              Create `/etc/systemd/system/tuition-worker.service`:

              ```ini
              [Unit]
              Description=Tuition Management Queue Worker
              After=network.target

              [Service]
              Type=simple
              User=www-data
              WorkingDirectory=/var/www/tution-management-system/backend
              ExecStart=/usr/bin/php artisan queue:work --sleep=3 --tries=3 --max-time=3600
              Restart=always
              RestartSec=10

              [Install]
              WantedBy=multi-user.target
              ```

              Enable and start:

              ```bash
              sudo systemctl daemon-reload
              sudo systemctl enable tuition-worker
              sudo systemctl start tuition-worker
              ```

              ### 8. Setup Scheduler

              Add to crontab:

              ```bash
              sudo crontab -e -u www-data

              # Add:
              * * * * * cd /var/www/tution-management-system/backend && php artisan schedule:run >> /dev/null 2>&1
              ```

              ### 9. Setup Automated Backups

              ```bash
              # Create backup directory
              sudo mkdir -p /var/backups/tuition-system/{database,storage}
              sudo chown www-data:www-data /var/backups/tuition-system -R

              # Add to crontab (www-data user)
              # Database backup - Daily at 2 AM
              0 2 * * * /var/www/tution-management-system/backend/scripts/backup-database.sh >> /var/log/tuition-backup.log 2>&1

              # Storage backup - Daily at 3 AM
              0 3 * * * /var/www/tution-management-system/backend/scripts/backup-storage.sh >> /var/log/tuition-backup.log 2>&1
              ```

              ## Production Checklist

              - [ ] Set `APP_ENV=production` in .env
              - [ ] - [ ] Set `APP_DEBUG=false` in .env
              - [ ] - [ ] Generate secure `APP_KEY`
              - [ ] - [ ] Configure production database credentials
              - [ ] - [ ] Set up Redis for cache/queue (if using)
              - [ ] - [ ] Enable HTTPS/SSL
              - [ ] - [ ] Set up queue workers
              - [ ] - [ ] Configure automated backups
              - [ ] - [ ] Set secure `GATE_API_KEY`
              - [ ] - [ ] Configure CORS for production domains
              - [ ] - [ ] Test all API endpoints
              - [ ] - [ ] Test RFID gate integration
              - [ ] - [ ] Verify email sending
              - [ ] - [ ] Setup monitoring and logging
              - [ ] - [ ] Run database migrations
              - [ ] - [ ] Seed initial data
              - [ ] - [ ] Test backup restoration
              - [ ] - [ ] Load test the API
             
              - [ ] ## Monitoring
             
              - [ ] - Application logs: `/var/www/tution-management-system/backend/storage/logs/`
              - [ ] - Nginx logs: `/var/log/nginx/`
              - [ ] - PHP-FPM logs: `/var/log/php8.2-fpm.log`
              - [ ] - Backup logs: `/var/log/tuition-backup.log`
             
              - [ ] ## Troubleshooting
             
              - [ ] ### Application not loading
              - [ ] ```bash
              - [ ] sudo systemctl status nginx
              - [ ] sudo systemctl status php8.2-fpm
              - [ ] tail -f /var/log/nginx/tuition-error.log
              - [ ] tail -f storage/logs/laravel.log
              - [ ] ```
             
              - [ ] ### Queue not processing
              - [ ] ```bash
              - [ ] sudo systemctl status tuition-worker
              - [ ] sudo systemctl restart tuition-worker
              - [ ] ```
             
              - [ ] ### Database connection issues
              - [ ] ```bash
              - [ ] php artisan tinker
              - [ ] DB::connection()->getPdo();
              - [ ] sudo systemctl status mysql
              - [ ] ```
             
              - [ ] ## Scaling Notes
             
              - [ ] - Use Redis for distributed caching
              - [ ] - Configure load balancer for multiple servers
              - [ ] - Use read replicas for MySQL
              - [ ] - Consider CDN for static assets
              - [ ] - Monitor database query performance
              - [ ] - Use APCu for opcache in production
             
              - [ ] ## Security Best Practices
             
              - [ ] 1. Keep all dependencies updated: `composer update`
              - [ ] 2. Run security audits: `composer audit`
              - [ ] 3. Use environment variables for secrets
              - [ ] 4. Enable two-factor authentication for admin accounts
              - [ ] 5. Regular security scanning with OWASP ZAP
              - [ ] 6. Monitor suspicious activities
              - [ ] 7. Keep backups encrypted and offsite
              - [ ] 8. Review logs regularly
             
              - [ ] ## Support and Maintenance
             
              - [ ] For issues or questions:
              - [ ] - Review logs in detail
              - [ ] - Check system resources
              - [ ] - Test with small data sets first
              - [ ] - Keep backup of working configuration
              - [ ] - Document any custom modifications
