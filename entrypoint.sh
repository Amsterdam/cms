#!/bin/sh
for I in profiles sites; do \
  mkdir -p /app/shared/$I
done

cp -rv /template/sites/* /app/shared/sites/

chown -R www-data:www-data /app/shared/*
chown -R www-data:www-data /app/config

chmod -R 0775 /app/shared/sites/default/

if DEPLOY_ENV == "dev"; then
  cp /app/shared/sites/default/dev.services.yml /app/shared/sites/default/services.yml && \
  drush updb -y && drush cache-rebuild
fi

# Startup Script
apache2-foreground
