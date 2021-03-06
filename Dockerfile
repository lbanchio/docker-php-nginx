FROM phusion/baseimage:18.04-1.0.0

MAINTAINER Harsh Vakharia <harshjv@gmail.com>
MAINTAINER Leandro Banchio <lbanchio@gmail.com>

# Default baseimage settings
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]
ENV DEBIAN_FRONTEND noninteractive

RUN echo 'DPkg::options { "--force-confdef"; };' >> /etc/apt/apt.conf
# Update software list, install php-nginx & clear cache
RUN locale-gen en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --force-yes nginx \
    php8.0-fpm \
    php8.0-zip \
    php8.0-mysql \
    php8.0-redis \
    php8.0-xml \
    php8.0-xdebug \
    php8.0-common \
    php8.0-sqlite \
    php8.0-curl \
    php8.0-zmq \
    php8.0-gd \
    php8.0-imagick \
    php8.0-soap \
    php8.0-apcu \
    php8.0-mbstring \
    php8.0-intl \
    php8.0-bcmath \
    php8.0-mongodb \
    unzip \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

# Configure users
RUN groupadd -g 1000 user && useradd --no-log-init -u 1000 -b /var/www -M -g user user

# Configure nginx
RUN echo "daemon off;" >>                                               /etc/nginx/nginx.conf
RUN sed -i "s/sendfile on/sendfile off/"                                /etc/nginx/nginx.conf
RUN sed -i "s/user www-data/user user/"                                 /etc/nginx/nginx.conf
RUN sed -i "s/user = www-data/user = user/"                             /etc/php/8.0/fpm/pool.d/www.conf
RUN sed -i "s/group = www-data/group = user/"                           /etc/php/8.0/fpm/pool.d/www.conf
RUN sed -i "s/listener.owner = www-data/listener.owner = user/"         /etc/php/8.0/fpm/pool.d/www.conf
RUN sed -i "s/listener.group = www-data/listener.group = user/"         /etc/php/8.0/fpm/pool.d/www.conf
RUN mkdir -p                                                            /var/www
RUN mkdir -p                                                            /run/php
RUN mkdir -m 777                                                        /tmp/php

# Configure PHP
RUN sed -i "s/;session.save_path =.*/session.save_path = \/tmp\/php/"   /etc/php/8.0/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/8.0/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/8.0/fpm/php.ini
RUN sed -i "s/variables_order =.*/variables_order = \"EGPCS\"/"         /etc/php/8.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g"                 /etc/php/8.0/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/8.0/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/8.0/cli/php.ini
RUN sed -i "s/;clear_env =.*/clear_env = no/"                           /etc/php/8.0/fpm/pool.d/www.conf      /etc/php/8.0/cli/php.ini

RUN echo "xdebug.idekey=phpstorm" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_enable=1" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_port=9000" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.max_nesting_level=600" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.scream=0" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.cli_color=1" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.show_local_vars=1" >> /etc/php/8.0/fpm/conf.d/20-xdebug.ini

RUN phpenmod xdebug

# Add nginx service
RUN mkdir                                                               /etc/service/nginx
ADD build/nginx/run.sh                                                  /etc/service/nginx/run
RUN chmod +x                                                            /etc/service/nginx/run

# Add PHP service
RUN mkdir                                                               /etc/service/phpfpm
ADD build/php/run.sh                                                    /etc/service/phpfpm/run
RUN chmod +x                                                            /etc/service/phpfpm/run

RUN chmod 777                                                           /var/lib/php -R
# Add nginx
VOLUME ["/var/www", "/etc/nginx/sites-available", "/etc/nginx/sites-enabled"]

# Workdir
WORKDIR /var/www

EXPOSE 80
