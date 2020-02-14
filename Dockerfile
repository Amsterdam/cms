FROM drupal:8.8.1-apache

#
ENV COMPOSER_ALLOW_SUPERUSER 1

# Set workdir
WORKDIR /var/www/html/

## Install
RUN apt update && apt install -y git unzip

# Install composer, require the elasticsearch dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer config --global repo.packagist composer https://packagist.org \
    && composer --ansi --version --no-interaction

# Install drupal cli
RUN composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader \
    && curl https://drupalconsole.com/installer -L -o drupal.phar \
    && mv drupal.phar /usr/local/bin/drupal \
    && chmod +x /usr/local/bin/drupal \
    && drupal list | grep ^Drupal

# Install drush cli
RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
    && mv drush.phar /usr/local/bin/drush \
    && chmod +x /usr/local/bin/drush \
    && composer require drush/drush \
    && drush version

# Install required module dependencies
RUN COMPOSER_MEMORY_LIMIT=-1 composer require "drupal/elasticsearch_connector:^6" \
      "nodespark/des-connector:^6" "drupal/search_api" \
      "webonyx/graphql-php" \
      "drupal/graphql_search_api"

RUN composer info


COPY data/php/conf.d/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
COPY data/sites /template/sites
COPY app/modules /app/modules
COPY app/config /app/config
COPY app/themes /app/themes
COPY app/content /app/content

RUN chmod 777 /app/content

RUN \
  for I in profiles sites; do \
    rm -rf /var/www/html/$I; \
    ln -s /app/shared/$I /var/www/html/$I; \
  done \
  && rm -rf /var/www/html/modules \
  && ln -s /app/modules /var/www/html/modules \
  && ln -s /app/themes /var/www/html/themes

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Extra Apache configs
COPY data/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod proxy proxy_http cache_disk

ENTRYPOINT [ "/entrypoint.sh"]
