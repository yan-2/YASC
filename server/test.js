// Create an osc.js UDP Port listening on port 57121.

let osc = require('osc')
var udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    localPort: 57121,
    remotePort:57120,
    remoteAddress:'127.0.0.1',
    // metadata: true
});

// Listen for incoming OSC messages.
udpPort.on("message", function (oscMsg, timeTag, info) {
    console.log("An OSC message just arrived!", oscMsg);
    console.log("Remote info is: ", info);
});

// Open the socket.
udpPort.open();

// When the port is read, send an OSC message to, say, SuperCollider
udpPort.on("ready", function () {
    setTimeout(()=>{
        udpPort.send({
            address: "/message",
            args: "hello from nodejs"
        });
    },0)
});


