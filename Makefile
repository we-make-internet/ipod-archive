DB_NAME = archive.db
SQLITE_OPTS = -bail

.PHONY: db
db:
	rm -f $(DB_NAME)
	sqlite3 $(SQLITE_OPTS) $(DB_NAME) < ./schema.sql
	./populate-db.sh

.PHONY: init-db
init-db:
	sqlite3 $(SQLITE_OPTS) $(DB_NAME) < ./schema.sql
