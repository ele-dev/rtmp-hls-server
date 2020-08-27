# Copy default players
while true; do echo n; done | cp -Ri /assets-default/players/* /assets/players/ &> /dev/null
# Copy default Nginx config
while true; do echo n; done | cp -Ri /assets-default/configs/nginx.conf /assets/configs/nginx.conf &> /dev/null
# Copy Stunnel config
while true; do echo n; done | cp -Ri /assets-default/configs/stunnel.conf /assets/configs/stunnel.conf &> /dev/null

# Link players from assets directory
ln -s /assets/players/ /usr/local/nginx/html/players/
# Link Nginx config from assets directory
ln -s /assets/configs/nginx.conf /etc/nginx/nginx.conf
# Link Stunnel config from assets directory
ln -s /assets/configs/stunnel.conf /etc/stunnel/stunnel.conf

# Start Stunnel
stunnel4
sleep 2
# Start Nginx
exec nginx -g "daemon off;"