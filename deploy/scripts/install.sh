#!/bin/bash
#
# The install script. Used by the init container to execute an installation of this store when first deployed into the
# kubernetes cluster.
#
set -e

# See sysexits.h
EX_USAGE=64

APP_ROOT="/var/www"

# Define variables
DATABASE_HOST="${DATABASE_HOST:-db}"
DATABASE_NAME="${DATABASE_NAME:-magento}"
DATABASE_USER="${DATABASE_USER:-magento}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_EMAIL="${ADMIN_EMAIL:-devnull@littleman.co}"
ADMIN_FIRSTNAME="${ADMIN_FIRSTNAME:-admin}"
ADMIN_LASTNAME="${ADMIN_LASTNAME:-user}"
LOCALE_LANGUAGE="${LOCALE_LANGUAGE:-en_GB}"
LOCALE_TIMEZONE="${LOCALE_TIMEZONE:-UTC}"

# Check required variables
if [[ -z "${ADMIN_PASSWORD}" ]] || [[ -z "${DATABASE_PASSWORD}" ]] || [[ -z "${BASE_URL}" ]]; then
   echo "Missing required environment variables."
   exit $EX_USAGE
fi

# Give the app/etc/ folder write permissions. This is required for Magento to add the necessary configuration to this
# location.
chmod 'u=rwx,g=,o=' "${APP_ROOT}/app/etc/"

php "${APP_ROOT}/bin/magento" setup:install \
    --db-host="${DATABASE_HOST}" \
    --db-name="${DATABASE_NAME}" \
    --db-user="${DATABASE_USER}" \
    --db-password="${DATABASE_PASSWORD}" \
    --db-prefix="" \
    --admin-user="${ADMIN_USER}" \
    --admin-password="${ADMIN_PASSWORD}" \
    --admin-email="${ADMIN_EMAIL}" \
    --admin-firstname="${ADMIN_FIRSTNAME}" \
    --admin-lastname="${ADMIN_LASTNAME}" \
    --base-url="${BASE_URL}" \
    --language="${LOCALE_LANGUAGE}" \
    --timezone="${LOCALE_TIMEZONE}"

# Todo: Cat the .env file, and turn it into a secret.
# See https://stackoverflow.com/questions/30690186/how-do-i-access-the-kubernetes-api-from-within-a-pod-container
cat "${APP_ROOT}/app/env.php"
