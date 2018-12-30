FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive
ENV TERM            xterm-color
ENV PHP_VERSION     7.2

RUN \
  apt-get update            && \
  apt-get install -y           \
    apt-transport-https        \
    apt-utils                  \
    ca-certificates            \
    curl                       \
    lsb-release                \
    wget                       \
    --no-install-recommends && \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg                         && \
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
  apt-get update            && \
  apt-get install -y           \
    nginx                      \
    php${PHP_VERSION}-curl     \
    php${PHP_VERSION}-dev      \
    php${PHP_VERSION}-fpm      \
    supervisor              && \
  mkdir -p /run/php           && \
  rm -rf /var/lib/apt/lists/* && \
  pecl install redis swoole                                                      && \
  echo "extension=redis.so"  > /etc/php/${PHP_VERSION}/mods-available/redis.ini  && \
  echo "extension=swoole.so" > /etc/php/${PHP_VERSION}/mods-available/swoole.ini && \
  phpenmod -s fpm redis                                                          && \
  phpenmod -s cli swoole                                                         && \
  curl                    \
    -sf                   \
    --connect-timeout 5   \
    --max-time         15 \
    --retry            5  \
    --retry-delay      2  \
    --retry-max-time   60 \
    http://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

COPY ./default          /etc/nginx/sites-enabled/default
COPY ./entrypoint.sh    /entrypoint.sh
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./www.conf         /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY ./www/             /var/www/

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]
