FROM busybox:stable

RUN echo "text/html    html" >  /etc/mime.types \
 && echo "text/css     css"  >> /etc/mime.types \
 && echo "text/javascript js" >> /etc/mime.types

COPY index.html /srv/index.html.template

WORKDIR /srv
EXPOSE 80

CMD ["/bin/sh", "-c", "sed \"s|DOMAIN_PLACEHOLDER|${DOMAIN}|g\" /srv/index.html.template > /srv/index.html && busybox httpd -f -v -p 80 -h /srv"]