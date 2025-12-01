.PHONY: help db-up db-down db-logs db-shell run dev clean

# Default target
help:
	@echo "Available commands:"
	@echo "  make db-up        - Start PostgreSQL database with docker-compose"
	@echo "  make db-down      - Stop and remove PostgreSQL database"
	@echo "  make db-logs      - Show database logs"
	@echo "  make db-shell     - Connect to PostgreSQL shell"
	@echo "  make run          - Run the Go backend"
	@echo "  make dev          - Start database and run backend"
	@echo "  make clean        - Stop containers and remove volumes"

# Database commands
db-up:
	@echo "Starting PostgreSQL database..."
	cd backend && docker-compose up -d --wait

db-down:
	@echo "Stopping PostgreSQL database..."
	cd backend && docker-compose down

db-logs:
	cd backend && docker-compose logs -f

db-shell:
	docker exec -it postgres-similarity psql -U postgres -d postgres

# Backend commands
run:
	@echo "Running backend..."
	cd backend && go run main.go

dev: db-up
	@echo "Starting development mode..."
	cd backend && go run main.go

# Cleanup
clean:
	@echo "Cleaning up..."
	cd backend && docker-compose down -v
	@echo "Cleanup complete!"
