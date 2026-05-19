# BugZillaManagement

```
git clone https://github.com/bugzilla/bugzilla.git
cd bugzilla
```

edit file:
```
nano docker-compose.yml
```

customize setup:
```
ports:
 XXXX:80
 BZ_URLBASE=...
 restart: unless-stopped
```

```
docker-compose up -d
```

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
nano /var/www/http/mod_perl.pl
```
modify: Apache2::SizeLimit->set_max_unshared_size(300_000);

Also create 'template/en/custom' folder and create files

`index.html.tmpl`, `global/footer.html.tmpl`, `global/variables.none.tmpl`

optionally, change favicon.ico in `/var/www/html/images/`

at the end run to cleanup the cache and apply the new configuration.
`./checksetup.pl`
