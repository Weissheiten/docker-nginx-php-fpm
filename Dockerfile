FROM ubuntu:16.04

RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" > /etc/apt/sources.list.d/ondrej.list \
  && echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" > /etc/apt/sources.list.d/nginx.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        php7.0-cli php7.0-common php7.0-curl php7.0-fpm php7.0-gd php7.0-json php7.0-mbstring \
        php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-readline php7.0-soap php7.0-tidy php7.0-xml \
        php7.0-xmlrpc php7.0-bcmath php-memcached php-mongodb php-redis nginx supervisor curl \
        ca-certificates \
  && echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list \
  && curl -sS -k 'https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg' | apt-key add - \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -yq install tideways-php \
  && apt-get -y remove curl \
  && apt-get -y dist-upgrade \
  && apt-get -y autoremove \
  && apt-get clean \
  && apt-get autoclean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/nginx/conf.d/default.conf

RUN userdel www-data \
  && useradd www-data -u 1001 -U -d /var/www -s /usr/sbin/nologin

RUN mkdir -p /var/www \
  && mkdir -p /run/php \
  && mkdir -p /tmp/nginx \
  && mkdir -p /tmp/php \
  && echo "<?php phpinfo(); ?>" > /var/www/index.php \
  && chown -R www-data:www-data /var/www \
  && chown -R www-data:www-data /tmp/php

COPY conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY conf/nginx /etc/nginx
COPY conf/php /etc/php/7.0

EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
