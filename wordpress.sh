#/bin/sh

version=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')

#Creating Variables
domain_name="bonguides.me"
install_dir="/var/www/$domain_name"

if [ $version == "Ubuntu" ]
then
    
    #Creating Random WP Database Credenitals
    db_name="wp`date +%s`"
    db_user=$db_name
    db_password=`date |md5sum |cut -c '1-12'`
    sleep 5
    mysqlrootpass=`date |md5sum |cut -c '1-12'`
    sleep 5

    #### Install Packages for nginx and mysql
    sudo apt -y update && apt -y upgrade
    sudo apt -y install nginx mariadb-server mariadb-client

    #### Open firewall port for http/https
    sudo ufw allow http && sudo ufw allow https

    #### Start, enable on boot and set root password
    sudo systemctl restart mariadb.service && systemctl enable mariadb.service
    mysql -u root -e "UPDATE user SET Password=PASSWORD($mysqlrootpass) WHERE user='root'";
    mysql -u root -e "CREATE USER $db_user@localhost IDENTIFIED BY '$db_password'";
    mysql -u root -e "create database $db_name";
    mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO $db_user@localhost";
    mysql -u root -e "FLUSH PRIVILEGES";

    ####Install PHP and increase file size
    sudo apt install php-fpm php-common php-mysql php-gmp php-curl php-intl php-mbstring php-xmlrpc php-gd php-xml php-cli php-zip -y
    sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php/8*/fpm/php.ini
    sudo sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /etc/php/8*/fpm/php.ini
    sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php/7*/fpm/php.ini
    sudo sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /etc/php/7*/fpm/php.ini
    systemctl restart php*-fpm && systemctl enable php*-fpm

    ####Download and extract latest WordPress Package
    wget -N "https://wordpress.org/latest.tar.gz" -P /tmp
    tar xf /tmp/latest.tar.gz -C /tmp
    mkdir $install_dir
    sudo mv /tmp/wordpress/* $install_dir
    sudo chown www-data:www-data $install_dir -R
    sudo rm /etc/nginx/sites-enabled/default

    #### Create WP-config and set DB credentials
    /bin/mv $install_dir/wp-config-sample.php $install_dir/wp-config.php
    /bin/sed -i "s/database_name_here/$db_name/g" $install_dir/wp-config.php
    /bin/sed -i "s/username_here/$db_user/g" $install_dir/wp-config.php
    /bin/sed -i "s/password_here/$db_password/g" $install_dir/wp-config.php

    #### Restart all services
    chown www-data: $install_dir -R
    systemctl restart nginx && systemctl restart php*-fpm && systemctl restart mariadb.service
    
    ######Display generated passwords to log file.
    echo "................................................................"
    echo ".....          The installation was successfull            ....."
    echo "................................................................"
    echo "Database Name: " $db_name
    echo "Database User: " $db_user
    echo "Database Password: " $db_password
    echo "Mysql root password: " $mysqlrootpass
    echo "................................................................"
    echo "................................................................"
    echo ".....          Your site information                       ....."
    echo "................................................................"
    echo "Your site: http://$domain_name"
    echo "WordPress admin: http://$domain_name/wp-admin"
    echo "Install localtion: $install_dir"
    echo "................................................................"

fi


if [ $version == "CentOS" ]
then
    #Creating Random WP Database Credenitals
    db_name="wp`date +%s`"
    db_user=$db_name
    db_password=`date |md5sum |cut -c '1-12'`
    sleep 5
    mysqlrootpass=`date |md5sum |cut -c '1-12'`
    sleep 5

    #### Install Packages for MariaDB
    sudo yum -y update
    sudo yum install wget vim epel-release -y
    sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    sudo curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
    sudo bash mariadb_repo_setup --mariadb-server-version=10.8
    sudo yum clean all
    sudo yum install MariaDB-server MariaDB-client MariaDB-backup -y

    #### Open firewall port for http/https
    sudo firewall-cmd --add-service=http --permanent
    sudo firewall-cmd --add-service=https --permanent

    #### Start, enable on boot and set root password
    systemctl restart mariadb.service && systemctl enable mariadb.service
    mysql -u root -e "UPDATE user SET Password=PASSWORD($mysqlrootpass) WHERE user='root'";
    mysql -u root -e "CREATE USER $db_user@localhost IDENTIFIED BY '$db_password'";
    mysql -u root -e "create database $db_name";
    mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO $db_user@localhost";
    mysql -u root -e "FLUSH PRIVILEGES";

    ####Install PHP7.4 and Nginx
    sudo yum -y install yum-utils
    sudo yum-config-manager --enable remi-php74
    yum update -y
    yum install nginx php php-cli -y
    yum install php-fpm php-gd php-json php-mbstring php-mysqlnd php-xml php-xmlrpc php-opcache -y
    sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php.ini
    sudo sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /etc/php.ini
    systemctl restart php-fpm && systemctl enable php-fpm
    systemctl restart nginx && systemctl enable nginx

    ###Configure php-fpm
    sudo sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
    sudo sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
    sudo sed -i 's/listen = 127.0.0.1:9000/listen =\/run\/php-fpm\/www.sock/g' /etc/php-fpm.d/www.conf
    sudo sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf
    sudo sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf

    ###Increase file size in PHP
    sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /etc/php.ini
    sudo sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /etc/php.ini

    ####Download and extract latest WordPress Package
    cd /tmp/ && wget "http://wordpress.org/latest.tar.gz";
    tar xf latest.tar.gz
    mkdir $install_dir
    sudo mv /tmp/wordpress/* $install_dir
    sudo chown -R nginx: $install_dir


    cat << EOF >> /etc/nginx/conf.d/$domain_name.conf
    # BEGIN
    server {
        listen 80;
        server_name $domain_name www.$domain_name;
        root /var/www/$domain_name;
        index index.php index.html index.htm;

        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }

        location ~ \.php$ {
            try_files \$fastcgi_script_name =404;
            include fastcgi_params;
            fastcgi_pass                   unix:/run/php-fpm/www.sock;
            fastcgi_index                  index.php;
            fastcgi_param DOCUMENT_ROOT    \$realpath_root;
            fastcgi_param SCRIPT_FILENAME  \$realpath_root\$fastcgi_script_name;
        }

        access_log /var/log/nginx/$domain_name.access.log;
        error_log /var/log/nginx/$domain_name.error.log;
    }
    # END
    EOF

    #### Create WP-config and set DB credentials
    /bin/mv $install_dir/wp-config-sample.php $install_dir/wp-config.php
    /bin/sed -i "s/database_name_here/$db_name/g" $install_dir/wp-config.php
    /bin/sed -i "s/username_here/$db_user/g" $install_dir/wp-config.php
    /bin/sed -i "s/password_here/$db_password/g" $install_dir/wp-config.php

    #### Restart all services and disable SELinux
    sudo chown -R nginx: $install_dir
    systemctl restart nginx && systemctl restart php-fpm && systemctl restart mariadb.service
    sed -i 's/enforcing/disabled/g' /etc/selinux/config
    
    ######Display generated passwords to log file.
    echo "................................................................"
    echo ".....          The installation was successfull            ....."
    echo "................................................................"
    echo "Database Name: " $db_name
    echo "Database User: " $db_user
    echo "Database Password: " $db_password
    echo "Mysql root password: " $mysqlrootpass
    echo "................................................................"
    echo "................................................................"
    echo ".....          Your site information                       ....."
    echo "................................................................"
    echo "Your site: http://$domain_name"
    echo "WordPress admin: http://$domain_name/wp-admin"
    echo "Install localtion: $install_dir"
    echo "................................................................"

fi



