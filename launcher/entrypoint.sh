#!/bin/sh
# Replace DOMAIN placeholder in the template and write to index.html
sed "s|DOMAIN_PLACEHOLDER|${DOMAIN}|g" /srv/index.html.template > /srv/index.html
# Start the web server
busybox httpd -f -v -p 80 -h /srv
