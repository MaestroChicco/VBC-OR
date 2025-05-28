# Server Configuration
NODE_ENV=development
PORT=3000

# Database
MONGODB_URI=mongodb://localhost:27017/vbc_db

# Security
JWT_SECRET=your-super-secure-jwt-secret-key-min-32-chars
SESSION_SECRET=your-super-secure-session-secret-key-min-32-chars

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000

# SSL Configuration (for production)
SSL_CERT_PATH=/path/to/ssl/cert.pem
SSL_KEY_PATH=/path/to/ssl/private.key

# Email Configuration (for notifications)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# WhatsApp API Configuration
WHATSAPP_API_URL=https://graph.facebook.com/v17.0
WHATSAPP_ACCESS_TOKEN=your-whatsapp-access-token
WHATSAPP_PHONE_NUMBER_ID=your-phone-number-id
WHATSAPP_WEBHOOK_VERIFY_TOKEN=your-webhook-verify-token

# Payment Gateway (Ghala Integration)
GHALA_API_URL=https://api.ghala.co.tz
GHALA_API_KEY=your-ghala-api-key
GHALA_SECRET_KEY=your-ghala-secret-key

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_PATH=./uploads

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
LOG_FILE_PATH=./logs/app.log