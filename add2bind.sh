#
# Created by muslu on 14:01:06   22/Şub/2020 
# 



if [ "$1" != "" ]; then
  echo "OK"
  domain=$1
else
  clear
  echo
  echo "Lütfen alan adını seçiniz!"
  echo
  echo
  echo "Örnek: sh $0 hasokeyk.com"
  exit
fi


host_ip=`bash -c 'wget -qO- ifconfig.me'`


echo "zone \"$1\" { type master; file \"/var/lib/bind/$1.hosts\"; };" >> /etc/bind/named.conf.local
clear

cat <<EOT >> /var/lib/bind/$1.hosts
\$ttl 3600

$1. IN  SOA ns1.$1. info.$1. ( `date +%Y%m%d`01 10800 3600 2419200 10800 )

ns1.$1.           IN      A       $host_ip
ns2.$1.           IN      A       $host_ip

$1.               IN      NS      ns1.$1.
$1.               IN      NS      ns2.$1.

$1.               IN      A       $host_ip
www.$1.           IN      A       $host_ip
mail.$1.          IN      A       $host_ip
$1.               IN      MX 10   mail.$1.

$1.               IN      TXT     "v=spf1 a mx ip4:$host_ip ~all"
_dmarc.$1.        IN      TXT     "v=DMARC1; pct=100; p=quarantine; adkim=r; aspf=r"

EOT
clear

rndc reload && rndc reconfig && systemctl restart bind9
exit