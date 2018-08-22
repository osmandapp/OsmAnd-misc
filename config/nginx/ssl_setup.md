```
cd /usr/bin
apt-get install host -y
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
getssl -c XXX.osmand.net
```

/root/.getssl/XXX.osmand.net/getssl.cfg
```
SANS=""
ACL=('/var/www-download/.well-known/acme-challenge')
USE_SINGLE_ACL="true"
DOMAIN_KEY_LOCATION="/etc/ssl/privkey.pem"
DOMAIN_CHAIN_LOCATION="/etc/ssl/cacert.pem"
```

/root/.getssl/getssl.cfg
```
CA="https://acme-v01.api.letsencrypt.org"
ACCOUNT_EMAIL=XXX
RELOAD_CMD="service nginx restart"
```

/etc/cron.d/copy_maps 
```
PATH=/usr/lib/sysstat:/usr/sbin:/usr/sbin:/usr/bin:/sbin:/bin
*/15 * * * * root bash /root/sync.sh
```
RUN: getssl -a

/etc/cron.d/update_cert 
```
PATH=/usr/lib/sysstat:/usr/sbin:/usr/sbin:/usr/bin:/sbin:/bin
23 5 * * * root bash getssl -u -a -q
```