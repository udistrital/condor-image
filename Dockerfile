# genera una imagen para S2I a partir de una imágen S2I existente
FROM centos/php-56-centos7:5.6
USER root

COPY oracle-instantclient11.2-devel-11.2.0.1.0-1.x86_64.rpm oracle-instantclient-devel.rpm
COPY oracle-instantclient11.2-basic-11.2.0.1.0-1.x86_64.rpm oracle-instantclient-basic.rpm
COPY oracle-instantclient11.2-ldconfig /etc/ld.so.conf.d/oas_oracle.conf
COPY oas_php_01.ini /etc/opt/rh/rh-php56/php.d/oas_php_01.ini
COPY oas_auto_prepend_file.php /opt/rh/rh-php56/root/usr/share/php/oas_auto_prepend_file.php
COPY aws-2.8.31.phar /opt/rh/rh-php56/root/usr/share/php/aws.phar
RUN ln -s /opt/rh/rh-php56/root/usr/share/php/oas_auto_prepend_file.php /opt/rh/rh-php56/root/usr/share/pear/oas_auto_prepend_file.php
RUN ln -s /opt/rh/rh-php56/root/usr/share/php/aws.phar /opt/rh/rh-php56/root/usr/share/pear/aws.phar

# libaio - dependencia de compilación de oci8
RUN yum install -y -q -e 0 \
  libaio \
  oracle-instantclient-basic.rpm \
  oracle-instantclient-devel.rpm \
  rh-php56-php-devel

RUN rm -f \
  oracle-instantclient-basic.rpm \
  oracle-instantclient-devel.rpm

ENV ORACLE_HOME /usr/lib/oracle/11.2/client64
ENV TNS_ADMIN /etc/httpd/conf
RUN CFLAGS=-I/usr/include/oracle/11.2/client64 LDFLAGS=-L/usr/lib/oracle/11.2/client64/lib pecl install oci8-1.4.10

COPY oas_php_02.ini /etc/opt/rh/rh-php56/php.d/oas_php_02.ini

RUN php -i | grep -o "OCI8 Support => enabled"

RUN groupadd -r -g 51111 oas # numero de usuario y numero de grupo debe ser consistente por que compartan datos con EFS
RUN useradd -r -g oas -G apache,root -u 51111 oas

# default se necesita para cumplir con el estándar S2I
USER default
