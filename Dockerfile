FROM nginx:1.20.2

WORKDIR /var/www

ENV PHP_LIB=/usr/lib

RUN apt update && apt -y install lsb-release apt-transport-https ca-certificates \
    && curl https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && apt update \
    && apt install -y build-essential systemtap-sdt-dev php8.1-dev libphp8.1-embed libxml2-dev libsodium-dev libpcre3 libpcre3-dev zlib1g zlib1g-dev libargon2-dev \
    && apt install -y php8.1-mysqlnd php8.1-gd php8.1-zip php8.1-sqlite3

RUN cd / \
    && curl -L -k https://github.com/rryqszq4/ngx-php/tarball/master -o nginx-php.tgz \
    && tar -xvf nginx-php.tgz \
    && mv rryqszq4-ngx-php* nginx-php

RUN ln -s /bin/sed /usr/bin/sed

RUN cd /nginx-php \
    && curl -sL -o nginx-${NGINX_VERSION}.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -xf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure --with-compat --add-dynamic-module=../ \
    && make modules \
    && mv objs/ngx_http_php_module.so /usr/lib/nginx/modules \
    && sed -i '1s#^#load_module modules/ngx_http_php_module.so;\n#' /etc/nginx/nginx.conf

# Optimize container builds
RUN apt-get clean \
    && rm -rf nginx-php* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
