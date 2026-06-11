# Implementation Guide: Rate Limiting, Security Hardening & Logging
## Issue #103: [BACKEND] Non-Fungsional

**Status**: ✓ Completed  
**Branch**: `feature/rate-limiting-security-logging-#103`

---

## 1. Rate Limiting (100 req/min per token) - SRS Bab 3.4

### Implementation
- **Nginx Level**: Rate limiting zone configured in `nginx.conf`
  - General API endpoints: 100 requests/minute per token
  - Authentication endpoints: 10 requests/minute per IP (stricter)
  - Burst capacity: 20 requests for API, 5 for Auth

- **Laravel Level**: `RateLimitMiddleware` for application-level rate limiting
  - Token-based rate limiting using X-API-Token header
  - Bearer token support
  - IP-based fallback

### Configuration Files
- `backend/config/nginx.conf` - Nginx rate limiting zones
- `backend/app/Http/Middleware/RateLimitMiddleware.php`
- `backend/app/Http/Kernel.php` - Middleware registration

### Usage
```bash
# HTTP request will receive rate limit headers
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 60

# When limit exceeded (HTTP 429)
{
  "status": "error",
  "code": 429,
  "message": "Rate limit exceeded. Maximum 100 requests per minute.",
  "retry_after": 45
}
```

---

## 2. HTTPS/TLS 1.2+ Configuration - NF-SEC-01

### Implementation
- **Protocol Support**: TLS 1.2 and TLS 1.3 only
- **Ciphers**: HIGH:!aNULL:!MD5 (secure cipher suites)
- **HTTP to HTTPS**: Automatic redirect on port 80
- **HSTS Header**: max-age=31536000 (1 year)

### Configuration
```nginx
# SSL Configuration in nginx.conf
listen 443 ssl http2;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
```

### SSL Certificate Setup
```bash
# Place certificates at:
/etc/nginx/ssl/cert.pem
/etc/nginx/ssl/key.pem

# Or use Let's Encrypt with certbot
certbot certonly --standalone -d yourdomain.com
```

---

## 3. OWASP Top 10 Protection - NF-SEC-07

### Implemented Controls

#### A. SQL Injection Prevention
- Laravel Eloquent ORM with parameterized queries
- Input validation on all endpoints
- Database driver security configurations

#### B. XSS (Cross-Site Scripting) Protection
- Content-Security-Policy header
- X-XSS-Protection header enabled
- HTML escaping in responses
- Input sanitization

#### C. CSRF (Cross-Site Request Forgery) Protection
- X-Frame-Options: SAMEORIGIN
- CSRF token validation in web routes
- SameSite cookie attribute

#### D. Security Headers
```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
Content-Security-Policy: [See nginx.conf for full policy]
```

#### E. Additional Protections
- Server token hiding (Server: API)
- HTTP/2 support
- Gzip compression with security considerations

### Configuration Files
- `backend/config/nginx.conf` - Security headers
- `backend/app/Http/Middleware/OWASPProtectionMiddleware.php`
- `backend/app/Http/Kernel.php` - Middleware registration

---

## 4. Immutable Audit Logging - NF-SAFE-02

### Implementation
- **Model**: `AuditLog` model for recording all financial transactions
- **Immutability**: UPDATED_AT disabled - logs cannot be modified after creation
- **Logging Scope**: Wallet top-ups, withdrawals, payments, transfers, refunds

### Recorded Information
```
- Transaction type (wallet_topup, payment, transfer, etc.)
- User ID & IP address
- Amount & reference ID
- Timestamp (UTC)
- User agent & metadata
- Status (recorded, completed, failed, cancelled)
```

### Usage Example
```php
use App\Models\AuditLog;

// Log a wallet transaction
AuditLog::logTransaction(
    AuditLog::TYPE_WALLET_TOPUP,
    $userId,
    [
        'amount' => 100000,
        'wallet_id' => $wallet->id,
        'payment_method' => 'credit_card'
    ],
    ['payment_gateway' => 'midtrans']
);

// Query logs
AuditLog::forUser($userId)
    ->ofType(AuditLog::TYPE_PAYMENT_COMPLETED)
    ->recent(30) // Last 30 days
    ->get();
```

