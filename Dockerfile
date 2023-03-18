FROM ubuntu:22.04

ARG VSCODE_BIN_PATH
ARG GIT_BIN_PATH
ARG DEFAULT_USER
ARG DEFAULT_USER_PASSWORD
ARG TZ
ARG HOSTNAME
ARG PHP_VERSION

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get install -y wget curl unzip vim && \
    apt-get install -y init systemd && \
    apt-get install -y mysql-server && \
    apt-get install -y nginx && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get install -y php$PHP_VERSION php$PHP_VERSION-fpm php$PHP_VERSION-mysql php$PHP_VERSION-curl php$PHP_VERSION-xml && \
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    apt-get install -y nodejs npm && \
    apt-get install -y sudo

#  user
RUN adduser $DEFAULT_USER && \
    usermod -aG sudo $DEFAULT_USER && \
    echo $DEFAULT_USER:$DEFAULT_USER_PASSWORD | chpasswd
    # echo root:$DEFAULT_USER_PASSWORD | chpasswd

# vscode & git
RUN echo "\n\
alias code='/mnt${VSCODE_BIN_PATH}'\n\
alias git='/mnt${GIT_BIN_PATH}'\n\
" >> /home/$DEFAULT_USER/.bashrc

# wsl
COPY server_files/configure/wsl.conf /etc/wsl.conf
RUN chmod 644 /etc/wsl.conf
RUN echo "\n\
[user]\n\
default=${DEFAULT_USER}\n\
[network]\n\
hostname=${HOSTNAME}\n\
" >> /etc/wsl.conf

COPY server_files/configure/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
COPY server_files/configure/nginx.conf /etc/nginx/sites-enabled/default

RUN chmod 777 /var/www/html
COPY server_files/configure/initialize.sh /initialize.sh
