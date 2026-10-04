FROM registry:3.1.2

# htpasswd ships in apache2-utils; installed at build time so the registry never depends on a
# package mirror while it starts.
RUN apk add --no-cache apache2-utils

COPY start.sh /start.sh
RUN chmod 755 /start.sh

ENTRYPOINT ["/start.sh"]