### Database
- Table: `audit_logs`
- Indexes: `transaction_type`, `reference_id`, `user_id + transaction_type`, `created_at`
- Migration: `2026_06_11_add_financial_audit_to_audit_logs.php`

---

## 5. MySQL Automatic Backup - SRS Bab 6

### Implementation
- **Schedule**: 02:00 AM WIB (Configurable)
- **Retention**: 30 days (automatic cleanup)
- **Format**: gzip compressed SQL dumps
- **Location**: `/app/storage/backups/mysql/`
- **Logging**: `/app/storage/logs/mysql-backup.log`

### Script Files
- `backend/scripts/mysql-backup.sh` - Backup execution script
- `backend/config/supervisord.conf` - Scheduler configuration

### Backup Process
1. Connect to MySQL database
2. Create compressed SQL dump
3. Store with timestamp filename
4. Log results (success/failure)
5. Remove backups older than 30 days
6. Report statistics

### Manual Backup
```bash
bash /app/scripts/mysql-backup.sh
```

### Restore Backup
```bash
gunzip < /app/storage/backups/mysql/lokal_app_backup_*.sql.gz | mysql -u root -p lokal_app
```

### Supervisor Configuration
```ini
[program:backup-scheduler]
command=/bin/bash -c "while true; do if [ $(date +%H:%M) = '02:00' ]; then bash /app/scripts/mysql-backup.sh; fi; sleep 60; done"
```

---

## 6. OpenAPI 3.0 Documentation - SRS Bab 5.4

### Implementation
- **Endpoint**: `GET /api/v1/docs/openapi.json`
- **Documentation**: `GET /api/v1/docs` (HTML view)
- **Auto-generated**: From Laravel routes
- **Format**: OpenAPI 3.0.0 compliant

### Features
- Complete API paths and methods
- Request/response schemas
- Security schemes (Bearer & API Key)
- Parameter documentation
- Error responses
- Server configurations

### Access
```
# JSON Specification
http://yourdomain.com/api/v1/docs/openapi.json

# HTML Documentation
http://yourdomain.com/api/v1/docs
```

### Controller
- `backend/app/Http/Controllers/Api/OpenApiDocumentationController.php`

### Route Configuration
```php
Route::get('docs/openapi.json', [OpenApiDocumentationController::class, 'specification']);
Route::get('docs', [OpenApiDocumentationController::class, 'documentation'])->name('api.docs');
```

---

## 7. Uptime Monitoring - SRS Bab 5.4 (Target: >= 99.5%/bulan)

### Implementation
- **Health Check**: `/api/v1/test` endpoint
- **Monitoring Script**: `backend/scripts/health-check.sh`
- **Log Location**: `/app/storage/monitoring/health-check.log`
- **Check Interval**: Configurable (recommend: every 5 minutes)

### Health Check Response
```json
{
  "message": "API is working!",
  "time": "2026-06-11T10:30:45Z"
}
```

### Manual Health Check
```bash
# Run health check
bash /app/scripts/health-check.sh

# View uptime statistics
bash /app/scripts/health-check.sh --stats
```

### Uptime Calculator
The script automatically calculates:
- Total checks performed
- Passed checks
- Uptime percentage

### Supervisor Configuration
Add to `supervisord.conf`:
```ini
[program:health-check-monitor]
command=/bin/bash -c "while true; do bash /app/scripts/health-check.sh; sleep 300; done"
autostart=true
autorestart=true
```

### External Monitoring Services
For production, integrate with:
- **Uptime Kuma** - Self-hosted monitoring
- **Pingdom** - Cloud-based monitoring
- **StatusPage.io** - Status page service
- **DataDog** - APM & infrastructure monitoring

