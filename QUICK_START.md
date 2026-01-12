# Quick Start Guide

Get the application running in under 5 minutes.

## Option 1: Docker (Recommended for First-Time Setup)

### Prerequisites
- Docker Desktop installed and running

### Steps

1. **Validate setup (optional)**
   ```bash
   ./validate-docker.sh
   ```

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

   This will:
   - Start PostgreSQL database
   - Build and start backend (with automatic migrations)
   - Build and start frontend

3. **Access the application**
   - Frontend: http://localhost:3001
   - Backend API: http://localhost:3000/admin/v1
   - API Docs: http://localhost:3000/admin/v1/api-docs

That's it! The application is now running.

**Note**: Database migrations and seeding happen automatically when the backend starts. No manual intervention needed!

### Stop the application
```bash
docker-compose down
```

---

## Option 2: Local Development

### Prerequisites
- Node.js 20+ installed
- PostgreSQL 16+ installed and running

### Steps

1. **Setup Backend**
   ```bash
   cd admin-api
   cp .env.example .env
   # Edit .env with your database credentials
   npm install
   npm run migration:run
   npm run seed:run
   npm run start:dev
   ```

2. **Setup Frontend** (in a new terminal)
   ```bash
   cd admin-antd-nextjs
   cp .env.example .env
   # Edit .env - ensure NEXT_PUBLIC_API_GATEWAY points to backend
   npm install
   npm run dev
   ```

3. **Access the application**
   - Frontend: http://localhost:3001
   - Backend API: http://localhost:3000/admin/v1

---

## Default Configuration

- **Database**: PostgreSQL on port 5432
- **Backend**: NestJS on port 3000
- **Frontend**: Next.js on port 3001

---

## Next Steps

- Read [BUILD.md](BUILD.md) for detailed build instructions
- Check API documentation at http://localhost:3000/admin/v1/api-docs
- Review environment variables in `.env.example` files

---

## Common Commands

### Docker
```bash
# View logs
docker-compose logs -f

# Restart a service
docker-compose restart backend

# Rebuild after code changes
docker-compose up -d --build
```

### Local Development
```bash
# Backend dev server with hot reload
cd admin-api && npm run start:dev

# Frontend dev server with hot reload
cd admin-antd-nextjs && npm run dev

# Run database migrations
cd admin-api && npm run migration:run
```

---

## Troubleshooting

**Port already in use?**
```bash
# Change ports in docker-compose.yml
# Or stop the conflicting service
```

**Database connection failed?**
```bash
# For Docker: Check postgres service is healthy
docker-compose ps

# For local: Verify PostgreSQL is running
psql -U postgres -c "SELECT 1"
```

**Need help?**
- See detailed troubleshooting in [BUILD.md](BUILD.md#troubleshooting)
