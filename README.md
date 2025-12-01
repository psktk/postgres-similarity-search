# PostgreSQL Similarity Search Demo

A demonstration project showcasing fuzzy text search capabilities using PostgreSQL's `pg_trgm` (trigram) extension. This project implements a REST API for searching achievements with similarity matching, allowing for typo-tolerant and partial text searches.

## 🎯 Objectives

This repository demonstrates:

- **PostgreSQL Trigram Similarity**: Using the `pg_trgm` extension for fuzzy text matching
- **Typo-Tolerant Search**: Finding results even with misspelled queries (e.g., "lerner" finds "learner")
- **Hybrid Search Strategy**: Combining similarity scoring with pattern matching (ILIKE) for comprehensive results
- **Performance Optimization**: Using GIN indexes for fast trigram searches
- **REST API Development**: Building a simple Go backend with Gin framework
- **Docker Integration**: Containerized PostgreSQL setup with initialization scripts

## 🏗️ Architecture

```
├── backend/
│   ├── main.go              # Go backend API server
│   ├── go.mod               # Go dependencies
│   ├── docker-compose.yml   # PostgreSQL container setup
│   └── init.sql             # Database initialization and seed data
├── frontend/
│   ├── health.http          # Health check endpoint test
│   └── search-achievements.http  # API test examples
├── Makefile                 # Convenience commands
└── README.md
```

### Technology Stack

- **Backend**: Go 1.25.4 with Gin web framework
- **Database**: PostgreSQL with pg_trgm extension
- **Infrastructure**: Docker & Docker Compose

## 🚀 Getting Started

### Prerequisites

- [Go](https://golang.org/dl/) (version 1.25.4 or later)
- [Docker](https://www.docker.com/get-started) and Docker Compose
- Make (optional, for convenience commands)

### Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/psktk/postgres-similarity-search.git
   cd postgres-similarity-search
   ```

2. **Start the database and backend**

   ```bash
   make dev
   ```

   This command will:

   - Start PostgreSQL in a Docker container (port 15432)
   - Enable the `pg_trgm` extension
   - Create the `achievement` table with GIN index
   - Seed sample achievement data
   - Start the Go backend server (port 8080)

3. **Test the API**

   Open `frontend/search-achievements.http` in VS Code with the REST Client extension, or use curl:

   ```bash
   # Search for "learner"
   curl "http://localhost:8080/achievements?query=learner"

   # Typo-tolerant search - "lerner" still finds "learner"
   curl "http://localhost:8080/achievements?query=lerner"

   # Partial match
   curl "http://localhost:8080/achievements?query=learn"
   ```

### Available Make Commands

```bash
make help          # Show all available commands
make db-up         # Start PostgreSQL database only
make db-down       # Stop PostgreSQL database
make db-logs       # View database logs
make db-shell      # Connect to PostgreSQL shell
make run           # Run the Go backend only
make dev           # Start database and run backend
make clean         # Stop containers and remove volumes
```

## 📡 API Endpoints

### Health Check

```http
GET /health
```

Returns: `ok`

### Search Achievements

```http
GET /achievements?query=<search_term>
```

**Parameters:**

- `query` (required): Search term for achievement names

**Response:**

```json
[
  {
    "id": 11,
    "name": "Fast Learner",
    "similarity": 0.8
  },
  {
    "id": 2,
    "name": "Quick Learner",
    "similarity": 0.75
  }
]
```

**Search Behavior:**

- For queries < 3 characters: Uses pattern matching only (ILIKE)
- For queries ≥ 3 characters: Uses trigram similarity (threshold 0.3) + pattern matching
- Results are ordered by similarity score (descending)
- Returns up to 10 results

## 🔍 How Similarity Search Works

The project uses PostgreSQL's `pg_trgm` extension, which:

1. **Breaks text into trigrams** (three-character sequences)

   - "learner" → " l", " le", "lea", "ear", "arn", "rne", "ner", "er "

2. **Calculates similarity** by comparing trigram sets

   - More shared trigrams = higher similarity score (0.0 to 1.0)

3. **Uses GIN indexes** for fast lookups

   - Index: `CREATE INDEX ON achievement USING GIN (name gin_trgm_ops)`

4. **Hybrid approach** for better results:
   - Similarity matching: Handles typos and fuzzy matches
   - Pattern matching (ILIKE): Ensures exact substrings are found

## 💾 Database Configuration

**Connection Details:**

- Host: `localhost`
- Port: `15432` (mapped from container's 5432)
- User: `postgres`
- Password: `postgres`
- Database: `postgres`

**Environment Variables** (optional overrides):

- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `PORT` (backend server port, default: 8080)

## 🧪 Testing

Use the included HTTP files in the `frontend/` directory with VS Code's REST Client extension:

- `health.http`: Test health check endpoint
- `search-achievements.http`: Various search examples including:
  - Exact matches
  - Partial matches
  - Typos
  - Single characters

## 🛠️ Development

### Running Components Separately

**Database only:**

```bash
make db-up
```

**Backend only** (requires database running):

```bash
cd backend
go run main.go
```

### Accessing the Database

```bash
make db-shell
```

Then run SQL queries:

```sql
-- View all achievements
SELECT * FROM achievement;

-- Test similarity function
SELECT name, similarity(name, 'lerner') as score
FROM achievement
WHERE similarity(name, 'lerner') > 0.3
ORDER BY score DESC;
```

### Adding More Data

Edit `backend/init.sql` and restart the database:

```bash
make clean
make db-up
```

## 🧹 Cleanup

Remove all containers and volumes:

```bash
make clean
```

## 📚 Learn More

- [PostgreSQL pg_trgm documentation](https://www.postgresql.org/docs/current/pgtrgm.html)
- [Gin web framework](https://github.com/gin-gonic/gin)
- [Go PostgreSQL driver](https://github.com/lib/pq)

## 📝 License

This is a demonstration project for educational purposes.

## 🤝 Contributing

Feel free to open issues or submit pull requests with improvements!
