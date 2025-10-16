# Recommended Indexes

Devices collection
- Unique index on mac_address
  - Ensures each device MAC is unique.
  - Example (mongosh):
    db.getSiblingDB("<DB_NAME>").getCollection("<DEVICES_COLLECTION>").createIndex({ mac_address: 1 }, { unique: true, name: "uniq_mac_address" })

- Index on ip_address
  - Speeds lookups by IP.
  - Example:
    db.getSiblingDB("<DB_NAME>").getCollection("<DEVICES_COLLECTION>").createIndex({ ip_address: 1 }, { name: "idx_ip_address" })

- Index on device_type
  - Improves filtering by type.
  - Example:
    db.getSiblingDB("<DB_NAME>").getCollection("<DEVICES_COLLECTION>").createIndex({ device_type: 1 }, { name: "idx_device_type" })

- Optional compound index on location + device_type
  - Useful for filtering by location and type together.
  - Example:
    db.getSiblingDB("<DB_NAME>").getCollection("<DEVICES_COLLECTION>").createIndex({ location: 1, device_type: 1 }, { name: "idx_location_device_type" })

Logs collection
- Index on device_id
  - Speeds retrieval of logs for a device.
  - Example:
    db.getSiblingDB("<DB_NAME>").getCollection("<LOGS_COLLECTION>").createIndex({ device_id: 1 }, { name: "idx_device_id" })

- Index on timestamp (descending)
  - Speeds latest log queries and time-range filtering.
  - Example:
    db.getSiblingDB("<DB_NAME>").getCollection("<LOGS_COLLECTION>").createIndex({ timestamp: -1 }, { name: "idx_timestamp_desc" })

Notes
- Replace <DB_NAME>, <DEVICES_COLLECTION>, and <LOGS_COLLECTION> with your environment values (e.g., myapp, devices, logs).
- Creating indexes is idempotent; running the same createIndex with the same name is safe.
- Review index usage with explain() and adjust based on actual query patterns.
