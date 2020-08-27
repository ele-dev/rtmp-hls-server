# Populate default players (if directory has been remapped)
while true; do echo n; done | cp -Ri /assets/players/* /usr/local/nginx/html/players/ &> /dev/null

stunnel4
sleep 2
exec nginx -g "daemon off;"