FROM phusion/baseimage
MAINTAINER Harsh Vakharia <harshjv@gmail.com>
MAINTAINER Leandro Banchio <lbanchio@gmail.com>

# Default baseimage settings
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]
ENV DEBIAN_FRONTEND noninteractive

# Update software list, install php-nginx & clear cache
RUN locale-gen en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --force-yes nginx \
    php7.1-fpm \
    php7.1-zip \
    php7.1-mysql \
    php7.1-redis \
    php7.1-mcrypt \
    php7.1-xml \
    php7.1-xdebug \
    php7.1-common \
    php7.1-sqlite \
    php7.1-curl \
    php7.1-zmq \
    php7.1-gd \
    php7.1-imagick \
    php7.1-soap \
    php7.1-mbstring \
    php7.1-intl \
    php7.1-mongodb \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

# Configure nginx
RUN echo "daemon off;" >>                                               /etc/nginx/nginx.conf
RUN sed -i "s/sendfile on/sendfile off/"                                /etc/nginx/nginx.conf
RUN mkdir -p                                                            /var/www
RUN mkdir -p                                                            /run/php
RUN mkdir -m 777                                                        /tmp/php

# Configure PHP
RUN sed -i "s/;session.save_path =.*/session.save_path = \/tmp\/php/"   /etc/php/7.1/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/7.1/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/7.1/fpm/php.ini
RUN sed -i "s/variables_order =.*/variables_order = \"EGPCS\"/"         /etc/php/7.1/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g"                 /etc/php/7.1/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/7.1/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/7.1/cli/php.ini
RUN sed -i "s/;clear_env =.*/clear_env = no/"                           /etc/php/7.1/fpm/pool.d/www.conf      /etc/php/7.1/cli/php.ini

RUN echo "xdebug.idekey=phpstorm" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_enable=1" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_port=9000" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.max_nesting_level=600" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.scream=0" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.cli_color=1" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.show_local_vars=1" >> /etc/php/7.1/fpm/conf.d/20-xdebug.ini

RUN phpenmod mcrypt
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
