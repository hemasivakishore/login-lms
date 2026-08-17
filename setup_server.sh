#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Repository URL for your Login App
LOGIN_REPO_URL="https://github.com/your-username/your-login-app.git"
WEB_ROOT="/var/www/html"

echo "=========================================="
echo " Starting Server Setup & App Deployment "
echo "=========================================="

# 1. Update the system to get the latest patches
echo "[1/6] Updating system packages..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update -y && sudo apt-get upgrade -y
elif command -v dnf &> /dev/null; then
    sudo dnf update -y
elif command -v yum &> /dev/null; then
    sudo yum update -y
fi

# 2. Install List of Utilities: zip, unzip, and git
echo "[2/6] Installing utilities (zip, unzip, git)..."
if command -v apt-get &> /dev/null; then
    sudo apt-get install -y zip unzip git curl
elif command -v dnf &> /dev/null; then
    sudo dnf install -y zip unzip git curl
elif command -v yum &> /dev/null; then
    sudo yum install -y zip unzip git curl
fi

# 3. Install HTTP Server (Nginx)
echo "[3/6] Installing and starting Nginx web server..."
if command -v apt-get &> /dev/null; then
    sudo apt-get install -y nginx
elif command -v dnf &> /dev/null || command -v yum &> /dev/null; then
    sudo dnf install -y nginx || sudo yum install -y nginx
fi

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl restart nginx

# 4. Remove sample test pages from web server root location
echo "[4/6] Cleaning up default/sample web files..."
sudo rm -rf ${WEB_ROOT}/*

# 5. Clone Login App to Nginx Server root location
echo "[5/6] Cloning Login App to Nginx root..."
sudo git clone "$LOGIN_REPO_URL" "$WEB_ROOT"

# Ensure proper permissions for web root
sudo chown -R www-data:www-data "$WEB_ROOT" 2>/dev/null || sudo chown -R nginx:nginx "$WEB_ROOT"
sudo chmod -R 755 "$WEB_ROOT"

# 6. Verify server is loading login app or not
echo "[6/6] Verifying server response..."
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost/)

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "SUCCESS: Nginx is up and serving the Login App (HTTP Status: $HTTP_STATUS)."
else
    echo "WARNING: Server responded with HTTP Status: $HTTP_STATUS. Check Nginx logs at /var/log/nginx/error.log."
fi

echo "=========================================="
echo " Deployment Process Complete! "
echo "=========================================="
