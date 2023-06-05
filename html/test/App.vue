<template>
    <div id="app">
        <button class="connect" type="button" @click="connect">Connect Joy-Con</button>
        <div>
            {{info}}
        </div>
    </div>
</template>
<script>

import * as JoyCon from './components/joycon/index.js';
import {connectedJoyCons, JoyConLeft} from "./components/joycon";

const MIDI_NOTE_ON_CH_1 = 0x90;
const MIDI_NOTE_OFF_CH_1 = 0x80;
const MIDI_VELOCITY_MAX = 0x7f;
const MIDI_VELOCITY_MIN = 0;
const MIDI_CC_CH_1 = 0xb0;

const noteOnOff = (note) => {
    return (readValue) => [
        readValue ? MIDI_NOTE_ON_CH_1 : MIDI_NOTE_OFF_CH_1,
        note,
        MIDI_VELOCITY_MAX,
    ];
};

const buttonCCForControl = (control) => {
    return (readValue) => [
        MIDI_CC_CH_1,
        control,
        readValue ? MIDI_VELOCITY_MAX : MIDI_VELOCITY_MIN,
    ];
};
const leftControls = [
    // Define buttons first since they're latency critical and the updates are
    // rarer.
    {
        name: 'down-button',
        read_value: (packet) => packet.buttonStatus.down,
        generate_midi: noteOnOff(0x24),
    },
    {
        name: 'right-button',
        read_value: (packet) => packet.buttonStatus.right,
        generate_midi: noteOnOff(0x25),
    },
    {
        name: 'up-button',
        read_value: (packet) => packet.buttonStatus.up,
        generate_midi: noteOnOff(0x26),
    },
    {
        name: 'left-button',
        read_value: (packet) => packet.buttonStatus.left,
        generate_midi: noteOnOff(0x27),
    },
    {
        name: 'l-button',
        read_value: (packet) => packet.buttonStatus.l,
        generate_midi: noteOnOff(0x28),
    },
    {
        name: 'zl-button',
        read_value: (packet) => packet.buttonStatus.zl,
        generate_midi: noteOnOff(0x29),
    },
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
        name: 'l-orientation.beta',
        read_value: (packet) =>
            (Number(packet.actualOrientation.beta) + 90.0) / 180.0,
        generate_midi: analogCCForControl(0x0b),
        threshold: 3 / 180.0,
    },
    {
        name: 'l-orientation.gamma',
        read_value: (packet) =>
            (Number(packet.actualOrientation.gamma) + 90.0) / 180.0,
        generate_midi: analogCCForControl(0x0c),
        threshold: 3 / 180.0,
    },
    {
        name: 'l-analog-horizontal',
        read_value: (packet) => {
            const hmin = -1.2;
            const hmax = 1.4;
            return (
                (Math.max(
                        hmin,
                        Math.min(Number(packet.analogStickLeft.horizontal), hmax)
                    ) -
                    hmin) /
                (hmax - hmin)
            );
        },
        generate_midi: analogCCForControl(0x0d),
        threshold: 0.02,
    },
    {
        name: 'l-analog-vertical',
        read_value: (packet) => {
            const vmin = -0.7;
            const vmax = 0.9;
            return (
                (Math.max(
                        vmin,
                        Math.min(Number(packet.analogStickLeft.vertical), vmax)
                    ) -
                    vmin) /
                (vmax - vmin)
            );
        },
        generate_midi: analogCCForControl(0x0e),
        threshold: 0.02,
    },
];

