FROM quay.io/yeebase/debian-base:stretch

ENV PHP_VERSION 7.2

RUN set -x && \
    clean-install apt-transport-https lsb-release ca-certificates curl gnupg && \
    curl -sL https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    curl -sL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    echo "deb https://nginx.org/packages/mainline/debian/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list && \
    clean-install \
      php${PHP_VERSION}-common \
      php${PHP_VERSION}-cli \
      php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-gd \
      php${PHP_VERSION}-json \
      php${PHP_VERSION}-mbstring \
      # php${PHP_VERSION}-mcrypt \ not available for php7.2
      php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-opcache \
      php${PHP_VERSION}-readline \
      php${PHP_VERSION}-soap \
      php${PHP_VERSION}-tidy \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-xmlrpc \
      php${PHP_VERSION}-bcmath \
      php${PHP_VERSION}-zip \
      php-mongodb \
      php-redis \
      nginx && \
    clean-uninstall curl && \
    mkdir -p /run/php /var/www /var/log/nginx/ && \
    ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm && \
    rm /etc/nginx/conf.d/default.conf

COPY conf/nginx /etc/nginx
COPY conf/php /etc/php/${PHP_VERSION}
COPY bin/ /usr/local/bin/

EXPOSE 80

CMD ["nginx-php-fpm"]
