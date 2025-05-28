// ssl-server.js - HTTPS Server Configuration
const express = require('express');
const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Import your main app
const app = require('./server');

// SSL Configuration for Production
if (process.env.NODE_ENV === 'production') {
  const sslOptions = {
    key: fs.readFileSync(process.env.SSL_KEY_PATH || './ssl/private.key'),
    cert: fs.readFileSync(process.env.SSL_CERT_PATH || './ssl/cert.pem')
  };

  // Create HTTPS server
  const httpsServer = https.createServer(sslOptions, app);
  
  httpsServer.listen(443, () => {
    console.log('HTTPS Server running on port 443');
  });

  // Redirect HTTP to HTTPS
  const httpApp = express();
  httpApp.use((req, res) => {
    res.redirect(301, `https://${req.headers.host}${req.url}`);
  });

  const httpServer = http.createServer(httpApp);
  httpServer.listen(80, () => {
    console.log('HTTP redirect server running on port 80');
  });

} else {
  // Development server (HTTP only)
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Development server running on http://localhost:${PORT}`);
  });
}

// SSL Certificate Generation Script (for development/testing)
// Run: node scripts/generate-ssl.js
const generateSSLScript = `
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Create SSL directory
const sslDir = path.join(__dirname, '..', 'ssl');
if (!fs.existsSync(sslDir)) {
  fs.mkdirSync(sslDir, { recursive: true });
}

// Generate self-signed certificate for development
try {
  console.log('Generating self-signed SSL certificate...');
  
  // Generate private key
  execSync(\`openssl genrsa -out \${path.join(sslDir, 'private.key')} 2048\`);
  
  // Generate certificate
  execSync(\`openssl req -new -x509 -key \${path.join(sslDir, 'private.key')} -out \${path.join(sslDir, 'cert.pem')} -days 365 -subj "/C=TZ/ST=Dar es Salaam/L=Dar es Salaam/O=VBC/CN=localhost"\`);
  
  console.log('SSL certificate generated successfully!');
  console.log('Files created:');
  console.log('- ssl/private.key');
  console.log('- ssl/cert.pem');
  console.log('\\nNote: This is a self-signed certificate for development only.');
  console.log('For production, use certificates from a trusted CA like Let\\'s Encrypt.');
  
} catch (error) {
  console.error('Error generating SSL certificate:', error.message);
  console.log('\\nMake sure OpenSSL is installed on your system.');
  console.log('On Ubuntu/Debian: sudo apt-get install openssl');
  console.log('On macOS: brew install openssl');
  console.log('On Windows: Download from https://slproweb.com/products/Win32OpenSSL.html');
}
`;

// Write the SSL generation script
fs.writeFileSync(path.join(__dirname, 'scripts', 'generate-ssl.js'), generateSSLScript);

module.exports = app;