#!/bin/bash

echo "Private SSL Certificate on Apache"
echo "This is for local testing only and does not take any responsibility"
echo "Expired 2031/09/09"
echo "Do you want to install it?"
echo "1) Yes"
echo "2) No"
read -p "Please, select number 1 or 2 : " yn
case "$yn" in
    1) echo "Install it. .";;
    *) echo "Abort the  installation. bye ";exit ;;
esac

if [ "root" != "$USER" ];then
    echo "Please run it with root user."
    echo "Abort the  installation"
    exit 1
fi
is_el8=`grep "release 8" /etc/redhat-release | wc -l`
if [ "${is_el8}" != "1" ];then
    echo "Please use this program with centos 8."
    echo "Abort the  installation"
    exit 1
fi

systemctl stop httpd

dnf install -y mod_ssl
cd private_ssl
chmod 400 localhost*
chmod 755 password

file_exetension=_`date "+%Y%m%d_%H%M%S"`

if [ -e /etc/pki/tls/private/localhost.key ];then
    mv /etc/pki/tls/private/localhost.key /etc/pki/tls/private/localhost.key${file_exetension}
fi
if [ -e /etc/pki/tls/certs/localhost.crt ];then
    mv /etc/pki/tls/certs/localhost.crt /etc/pki/tls/certs/localhost.crt${file_exetension}
fi
if [ -e /etc/pki/tls/certs/localhost.csr ];then
    mv /etc/pki/tls/certs/localhost.csr /etc/pki/tls/certs/localhost.csr${file_exetension}
fi
cp -p ./localhost.key /etc/pki/tls/private/
cp -p ./localhost.crt /etc/pki/tls/certs/
cp -p ./localhost.csr /etc/pki/tls/certs/
cp -p ./password /usr/libexec/

mv /etc/crypto-policies/config /etc/crypto-policies/config${file_exetension}
echo "LEGACY" > /etc/crypto-policies/config
update-crypto-policies
cp -p /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf${file_exetension}
sed -i -e 's/SSLPassPhraseDialog exec:\/usr\/libexec\/httpd-ssl-pass-dialog/SSLPassPhraseDialog exec:\/usr\/libexec\/password/g' /etc/httpd/conf.d/ssl.conf

systemctl start httpd

echo "Product by park.iggy"
echo "Email adress naiggy@gmail.com"
