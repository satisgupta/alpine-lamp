#Ubuntu
FROM alpine:3.10

MAINTAINER Satish Gupta

#ENV DEBIAN_FRONTEND=noninteractive

ENV TIMEZONE UTC

RUN apk update && apk upgrade
RUN apk add --no-cache curl git vim htop wget \
    # Install apache
    apache2 \
    apache2-utils \
    # Install php 7
    php7 \
    php7-fpm \
    php7-cli \
    php7-apache2 \
    php7-session \
    php7-mysqli \
    php7-cli \
    php7-json \
    php7-curl \
    php7-gd \
    php7-ldap \
    php7-mbstring \
    php7-soap \
    php7-xml \
    php7-zip \
    php7-intl \
    php7-phar \
    php7-imagick \
    &&  rm -rf /var/cache/apk/*

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin --filename=composer

    
# Set locales
#RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8

# Enable Rewrite module 
#RUN a2enmod rewrite expires

RUN mkdir -p /run/apache2 && chown -R apache:apache /run/apache2 && chown -R apache:apache /var/www/localhost/htdocs/ && \
    sed -i 's#\#LoadModule rewrite_module modules\/mod_rewrite.so#LoadModule rewrite_module modules\/mod_rewrite.so#' /etc/apache2/httpd.conf && \
    sed -i 's#ServerName localhost:80#\nServerName localhost:80#' /etc/apache2/httpd.conf

# Configure PHP
RUN sed -i 's#display_errors = Off#display_errors = On#' /etc/php7/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 100M#' /etc/php7/php.ini && \
    sed -i 's#post_max_size = 8M#post_max_size = 100M#' /etc/php7/php.ini && \
    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/php7/php.ini && \
    sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#' /etc/php7/php.ini

# Create Virtual host
#COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy web direcotry and setup work directory
WORKDIR /var/www/localhost/htdocs
COPY webapp /var/www/localhost/htdocs

# Run Composer Install
#RUN COMPOSER_MEMORY_LIMIT=-1 composer install

#RUN chown -Rf www-data:www-data /var/www/html
#RUN chmod -Rf 775 /var/www/html

CMD rm -rf /run/apache2/* || true && /usr/sbin/httpd -DFOREGROUND

EXPOSE 80
