FROM drupal:8.9.8-apache

RUN apt update && \
  apt install -y git unzip && \
  rm -rf /var/lib/apt/lists

COPY data/php/conf.d/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar && \
  mv drush.phar /usr/local/bin/drush && \
  chmod +x /usr/local/bin/drush

WORKDIR /opt/drupal

COPY composer.json composer.lock ./

# Composer is available in the Drupal image, we can just run it without the need to install it
RUN composer install --ansi --no-interaction --no-cache --no-suggest

RUN rm -rf /template/sites
COPY data/sites /template/sites

RUN rm -rf /app/config
COPY app/config /app/config

RUN rm -rf /app/themes
COPY app/themes /app/themes

WORKDIR /opt/drupal/web

RUN \
  for I in profiles sites; do \
  rm -rf ./$I; \
  ln -s /app/shared/$I ./$I; \
  done

RUN rm -rf ./themes && \
  ln -s /app/themes ./themes

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN mkdir /var/log/apache2/drupal/

COPY data/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod proxy proxy_http cache_disk headers

CMD ["/entrypoint.sh"]
