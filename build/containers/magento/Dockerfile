# USAGE
#
# cd $(git rev-parse --show-toplevel)
# docker build -f build/docker/magento/Dockerfile .
#
# After that, you're on your own.
FROM quay.io/littlemanco/apache-php:7.0.19-1_3

ADD app /var/www/

# Chown the added files so they're owned by the correct user. 
# Note: Previously, this had problems with Dockers layered FS. Dunno whether it works yet.
RUN chown -R www-data:www-data /var/www

ENV SERVER_NAME "m2onk8s.hackery.littleman.co"
ENV SERVER_ADMIN "devnull@littleman.co"
ENV DOCUMENT_ROOT "/var/www/pub/"
