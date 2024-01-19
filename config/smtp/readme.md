# RTFM

https://geoffstratton.com/spf-dkim-and-dmarc-postfix-and-ubuntu-2004/
https://www.linuxbabe.com/mail-server/setting-up-dkim-and-spf (detailed)
https://sendgrid.com/en-us/blog/how-to-meet-the-new-t-online-de-email-delivery-requirements#span-stylefontweight-400i-use-a-dedicated-ip-address-and-tonlinede-is-blocking-my-emailspan

# Ubuntu setup

apt install postfix opendkim opendkim-tools postfix-policyd-spf-python # select "Internet site" in $ dpkg-reconfigure postfix
gpasswd -a postfix opendkim
systemctl enable postfix
systemctl enable opendkim
#cd / && tar xvfz /tmp/smtp.config.tgz # or rtfm and setup manually

# Generate opendkim keys (skip if backup config used)

mkdir -p /etc/opendkim/keys ; opendkim-genkey -b 2048 -d osmand.net -D /etc/opendkim/keys -s default -v ; chown -hR opendkim:opendkim /etc/opendkim ; chmod -R 700 /etc/opendkim/keys

# Connect Postfix to OpenDKIM (symlinks aren't included in backup)

mkdir /var/spool/postfix/opendkim
chown opendkim:postfix /var/spool/postfix/opendkim

#change opendkim socket to postfix-chroot
sed -i 's/^Socket/#Socket/g' /etc/opendkim.conf
grep -q postfix /etc/opendkim.conf || echo 'Socket local:/var/spool/postfix/opendkim/opendkim.sock' >>/etc/opendkim.conf
sed -i 's,SOCKET=local:$RUNDIR/opendkim.sock,SOCKET=local:/var/spool/postfix/opendkim/opendkim.sock,g' /etc/default/opendkim

#apply Milter configuration (from backup) for /etc/postfix/main.cf

#apply postfix TLS configuration (from backup)

# Setup DNS (godaddy)

add smtp A 88.198.16.57 (not CNAME to avoid ipv6)

add SPF: TXT @ "v=spf1 a:smtp.osmand.net include:sendgrid.net include:mail.zendesk.com ~all"
(optional instead of previous, to enable all OsmAnd server's networks as senders): TXT @ "v=spf1 ip4:88.198.46.0/24 ip4:168.119.14.0/24 ip4:148.251.126.0/24 ip4:88.198.16.0/24 ip4:213.239.209.0/24 ip4:167.235.1.0/24 ip4:51.159.29.0/24 include:sendgrid.net include:mail.zendesk.com include:_spf.google.com ~all")

add DKIM pubkey from /etc/opendkim/keys/default.txt (reformat to 1-line): TXT default._domainkey "v=DKIM1;h=sha256;k=rsa;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw7JxZFWXUg9pNK3E+NYUV/sWxQv+P5ta0VnjRCf+rIjHkrUmCpT04BJZIjc8zRw2cnMWmptCxG4o3hvI+yHWVO2ivD+P/47F9hJUMSt8VjDLma6j00PSLfZrrkNSvSQi3AU5xOLK29fyB7R1Wwy41cEsAM0uRcdg6ynm7wyUEZhLcNoPKPMCtmLpLJrzdNE1u0m8b9JgsEbst8faUqqOnVWMYc7DFHwJbroKdfdJ5JywhqHxWF7OF4YX5rqTYVoxQ5nr9oUfeI18Vby6GzGC9naGrcBcXLLX7QdNhCccePUNG8KMb/sGCyCQJql9yZhVMkE6l55+G8Uq6bFEZD7T9wIDAQAB"

add DMARC: TXT _dmarc "v=DMARC1;p=none;pct=100;rua=mailto:dmarc-reports@osmand.net"

# Setup BACKRESOLVING (hetzner)

88.198.16.57 = dl2.osmand.net
2a01:4f8:222:3155::2 = dl2.osmand.net

# TEST

opendkim-testkey -d osmand.net -s default -vvv
https://www.mail-tester.com/ # (echo Subject: hello; echo world) | sendmail test-xxx@srv1.mail-tester.com
to=osmand@t-online.de; (echo From: admin@osmand.net; echo To: $to; echo Subject: Test SMTPS `date`; date) | curl -v -k -4 --url 'smtps://smtp.osmand.net:465' --mail-from 'admin@osmand.net' --mail-rcpt $to --upload-file -
to=osmand@t-online.de; (echo From: admin@osmand.net; echo To: $to; echo Subject: Test SMTP/TLS `date`; date) | curl -v -k -4 --ssl --url 'smtp://smtp.osmand.net:587' --mail-from 'admin@osmand.net' --mail-rcpt $to --upload-file -

# DKIM/POSTFIX BACKUP

tar cvfz /tmp/smtp.config.tgz /etc/postfix* /etc/opendkim* /etc/mailname /etc/aliases /etc/nginx/sites-available/osmand-default

