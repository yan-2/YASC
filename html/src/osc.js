
function OSCInit(){
    // oscPort.open();
    // oscPort.on("ready", function () {
    //     console.log('OSC is ready')
    //     oscPort.send({
    //         address: "/message",
    //         args: [
    //             {
    //                 type: "f",
    //                 value: 440
    //             }
    //         ]
    //     });
    // });
    return oscPort
}
export {OSCInit}