---

## Deployment Checklist

### Prerequisites
- [ ] PHP 8.1+
- [ ] Laravel 11+
- [ ] MySQL 8.0+
- [ ] Nginx 1.24+
- [ ] OpenSSL with TLS 1.2+ support

### Before Deployment
1. **Generate SSL Certificates**
   ```bash
   # Using Let's Encrypt
   certbot certonly --standalone -d yourdomain.com
   ```

2. **Create Storage Directories**
   ```bash
   mkdir -p /app/storage/backups/mysql
   mkdir -p /app/storage/monitoring
   mkdir -p /app/storage/logs
   chmod 755 /app/scripts/*.sh
   ```

3. **Run Migrations**
   ```bash
   php artisan migrate
   ```

4. **Update Environment Variables**
   ```
   HTTPS_ENABLED=true
   RATE_LIMIT_ENABLED=true
   AUDIT_LOG_ENABLED=true
   BACKUP_ENABLED=true
   ```

### After Deployment
- [ ] Test rate limiting (send 101+ requests)
- [ ] Verify HTTPS/TLS configuration
- [ ] Test OpenAPI documentation endpoint
- [ ] Check audit logs are recorded
- [ ] Verify backup script runs at 02:00 AM
- [ ] Test health check endpoint
- [ ] Monitor uptime metrics for 1 week

---

## Monitoring & Maintenance

### Daily Tasks
- Check backup logs: `tail /app/storage/logs/mysql-backup.log`
- Monitor health checks: `tail /app/storage/monitoring/health-check.log`

### Weekly Tasks
- Review audit logs for suspicious activity
- Check rate limit statistics
- Verify HTTPS certificate expiration

### Monthly Tasks
- Analyze uptime metrics
- Review backup integrity
- Audit security headers
- Update security policies

### Annual Tasks
- Renew SSL certificates
- Update TLS cipher suites
- Review OWASP Top 10 checklist
- Penetration testing

---

## Troubleshooting

### Rate Limiting Issues
```php
// Check rate limit status
$limiter = app('Illuminate\Cache\RateLimiter');
$limiter->tooManyAttempts('key', 100, 1);
```

### SSL/TLS Problems
```bash
# Test SSL configuration
openssl s_client -connect yourdomain.com:443

# Verify certificate
openssl x509 -in cert.pem -text -noout
```

### Backup Issues
```bash
# Test backup manually
bash /app/scripts/mysql-backup.sh

# Check backup log
tail -f /app/storage/logs/mysql-backup.log
```

### Audit Log Issues
```bash
# Query audit logs in Laravel tinker
php artisan tinker
>>> AuditLog::latest()->first();
```

---

## Security Recommendations

1. **Regularly Update Dependencies**
   - `composer update`
   - `npm update`

2. **Rotate SSL Certificates**
   - Before expiration
   - Use auto-renewal with certbot

3. **Monitor Security Headers**
   - Use security.headers.io
   - Verify CSP policy

4. **Database Backups**
   - Test restore procedures monthly
   - Store backups off-site
   - Encrypt sensitive backup data

5. **Log Rotation**
   - Implement log rotation for disk management
   - Archive logs regularly
   - Retain for compliance periods

---

## Performance Metrics

### Expected Performance
- Rate limiting overhead: < 1ms per request
- HTTPS/TLS negotiation: < 100ms (cold)
- Audit logging: < 5ms per transaction
- Backup duration: 2-5 minutes (depends on DB size)
- Health check time: < 500ms

### Monitoring Points
- Response time (p50, p95, p99)
- Error rate (4xx, 5xx)
- Rate limit rejections
- Backup success rate
- SSL certificate validity

---

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.3)
- [Laravel Security](https://laravel.com/docs/11.x/security)
- [Nginx Security](https://nginx.org/en/docs/)
- [TLS 1.2+ Best Practices](https://mozilla.github.io/server-side-tls/ssl-config-generator/)

