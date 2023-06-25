#!/bin/bash

version=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')

if [ $version == "Ubuntu" ]
then

    ###Update Software Packages
    sudo apt -y update && sudo apt -y upgrade

    ###Install Nginx Web Server
    sudo apt install nginx -y
    sudo systemctl enable nginx && sudo systemctl start nginx
    sudo chown www-data:www-data /usr/share/nginx/html -R

    #### Install Packages for MariaDB
    sudo apt -y install nginx mariadb-server mariadb-client
    sudo systemctl enable mariadb && sudo systemctl start mariadb
    sudo mysql_secure_installation

    #### Open firewall port for http/https
    sudo ufw allow http && sudo ufw allow https

    ####Install PHP and increase file size
    sudo apt -y install php7.4 php7.4-fpm php7.4-mysql php7.4-readline 
    sudo apt -y install php7.4-cli php7.4-common php7.4-json php7.4-opcache 
    sudo apt -y install php7.4-mbstring php7.4-xml php7.4-gd php7.4-curl
    systemctl enable php7.4-fpm && sudo systemctl start php7.4-fpm

    ####Download and extract latest WordPress Package
    sudo rm /etc/nginx/sites-enabled/default

    ####Create a Nginx Server Block
    cat << EOF >> /etc/nginx/conf.d/default.conf
        # BEGIN
        server {
        listen 80;
        listen [::]:80;
        server_name _;
        root /usr/share/nginx/html/;
        index index.php index.html index.htm index.nginx-debian.html;

        location / {
            try_files \$uri \$uri/ /index.php;
        }

        location ~ \.php\$ {
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
            include snippets/fastcgi-php.conf;
        }

        # A long browser cache lifetime can speed up repeat visits to your page
        location ~* \.(jpg|jpeg|gif|png|webp|svg|woff|woff2|ttf|css|js|ico|xml)\$ {
            access_log        off;
            log_not_found     off;
            expires           360d;
        }

        # disable access to hidden files
        location ~ /\.ht {
            access_log off;
            log_not_found off;
            deny all;
        }
        }
        # END
        EOF

    #### Restart all services
    systemctl restart nginx && systemctl restart php7.4-fpm && systemctl restart mariadb.service
    systemctl --type=service | grep 'nginx\|mariadb\|php'

fi


if [ $version == "CentOS" ]
then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
    sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y &&
    sudo systemctl start docker
    sudo systemctl status docker
fi

if [ $version == "Debian" ]
then
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl status docker
fi

if [ $version == "Fedora" ]
then
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl status docker
fi

if [ $version == "Red" ]
then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
    sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl status docker
fi
















