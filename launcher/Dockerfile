FROM busybox:stable

RUN echo "text/html    html" >  /etc/mime.types \
 && echo "text/css     css"  >> /etc/mime.types \
 && echo "text/javascript js" >> /etc/mime.types

COPY index.html /srv/index.html

WORKDIR /srv
EXPOSE 80
CMD ["busybox", "httpd", "-f", "-v", "-p", "80", "-h", "/srv"]