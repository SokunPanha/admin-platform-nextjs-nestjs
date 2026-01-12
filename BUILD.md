# Build Instructions

This project consists of two main components:
- **Backend API** (NestJS) - Located in `admin-api/`
- **Frontend** (Next.js with Ant Design) - Located in `admin-antd-nextjs/`

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start with Docker](#quick-start-with-docker)
- [Local Development Setup](#local-development-setup)
- [Building for Production](#building-for-production)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### For Docker Setup
- Docker Desktop 20.10+
- Docker Compose 2.0+

### For Local Development
- Node.js 20.x or higher
- npm 10.x or higher
- PostgreSQL 16.x

---

## Quick Start with Docker

The easiest way to run the entire application stack is using Docker Compose.

### 0. Validate Docker Setup (Optional)

Before building, you can validate that all required files and configurations are in place:

```bash
# From the project root directory
./validate-docker.sh
```

This will check:
- All Docker files exist
- Required npm scripts are configured
- Next.js standalone output is enabled
- Entrypoint script permissions

### 1. Start All Services

```bash
# From the project root directory
docker-compose up -d
```

This will:
1. Start PostgreSQL database on port `5432`
2. Build and start Backend API on port `3000`
3. Build and start Frontend on port `3001`

**Note**: The backend automatically runs migrations and seeds the database on startup via the `docker-entrypoint.sh` script. You don't need to run them manually.

### 2. Verify Services are Running

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

### 3. Access the Application

- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000/admin/v1
- **API Documentation**: http://localhost:3000/admin/v1/api-docs

### 4. Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (Warning: This will delete database data)
docker-compose down -v
```

---

## Docker Architecture

### Backend Container
The backend Dockerfile uses a multi-stage build:
1. **Builder stage**: Compiles TypeScript to JavaScript
2. **Production stage**:
   - Installs production dependencies plus migration tools (ts-node, typeorm)
   - Copies compiled code and source files needed for migrations
   - Uses `docker-entrypoint.sh` to:
     - Wait for database to be ready
     - Run migrations automatically
     - Seed the database
     - Start the application

### Frontend Container
The frontend Dockerfile uses a multi-stage build optimized for Next.js:
1. **Deps stage**: Installs all dependencies
2. **Builder stage**: Builds the Next.js application with standalone output
3. **Runner stage**:
   - Creates a minimal production image
   - Runs as non-root user for security
   - Only includes necessary files for running

### Database Migrations
**Important**: Database migrations run automatically when the backend container starts. The `docker-entrypoint.sh` script:
- Waits for PostgreSQL to be healthy
- Runs `npm run migration:run`
- Runs `npm run seed:run`
- Then starts the application

You don't need to run migrations manually when using Docker.

---

## Local Development Setup

### Backend (NestJS API)

#### 1. Navigate to Backend Directory
```bash
cd admin-api
```

#### 2. Install Dependencies
```bash
npm install
```

#### 3. Configure Environment
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your configuration
# Required variables:
# - DATABASE_URL
# - JWT_SECRET
# - JWT_ACCESS_SECRET
# - JWT_REFRESH_SECRET
```

#### 4. Setup Database
```bash
# Make sure PostgreSQL is running
# Create database if it doesn't exist

# Run migrations
npm run migration:run

# Seed initial data
npm run seed:run
```

#### 5. Start Development Server
```bash
npm run start:dev
```

The backend API will be available at http://localhost:3000/admin/v1

#### Backend Available Scripts
- `npm run start:dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm run start:prod` - Start production server
- `npm run migration:generate` - Generate migration from entity changes
- `npm run migration:run` - Run pending migrations
- `npm run migration:revert` - Revert last migration
- `npm run seed:run` - Seed database with initial data
- `npm run test` - Run unit tests
- `npm run lint` - Run linter

---

### Frontend (Next.js)

#### 1. Navigate to Frontend Directory
```bash
cd admin-antd-nextjs
```

#### 2. Install Dependencies
```bash
npm install
```

#### 3. Configure Environment
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your configuration
# NEXT_PUBLIC_API_GATEWAY should point to your backend URL
# Default: http://localhost:3000
```

#### 4. Start Development Server
```bash
npm run dev
```

The frontend will be available at http://localhost:3001

#### Frontend Available Scripts
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run linter

---

## Building for Production

### Using Docker (Recommended)

```bash
# Build all services
docker-compose build

# Build specific service
docker-compose build backend
docker-compose build frontend

# Build with no cache
docker-compose build --no-cache
```

### Manual Build

#### Backend
```bash
cd admin-api
npm ci --omit=dev
npm run build
npm run start:prod
```

#### Frontend
```bash
cd admin-antd-nextjs
npm ci --omit=dev
npm run build
npm run start
```

---

## Environment Variables

### Backend (.env)

```env
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/database_name

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key
JWT_ACCESS_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your-super-secret-refresh-key
JWT_REFRESH_EXPIRES_IN=7d

# Application
NODE_ENV=development
PORT=3000
```

### Frontend (.env)

```env
# API Gateway
NEXT_PUBLIC_API_GATEWAY=http://localhost:3000

# Node Environment
NODE_ENV=development
```

**Important**:
- Never commit `.env` files to version control
- Change all secrets in production
- Use `.env.example` as a template

---

## Database Setup

### Using Docker
The database is automatically created when using `docker-compose up`.

### Local PostgreSQL

#### 1. Create Database
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE admin_db;

# Create user (optional)
CREATE USER admin WITH PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON DATABASE admin_db TO admin;
```

#### 2. Run Migrations
```bash
cd admin-api
npm run migration:run
```

#### 3. Seed Data
```bash
npm run seed:run
```

### Migration Commands

```bash
# Generate new migration from entity changes
npm run migration:generate -- src/database/migrations/MigrationName

# Create empty migration
npm run migration:create -- src/database/migrations/MigrationName

# Run pending migrations
npm run migration:run

# Revert last migration
npm run migration:revert

# Show migration status
npm run migration:show
```

---

## Troubleshooting

### Docker Issues

**Problem**: Port already in use
```bash
# Find process using the port
lsof -i :3000
lsof -i :3001
lsof -i :5432

# Kill the process or change ports in docker-compose.yml
```

**Problem**: Database connection refused
```bash
# Check if postgres is healthy
docker-compose ps

# View postgres logs
docker-compose logs postgres

# Restart postgres
docker-compose restart postgres
```

**Problem**: Build fails
```bash
# Clean build
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Local Development Issues

**Problem**: Module not found
```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Problem**: Database migration fails
```bash
# Check database connection
# Ensure DATABASE_URL is correct in .env

# Revert and retry
npm run migration:revert
npm run migration:run
```

**Problem**: TypeScript errors
```bash
# Rebuild
npm run build

# Check for type errors
npx tsc --noEmit
```

### Common Issues

**CORS Errors**:
- Check that `NEXT_PUBLIC_API_GATEWAY` in frontend `.env` matches backend URL
- Verify CORS settings in `admin-api/src/main.ts`

**Authentication Errors**:
- Ensure JWT secrets match between environments
- Check token expiration settings

**Build Optimization**:
- Frontend Docker image uses standalone output for smaller size
- Backend uses multi-stage build to reduce image size

---

## Project Structure

```
project/
├── admin-api/              # NestJS Backend
│   ├── src/
│   │   ├── modules/        # Feature modules
│   │   ├── database/       # Database config, migrations, seeds
│   │   ├── common/         # Shared utilities, filters, interceptors
│   │   └── main.ts         # Application entry point
│   ├── Dockerfile
│   └── package.json
│
├── admin-antd-nextjs/      # Next.js Frontend
│   ├── src/
│   │   ├── app/            # App router pages
│   │   ├── components/     # React components
│   │   └── i18n/           # Internationalization
│   ├── Dockerfile
│   └── package.json
│
└── docker-compose.yml      # Docker orchestration
```

---

## Additional Resources

- [NestJS Documentation](https://docs.nestjs.com/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Ant Design Documentation](https://ant.design/docs/react/introduce)
- [TypeORM Documentation](https://typeorm.io/)
- [Docker Documentation](https://docs.docker.com/)

---

## Production Deployment Checklist

- [ ] Change all secrets and passwords
- [ ] Set `NODE_ENV=production`
- [ ] Configure proper CORS origins
- [ ] Setup SSL/TLS certificates
- [ ] Configure database backups
- [ ] Setup monitoring and logging
- [ ] Configure rate limiting
- [ ] Review security headers
- [ ] Setup CI/CD pipeline
- [ ] Configure environment-specific variables
- [ ] Test all API endpoints
- [ ] Verify database migrations
- [ ] Load test the application
