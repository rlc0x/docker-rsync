FROM centos:centos6
MAINTAINER Raymond Cox rcox@lunartix.com

RUN yum -y update && yum -y install \
    authconfig \
    curl \
    epel-release \
    gcc \
    git \
		nfs-utils \
    openssl-devel \
    sqlite \
    sqlite-devel \
    sudo \
    tar \
    vim \
    wget \
    xz \
    zlib \
    zlib-devel
RUN mkdir -p /usr/local/src \
    && curl -SL https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tar.xz \
    | tar -xJC /usr/local/src \
    && cd /usr/local/src/Python-3.6.0 \
    && ./configure --with-sqlite \
    && make altinstall \
    && pip3.6 install testinfra
RUN curl -Sl https://download.samba.org/pub/rsync/src/rsync-3.1.2.tar.gz \
    | tar -xzC /usr/local/src \
    && cd /usr/local/src/rsync-3.1.2 \
    && ./configure \
    && make install
RUN curl -SL https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz \
    | tar -xJC /usr/local/src \
    && cd /usr/local/src/Python-2.7.13 \
    && ./configure  \
    && make altinstall
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python2.7 get-pip.py \
    && pip2.7 install testinfra
RUN curl -SL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/bin/jq \
    && chmod +x /usr/bin/jq
ENTRYPOINT [ "/sbin/entrypoint.sh" ]
CMD ["maint:shell"]
COPY entrypoint.sh /sbin/entrypoint.sh 
RUN chmod +x /sbin/entrypoint.sh
