
FROM ubuntu:18.04 AS build
WORKDIR /home

# COMMON BUILD TOOLS
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y -q --no-install-recommends build-essential autoconf automake make git wget pciutils cpio libtool lsb-release ca-certificates pkg-config bison flex

# Install cmake
ARG CMAKE_VER=3.13.1
ARG CMAKE_REPO=https://cmake.org/files
RUN wget -O - ${CMAKE_REPO}/v${CMAKE_VER%.*}/cmake-${CMAKE_VER}.tar.gz | tar xz; \
    cd cmake-${CMAKE_VER}; \
    ./bootstrap --prefix="/usr"; \
    make -j8; \
    make install


# Build nginx-rtmp
ARG NGINX_RTMP_VER=v1.2.1
ARG NGINX_RTMP_REPO=https://github.com/arut/nginx-rtmp-module/archive/${NGINX_RTMP_VER}.tar.gz
ARG NGINX_RTMP_PATCH_REPO=https://raw.githubusercontent.com/VCDP/CDN/master/Add-hevc-support-for-rtmp-dash-and-hls.patch
ARG NGINX_RTMP_STAT_REPO=https://raw.githubusercontent.com/arut/nginx-rtmp-module/${NGINX_RTMP_VER}/stat.xsl

RUN wget -O - ${NGINX_RTMP_REPO} | tar xz && mv nginx-rtmp-module-${NGINX_RTMP_VER#v} nginx-rtmp-module
#    cd nginx-rtmp-module;
#    wget -O - ${NGINX_RTMP_PATCH_REPO} | patch -p1;

RUN mkdir -p /home/build/var/www/html; \
    wget -O /home/build/var/www/html/stat.xsl ${NGINX_RTMP_STAT_REPO};


# Build nginx & nginx-rtmp
ARG NGINX_VER=1.14.2
ARG NGINX_REPO=https://nginx.org/download/nginx-${NGINX_VER}.tar.gz

RUN apt-get update && apt-get install -y -q --no-install-recommends libssl-dev libpcre3-dev zlib1g-dev libxslt1-dev

RUN wget -O - ${NGINX_REPO} | tar xz; \
    cd nginx-${NGINX_VER}; \
    ./configure --prefix=/var/www --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/x86_64-linux-gnu/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/www/log/error.log --pid-path=/var/www/nginx.pid --lock-path=/var/www/nginx.lock --http-log-path=/var/www/log/access.log --http-client-body-temp-path=/var/www/tmp/client_body --http-proxy-temp-path=/var/www/tmp/proxy --http-fastcgi-temp-path=/var/www/tmp/fastcgi --http-uwsgi-temp-path=/var/www/tmp/uwsgi --http-scgi-temp-path=/var/www/tmp/scgi --user=www-data --group=www-data --with-select_module --with-poll_module --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-stream --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module --with-pcre --add-module=../nginx-rtmp-module ; \
    make -j8; \
    make install DESTDIR=/home/build;

# NGINX Setup
COPY nginx.conf /home/build/etc/nginx
RUN mkdir -p /home/build/var/www/tmp/client_body; \
    mkdir -p /home/build/var/www/tmp/proxy; \
    mkdir -p /home/build/var/www/tmp/fastcgi; \
    mkdir -p /home/build/var/www/tmp/uwsgi; \
    mkdir -p /home/build/var/www/tmp/scgi; \
    mkdir -p /home/build/var/www/cache; \
    mkdir -p /home/build/var/www/html; \
    touch /home/build/var/www/html/index.html;


FROM xeone3-ubuntu1804-ffmpeg:latest
LABEL Description="This is the base image for a NGINX+RTMP service"
LABEL Vendor="Intel Corporation"
WORKDIR /home

# Prerequisites
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime; \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y -q --no-install-recommends libxml2 libssl1.0.0 libpcre3 zlib1g libxslt1.1 ; \
    rm -rf /var/lib/apt/lists/*;
# Install
COPY --from=build /home/build /
CMD /usr/sbin/nginx
VOLUME /etc/nginx /var/www/html /var/www/tmp/client_body /var/www/tmp/proxy /var/www/tmp/fastcgi /var/www/tmp/uwsgi /var/www/tmp/scgi /var/www/cache /var/www/dash /var/www/hls
EXPOSE 80 1935

