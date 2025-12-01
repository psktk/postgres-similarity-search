package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

func main() {
	// Database connection parameters
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "15432")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "postgres")
	dbname := getEnv("DB_NAME", "postgres")

	// Connection string
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	// Connect to database
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Error opening database:", err)
	}
	defer db.Close()

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatal("Error connecting to database:", err)
	}

	fmt.Println("Successfully connected to PostgreSQL database!")

	// Setup Gin router
	r := gin.Default()

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.String(200, "ok")
	})

	// Get achievements by similarity
	r.GET("/achievements", func(c *gin.Context) {
		query := c.Query("query")
		if query == "" {
			c.JSON(400, gin.H{"error": "query parameter is required"})
			return
		}

		var rows *sql.Rows
		var err error

		// For very short queries, use only pattern matching (no similarity)
		if len(query) < 3 {
			rows, err = db.Query(`
				SELECT id, name, 0 as similarity_score
				FROM achievement
				WHERE name ILIKE '%' || $1 || '%'
				ORDER BY name ASC
				LIMIT 20
			`, query)
		} else {
			// Use pg_trgm similarity search combined with pattern matching
			rows, err = db.Query(`
				SELECT id, name, similarity(name, $1) as similarity_score
				FROM achievement
				WHERE similarity(name, $1) > 0.3 OR name ILIKE '%' || $1 || '%'
				ORDER BY similarity_score DESC
				LIMIT 20
			`, query)
		}

		if err != nil {
			c.JSON(500, gin.H{"error": err.Error()})
			return
		}
		defer rows.Close()

		type Achievement struct {
			ID         int     `json:"id"`
			Name       string  `json:"name"`
			Similarity float64 `json:"similarity"`
		}

		var achievements []Achievement
		for rows.Next() {
			var a Achievement
			if err := rows.Scan(&a.ID, &a.Name, &a.Similarity); err != nil {
				c.JSON(500, gin.H{"error": err.Error()})
				return
			}
			achievements = append(achievements, a)
		}

		if err := rows.Err(); err != nil {
			c.JSON(500, gin.H{"error": err.Error()})
			return
		}

		c.JSON(200, achievements)
	})

	// Start server
	port = getEnv("PORT", "8080")
	log.Printf("Starting server on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
