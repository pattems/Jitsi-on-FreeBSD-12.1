-- Prosody Configuration File
---------- Server-wide settings ----------

-- A list of accounts that are admins for the server.
admins = { "focus@auth.jitsi.example.com" }

pidfile = "/tmp/prosody.pid";

modules_enabled = {
        -- Generally required
                "roster"; -- Allow users to have a roster. Recommended ;)
                "saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
                "tls"; -- Add support for secure TLS on c2s/s2s connections
                "dialback"; -- s2s dialback support
                "disco"; -- Service discovery
        -- Not essential, but recommended
                "carbons"; -- Keep multiple clients in sync
                "pep"; -- Enables users to publish their avatar, mood, activity, playing music and more
                "private"; -- Private XML storage (for room bookmarks, etc.)
                "blocklist"; -- Allow users to block communications with other users
                "vcard4"; -- User profiles (stored in PEP)
                "vcard_legacy"; -- Conversion between legacy vCard and PEP Avatar, vcard
        -- Nice to have
                "version"; -- Replies to server version requests
                "uptime"; -- Report how long server has been running
                "time"; -- Let others know the time here on this server
                "ping"; -- Replies to XMPP pings with pongs
                "register"; -- Allow users to register on this server using a client and change passwords
                "mam"; -- Store messages in an archive and allow users to access it
        -- Admin interfaces
                "admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
        -- HTTP modules
                "bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
                "pubsub";
                --"websocket"; -- XMPP over WebSockets
}

modules_disabled = {}

-- Disable account creation by default, for security
allow_registration = false

-- Force clients to use encrypted connections? This option will prevent clients from authenticating unless they are using encryption.
c2s_require_encryption = true

-- Force servers to use encrypted connections? This option will prevent servers from authenticating unless they are using encryption.
s2s_require_encryption = true

-- Force certificate authentication for server-to-server connections?
s2s_secure_auth = false

authentication = "internal_hashed"

-- Archiving configuration
archive_expires_after = "1w" -- Remove archived messages after 1 week

-- Logging configuration
log = {
        info = "prosody.log";
        error = "prosody.err";
}

-- Location of directory to find certificates in (relative to main config file):
certificates = "../../../../var/db/prosody/"

----------- Virtual hosts -----------

VirtualHost "localhost"

VirtualHost "jitsi.example.com"
        authentication = "anonymous"
        ssl = {
                key = "/var/db/prosody/jitsi.example.com.key";
                certificate = "/var/lib/prosody/jitsi.example.com.crt";
        }
        c2s_require_encryption = false

VirtualHost "auth.jitsi.example.com"
    ssl = {
        key = "/var/db/prosody/auth.jitsi.example.com.key";
        certificate = "/var/db/prosody/auth.jitsi.example.com.crt";
    }
    authentication = "internal_plain"

------ Components ------
Component "conference.jitsi.example.com" "muc"
Component "jitsi-videobridge.jitsi.example.com"
    component_secret = "<YOURSECRET1>"
Component "focus.jitsi.example.com"
    component_secret = "<YOURSECRET2>"
