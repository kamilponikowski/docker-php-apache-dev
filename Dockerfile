FROM php:7.2-apache

ARG DEV_USER_UID=1000

ENV LD_LIBRARY_PATH=/usr/local/instantclient
ENV PATH=${PATH}:${LD_LIBRARY_PATH}

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
    curl \
    git \
    htop \
    libaio1 \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpq-dev \
    libxslt-dev \
    nano \
    openssh-client \
    sudo \
    unzip \
    wget
RUN rm -r /var/lib/apt/lists/*

RUN pecl channel-update pecl.php.net

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/libjpeg.so

RUN docker-php-ext-install -j$(nproc) bcmath
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) intl
#RUN docker-php-ext-install -j$(nproc) mcrypt
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) opcache
RUN docker-php-ext-install -j$(nproc) pcntl
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) pdo_pgsql
RUN docker-php-ext-install -j$(nproc) sockets
RUN docker-php-ext-install -j$(nproc) zip

RUN pecl install xdebug
RUN pecl install mongodb

RUN docker-php-ext-enable mongodb

RUN curl -LsS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony
RUN curl -LsS https://www.phing.info/get/phing-2.16.0.phar -o /usr/local/bin/phing && chmod +x /usr/local/bin/phing

RUN printf "alias l='ls -CF'\nalias la='ls -A'\nalias ll='ls -alF'\n" >> /etc/bash.bashrc
RUN printf "if [ -d \"\$HOME/.composer/vendor/bin\" ]; then\n    PATH=\"\$HOME/.composer/vendor/bin:\$PATH\"\nfi\n" >> /etc/bash.bashrc

RUN printf "export APACHE_RUN_USER=dev\nexport APACHE_RUN_GROUP=dev\n" >> /etc/apache2/envvars

ADD rootfs /

RUN unzip ${LD_LIBRARY_PATH}/instantclient-basic-linux.x64-12.2.0.1.0.zip -d ${LD_LIBRARY_PATH}/
RUN unzip ${LD_LIBRARY_PATH}/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d ${LD_LIBRARY_PATH}/
RUN unzip ${LD_LIBRARY_PATH}/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d ${LD_LIBRARY_PATH}/

RUN ln -sf ${LD_LIBRARY_PATH}/instantclient_12_2/sqlplus /usr/bin/sqlplus
RUN find ${LD_LIBRARY_PATH}/instantclient_12_2 -name 'libclntsh.so*' -type f -exec ln -sf {} "${LD_LIBRARY_PATH}/instantclient_12_2/libclntsh.so" \;
RUN echo 'instantclient,${LD_LIBRARY_PATH}/instantclient_12_2' | pecl install oci8
RUN echo '${LD_LIBRARY_PATH}/instantclient_12_2' > /etc/ld.so.conf.d/oracle-instantclient.conf
RUN ldconfig

RUN adduser --disabled-password --gecos '' --uid ${DEV_USER_UID} dev \
    && adduser dev sudo \
    && printf "dev ALL=(ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/dev

RUN chown -R dev:dev /www /var/lock/apache2 /var/log/apache2

RUN a2enmod rewrite && a2enmod vhost_alias && a2enconf vhost-alias

USER dev

VOLUME /www
WORKDIR /www

EXPOSE 80
CMD ["sudo", "apache2-foreground"]