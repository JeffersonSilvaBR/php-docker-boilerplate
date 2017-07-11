#++++++++++++++++++++++++++++++++++++++
# PHP application Docker container
#++++++++++++++++++++++++++++++++++++++
#
# PHP-Versions:
#  ubuntu-12.04 -> PHP 5.3         (precise)  LTS
#  ubuntu-14.04 -> PHP 5.5         (trusty)   LTS
#  ubuntu-15.04 -> PHP 5.6         (vivid)
#  ubuntu-15.10 -> PHP 5.6         (wily)
#  ubuntu-16.04 -> PHP 7.0         (xenial)   LTS
#  centos-7     -> PHP 5.4
#  debian-7     -> PHP 5.4         (wheezy)
#  debian-8     -> PHP 5.6 and 7.x (jessie)
#  debian-9     -> PHP 7.0         (stretch)
#
# Apache:
#   webdevops/php-apache-dev:5.6
#   webdevops/php-apache-dev:7.0
#   webdevops/php-apache-dev:7.1
#   webdevops/php-apache-dev:ubuntu-12.04
#   webdevops/php-apache-dev:ubuntu-14.04
#   webdevops/php-apache-dev:ubuntu-15.04
#   webdevops/php-apache-dev:ubuntu-15.10
#   webdevops/php-apache-dev:ubuntu-16.04
#   webdevops/php-apache-dev:centos-7
#   webdevops/php-apache-dev:debian-7
#   webdevops/php-apache-dev:debian-8
#   webdevops/php-apache-dev:debian-8-php7
#   webdevops/php-apache-dev:debian-9
#
# Nginx:
#   webdevops/php-nginx-dev:5.6
#   webdevops/php-nginx-dev:7.0
#   webdevops/php-nginx-dev:7.1
#   webdevops/php-nginx-dev:ubuntu-12.04
#   webdevops/php-nginx-dev:ubuntu-14.04
#   webdevops/php-nginx-dev:ubuntu-15.04
#   webdevops/php-nginx-dev:ubuntu-15.10
#   webdevops/php-nginx-dev:ubuntu-16.04
#   webdevops/php-nginx-dev:centos-7
#   webdevops/php-nginx-dev:debian-7
#   webdevops/php-nginx-dev:debian-8
#   webdevops/php-nginx-dev:debian-8-php7
#   webdevops/php-nginx-dev:debian-9
#
# HHVM:
#   webdevops/hhvm-apache
#   webdevops/hhvm-nginx
#
#++++++++++++++++++++++++++++++++++++++

FROM webdevops/php-apache-dev:ubuntu-16.04

ENV PROVISION_CONTEXT "development"

# Deploy scripts/configurations
COPY etc/             /opt/docker/etc/

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential g++-5\
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y unixodbc-dev msodbcsql

# install SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# php libraries
RUN apt-get update && apt-get install -y \
    php7.0 libapache2-mod-php7.0 mcrypt php7.0-mcrypt php-mbstring php-pear php7.0-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# install SQL Server PHP connector module
RUN pecl install sqlsrv pdo_sqlsrv

# initial configuration of SQL Server PHP connector
RUN echo "extension=/usr/lib/php/20151012/sqlsrv.so" >> /etc/php/7.0/cli/php.ini
RUN echo "extension=/usr/lib/php/20151012/pdo_sqlsrv.so" >> /etc/php/7.0/cli/php.ini

# install additional utilities
RUN apt-get update && apt-get install gettext nano vim -y

RUN ln -sf /opt/docker/etc/cron/crontab /etc/cron.d/docker-boilerplate \
    && chmod 0644 /opt/docker/etc/cron/crontab \
    && echo >> /opt/docker/etc/cron/crontab \
    && ln -sf /opt/docker/etc/php/development.ini /opt/docker/etc/php/php.ini

# Configure volume/workdir
WORKDIR /app/
