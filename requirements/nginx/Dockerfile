FROM debian:oldstable-slim

RUN apt-get -y update
RUN apt-get -y install nginx
COPY tools/sites-available/default /etc/nginx/sites-available
COPY ssl_certificate /etc/nginx/ssl/certificate.pem
COPY ssl_private-key /etc/nginx/ssl/private-key.pem

STOPSIGNAL SIGQUIT

EXPOSE 443/tcp
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
