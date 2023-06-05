function noteOnOff(){

}
function buttonCCForControl(){

}
function analogCCForControl(){

}
const rightControls = [
    // Define buttons first since they're latency critical and the updates are
    // rarer.
    {
        name: 'B',
        read_value: (packet) => packet.buttonStatus.b,
        generate_midi: noteOnOff(0x2c),
    },
    {
        name: 'A',
        read_value: (packet) => packet.buttonStatus.a,
        generate_midi: noteOnOff(0x2d),
    },
    {
        name: 'X',
        read_value: (packet) => packet.buttonStatus.x,
        generate_midi: noteOnOff(0x2e),
    },
    {
        name: 'Y',
        read_value: (packet) => packet.buttonStatus.y,
        generate_midi: noteOnOff(0x2f),
    },
    {
        name: 'R',
        read_value: (packet) => packet.buttonStatus.r,
        generate_midi: noteOnOff(0x30),
    },
    {
        name: 'ZR',
        read_value: (packet) => packet.buttonStatus.zr,
        generate_midi: noteOnOff(0x31),
    },
    {
        // home
        name: 'HomeButton',
        read_value: (packet) => packet.buttonStatus.home,
        generate_midi: noteOnOff(0x32),
    },
    {
        name: 'PlusButton',
        read_value: (packet) => packet.buttonStatus.plus,
        generate_midi: noteOnOff(0x33),
    },
    {
        name: 'SRButton',
        read_value: (packet) => packet.buttonStatus.sr,
        generate_midi: buttonCCForControl(0x08),
    },
    {
        name: 'slButton',
        read_value: (packet) => packet.buttonStatus.sl,
        generate_midi: buttonCCForControl(0x09),
    },
    {// right click
        name: 'r-stick',
        read_value: (packet) => {
            return packet.buttonStatus.rightStick
        },
        generate_midi: buttonCCForControl(0x0a),
    },

    // Analog controls (CC)
    //
    // {
    //     name: 'orientation.beta',
    //     read_value: (packet) =>
    //         (Number(packet.actualOrientation.beta) + 90.0) / 180.0,
    //     generate_midi: analogCCForControl(0x0f),
    //     threshold: 3 / 180.0,
    // },
    // {
    //     name: 'orientation.gamma',
    //     read_value: (packet) =>
    //         (Number(packet.actualOrientation.gamma) + 90.0) / 180.0,
    //     generate_midi: analogCCForControl(0x10),
    //     threshold: 3 / 180.0,
    // },
    // {
    //     name: 'r-analog-horizontal',
    //     read_value: (packet) => {
    //         const hmin = -1.2;
    //         const hmax = 1.4;
    //         // console.log('r-analog-horizontal')
    //         return (
    //             (Math.max(
    //                     hmin,
    //                     Math.min(Number(packet.analogStickRight.horizontal), hmax)
    //                 ) -
    //                 hmin) /
    //             (hmax - hmin)
    //         );
    //     },
    //     generate_midi: analogCCForControl(0x11),
    //     threshold: 0.02,
    // },
    {
        name: 'LStickTop',
        read_value: (packet) => {
            return packet.analogStickRight.vertical <= -0.2;
        },
        generate_midi: analogCCForControl(0x12),
        threshold: 0.5,
    },
    {
        name: 'LStickDown',
        read_value: (packet) => {
            return packet.analogStickRight.vertical >= 1.4;
        },
        generate_midi: analogCCForControl(0x12),
        threshold: 0.5,
    },
    {
        name: 'LStickLeft',
        read_value: (packet) => {
            return packet.analogStickRight.horizontal <= -0.9;
        },
        generate_midi: analogCCForControl(0x12),
        threshold: 0.5,
    },
    {
        name: 'LStickRight',
        read_value: (packet) => {
            return packet.analogStickRight.horizontal >= 1.3;
            // return packet.analogStickRight.horizontal;
        },
        generate_midi: analogCCForControl(0x12),
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
        generate_midi: analogCCForControl(0x12),
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
        generate_midi: noteOnOff(0x24),
    },
    {
        name: 'Right',
        read_value: (packet) => packet.buttonStatus.right,
        generate_midi: noteOnOff(0x25),
    },
    {
        name: 'Up',
        read_value: (packet) => packet.buttonStatus.up,
        generate_midi: noteOnOff(0x26),
    },
    {
        name: 'Left',
        read_value: (packet) => packet.buttonStatus.left,
        generate_midi: noteOnOff(0x27),
    },
    {
        name: 'L',
        read_value: (packet) => packet.buttonStatus.l,
        generate_midi: noteOnOff(0x28),
    },
    {
        name: 'ZL',
        read_value: (packet) => packet.buttonStatus.zl,
        generate_midi: noteOnOff(0x29),
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
        generate_midi: analogCCForControl(0x12),
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
    // {
    //     name: 'LeftShake',
    //     // packet = event.detail
    //     read_value: (packet) => {
    //         let accelerometer = packet.actualAccelerometer;
    //         if (!accelerometer || !accelerometer.x) {
    //             return 0
    //         }
    //         return Math.abs(accelerometer.x);
    //     },
    //     generate_midi: analogCCForControl(0x12),
    //     threshold: 0.05,
    // },
    {
        name: 'capture-button-as-note',
        read_value: (packet) => packet.buttonStatus.capture,
        generate_midi: noteOnOff(0x2a),
    },
    {
        name: 'minus-button-as-note',
        read_value: (packet) => packet.buttonStatus.minus,
        generate_midi: noteOnOff(0x2b),
    },

    // Control (CC) buttons
    {
        name: 'minus-button-as-cc',
        read_value: (packet) => packet.buttonStatus.minus,
        generate_midi: buttonCCForControl(0x01),
    },
    {
        name: 'capture-button-as-cc',
        read_value: (packet) => packet.buttonStatus.capture,
        generate_midi: buttonCCForControl(0x02),
    },
    {
        name: 'l-sl-button',
        read_value: (packet) => packet.buttonStatus.sl,
        generate_midi: buttonCCForControl(0x03),
    },
    {
        name: 'l-sr-button',
        read_value: (packet) => packet.buttonStatus.sr,
        generate_midi: buttonCCForControl(0x04),
    },
    {
        name: 'l-stick',
        read_value: (packet) => packet.buttonStatus.leftStick,
        generate_midi: buttonCCForControl(0x05),
    },
    // Analog controls (CC)
    {
        name: 'lOrientationBeta',
        read_value: (packet) =>{
            return ((Number(packet.actualOrientation.beta) + 90.0) / 180.0)
            // return packet.actualOrientation.beta
        },
        generate_midi: analogCCForControl(0x0b),
        threshold: 10 / 180.0,
    },
    {
        name: 'lOrientationGamma',
        read_value: (packet) =>{
            return ((Number(packet.actualOrientation.gamma) + 90.0) / 180.0)
            // return packet.actualOrientation.gamma;
            // return (Number(packet.actualOrientation.gamma) + 90.0) / 180.0
        },
        generate_midi: analogCCForControl(0x0c),
        threshold: 10 / 180.0,
    },
    {
        name: 'lOrientationBetaAlpha',
        read_value: (packet) =>{
            return ((Number(packet.actualOrientation.alpha) + 90.0) / 180.0)
            // return packet.actualOrientation.alpha;
            // (Number(packet.actualOrientation.gamma) + 90.0) / 180.0,
        },
        generate_midi: analogCCForControl(0x0c),
        threshold: 10 / 180.0,
    },
    // {
    //     name: 'l-analog-horizontal',
    //     read_value: (packet) => {
    //         const hmin = -1.2;
    //         const hmax = 1.4;
    //         return (
    //             (Math.max(
    //                     hmin,
    //                     Math.min(Number(packet.analogStickLeft.horizontal), hmax)
    //                 ) -
    //                 hmin) /
    //             (hmax - hmin)
    //         );
    //     },
    //     generate_midi: analogCCForControl(0x0d),
    //     threshold: 0.02,
    // },

    // {
    //     name: 'l-analog-vertical',
    //     read_value: (packet) => {
    //         const vmin = -0.7;
    //         const vmax = 0.9;
    //         return (
    //             (Math.max(
    //                     vmin,
    //                     Math.min(Number(packet.analogStickLeft.vertical), vmax)
    //                 ) -
    //                 vmin) /
    //             (vmax - vmin)
    //         );
    //     },
    //     generate_midi: analogCCForControl(0x0e),
    //     threshold: 0.02,
    // },
];
export {leftControls,rightControls}
