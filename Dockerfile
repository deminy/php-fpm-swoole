FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive
ENV TERM            xterm-color
ENV PHP_VERSION     7.3

RUN \
  apt-get update            && \
  apt-get install -y           \
    apt-transport-https        \
    apt-utils                  \
    ca-certificates            \
    curl                       \
    lsb-release                \
    nginx                      \
    supervisor                 \
    wget                       \
    --no-install-recommends && \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg                         && \
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
  apt-get update            && \
  apt-get install -y           \
    php${PHP_VERSION}-cli      \
    php${PHP_VERSION}-curl     \
    php${PHP_VERSION}-dev      \
    php${PHP_VERSION}-fpm      \
    php${PHP_VERSION}-xml      \
    php${PHP_VERSION}-zip   && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i "$ s|\-n||g" /usr/bin/pecl && \
  pecl update-channels && \
  pecl install            \
      redis-4.2.0         \
      swoole-4.3.3     && \
  mkdir -p /run/php    && \
  curl                    \
    -sf                   \
    --connect-timeout 5   \
    --max-time         15 \
    --retry            5  \
    --retry-delay      2  \
    --retry-max-time   60 \
    http://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

COPY ./rootfilesystem/ /

RUN \
  phpenmod -s fpm redis  && \
  phpenmod -s cli swoole

WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]
