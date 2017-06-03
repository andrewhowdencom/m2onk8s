#!/bin/bash
#
# The install script. Used by the init container to execute an installation of this store when first deployed into the
# kubernetes cluster.
#
set -e

su --shell=/bin/bash www-data --command=' \
  php /var/www/html/bin/magento setup:install \
    --db-host="db" \
    --db-name="magento" \
    --db-user="magento" \
    --db-password="thisisthemagentopassword" \
    --db-prefix="" \
    --admin-user="m2onk8s" \
    --admin-password="m2onk8s" \
    --admin-email="devnull@littleman.co" \
    --admin-firstname="m2onk8s" \
    --admin-lastname="developer" \
    --base-url="http://m2onk8s.hackery.littleman.local" \
    --language="en_GB" \
    --timezone="UTC" && \
  chmod "u=rx,g=,o=" /var/www/html/app/etc/'

# Todo: Cat the .env file, and turn it into a secret.
