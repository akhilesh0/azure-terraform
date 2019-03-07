FROM centos:centos7

# Dockerfile author / maintainer
MAINTAINER Name akhilesh0
RUN yum install -y gcc-c++ make
RUN yum -y install epel-release; yum clean all
RUN yum -y install nodejs npm; yum clean all

ADD nodejs /app
RUN cd /app; npm install
EXPOSE 5000
CMD ["node", "/app/index.js"]
