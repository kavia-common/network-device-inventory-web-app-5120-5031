# MongoDB Database (Standard Port 5001)

This container provides a local MongoDB instance for the Network Device Inventory app, standardized to run on port 5001.

- Default DB: myapp
- Default users:
  - Admin: appuser / dbuser123 (admin DB, userAdminAnyDatabase + readWriteAnyDatabase)
  - App: appuser / dbuser123 (scoped to myapp with readWrite)
- Bind: 127.0.0.1:5001

Start MongoDB
- Run: ./startup.sh
- Idempotent: If mongod is already on 5001, the script prints connection info and exits.
- Credentials: Edit DB_USER and DB_PASSWORD at the top of startup.sh if needed.

Backup/Restore
- Backup: ./backup_db.sh -> creates database_backup.archive for MongoDB
- Restore: ./restore_db.sh -> restores from database_backup.archive if present
- Scripts are idempotent and safe to re-run.

Connection example
- mongosh mongodb://appuser:dbuser123@localhost:5001/myapp?authSource=admin

Backend environment variables
- MONGODB_URI: e.g. mongodb://appuser:dbuser123@localhost:5001/?authSource=admin
- MONGODB_DB_NAME: e.g. myapp
- MONGODB_COLLECTION_DEVICES: e.g. devices
- MONGODB_COLLECTION_LOGS: e.g. logs

Notes
- User creation/auth: startup.sh creates the admin user on the admin database and an app user scoped to the myapp database if they do not already exist.
- Customize credentials: Update DB_USER and DB_PASSWORD in startup.sh before first run.
- The app enforces schema at the application layer; see app_schema.json for JSON Schemas and indexes.md for suggested indexes.
