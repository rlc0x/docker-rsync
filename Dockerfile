FROM centos:centos6
MAINTAINER Raymond Cox rcox@lunartix.com

RUN yum -y update && yum -y install \
	nfs-utils \
    vim 
RUN curl -SL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/bin/jq \
    && chmod +x /usr/bin/jq
ENTRYPOINT [ "/sbin/entrypoint.sh" ]
CMD ["maint:shell"]
COPY entrypoint.sh /sbin/entrypoint.sh 
RUN chmod +x /sbin/entrypoint.sh
