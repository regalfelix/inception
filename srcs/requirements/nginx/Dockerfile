FROM debian:12.15

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

COPY tools/default /etc/nginx/sites-available/default

STOPSIGNAL SIGQUIT

EXPOSE 443/tcp
CMD ["nginx", "-g", "daemon off;"]
