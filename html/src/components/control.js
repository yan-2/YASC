const rightControls = [
    {
        name: 'B',
        read_value: (packet) => packet.buttonStatus.b,
    },
    {
        name: 'A',
        read_value: (packet) => packet.buttonStatus.a,
    },
    {
        name: 'X',
        read_value: (packet) => packet.buttonStatus.x,
    },
    {
        name: 'Y',
        read_value: (packet) => packet.buttonStatus.y,
    },
    {
        name: 'R',
        read_value: (packet) => packet.buttonStatus.r,
    },
    {
        name: 'ZR',
        read_value: (packet) => packet.buttonStatus.zr,
    },
    {
        // home
        name: 'HomeButton',
        read_value: (packet) => packet.buttonStatus.home,
    },
    {
        name: 'PlusButton',
        read_value: (packet) => packet.buttonStatus.plus,
    },
    {
        name: 'SRButton',
        read_value: (packet) => packet.buttonStatus.sr,
    },
    {
        name: 'slButton',
        read_value: (packet) => packet.buttonStatus.sl,
    },
    {// right click
        name: 'r-stick',
        read_value: (packet) => {
            return packet.buttonStatus.rightStick
        },
    },
    {
        name: 'LStickTop',
        read_value: (packet) => {
            return packet.analogStickRight.vertical <= -0.2;
        },
        threshold: 0.5,
    },
    {
        name: 'LStickDown',
        read_value: (packet) => {
            return packet.analogStickRight.vertical >= 1.4;
        },
        threshold: 0.5,
    },
    {
        name: 'LStickLeft',
        read_value: (packet) => {
            return packet.analogStickRight.horizontal <= -0.9;
        },
        threshold: 0.5,
    },
    {
        name: 'LStickRight',
        read_value: (packet) => {
            return packet.analogStickRight.horizontal >= 1.3;
            // return packet.analogStickRight.horizontal;
        },
        threshold: 0.5,
    },
    {
        name: 'RVerticalMove',
        // packet = event.detail
        read_value: (packet) => {
            let accelerometer = packet.actualAccelerometer;
            if (!accelerometer || !accelerometer.x) {
                return 0
            }
            return accelerometer.x;
        },
        threshold: 0.001,
        computePercent(v){
            let min = -0.009;
            let max = 0.009;
            let tenPercent = (max-min)/10;
            // -0.009 ~ 0.009
            if(v<=min){
                return 0
            }
            if(v>=max){
                return 1
            }
            return ((v-min)/(max-min)).toFixed(2);
        },
        computeFrequency(v,packet){
            let me = this;
            let basic = me.computePercent(v)*200
            let offsetGamma = Math.abs(Number(packet.actualOrientation.gamma))*2
            let offsetBeta =Math.abs(Number(packet.actualOrientation.beta))*2
            let offsetAlpha = Math.abs(Number(packet.actualOrientation.alpha))*2
            let gyroscope= packet.actualGyroscope.dps;
            let gyroscopeX = Math.abs(Number(gyroscope.x *10))
            let gyroscopeY = Math.abs(Number(gyroscope.y *15))
            let gyroscopeZ = Math.abs(Number(gyroscope.z *10))
            let yOffset = packet.actualAccelerometer.y * 1;
            console.log(gyroscopeX)
            return basic + offsetGamma + yOffset+offsetAlpha+offsetBeta+gyroscopeX+gyroscopeY+gyroscopeZ
        },
    },
];

const leftControls = [
    // Define buttons first since they're latency critical and the updates are
    // rarer.
    {
        name: 'Down',
        read_value: (packet) => {
            return packet.buttonStatus.down
        },
    },
    {
        name: 'Right',
        read_value: (packet) => packet.buttonStatus.right,
    },
    {
        name: 'Up',
        read_value: (packet) => packet.buttonStatus.up,
    },
    {
        name: 'Left',
        read_value: (packet) => packet.buttonStatus.left,
    },
    {
        name: 'L',
        read_value: (packet) => packet.buttonStatus.l,
    },
    {
        name: 'ZL',
        read_value: (packet) => packet.buttonStatus.zl,
    },
    {
        name: 'LVerticalMove',
        // packet = event.detail
        read_value: (packet) => {
            let accelerometer = packet.actualAccelerometer;
            if (!accelerometer || !accelerometer.x) {
                return 0
            }
            return accelerometer.x;
        },
        threshold: 0.002,
        computePercent(v){
            let min = -0.009;
            let max = 0.009;
            let tenPercent = (max-min)/10;
            // -0.009 ~ 0.009
            if(v<=min){
                return 0
            }
            if(v>=max){
                return 1
            }
            return ((v-min)/(max-min)).toFixed(2);
        }
    },
    {
        name: 'capture-button-as-note',
        read_value: (packet) => packet.buttonStatus.capture,
    },
    {
        name: 'minus-button-as-note',
        read_value: (packet) => packet.buttonStatus.minus,
    },

    // Control (CC) buttons
    {
        name: 'minus-button-as-cc',
        read_value: (packet) => packet.buttonStatus.minus,
    },
    {
        name: 'capture-button-as-cc',
        read_value: (packet) => packet.buttonStatus.capture,
    },
    {
        name: 'l-sl-button',
        read_value: (packet) => packet.buttonStatus.sl,
    },
    {
        name: 'l-sr-button',
        read_value: (packet) => packet.buttonStatus.sr,
    },
    {
        name: 'l-stick',
        read_value: (packet) => packet.buttonStatus.leftStick,
    },
    // Analog controls (CC)
    {
        name: 'lOrientationBeta',
        read_value: (packet) =>{
            return ((Number(packet.actualOrientation.beta) + 90.0) / 180.0)
        },
        threshold: 10 / 180.0,
    },
    {
        name: 'lOrientationGamma',
        read_value: (packet) =>{
            return ((Number(packet.actualOrientation.gamma) + 90.0) / 180.0)
        },
        threshold: 10 / 180.0,
    },
    {
        name: 'lOrientationBetaAlpha',
        read_value: (packet) =>{
            return ((Number(packet.actualOrientation.alpha) + 90.0) / 180.0)
        },
        threshold: 10 / 180.0,
    },

];
export {leftControls,rightControls}
