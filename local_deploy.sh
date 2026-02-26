#!/usr/bin/env bash

# Use Strict Mode
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status.
set -euo pipefail

# Variables, Configurations
JWT_SECRET="vananhdeptraiokokokokokokokokokokokokokokok"
PUBLIC_HOST="localhost"
COMPOSE_CMD="docker compose"

# Colors for logging
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper Functions
log_step() { echo -e "\n${BLUE}==> $1${NC}"; }
log_success() { echo -e "${GREEN}SUCCESS: $1${NC}"; }
log_error() { echo -e "${RED}ERROR: $1${NC}"; }

# Trap errors to provide a clear message if the script crashes
trap 'log_error "Deployment failed at line $LINENO. Check the logs above."' ERR

# Phase 1: File Preparation
log_step "Generating Global .env file..."
cat <<EOF > .env
# HPC ROOT - GLOBAL ENVIRONMENT VARIABLES
JWT_SECRET=${JWT_SECRET}
APP_URL_SYS=http://${PUBLIC_HOST}:8082
APP_URL_TUYEN=http://${PUBLIC_HOST}:8020
NEXT_PUBLIC_API_URL=http://${PUBLIC_HOST}:8082/api
NEXT_PUBLIC_REVERB_HOST=${PUBLIC_HOST}
EOF

log_step "Generating Database Initialization Script..."
cat <<EOF > create_dbs.sql
CREATE DATABASE IF NOT EXISTS LMS;
CREATE DATABASE IF NOT EXISTS module_tuyendung;
CREATE DATABASE IF NOT EXISTS system_services;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
EOF

# Phase 2: Docker Deployment
log_step "Cleaning up old containers..."
# Removes existing containers and prevents the "name already in use" conflict
${COMPOSE_CMD} down --remove-orphans || true
docker rm -f hpc_dispatch_service 2>/dev/null || true

log_step "Starting Docker Compose (with build)..."
${COMPOSE_CMD} up -d --build

# Phase 3: System Management setup (core)
log_step "Setting up System-Management..."
cp -n System-Management/.env.example System-Management/.env || true

${COMPOSE_CMD} exec -T sys_app mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
${COMPOSE_CMD} exec -T sys_app chmod -R 777 storage bootstrap/cache
${COMPOSE_CMD} exec -T sys_app composer install --no-interaction --prefer-dist
${COMPOSE_CMD} exec -T sys_app php artisan key:generate

# Phase 4: Module-Tuyendung Setup
log_step "Setting up Module Tuyendung..."
cp -n Module_Tuyendung/back-end/.env.example Module_Tuyendung/back-end/.env || true

# Install required system dependencies inside the Alpine/Ubuntu container
${COMPOSE_CMD} exec -T -u root tuyen_app sh -c '
  if command -v apt-get >/dev/null; then
    apt-get update && apt-get install -y zip unzip git
  elif command -v apk >/dev/null; then
    apk add --no-cache zip unzip git
  fi
'

${COMPOSE_CMD} exec -T tuyen_app mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
${COMPOSE_CMD} exec -T tuyen_app chmod -R 777 storage bootstrap/cache || true

log_step "Setting up public/cvs directory permission for Module_Tuyendung"
${COMPOSE_CMD} exec -T tuyen_app mkdir -p public/cvs
${COMPOSE_CMD} exec -T -u root tuyen_app chown -R www-data:www-data public/cvs
${COMPOSE_CMD} exec -T -u root tuyen_app chmod -R 775 public/cvs

${COMPOSE_CMD} exec -T tuyen_app composer install --no-interaction --prefer-dist
${COMPOSE_CMD} exec -T tuyen_app php artisan key:generate


# Phase 5: Database Migrations and Seeding
log_step "Waiting for Shared MySQL Database to be ready..."
# Loop until mysqladmin ping succeeds
max_tries=15
counter=0
until ${COMPOSE_CMD} exec -T shared_db mysqladmin ping -h localhost -u root -proot --silent; do
  counter=$((counter+1))
  if [ $counter -gt $max_tries ]; then
    log_error "MySQL failed to start within the expected time."
    exit 1
  fi
  echo "Waiting for MySQL... ($counter/$max_tries)"
  sleep 5
done

MIGRATE_CMD="migrate"

if [[ "${1:-}" == "--fresh" ]]; then
    MIGRATE_CMD="migrate:fresh"
    log_step "Wiping Database and Running Fresh Migrations..."
else
    log_step "Running Core System Migrations..."
fi

log_step "Running Core System Migrations..."
${COMPOSE_CMD} exec -T sys_app php artisan ${MIGRATE_CMD} --path=database/migrations --force

log_step "Running Task Module Migrations..."
${COMPOSE_CMD} exec -T sys_app php artisan migrate --path=Modules/Task/database/migrations --force

log_step "Seeding System Database (Admin)..."
${COMPOSE_CMD} exec -T sys_app php artisan db:seed --class=AdminSeeder

log_step "Clearing System Cache..."
${COMPOSE_CMD} exec -T sys_app php artisan optimize:clear

log_step "Running Tuyen Migrations..."
${COMPOSE_CMD} exec -T tuyen_app php artisan ${MIGRATE_CMD} --force
${COMPOSE_CMD} exec -T tuyen_app php artisan db:seed --class=TeachersSeeder --force
${COMPOSE_CMD} exec -T tuyen_app php artisan db:seed --class=StudentSeeder --force

log_step "Running Dispatch Migrations..."
${COMPOSE_CMD} exec -w /app/src dispatch_service python -m hpc_dispatch_management.seed



# Phase 6: Finish
echo -e "\n============================================================"
log_success "DEPLOYMENT COMPLETE! System is running."
echo -e "Frontend: http://${PUBLIC_HOST}:3001"
echo -e "System:   http://${PUBLIC_HOST}:8082"
echo -e "LMS:      http://${PUBLIC_HOST}:8083"
echo -e "Tuyen:    http://${PUBLIC_HOST}:8020"
echo -e "============================================================\n"
