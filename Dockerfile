FROM rbekker87/alpine-apache-php5
ADD orangescrum-master /web/html
ADD boot.sh /boot.sh
RUN chmod +x /boot.sh  && chmod -R 777 /web/html/app/webroot /web/html/app/tmp
