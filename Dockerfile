FROM quay.io/yeebase/debian-base:stretch

ENV PHP_VERSION 7.4
ENV NGINX_VTS_VERSION 0.1.18

RUN set -x && \
    clean-install \
      apt-transport-https \
      curl \
      devscripts \
      dpkg-dev \
      equivs \
      gnupg \
      lsb-release && \
    curl -sL https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    curl -sL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    echo "deb https://nginx.org/packages/mainline/debian/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src https://nginx.org/packages/mainline/debian/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list.d/nginx.list && \
    curl -sL https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - && \
    echo "deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main" > /etc/apt/sources.list.d/tideways.list && \
    clean-install \
      php${PHP_VERSION}-common \
      php${PHP_VERSION}-cli \
      php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-gd \
      php${PHP_VERSION}-json \
      php${PHP_VERSION}-mbstring \
      # php${PHP_VERSION}-mcrypt \ not available for php7.3
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
      tideways-php \
      tideways-cli && \
    mkdir -p /opt/rebuildnginx && \
    chmod 0777 /opt/rebuildnginx && \
    cd /opt/rebuildnginx && \
    apt-get update && \
    export NGINX_VERSION=`apt-cache policy nginx | sed -rn 's/^[[:space:]]*Candidate:[[:space:]](.*)-[[:digit:]]~.*$/\1/p'` && \
    su --preserve-environment -s /bin/bash -c "apt-get source nginx" _apt && \
    mk-build-deps nginx --install --remove --tool "apt-get --no-install-recommends -y" && \
    cd /opt && \
    curl -sL https://github.com/vozlt/nginx-module-vts/archive/v${NGINX_VTS_VERSION}.tar.gz | tar -xz && \
    sed -i -r -e "s/\.\/configure(.*)/.\/configure\1 --add-module=\/opt\/nginx-module-vts-${NGINX_VTS_VERSION}/" /opt/rebuildnginx/nginx-${NGINX_VERSION}/debian/rules && \
    cd /opt/rebuildnginx/nginx-${NGINX_VERSION} && \
    dpkg-buildpackage -b && \
    cd /opt/rebuildnginx && \
    dpkg --install nginx_${NGINX_VERSION}-1~stretch_amd64.deb && \
    clean-uninstall \
      curl \
      devscripts \
      dpkg-dev \
      equivs \
      nginx-build-deps && \
    mkdir -p /run/php /var/www /var/log/nginx/ && \
    ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm && \
    rm -r /opt && \
    rm /etc/nginx/conf.d/default.conf

COPY conf/nginx /etc/nginx
COPY conf/php /etc/php/${PHP_VERSION}
COPY bin/ /usr/local/bin/

EXPOSE 80

CMD ["nginx-php-fpm"]
