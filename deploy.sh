#!/bin/bash

# Variables
KEY="hcombVM_key.pem"
USER="azureuser"
HOST="172.206.244.234"
REMOTE_DIR="/home/azureuser/TrainingHCOMB/TrainingAdmin"
LOCAL_BUILD_DIR="./build"

# Step 1: Set permissions for the key file
echo "Setting permissions for the key file..."
chmod 400 "$KEY"

# Step 2: Checkout to the main branch and pull the latest code
echo "Checking out to the main branch and pulling the latest code..."
git checkout main
git pull origin main

# Add delay
sleep 2

# Step 3: Build the project
echo "Building the project..."
npm install && NODE_OPTIONS="--max-old-space-size=4096" npm run build

# Add delay
sleep 2

# Step 4: SSH into the server and remove the build folder directly
echo "Removing the existing build folder on the server..."
ssh -i "$KEY" "$USER@$HOST" "rm -rf $REMOTE_DIR/build"

# Add delay
sleep 2

# Step 5: Copy the local build folder to the server
echo "Copying the local build folder to the server..."
scp -i "$KEY" -r "$LOCAL_BUILD_DIR" "$USER@$HOST:$REMOTE_DIR"

# Add delay
sleep 2

# Step 6: Restart the application using pm2
echo "Restarting the application using pm2..."
ssh -i "$KEY" "$USER@$HOST" "cd $REMOTE_DIR && pm2 restart training-server"

echo "Deployment completed successfully!"
