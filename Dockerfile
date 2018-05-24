FROM php:7.2-apache

ARG DEV_USER_UID=1000

ARG PHING2_VERSION=2.16.0
ARG PHPUNIT6_VERSION=6.5
ARG PHPUNIT7_VERSION=7.0

MAINTAINER Kamil Ponikowski <kamilponikowski@gmail.com>

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    openssh-client \
    sudo \
    git \
    wget \
    curl \
    cron \
    nano \
    htop \
    unzip \
    libicu-dev \
    libmcrypt-dev \
    libpq-dev \
#    libpng12-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libxslt-dev \
    libtidy-dev \
    && rm -r /var/lib/apt/lists/*

RUN pecl channel-update pecl.php.net

# Install Oracle Instantclient
RUN mkdir -p /opt
RUN chown -R dev:dev /opt
RUN mkdir -p /opt/oracle
RUN chown -R dev:dev /opt/oracle
RUN cd /opt/oracle
RUN wget https://ws.moleo.pl/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip
RUN wget https://ws.moleo.pl/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip
# RUN unzip /opt/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /opt/oracle
# RUN unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle
#    && ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.2 /opt/oracle/instantclient_12_2/libclntsh.so \
#    && ln -s /opt/oracle/instantclient_12_2/libclntshcore.so.12.2 /opt/oracle/instantclient_12_2/libclntshcore.so \
#    && ln -s /opt/oracle/instantclient_12_2/libocci.so.12.2 /opt/oracle/instantclient_12_2/libocci.so \
#    && rm -rf /opt/oracle/*.zip

RUN cd ..
RUN cd ..

#RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_12_2,12.2
#RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/opt/oracle/instantclient_12_2,12.2

RUN docker-php-ext-install -j$(nproc) bcmath
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/libjpeg.so
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) mbstring
#RUN docker-php-ext-install -j$(nproc) mcrypt
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) opcache
RUN docker-php-ext-install -j$(nproc) pcntl
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) pdo_pgsql
RUN docker-php-ext-install -j$(nproc) sockets
RUN docker-php-ext-install -j$(nproc) zip
RUN docker-php-ext-install -j$(nproc) soap
RUN pecl install xdebug
#RUN pecl install mongodb
#RUN docker-php-ext-enable mongodb

#RUN curl -LsS http://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
#RUN curl -LsS http://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony
#
#RUN curl -LSs http://box-project.github.io/box2/installer.php | php && mv box.phar /usr/local/bin/box
#
#RUN curl -LsS http://robo.li/robo.phar -o /usr/local/bin/robo && chmod +x /usr/local/bin/robo
#
#RUN curl -LsS http://www.phing.info/get/phing-${PHING2_VERSION}.phar -o /usr/local/bin/phing && chmod +x /usr/local/bin/phing
#
#RUN curl -LsS http://deployer.org/deployer.phar -o /usr/local/bin/dep && chmod +x /usr/local/bin/dep
#
#RUN curl -LsS http://phar.phpunit.de/phpunit-${PHPUNIT6_VERSION}.phar -o /usr/local/bin/phpunit6 && chmod +x /usr/local/bin/phpunit6
#RUN curl -LsS http://phar.phpunit.de/phpunit-${PHPUNIT7_VERSION}.phar -o /usr/local/bin/phpunit7 && chmod +x /usr/local/bin/phpunit7

RUN ln -s /usr/local/bin/phpunit6 /usr/local/bin/phpunit

RUN printf "alias l='ls -CF'\nalias la='ls -A'\nalias ll='ls -alF'\n" >> /etc/bash.bashrc
RUN printf "if [ -d \"\$HOME/.composer/vendor/bin\" ]; then\n    PATH=\"\$HOME/.composer/vendor/bin:\$PATH\"\nfi\n" >> /etc/bash.bashrc

RUN printf "export APACHE_RUN_USER=dev\nexport APACHE_RUN_GROUP=dev\n" >> /etc/apache2/envvars

ADD rootfs /

RUN adduser --disabled-password --gecos '' --uid ${DEV_USER_UID} dev \
    && adduser dev sudo \
    && printf "dev ALL=(ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/dev

RUN chown -R dev:dev /var/lock/apache2 /var/log/apache2

RUN a2enmod rewrite && a2enmod vhost_alias && a2enconf vhost-alias

USER dev

VOLUME /www
WORKDIR /www

EXPOSE 80
CMD ["sudo", "apache2-foreground"]
