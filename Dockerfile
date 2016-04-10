FROM phusion/baseimage:0.9.16
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
    php7.0 php7.0-zip php-fpm php-cli php-mysql php-redis php-mcrypt \
    php-pspell aspell-es php-imagick php-xdebug \
    php-sqlite3 mediainfo git \
    php-curl php-gd php-intl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

# Configure nginx
RUN echo "daemon off;" >>                                               /etc/nginx/nginx.conf
RUN sed -i "s/sendfile on/sendfile off/"                                /etc/nginx/nginx.conf
RUN mkdir -p                                                            /var/www

# Configure PHP
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g"                 /etc/php/7.0/fpm/php-fpm.conf
##Updated for PHP 7.0
RUN sed -i "s/pid =.*/pid = \/var\/run\/php-fpm.pid/"                   /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i "s/listen =.*sock/listen = \/var\/run\/php-fpm.sock/"        /etc/php/7.0/fpm/pool.d/www.conf
##
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/7.0/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/7.0/cli/php.ini
RUN phpenmod mcrypt
RUN phpenmod xdebug
RUN phpenmod zip

# Add nginx service
RUN mkdir                                                               /etc/service/nginx
ADD build/nginx/run.sh                                                  /etc/service/nginx/run
RUN chmod +x                                                            /etc/service/nginx/run

# Add PHP service
RUN mkdir                                                               /etc/service/phpfpm
ADD build/php/run.sh                                                    /etc/service/phpfpm/run
RUN chmod +x                                                            /etc/service/phpfpm/run

# Add nginx
VOLUME ["/var/www", "/etc/nginx/sites-available", "/etc/nginx/sites-enabled"]

# Workdir
WORKDIR /var/www

EXPOSE 80
