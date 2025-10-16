#!/bin/bash

# MongoDB startup script
# NOTE: Customize credentials below as needed for your environment.
DB_NAME="myapp"
DB_USER="appuser"         # Customize: admin user to create (admin database)
DB_PASSWORD="dbuser123"   # Customize: password for both admin and app user
DB_PORT="5001"            # Standardized MongoDB port for this project

echo "Starting MongoDB setup (target port: ${DB_PORT})..."

# If MongoDB already running on desired port, print connection info and exit idempotently
if mongosh --port ${DB_PORT} --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo "MongoDB is already running on port ${DB_PORT}."

    # Verify access
    if mongosh "mongodb://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}?authSource=admin" --eval "db.getName()" > /dev/null 2>&1; then
        echo "Database ${DB_NAME} is accessible with user ${DB_USER}."
    else
        echo "MongoDB is running but authentication might not yet be configured for ${DB_USER}."
    fi

    echo ""
    echo "Database: ${DB_NAME}"
    echo "Admin user: ${DB_USER} (password: ${DB_PASSWORD})"
    echo "App user: appuser (password: ${DB_PASSWORD})"
    echo "Port: ${DB_PORT}"
    echo ""

    if [ -f "db_connection.txt" ]; then
        echo "To connect to the database, use:"
        cat db_connection.txt
    else
        echo "To connect to the database, use:"
        echo "mongosh mongodb://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}?authSource=admin"
    fi

    echo ""
    echo "Script finished (idempotent): MongoDB already running."
    exit 0
fi

# If mongod is running elsewhere, stop it for rebind to standard port
if pgrep -x mongod > /dev/null; then
    MONGO_PID=$(pgrep -x mongod)
    CURRENT_PORT=$(sudo lsof -Pan -p $MONGO_PID -i 2>/dev/null | awk -F: '/TCP/ {print $2}' | awk '{print $1}' | head -1)
    if [ -n "$CURRENT_PORT" ] && [ "$CURRENT_PORT" != "${DB_PORT}" ]; then
        echo "MongoDB is running on different port (${CURRENT_PORT}), stopping it to restart on ${DB_PORT}..."
        sudo pkill -x mongod
        sleep 2
    else
        echo "MongoDB process running but port not detected; restarting to ensure ${DB_PORT}."
        sudo pkill -x mongod || true
        sleep 2
    fi
fi

# Clean stale sockets
sudo rm -f /tmp/mongodb-*.sock 2>/dev/null

# Ensure data/log dirs exist (common defaults)
sudo mkdir -p /var/lib/mongodb /var/run/mongodb
sudo chown -R "$(whoami)":"$(whoami)" /var/lib/mongodb /var/run/mongodb 2>/dev/null || true

# Start mongod
echo "Starting MongoDB server on port ${DB_PORT}..."
nohup mongod --dbpath /var/lib/mongodb --port ${DB_PORT} --bind_ip 127.0.0.1 --unixSocketPrefix /var/run/mongodb > /var/lib/mongodb/mongod.log 2>&1 &

# Wait for server readiness (max ~30s)
echo "Waiting for MongoDB to start..."
for i in {1..15}; do
    if mongosh --port ${DB_PORT} --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo "MongoDB is ready on port ${DB_PORT}."
        break
    fi
    echo "Waiting... ($i/15)"
    sleep 2
done

# Double-check readiness
if ! mongosh --port ${DB_PORT} --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo "Error: MongoDB did not start properly on port ${DB_PORT}."
    exit 1
fi

# Create admin and app users idempotently
echo "Configuring database users and application database..."
mongosh --port ${DB_PORT} << 'EOF'
const dbName = process.env.DB_NAME || "myapp";
const adminUser = process.env.DB_USER || "appuser";
const adminPwd = process.env.DB_PASSWORD || "dbuser123";

// Admin user on 'admin' database
db.getSiblingDB("admin");
if (!db.getUser(adminUser)) {
  db.createUser({
    user: adminUser,
    pwd: adminPwd,
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  });
}

// App user scoped to application database
db.getSiblingDB(dbName);
if (!db.getUser("appuser")) {
  db.createUser({
    user: "appuser",
    pwd: adminPwd,
    roles: [{ role: "readWrite", db: dbName }]
  });
}

print("MongoDB setup complete.");
EOF

# Save connection and env helper files with standardized port 5001
echo "mongosh mongodb://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}?authSource=admin" > db_connection.txt
echo "Connection string saved to db_connection.txt"

cat > db_visualizer/mongodb.env << EOF
export MONGODB_URL="mongodb://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/?authSource=admin"
export MONGODB_DB="${DB_NAME}"
EOF

echo "MongoDB setup complete!"
echo "Database: ${DB_NAME}"
echo "Admin user: ${DB_USER} (password: ${DB_PASSWORD})"
echo "App user: appuser (password: ${DB_PASSWORD})"
echo "Port: ${DB_PORT}"
echo ""
echo "Environment variables saved to db_visualizer/mongodb.env"
echo "To use with Node.js viewer, run: source db_visualizer/mongodb.env"
echo "To connect to the database, use:"
cat db_connection.txt

echo ""
echo "MongoDB is running in the background."
echo "You can now start your application."