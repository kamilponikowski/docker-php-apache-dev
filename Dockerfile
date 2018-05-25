FROM gander/php-apache-dev:7.1

ENV LD_LIBRARY_PATH /usr/local/instantclient/

USER root

ADD rootfs /
ADD php/test_oci.php	/tmp/test_oci.php

RUN apt-get clean -y
RUN apt-get update
RUN apt-get install -y --no-install-recommends unzip libaio-dev
RUN apt-get clean -y
RUN rm -r /var/lib/apt/lists/*

# Oracle instantclient
ADD /oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip
ADD /oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip
ADD /oracle/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip

RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /usr/local/

RUN rm /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip
RUN rm /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip
RUN rm /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip

RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8

USER dev
