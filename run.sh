#!/bin/sh

# Copy assets from /assets-default to /assets
# If /assets has been mounted from the host, this will automatically populate the host directory with the files
# Copy default players and configs
echo "Copying Assets..."
cp -Rnv /assets-default/* /assets/

echo "Creating symlinks to Configs and Players from /assets"
# Link players from assets directory
ln -sf /assets/players /usr/local/nginx/html/players
# Link Nginx config from assets directory
ln -sf /assets/configs/nginx.conf /etc/nginx/nginx.conf
# Link Stunnel config from assets directory
ln -sf /assets/configs/stunnel.conf /etc/stunnel/stunnel.conf

# Start Stunnel
echo "Starting Stunnel..."
stunnel4
sleep 2
# Start Nginx
echo "Starting Nginx!"
exec nginx -g "daemon off;"