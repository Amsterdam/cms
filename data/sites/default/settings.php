<?php

error_reporting(E_ALL);

// @codingStandardsIgnoreFile

$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT');
$settings['update_free_access'] = FALSE;
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';
$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];
$config['system.logging']['error_level'] = 'verbose';
$settings['entity_update_batch_size'] = 50;
$settings['entity_update_backup'] = TRUE;
$databases['default']['default'] = array (
  'database' => getenv('DRUPAL_DBNAME'),
  'username' => getenv('DRUPAL_USERNAME'),
  'password' => getenv('DRUPAL_PASSWORD'),
  'prefix' => '',
  'host' => getenv('DRUPAL_DBHOST'),
  'port' => getenv('DRUPAL_DBPORT'),
  'namespace' => 'Drupal\\Core\\Database\\Driver\\pgsql',
  'driver' => 'pgsql',
);

$settings['config_sync_directory'] = '/app/config';

$settings['trusted_host_patterns'] = array (
  '^localhost(.*)$',
  '^cms.service.consul$',
  '^cms.data.amsterdam.nl$',
  '^acc.cms.data.amsterdam.nl$',
);
