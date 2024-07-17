#!/bin/bash

VERSION="0.0.1"

# Define sexy terminal colors
RESET='\033[0m'
CYAN='\033[0;96m'
GREEN='\033[0;32m'
RED='\033[0;91m'
BOLD='\x1b[1m'
GRAY='\x1b[90m'

# Function to add a new site
add_site() {
    local domain=$1
    local nginx_conf="/etc/nginx/sites-available/$domain"
    local nginx_link="/etc/nginx/sites-enabled/$domain"
    
    if [ -f "$nginx_conf" ]; then
        echo "Site configuration for $domain already exists."
        exit 1
    fi

    # Create nginx configuration file
    cat <<EOL > $nginx_conf
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:3000; # Adjust the port or backend service as needed
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

    # Enable the site
    ln -s $nginx_conf $nginx_link

    # Reload nginx
    nginx -t && systemctl reload nginx

    # Run certbot to obtain SSL certificate
    certbot --nginx -d $domain

    echo "${GREEN} $domain has been added successfully.${RESET}"
}

# Function to remove a site
remove_site() {
    local domain=$1
    local nginx_conf="/etc/nginx/sites-available/$domain"
    local nginx_link="/etc/nginx/sites-enabled/$domain"
    
    if [ ! -f "$nginx_conf" ]; then
        echo "Site configuration for $domain does not exist."
        exit 1
    fi

    # Disable the site
    rm $nginx_link

    # Remove the configuration file
    rm $nginx_conf

    # Reload nginx
    nginx -t && systemctl reload nginx

    # Remove certbot certificates
    certbot delete --cert-name $domain

    echo "${GREEN} $domain has been removed successfully.${RESET}"
}

# Parse the command line arguments
case $1 in
    add)
        while getopts "d:" opt; do
            case $opt in
                d)
                    add_site $OPTARG
                    ;;
                *)
                    echo "Usage: $0 add -d domain"
                    exit 1
                    ;;
            esac
        done
        ;;
    remove)
        while getopts "d:" opt; do
            case $opt in
                d)
                    remove_site $OPTARG
                    ;;
                *)
                    echo "Usage: $0 remove -d domain"
                    exit 1
                    ;;
            esac
        done
        ;;
    version|v)
        echo "Web Tools version is:"
        echo "${BOLD}${CYAN}${VERSION}${RESET}"
        exit 1
        ;;
    *|help)
        echo "${CYAN}Web(lutions) Tools - https://github.com/FAXES/webt${RESET}"
        echo "Commands:"
        echo "  webt add -d example.com ${GRAY} - Add a domain to NGINX and create an SSL certificate for it.${RESET}"
        echo "  webt remove -d example.com ${GRAY} - Removes a domain file from NGINX, provided it was setup with webt.${RESET}"
        echo "  webt version ${GRAY} - Get to know the version of webt.${RESET}"
        # echo "  webt autostart -s service ${GRAY} - Get to know the version of webt.${RESET}"
        exit 1
        ;;
esac