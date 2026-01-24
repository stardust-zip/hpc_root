#!/bin/bash

# Stop execution if any command fails
set -e

echo "🚀 HPC Setup Script"
echo "=================================="

default_ip="localhost"
read -p "Nhập địa chỉ IP [default: $default_ip]: " input_ip
PUBLIC_HOST="${input_ip:-$default_ip}"

echo "✅ Đang cài đặt cho: $PUBLIC_HOST"

echo "📝 Đang tạo file .env tại root..."
cat > .env <<EOF
# Frontend connects here
NEXT_PUBLIC_API_URL=http://$PUBLIC_HOST:8082/api
NEXT_PUBLIC_REVERB_HOST=$PUBLIC_HOST

# Backend System Management Public URL
APP_URL_SYS=http://$PUBLIC_HOST:8082

# Backend Recruitment Public URL
APP_URL_TUYEN=http://$PUBLIC_HOST:8020
EOF

echo "📥 Đang đồng bộ code..."
git submodule update --init --recursive

echo "🔧 Đang cài đặt System-Management..."
if [ ! -f System-Management/.env ]; then
    cp System-Management/.env.example System-Management/.env
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/DB_HOST=db/DB_HOST=sys_db/g' System-Management/.env
        sed -i '' 's/DB_HOST=127.0.0.1/DB_HOST=sys_db/g' System-Management/.env
    else
        sed -i 's/DB_HOST=db/DB_HOST=sys_db/g' System-Management/.env
        sed -i 's/DB_HOST=127.0.0.1/DB_HOST=sys_db/g' System-Management/.env
    fi
    echo "   -> Fixed DB_HOST to 'sys_db'"
fi

echo "🐳 Đang build và start containers..."
docker compose up -d --build

echo "⏳ Chờ Database (15s)..."
sleep 15

echo "🌱 Đang Seed Database..."
docker-compose exec -T sys_app mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views
docker compose exec -T sys_app chmod -R 777 storage bootstrap/cache
docker compose exec -T sys_app composer install --no-interaction --prefer-dist
docker compose exec -T sys_app php artisan key:generate

docker compose exec -T sys_app php artisan migrate --path=database/migrations --force
docker compose exec -T sys_app php artisan db:seed --class=AdminSeeder

docker compose exec -T sys_app php artisan optimize:clear

echo "=================================="
echo "✅ ĐÃ XONG!"
echo "=================================="
echo "🌍 Frontend: http://$PUBLIC_HOST:3000"
echo "👤 Admin (Giảng viên: admin / 123456"
echo "👤 Sinh Viên: sv_sv001 / 123456"
echo "=================================="
