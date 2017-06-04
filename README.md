# Self-Signed TSL/SSL Certificates for Client Authentication
These scripts create self-signed certificates and keys to establish client authentication for web servers.  
This script is mostly from [here](https://stackoverflow.com/a/43666288). Thanks to Mr. Parks.

## Steps to Create Certificates
#### Download Scripts
```
git clone git@github.com:pikanji/ssl-client-auth.git
```

#### Create a Configuration File
Create `.env` file with necessary information about the certificates.

```
cd ssl-client-auth
cp .env.dist .env
```

Open `.env` and update with the information of your server.

| Item | Description |
|------|-------------|
| DOMAIN | Target domain name |
| COMMON_NAME | The domain name actually used as the common name. If not specified the wildcard domain name `*.$DOMAIN` will be used. To use the name set in DOMAIN above, just set the same value here. |
| NUM_OF_DAYS | Number of days to expire |
| COUNTRY | Country name in two letters |
| STATE | Name of the state |
| LOCALITY | City |
| ORGANIZATION | Organization name. e.g. company. For root authority, this will be used as COMMON_NAME. |
| ORGANIZATION_UNIT| sub-division or product name |

#### Create Certificate and Key for Root Certificate Authority
```
./create_root_cert_and_key.sh
```

#### Create Certificate and Key for Server and Client
```
./create_certificate_for_domain.sh
```

## Deploy to Server
#### Place Certificate and Key on the Server and Enable HTTPS
Assuming the web server is Apache2.4+, and RedHat base system.

Install `mod24_ssl` if not installed.

Create `/etc/httpd/conf.d/ssl.conf` with the content below. The last 3 lines related logs can be anything.

```
LoadModule ssl_module modules/mod_ssl.so
Listen 443
<VirtualHost *:443>
  <Proxy *>
    Order deny,allow
    Allow from all
  </Proxy>
  SSLEngine on
  SSLProtocol All -SSLv2 -SSLv3
  SSLCertificateFile "/etc/pki/tls/certs/server.crt"
  SSLCertificateKeyFile "/etc/pki/tls/certs/server.key"
  SSLCACertificateFile "/etc/pki/tls/certs/root_ca.crt"
  SSLVerifyClient require

  LogFormat "%h (%{X-Forwarded-For}i) %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
  ErrorLog /var/log/httpd/elasticbeanstalk-error_log
  TransferLog /var/log/httpd/elasticbeanstalk-access_log
</VirtualHost>
```

Place the certificate and key files specified these lines. `server.crt` is the file created as `[domain].crt`.

```
  SSLCertificateFile "/etc/pki/tls/certs/server.crt"
  SSLCertificateKeyFile "/etc/pki/tls/certs/server.key"
  SSLCACertificateFile "/etc/pki/tls/certs/root_ca.crt"
```

#### Force HTTPS
To force HTTPS access, redirect HTTP access to HTTPS.

Add the code below in `.htaccess` under the document root of the web server.  
The important part is the two lines with `RewriteCond` and `RewriteRule`.

```
<IfModule mod_rewrite.c>

  RewriteEngine on

  RewriteCond %{HTTPS} !=on
  RewriteRule ^.*$ https://%{SERVER_NAME}%{REQUEST_URI} [L,R]

</IfModule>
```

Restart the web server.

```
sudo apachectl restart
```

## Settings on Client Device
Assuming the device is Mac...

Double click on .p12 file created above to install the certificates.
In Keychain Access, open the installed certificate of the root certificate authority and set to "Always Trust".

When you visit the web site, on the popup dialog, select the certificate you have installed and click OK.

Now, you should see the green "Secure" label on the left side of the address bar of Chrome browser.
