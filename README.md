# Installing Jitsi Meet on FreeBSD 12.1

 Install the packages we'll need (openjdk8 and maven are optional to install as packages, but this saves having to build them):
 
```
pkg install prosody nginx openjdk8 maven
```

Fetch and extract the ports tree, if you haven't already; Jitsi Videobridge, Jitsi Conference Focus, and Jitsi Meet aren't currently available as packages.

```
portsnap fetch && portsnap extract
```

#### Notes
* This guide describes configuring a server `jitsi.example.com`. You will need to change references to that to match your host, and generate some passwords for `YOURSECRET1`, `YOURSECRET2` and `YOURSECRET3`. These placeholders are indicated in this guide and in the example configuration files with `<angled brackets>`
* These instructions are modified from the official Devops guide, which can be found [here](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-manual)

## Configure prosody

Edit config file `/usr/local/etc/prosody/prosody.cfg.lua` (see example config file [here](prosody.cfg.lua))

Add focus user to server admins

```
admins = { "focus@auth.jitsi.example.com" }
```

Add a pidfile location

```
pidfile = "/tmp/prosody.pid";
```

add your domain virtual host section

```
VirtualHost "jitsi.example.com"
    authentication = "anonymous"
    ssl = {
        key = "/var/db/prosody/jitsi.example.com.key";
        certificate = "/var/db/prosody/jitsi.example.com.crt";
    }
    modules_enabled = {
        "bosh";
        "pubsub";
    }
    c2s_require_encryption = false
```

add domain with authentication for conference focus user

```
VirtualHost "auth.jitsi.example.com"
	ssl = {
		key = "/var/db/prosody/auth.jitsi.example.com.key";
		certificate = "/var/db/prosody/auth.jitsi.example.com.crt";
	}
	authentication = "internal_plain"
```

change the location of the certs folder from certs to the correct path (unsure if this step is actually necessary)

```
certificates = "../../../../var/db/prosody/"
```

and finally configure components

```
Component "conference.jitsi.example.com" "muc"
Component "jitsi-videobridge.jitsi.example.com"
    component_secret = "<YOURSECRET1>"
Component "focus.jitsi.example.com"
    component_secret = "<YOURSECRET2>"
```

Save the file and generate certs for the domain

```
prosodyctl cert generate jitsi.example.com
prosodyctl cert generate auth.jitsi.example.com
```

Create conference focus user

```
prosodyctl register focus auth.jitsi.example.com <YOURSECRET3>
```

Enable and start prosody

```
service prosody enable && service prosody start
```

##### Important Differences from Linux install procedure
* location of the config file is different. 
* certificates are generated in `/var/db/prosody` instead of `/var/lib/prosody` 
* a pidfile must be specified.

## Configure Nginx
Edit the nginx.conf file located at `/usr/local/etc/nginx.conf`, inside the http block (see example config file [here](nginx.conf))

```
server_names_hash_bucket_size 64;
server {
	listen 0.0.0.0:443 ssl http2;
	listen [::]:443 ssl http2;
	ssl_certificate /path/to/fullchain.pem;
	ssl_certificate_key /path/to/privkey.pem;
	server_name jitsi.example.com;
	root /usr/local/www/jitsi-meet;
	index index.html;
	location ~ ^/([a-zA-Z0-9=\?]+)$ { rewrite ^/(.*)$ / break; }
	location / { ssi on; }
	location /http-bind {
		proxy_pass http://localhost:5280/http-bind;
		proxy_set_header X-Forwarded-For $remote_addr;
		proxy_set_header Host $http_host;
	}
	location /external_api.js { alias /usr/local/www/jitsi-meet/libs/external_api.min.js; }
}
```

Enable and start nginx

```
service nginx enable && service nginx start
```

##### Important Differences from Linux install procedure
* The FreeBSD defaults for config files don't include the sites-available and sites-enabled directories, and is configured by default from the main config file (which is also located in `/usr/local/etc/nginx` instead of `/etc/nginx`
* On FreeBSD, Nginx serves files from `/usr/local/www/` instead of `/srv/` by default

## Install and Configure Jitsi Videobridge
Install Jitsi-videobridge from ports

```
cd /usr/ports/net-im/jitsi-videobridge/ && make install clean
```

Edit the videobridge config file located at `/usr/local/etc/jitsi/videobridge/jitsi-videobridge.conf` (see example config file [here](jitsi-videobridge.conf))

```
JVB_XMPP_HOST=localhost
JVB_XMPP_DOMAIN=jitsi.example.com
JVB_XMPP_PORT=5347
JVB_XMPP_SECRET=<YOURSECRET1>
VIDEOBRIDGE_MAX_MEMORY=3072m
```

create `/usr/local/etc/jitsi/videobridge/sip-communicator.properties` with the following lines (see example config file [here](sip-communicator.properties))

```
org.jitsi.impl.neomedia.transform.srtp.SRTPCryptoContext.checkReplay=false
org.jitsi.videobridge.TCP_HARVESTER_PORT=4443
```

Enable and start Jitsi Videobridge

```
service jitsi-videobridge enable && service jitsi-videobridge start
```

## Install and Configure Jitsi Conference Focus (jicofo)

Install Jitsi Conference Focus from ports

```
cd /usr/ports/net-im/jicofo/ && make install clean
```

Edit the configuration file located at `/usr/local/etc/jitsi/jicofo/jicofo.conf` (see example config file [here](jicofo.conf))

```
JVB_XMPP_HOST=localhost
JVB_XMPP_DOMAIN=jitsi.example.com
JVB_XMPP_PORT=5347
JVB_XMPP_SECRET=<YOURSECRET2>
JVB_XMPP_USER_DOMAIN=auth.jitsi.example.com
JVB_XMPP_USER_NAME=focus
JVB_XMPP_USER_SECRET=<YOURSECRET3>
MAX_MEMORY=3072m
```

Enable and start Jitsi Conference Focus

```
service jicofo enable && service jicofo start
```

## Install and Configure Jitsi Meet
Install Jitsi Meet from ports

```
cd /usr/ports/www/jitsi-meet/ && make install clean
```

Edit host names in `/usr/local/www/jitsi-meet/config.js` (see example config file [here](config.js))

```
var config = {
  hosts: {
    domain: 'jitsi.example.com',
    muc: 'conference.jitsi.example.com',
    bridge: 'jitsi-videobridge.jitsi.example.com',
    focus: 'focus.jitsi.example.com'
  },
bosh: '//jitsi.example.com/http-bind',
```

Verify that nginx config is valid and reload nginx:

```
nginx -t && nginx -s reload
```

## Running behind NAT

Jitsi Videobridge can run behind a NAT, provided that both required ports are routed (forwarded) to the machine that it runs on. By default these ports are `TCP/4443` and `UDP/10000`.

If you do not route these two ports, Jitsi Meet will only work with video for two people, breaking upon 3 or more people trying to show video.

`TCP/443` is required for the webserver which can be running on another machine than the Jitsi Videobrige is running on.

The following extra lines need to be added to the file `/usr/local/etc/jitsi/videobridge/sip-communicator.properties`:
```
org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS=<Local.IP.Address>
org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=<Public.IP.Address>
```

Restart Jitsi Videobridge

```
service jitsi-videobridge restart
```

## Hold your first conference

You are now all set and ready to have your first meet by going to  [http://jitsi.example.com](http://jitsi.example.com/)
