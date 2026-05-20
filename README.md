# BugZillaManagement

Download buzilla source code from the official repository.

```
git clone https://github.com/bugzilla/bugzilla.git
cd bugzilla
```

Before you compose the docker containers edit the file:
```
nano docker-compose.yml
```

You can set a custom port for the webserver, specify the URL location (for example if it is proxied), add restart:unless-stopped to both the webserver and the database. 
```
ports:
 XXXX:80
 BZ_URLBASE=...
restart: unless-stopped
```

Then compose and start the docker containers:
```
docker-compose up -d
```

In your apache server you can protect buzilla with SAML authentication using mellon.
```
sudo apt update
sudo apt install libapache2-mod-auth-mellon
sudo a2enmod auth_mellon
sudo systemctl restart apache2
sudo mkdir -p /etc/apache2/mellon
```
In the mellon folder create:
```
sudo mellon_create_metadata https://your_domain.com/bugzilla_location https://your_domain.com/mellon
```
Rename the three files `sp.key`, `sp.cert`, and `sp.xml`.
Also place in this folder the `xml` and `cert` from your identiry provider such as `zoho-idp`. 
Make sure the files have proper permissions.

Edit your virtual server configuration file:
```
<Location />
    MellonEnable info
    MellonEndpointPath /mellon

    MellonSecureCookie On
    MellonCookieSameSite none

    MellonCookiePath /
    MellonCookieDomain <ADD HERE YOUR DOMAIN>.com

    MellonSPPrivateKeyFile /etc/apache2/mellon/sp.key
    MellonSPCertFile /etc/apache2/mellon/sp.cert
    MellonSPMetadataFile /etc/apache2/mellon/sp.xml
    MellonIdPMetadataFile /etc/apache2/mellon/zoho-idp.xml
    MellonIdPPublicKeyFile /etc/apache2/mellon/zoho-idp.cert
    MellonEndpointPath /mellon
</Location>
<Location /bugzilla/>
    AuthType Mellon
    MellonEnable auth
    Require valid-user

    MellonSetEnvNoPrefix REMOTE_USER NAME_ID
    MellonSetEnvNoPrefix REALNAME "Real name"

    ProxyPass  http://localhost:<ADD HERE BUGZILLA PORT>/
    ProxyPassReverse  http://localhost:<ADD HERE BUGZILLA PORT>/

    RequestHeader set X-Forwarded-User %{REMOTE_USER}e
    RequestHeader set X-Forwarded-Name %{REALNAME}e
</Location>
```

In the Bugzilla interface go to Administration - Parameters - User Authentication and set the following
```
auth_env_id = HTTP_X_FORWARDED_USER
auth_env_email = HTTP_X_FORWARDED_USER
auth_env_realname = HTTP_X_FORWARDED_NAME
user_info_class = Env,CGI
requirelogin = On
```



Go into container: docker exec -it bugzilla_bugzilla5.web_1 bash
```
apt-get install tzdata
apt-get install nano
apt-get install curl
nano /var/www/http/mod_perl.pl
```

Increase the maximum request memory size limit by modifying the corresponding line to: 
```
Apache2::SizeLimit->set_max_unshared_size(300_000);
```

Also create `template/en/custom` folder and create a custom template like the one in the folder template in this repository. 
At the end run `./checksetup.pl` to cleanup the cache and apply the new template.

### Configuration for general ticket creation (HR, Customer Service...)

To use bugzilla for general tickets such as HR, customer service, etc. create Classifications: `HR`, `Finance`, `IT`, etc. and then within each classification you can define Products such as `Onboard employee`, `Offboard employee`, `Annual Performance Review`, etc. and within each of these processes create Components such as `1. Initiate ticket`, `2. Interview candidate`, `3. Sign Contract`, `4. Add to Payroll`, `5. Assign Training`, etc.

### Programmatic Ticket Creation

If you want to create tickets from another mechanism, create an API_KEY from Preferences - API Keys and use a script like the example in `new_ticket.sh`

You can create tickets from outside the container by calling this:
```
docker exec -it bugzilla_bugzilla5.web_1 /path_to_scripts/new_ticket.sh "TestProduct" "TestComponent" "This is a new ticket" "This is a new comment" 
```
