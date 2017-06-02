# USAGE
#
# cd $(git rev-parse --show-toplevel)
# docker build -f build/docker/magento/Dockerfile .
#
# After that, you're on your own.
FROM quay.io/littlemanco/apache-php:7.0.19-1_3

ADD app /var/www/

ENV SERVER_NAME "m2onk8s.hackery.littleman.co"
ENV SERVER_ADMIN "devnull@andrewhowden.com"
ENV DOCUMENT_ROOT "/var/www/public/"
