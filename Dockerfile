FROM rbekker87/alpine-apache-php5
ADD orangescrum-master /web/html
ADD boot.sh /boot.sh
RUN chmod +x /boot.sh 
