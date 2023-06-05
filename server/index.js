let osc = require("osc"),
    http = require("http"),
    WebSocket = require("ws");

// Create an Express server app
// and serve up a directory of static files.
let express = require("express");
let app = express()

const path = require('path');
const parentDir = path.dirname(__dirname);

app.use(express.static('./html/dist'))
app.get('/game/hotkeys', (req, res) => {
    res.sendFile(parentDir + '/html/dist/index.html');
})
app.get('/game/dino', (req, res) => {
    res.sendFile(parentDir + '/html/dist/index.html');
})
app.get('/game/stft', (req, res) => {
    res.sendFile(parentDir+ '/html/dist/index.html');
})
app.get('/', (req, res) => {
    res.sendFile(parentDir+ '/html/dist/index.html');
})

let server = app.listen(8081);

let wss = new WebSocket.Server({
    server: server
});

let udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    localPort: 57121,
    remotePort:57120,
    remoteAddress:'127.0.0.1',
    // metadata: true
});
let udpPortReady = false;
udpPort.open();
// Listen
const recorder = 'recorder'
wss.on("connection", function (socket) {
    console.log("A Web Socket connection has been established!");
    // after get the message => send to SC
    let socketPort = new osc.WebSocketPort({
        socket: socket,
        metadata: true
    });

    socketPort.on("message", function (oscMsg) {
        // send to SC
        console.log("received");
        let str = oscMsg.args[0].value;
        // console.log("ss", JSON.parse(str).frequency);
        let obj = JSON.parse(str)
        let instrument = obj.instrument
        if(instrument==='recorder'&&obj.name!=='RVerticalMove'){
            let address = '/play'
            if(instrument===recorder){
                address+=`/${recorder}`
            }
            console.log('address send',address)
            udpPort.send({
                address: address,
                args: [{
                    type:'s',
                    value:obj.status
                },{
                    type:'f',
                    value:obj.frequency
                },{
                    type:'s',
                    value:obj.name
                }]
            });
        }
        if(instrument==='recorder'&&obj.name==='RVerticalMove'){
            let address = '/play/freestyle'
            console.log('address send',address)
            udpPort.send({
                address: address,
                args: [{
                    type:'s',
                    value:obj.status
                },{
                    type:'f',
                    value:obj.frequency
                },{
                    type:'s',
                    value:obj.name
                }]
            });
        }
        if(instrument==='control') {
            let address = '/control'
            console.log('address send',address)
            udpPort.send({
                address: address,
                args: [{
                    type:'s',
                    value:obj.operation
                },{
                    type:'f',
                    value:obj.value
                }]
            });
        }
        if(instrument==='mario'){
            let address = '/play/demo'
            udpPort.send({
                address: address,
                args: []
            });
        }
        if(instrument==='freestyle'){
            let address = '/freestyle/switch'
            console.log('switch')
            udpPort.send({
                address: address,
                args: []
            });
        }
    });
});
