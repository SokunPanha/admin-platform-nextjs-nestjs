#!/bin/bash

echo "🔍 Validating Docker Setup..."
echo ""

# Check if required files exist
echo "✓ Checking required files..."

FILES=(
    "docker-compose.yml"
    "admin-api/Dockerfile"
    "admin-api/.dockerignore"
    "admin-api/docker-entrypoint.sh"
    "admin-client/Dockerfile"
    "admin-client/.dockerignore"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file missing"
        exit 1
    fi
done

echo ""
echo "✓ Checking npm scripts..."

# Check backend scripts
cd admin-api
if npm run 2>&1 | grep -q "build"; then
    echo "  ✓ admin-api has build script"
else
    echo "  ✗ admin-api missing build script"
    exit 1
fi

if npm run 2>&1 | grep -q "start:prod"; then
    echo "  ✓ admin-api has start:prod script"
else
    echo "  ✗ admin-api missing start:prod script"
    exit 1
fi

if npm run 2>&1 | grep -q "migration:run"; then
    echo "  ✓ admin-api has migration:run script"
else
    echo "  ✗ admin-api missing migration:run script"
    exit 1
fi

if npm run 2>&1 | grep -q "seed:run"; then
    echo "  ✓ admin-api has seed:run script"
else
    echo "  ✗ admin-api missing seed:run script"
    exit 1
fi

# Check frontend scripts
cd ../admin-client
if npm run 2>&1 | grep -q "build"; then
    echo "  ✓ admin-client has build script"
else
    echo "  ✗ admin-client missing build script"
    exit 1
fi

if npm run 2>&1 | grep -q "start"; then
    echo "  ✓ admin-client has start script"
else
    echo "  ✗ admin-client missing start script"
    exit 1
fi

cd ..

echo ""
echo "✓ Checking environment files..."

if [ -f "admin-api/.env.example" ]; then
    echo "  ✓ admin-api/.env.example exists"
else
    echo "  ✗ admin-api/.env.example missing"
fi

if [ -f "admin-client/.env.example" ]; then
    echo "  ✓ admin-client/.env.example exists"
else
    echo "  ✗ admin-client/.env.example missing"
fi

echo ""
echo "✓ Checking Next.js standalone output configuration..."
if grep -q "output.*standalone" admin-client/next.config.ts; then
    echo "  ✓ Next.js configured for standalone output"
else
    echo "  ⚠ Next.js not configured for standalone output"
    echo "    Add 'output: \"standalone\"' to next.config.ts"
fi

echo ""
echo "✓ Checking docker-entrypoint.sh permissions..."
if [ -x "admin-api/docker-entrypoint.sh" ]; then
    echo "  ✓ docker-entrypoint.sh is executable"
else
    echo "  ⚠ docker-entrypoint.sh is not executable"
    echo "    Run: chmod +x admin-api/docker-entrypoint.sh"
fi

echo ""
echo "═══════════════════════════════════════"
echo "✅ Docker setup validation complete!"
echo "═══════════════════════════════════════"
echo ""
echo "To build and run with Docker:"
echo "  1. Start Docker Desktop"
echo "  2. Run: docker-compose up -d"
echo "  3. Wait for services to start"
echo "  4. Access:"
echo "     - Frontend: http://localhost:3001"
echo "     - Backend: http://localhost:3000/admin/v1"
echo "     - API Docs: http://localhost:3000/admin/v1/api-docs"
echo ""
