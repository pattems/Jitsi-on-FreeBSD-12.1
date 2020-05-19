/* eslint-disable no-unused-vars, no-var */

var config = {
// Connection
        hosts: {
                domain: '<jitsi.example.com>',                     //changeme
                muc: 'conference.<jitsi.example.com>',             //changeme
                bridge: 'jitsi-videobridge.<jitsi.example.com>',   //changeme
                focus: 'focus.<jitsi.example.com>'                 //changeme
                // anonymousdomain: 'guest.jitsi.example.com',     // When using authentication, domain for guest users.
                // authdomain: 'auth.jitsi.example.com'            // Domain for authenticated users. Defaults to <domain>.
        },
        bosh: '//<jitsi.example.com>/http-bind',                   // BOSH URL.
        clientNode: 'http://jitsi.org/jitsimeet',                  // The name of client node advertised in XEP-0115 'c' stanza
        testing: { p2pTestMode: false },                           // Testing / experimental features.
// Audio
        enableNoAudioDetection: true,
        enableNoisyMicDetection: true,
        startAudioOnly: true,
// Desktop sharing
        desktopSharingChromeExtId: null,
        desktopSharingChromeSources: [ 'screen', 'window', 'tab' ],
        desktopSharingChromeMinExtVersion: '0.1',
// Misc
        channelLastN: -1,
// UI
        // useNicks: false,             // Use display name as XMPP nickname
        requireDisplayName: true,       // Require users to always specify a display name.
        enableWelcomePage: true,
        enableUserRolesBasedOnToken: false,
// Peer-To-Peer mode: used (if enabled) when there are just 2 participants.
        p2p: {
                enabled: true,
                stunServers: [ { urls: 'stun:meet-jit-si-turnrelay.jitsi.net:443' } ],  // The STUN servers that will be used in the peer to peer connections
                preferH264: true        // If set to true, it will prefer to use H.264 for P2P calls (if H.264 is supported).
        },
// Mainly privacy related settings
        doNotStoreRoom: false,   // Disables storing the room name to the recents list
        makeJsonParserHappy: 'even if last key had a trailing comma'

// no configuration value should follow this line.
};

/* eslint-enable no-unused-vars, no-var */
