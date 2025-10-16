# MongoDBDatabase

This container hosts MongoDB data for the app. No runtime dependencies are required here beyond the DB service itself.

If you add seed or migration tooling, consider using:
- mongosh (latest)
- Node or Python scripts with drivers:
  - pymongo >=4.8,<5 (Python)
  - mongodb >=6.x (Node.js driver)

Provide a requirements.txt or package.json in this folder if such tooling is added.

Environment variables (consumed by backend):
- MONGODB_URI
- MONGODB_DB
- MONGODB_COLLECTION