const rightControls = [
    // Define buttons first since they're latency critical and the updates are
    // rarer.
    {
        name: 'b-button',
        read_value: (packet) => packet.buttonStatus.b,
        generate_midi: noteOnOff(0x2c),
    },
    {
        name: 'a-button',
        read_value: (packet) => packet.buttonStatus.a,
        generate_midi: noteOnOff(0x2d),
    },
    {
        name: 'x-button',
        read_value: (packet) => packet.buttonStatus.x,
        generate_midi: noteOnOff(0x2e),
    },
    {
        name: 'y-button',
        read_value: (packet) => packet.buttonStatus.y,
        generate_midi: noteOnOff(0x2f),
    },
    {
        name: 'r-button',
        read_value: (packet) => packet.buttonStatus.r,
        generate_midi: noteOnOff(0x30),
    },
    {
        name: 'zr-button',
        read_value: (packet) => packet.buttonStatus.zr,
        generate_midi: noteOnOff(0x31),
    },
    {
        name: 'home-button-as-note',
        read_value: (packet) => packet.buttonStatus.home,
        generate_midi: noteOnOff(0x32),
    },
    {
        name: 'plus-button-as-note',
        read_value: (packet) => packet.buttonStatus.plus,
        generate_midi: noteOnOff(0x33),
    },

    // Control (CC) buttons
    {
        name: 'plus-button-as-cc',
        read_value: (packet) => packet.buttonStatus.plus,
        generate_midi: buttonCCForControl(0x06),
    },
    {
        name: 'home-button-as-cc',
        read_value: (packet) => packet.buttonStatus.home,
        generate_midi: buttonCCForControl(0x07),
    },
    {
        name: 'sr-button',
        read_value: (packet) => packet.buttonStatus.sr,
        generate_midi: buttonCCForControl(0x08),
    },
    {
        name: 'sl-button',
        read_value: (packet) => packet.buttonStatus.sl,
        generate_midi: buttonCCForControl(0x09),
    },
    {
        name: 'r-stick',
        read_value: (packet) => packet.buttonStatus.rightStick,
        generate_midi: buttonCCForControl(0x0a),
    },

    // Analog controls (CC)
    {
        name: 'orientation.beta',
        read_value: (packet) =>
            (Number(packet.actualOrientation.beta) + 90.0) / 180.0,
        generate_midi: analogCCForControl(0x0f),
        threshold: 3 / 180.0,
    },
    {
        name: 'orientation.gamma',
        read_value: (packet) =>
            (Number(packet.actualOrientation.gamma) + 90.0) / 180.0,
        generate_midi: analogCCForControl(0x10),
        threshold: 3 / 180.0,
    },
    {
        name: 'r-analog-horizontal',
        read_value: (packet) => {
            const hmin = -1.2;
            const hmax = 1.4;
            return (
                (Math.max(
                        hmin,
                        Math.min(Number(packet.analogStickRight.horizontal), hmax)
                    ) -
                    hmin) /
                (hmax - hmin)
            );
        },
        generate_midi: analogCCForControl(0x11),
        threshold: 0.02,
    },
    {
        name: 'r-analog-vertical',
        read_value: (packet) => {
            const vmin = -0.7;
            const vmax = 1.4;
            return (
                (Math.max(
                        vmin,
                        Math.min(Number(packet.analogStickRight.vertical), vmax)
                    ) -
                    vmin) /
                (vmax - vmin)
            );
        },
        generate_midi: analogCCForControl(0x12),
        threshold: 0.02,
    },
];
export default {
    data() {
        return {
            info:""
        }
    },
    methods:{
        async connect(){
            let me = this
            await JoyCon.connectJoyCon();
            me.watchStatus()
        },
        async show(){

        },
        updateControl (control, packet, side)  {
            window.lastPacket = packet;
            if (control.threshold === undefined) {
                control.threshold = 0;
            }
            if (control.last_value === undefined) {
                if (control.init_value === undefined) {
                    control.init_value = 0;
                }
                control.last_value = control.init_value;
            }
            const newValue = control.read_value(packet);
            if (Math.abs(newValue - control.last_value) > control.threshold) {
                const msg = control.generate_midi(newValue);
                if (msg !== undefined) {
                    // sendMidi(msg, control.name);
                }
                control.last_value = newValue;
            }
        },
        updateBothControls(joyCon, packet) {
            let me = this
            if (!packet || !packet.actualOrientation) {
                return;
            }
            if (joyCon instanceof JoyConLeft) {
                for (const control of leftControls) {
                     me.updateControl(control, packet);
                }
            } else {
                for (const control of rightControls) {
                    me.updateControl(control, packet);
                }
            }
        },
        watchStatus(){
            let me = this
            setInterval(async () => {
                for (const joyCon of connectedJoyCons.values()) {
                    if (joyCon.eventListenerAttached) {
                        continue;
                    }
                    joyCon.eventListenerAttached = true;
                    await joyCon.disableVibration();
                    joyCon.addEventListener('hidinput', (event) => {
                        me.updateBothControls(joyCon, event.detail);
                        // me.visualize(joyCon, event.detail);
                    });
                }
            }, 2000);
        }
    }
}
</script>
<style lang="less" scoped>
</style>
