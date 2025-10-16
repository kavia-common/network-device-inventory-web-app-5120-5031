# MongoDB Database - Network Device Inventory

This service stores device and log data for the application.

## Port
- MongoDB host port: 5001 (mapped to container 27017)

Ensure your container maps `-p 5001:27017` and that the backend uses `MONGODB_URI=mongodb://localhost:5001`.

## Environment
A sample env file is provided at `db_visualizer/mongodb.env`:
- MONGO_PORT=5001

## Startup Order
1. Start MongoDB (5001)
2. Start Flask Backend (3001)
3. Start React Frontend (3000)
