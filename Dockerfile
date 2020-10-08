FROM docker.io/alpine

LABEL maintainer="Travis Ralston <travis@t2bot.io>"

COPY res/start.sh /start.sh
COPY ./res/nginx.conf /tmp/nginx.conf
RUN apk add --no-cache nginx dos2unix tar grep sed curl \
    && dos2unix /start.sh \
    && dos2unix /etc/nginx/nginx.conf \
    && chmod +x /start.sh \
    && adduser -D -g 'www' www \
    && mkdir /www \
    && chown -R www:www /var/lib/nginx \
    && chown -R www:www /www \
    && mv /tmp/nginx.conf /etc/nginx/nginx.conf \
    && echo '<h1>element-web failed to install</h1>' > /www/index.html

STOPSIGNAL SIGTERM
CMD ["/start.sh"]
