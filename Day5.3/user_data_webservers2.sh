#! /bin/bash
  yum update -y
  yum install httpd -y
  chmod -R 777 /var/www
  /bin/echo "Razor's Family.!" > /var/www/html/index.html
  /bin/echo " / www.linkedin.com/in/nuwansck / " >> /var/www/html/index.html
  systemctl start httpd
  systemctl enable httpd
  yum install firewalld -y
  systemctl start firewalld
  systemctl enable firewalld
  firewall-cmd --zone=public --add-port=80/tcp --permanent
  firewall-cmd --zone=public --add-port=22/tcp --permanent
  firewall-cmd --reload
  instance_ip=`curl "http://169.254.169.254/latest/meta-data/local-ipv4"`
  /bin/echo $instance_ip >> /var/www/html/index.html