FROM alpine:3.5

#Install dependencies
#php7-tokenizer will be needed when migrating to 7.1
RUN apk add --no-cache \
    apache2 git php7 php7-ctype php7-session php7-apache2 php7-xml \
    php7-json php7-pdo php7-pdo_mysql php7-curl php7-ldap php7-mcrypt php7-iconv \
    php7-xml php7-xsl php7-gd php7-zip php7-soap php7-mbstring php7-zlib \
    php7-mysqli php7-sockets perl mysql-client tar curl imagemagick-dev \
    python git libffi-dev py-pip python-dev build-base dcron vim nano bash bash-doc bash-completion tree curl
#clone openemr
RUN git clone https://github.com/openemr/openemr.git --depth 1 \
    && mv openemr openemr_for_build \
    && rm -rf openemr_for_build/.git \
    && chmod 666 openemr_for_build/sites/default/sqlconf.php \
    && chmod 666 openemr_for_build/interface/modules/zend_modules/config/application.config.php \
    && chown -R apache openemr_for_build/ \
    && mv openemr_for_build /var/www/localhost/htdocs/ \
    && apk del --no-cache git build-base libffi-dev python-dev
WORKDIR /var/www/localhost/htdocs/openemr_for_build
#configure apache & php properly
ENV APACHE_LOG_DIR=/var/log/apache2
COPY php.ini /etc/php7/php.ini
COPY openemr.conf /etc/apache2/conf.d/
#add runner and auto_configure and prevent auto_configure from being run w/o being enabled
COPY auto_configure.php /var/www/localhost/htdocs/openemr_for_build/
COPY run_openemr.sh /var/www/localhost/htdocs/
COPY utilities/unlock_admin.php utilities/unlock_admin.sh /root/
RUN chmod 500 /var/www/localhost/htdocs/run_openemr.sh /root/unlock_admin.sh \
    && chmod 000 /var/www/localhost/htdocs/openemr_for_build/auto_configure.php /root/unlock_admin.php \
    && ln -s /usr/bin/php7 /usr/bin/php
#fix issue with apache2 dying prematurely
RUN mkdir -p /run/apache2
#go
CMD [ "../run_openemr.sh" ]

EXPOSE 80
