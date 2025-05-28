# .gitignore
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Database
*.db
*.sqlite
*.sqlite3

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage
.grunt

# Bower dependency directory
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons
build/Release

# Dependency directories
node_modules/
jspm_packages/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache
.cache
.parcel-cache

# Next.js build output
.next

# Nuxt.js build / generate output
.nuxt
dist

# Gatsby files
.cache/
public

# Storybook build outputs
.out
.storybook-out

# Temporary folders
tmp/
temp/

# SSL certificates (for development)
ssl/
*.pem
*.key
*.crt

# Uploads directory
uploads/

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Production builds
build/
dist/

---

# README.md Template
# VBC WhatsApp Bot Backend

A complete Node.js/Express backend server for the VBC WhatsApp shopping bot with authentication, session management, SSL support, and comprehensive API endpoints.

## Features

- 🔐 **Authentication & Authorization**: JWT tokens + session management
- 🛡️ **Security**: Helmet, CORS, rate limiting, password hashing
- 📊 **Database**: MongoDB with Mongoose ODM
- 🔒 **SSL Support**: HTTPS configuration for production
- 📱 **API Endpoints**: RESTful APIs for products, orders, users
- 📈 **Analytics**: Admin dashboard with business metrics
- 🚀 **Production Ready**: Error handling, logging, graceful shutdown

## Quick Start

### Prerequisites

- Node.js (v16+)
- MongoDB
- OpenSSL (for SSL certificates)

### Installation

1. Clone the repository:
\`\`\`bash
git clone <your-repo-url>
cd vbc-whatsapp-bot-server
\`\`\`

2. Install dependencies:
\`\`\`bash
npm install
\`\`\`

3. Set up environment variables:
\`\`\`bash
cp .env.example .env
# Edit .env with your configuration
\`\`\`

4. Generate SSL certificates (development):
\`\`\`bash
node scripts/generate-ssl.js
\`\`\`

5. Start the server:
\`\`\`bash
# Development
npm run dev

# Production
npm start
\`\`\`

## API Endpoints

### Authentication
- \`POST /api/auth/register\` - Register new user
- \`POST /api/auth/login\` - User login
- \`POST /api/auth/logout\` - User logout

### Products
- \`GET /api/products\` - Get all products (with pagination, search, filters)
- \`GET /api/products/:id\` - Get single product
- \`POST /api/products\` - Create product (admin only)
- \`PUT /api/products/:id\` - Update product (admin only)
- \`DELETE /api/products/:id\` - Delete product (admin only)

### Orders
- \`POST /api/orders\` - Create new order
- \`GET /api/orders\` - Get user orders (or all for admin)
- \`GET /api/orders/:id\` - Get single order
- \`PUT /api/orders/:id/status\` - Update order status (admin only)

### Analytics
- \`GET /api/analytics/dashboard\