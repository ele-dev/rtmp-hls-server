#!/bin/sh

function generate_certificate () {
    SUBJ="/CN=$SSL_DOMAIN"
    echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: The generated certificate will be valid for: $SSL_DOMAIN"
    openssl genrsa -out /assets/ssl/.self_signed/rtmp.key 2048
    openssl req -new -key /assets/ssl/.self_signed/rtmp.key -subj $SUBJ -out /tmp/rtmp.csr
    openssl x509 -req -in /tmp/rtmp.csr -CA /assets/ssl/.self_signed/RTMP-CA.crt -CAkey /assets/ssl/.self_signed/RTMP-CA.key \
    -CAcreateserial -days 365 -sha256 -out /assets/ssl/.self_signed/rtmp.crt
    echo -e ""
}

# Copy assets from /assets-default to /assets
# If /assets has been mounted from the host, this will automatically populate the host directory with the files
# Copy default players and configs
echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Copying default Assets to /assets/"
echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: This WILL NOT overwrite files that already exist! \\n"

if [ "$IMAGE" = "Alpine" ]; then
    false | cp -Riv /assets-default/* /assets/ 2>/dev/null
else
    cp -Rnv /assets-default/* /assets/ 2>/dev/null
fi

echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Creating symlinks to Configs and Players from /assets/ \\n"
# Link players from assets directory
ln -sf /assets/players /usr/local/nginx/html/
# Link Nginx config from assets directory
ln -sf /assets/configs/nginx.conf /etc/nginx/nginx.conf
# Link Stunnel config from assets directory
ln -sf /assets/configs/stunnel.conf /etc/stunnel/stunnel.conf

# Verify the SSL directory exists. if not, create it
if [ ! -d /assets/ssl/.self_signed ]; then
    mkdir -p /assets/ssl/.self_signed
fi

# Generate a cert/key pair for generation of a CA if they dont' already exist, otherwise Nginx won't start properly.
if [ ! -f "/assets/ssl/.self_signed/RTMP-CA.crt" ]; then
    echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Generating a Self Signing Certificate Authority..."
    openssl genrsa -out /assets/ssl/.self_signed/RTMP-CA.key 2048
    openssl req -x509 -new -nodes -key /assets/ssl/.self_signed/RTMP-CA.key -sha256 -days 1825 -subj '/CN=RTMP-Server-CA' -out /assets/ssl/.self_signed/RTMP-CA.crt
    cp -fv /assets/ssl/.self_signed/RTMP-CA.crt /assets/ssl/
fi

if [ ! -f "/assets/ssl/.self_signed/rtmp.crt" ]; then
    echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Couldn't find an existing SSL certificate in '/assets/ssl/.self_signed/'"
    echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Generating one for you so that Nginx can start properly..."
    generate_certificate
    echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Please update the Nginx confguration file to use vaild signed certificate for your domain"
    echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: or install 'ssl/RTMP-CA.crt' as a certificate authority on your machine to use the generated Self Signed certificate. \\n"
else
    SSL_DOMAIN_CURRENT=$(openssl x509 -noout -subject -in /assets/ssl/.self_signed/rtmp.crt | sed 's|subject=CN\ =\ ||' )
    if [ "$SSL_DOMAIN_CURRENT" != "$SSL_DOMAIN" ]; then
        echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Current certificate is not valid for: $SSL_DOMAIN"
        echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Re-Generating a new one that is..."
        generate_certificate
    fi
fi

echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Setting Owner:Group on /assets/ to: $PUID:$PGID \\n"
chown -R $PUID:$PGID /assets

# Start Stunnel
echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Starting Stunnel..."
stunnel4
sleep 2
# Start Nginx
echo -e "`date +"%Y-%m-%d %H:%M:%S"` INFO: Starting Nginx!"
exec nginx -g "daemon off;"
