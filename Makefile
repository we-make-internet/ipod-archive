DB_NAME = archive.db

SQLITE_OPTS = -bail

.PHONY: init-db
init-db:
	sqlite3 $(SQLITE_OPTS) $(DB_NAME) < ./schema.sql
