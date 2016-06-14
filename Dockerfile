FROM centos:6.8

MAINTAINER tomsato

RUN yum -y update

# util
RUN yum -y install wget vim git tar

# PHP
RUN yum -y install epel-release
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN yum -y install --enablerepo=remi,remi-php56 php php-devel php-mbstring php-pdo php-gd

# mysql
RUN yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
RUN yum -y install mysql-community-server
RUN mysql_install_db --datadir=/var/lib/mysql --user=mysql

# dev tool
RUN yum -y groupinstall "Development tools"
RUN yum -y install source-highlight

# httpd
RUN yum -y install httpd
ADD src/index.html /var/www/html/

# ssh
RUN yum -y install passwd openssh openssh-server openssh-clients sudo
RUN mkdir -p /var/run/sshd
RUN useradd -d /home/tomsato -m -s /bin/bash tomsato
RUN echo tomsato:tomsato | chpasswd
RUN echo 'tomsato ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ADD sshd/sshd_config /etc/ssh/sshd_config
RUN /etc/init.d/sshd start;/etc/init.d/sshd stop

# bashrc
COPY resource/bashrc /etc/bashrc

# supervisor
RUN yum -y install python-setuptools
RUN easy_install 'supervisor == 3.2.0' 'supervisor-stdout == 0.1.1' && mkdir -p /var/log/supervisor
ADD supervisor/supervisord.conf /etc/supervisord.conf

# expose for sshd, httpd, mysql
EXPOSE 22 80 3306

CMD ["/usr/bin/supervisord"]

