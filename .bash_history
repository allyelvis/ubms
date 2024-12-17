gcloud config set project sokoni-44ef1
#!/bin/bash
# Unified Business Management System Deployment Script
# Author: Ally Elvis Nzeyimana
# Purpose: Automate the setup, installation, and deployment of UBMS.
# Function to print messages
log() {     echo -e "\e[32m[INFO]\e[0m $1"; }
error() {     echo -e "\e[31m[ERROR]\e[0m $1";     exit 1; }
# Check prerequisites
check_prerequisites() {     log "Checking prerequisites...";     for cmd in docker docker-compose git; do         if ! command -v $cmd &> /dev/null; then             error "$cmd is not installed. Please install it and rerun this script.";         fi;     done;     log "All prerequisites are met."; }
# Clone repositories
clone_repos() {     log "Cloning repositories...";     git clone https://github.com/allyelvis/ae-pos.git || error "Failed to clone AE-POS repository.";     git clone https://github.com/allyelvis/Smart-store-room.git || error "Failed to clone Smart Store Room repository.";     git clone https://github.com/allyelvis/posc.git || error "Failed to clone POSC repository."; }
# Set up Docker environment
setup_docker() {     log "Setting up Docker environment..."; 
    cat > docker-compose.yml <<EOL
version: "3.8"
services:
  backend:
    build:
      context: ./ae-pos
    container_name: ubms_backend
    ports:
      - "8000:8000"
    volumes:
      - ./ae-pos:/app
    depends_on:
      - database
  frontend:
    build:
      context: ./Smart-store-room
    container_name: ubms_frontend
    ports:
      - "3000:3000"
    volumes:
      - ./Smart-store-room:/app
  database:
    image: postgres:15
    container_name: ubms_db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
      POSTGRES_DB: ubms
    volumes:
      - postgres_data:/var/lib/postgresql/data
  chrome_extension:
    build:
      context: ./posc
    container_name: ubms_invoice_extension
    volumes:
      - ./posc:/app
volumes:
  postgres_data:
EOL
      log "Docker environment set up."; }
# Build and deploy containers
deploy_containers() {     log "Building and deploying Docker containers...";     docker-compose up -d --build || error "Failed to deploy Docker containers.";     log "Containers are up and running."; }
# Initialize database schema
initialize_database() {     log "Initializing database schema..."
    docker exec -i ubms_db psql -U admin -d ubms <<EOL
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    price NUMERIC(10, 2),
    stock INT
);

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    quantity INT,
    total NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOL
     log "Database schema initialized."; }
# Configure environment variables
configure_env() {     log "Configuring environment variables..."
    cat > .env <<EOL
# Backend
DJANGO_SECRET_KEY=supersecretkey
DATABASE_URL=postgresql://admin:password@ubms_db:5432/ubms

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8000/api
EOL
     log "Environment variables configured."; }
# Run migrations and seed data
run_migrations() {     log "Running database migrations...";     docker exec -it ubms_backend python manage.py migrate || error "Failed to run migrations.";     docker exec -it ubms_backend python manage.py loaddata initial_data.json || error "Failed to load seed data.";     log "Migrations and seed data applied."; }
# Main script
main() {     check_prerequisites;     clone_repos;     setup_docker;     configure_env;     deploy_containers;     initialize_database;     run_migrations;      log "Unified Business Management System deployed successfully!";     log "Frontend: http://localhost:3000";     log "Backend: http://localhost:8000"; }
main
#!/bin/bash
# Unified Business Management System Deployment Script
# Author: Ally Elvis Nzeyimana
# Purpose: Automate the setup, installation, and deployment of UBMS.
# Function to print messages
log() {     echo -e "\e[32m[INFO]\e[0m $1"; }
error() {     echo -e "\e[31m[ERROR]\e[0m $1";     exit 1; }
# Check prerequisites
check_prerequisites() {     log "Checking prerequisites...";     for cmd in docker docker-compose git; do         if ! command -v $cmd &> /dev/null; then             error "$cmd is not installed. Please install it and rerun this script.";         fi;     done;     log "All prerequisites are met."; }
# Clone repositories
clone_repos() {     log "Cloning repositories...";     git clone https://github.com/allyelvis/ae-pos.git || error "Failed to clone AE-POS repository.";     git clone https://github.com/allyelvis/Smart-store-room.git || error "Failed to clone Smart Store Room repository.";     git clone https://github.com/allyelvis/posc.git || error "Failed to clone POSC repository."; }
# Set up Docker environment
setup_docker() {     log "Setting up Docker environment..."; 
    cat > docker-compose.yml <<EOL
version: "3.8"
services:
  backend:
    build:
      context: ./ae-pos
    container_name: ubms_backend
    ports:
      - "8000:8000"
    volumes:
      - ./ae-pos:/app
    depends_on:
      - database
  frontend:
    build:
      context: ./Smart-store-room
    container_name: ubms_frontend
    ports:
      - "3000:3000"
    volumes:
      - ./Smart-store-room:/app
  database:
    image: postgres:15
    container_name: ubms_db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
      POSTGRES_DB: ubms
    volumes:
      - postgres_data:/var/lib/postgresql/data
  chrome_extension:
    build:
      context: ./posc
    container_name: ubms_invoice_extension
    volumes:
      - ./posc:/app
volumes:
  postgres_data:
EOL
      log "Docker environment set up."; }
# Build and deploy containers
deploy_containers() {     log "Building and deploying Docker containers...";     docker-compose up -d --build || error "Failed to deploy Docker containers.";     log "Containers are up and running."; }
# Initialize database schema
initialize_database() {     log "Initializing database schema..."
    docker exec -i ubms_db psql -U admin -d ubms <<EOL
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    price NUMERIC(10, 2),
    stock INT
);

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    quantity INT,
    total NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOL
     log "Database schema initialized."; }
# Configure environment variables
configure_env() {     log "Configuring environment variables..."
    cat > .env <<EOL
# Backend
DJANGO_SECRET_KEY=supersecretkey
DATABASE_URL=postgresql://admin:password@ubms_db:5432/ubms

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8000/api
EOL
     log "Environment variables configured."; }
# Run migrations and seed data
run_migrations() {     log "Running database migrations...";     docker exec -it ubms_backend python manage.py migrate || error "Failed to run migrations.";     docker exec -it ubms_backend python manage.py loaddata initial_data.json || error "Failed to load seed data.";     log "Migrations and seed data applied."; }
# Main script
main() {     check_prerequisites;     clone_repos;     setup_docker;     configure_env;     deploy_containers;     initialize_database;     run_migrations;      log "Unified Business Management System deployed successfully!";     log "Frontend: http://localhost:3000";     log "Backend: http://localhost:8000"; }
main
ls -la
git config --global userer.email "allyelvis6569@gmail.com"
git config --global user.email "allyelvis6569@gmail.com"
git config --global user.name "allyelvis"
gh auth login
git remote add origin https://github.com/allyelvis/ubms.git
git branch -M main
git push -u origin main
echo "# ubms" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/allyelvis/ubms.git
git push -u origin main
git status
git remote add origin https://github.com/allyelvis/ubms.git
git branch -M main
git push -u origin main
