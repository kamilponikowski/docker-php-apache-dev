FROM php:7.1-apache

RUN apt-get clean -y
RUN apt-get update
# Oracle instantclient
ADD instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip
ADD instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip
ADD instantclient-sqlplus-linux.x64-12.1.0.2.0.zip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip

RUN apt-get install -y unzip

RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

ENV LD_LIBRARY_PATH /usr/local/instantclient/

RUN apt-get install libaio-dev -y
RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8
ADD php/oci8.ini	/usr/local/etc/php/conf.d/oci8.ini

# Install the PHP extensions we need
RUN apt-get install -y --no-install-recommends \
    curl \
	mysql-client \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libssl-dev \
    libmcrypt-dev && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-install gd pdo_mysql mysqli opcache intl && \
	docker-php-ext-enable pdo_mysql

RUN echo "<?php oci_connect('baza_bpsc', 'baza_bpsc', '192.168.6.20/BPSC');" > /tmp/test.php
ADD php/test_oci.php	/tmp/test_oci.php

VOLUME /www
WORKDIR /www

EXPOSE 80
CMD ["apache2-foreground"]