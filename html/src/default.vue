<template>
    <div class="container">
        <img @click="home" v-if="'start'!==currentRouteName" class="arrow-back" src="./assets/home.svg" alt="home" />
        <img @click="connect" v-if="'start'!==currentRouteName" class="gamepad" src="./assets/gamepad.svg" alt="gamepad" />
<!--        <button @click="sendOSC({name:'Up'},'on','left')">control</button>-->
<!--        <button @click="sendOSC({name:'Down'},'off','left')">off</button>-->
        <notifications />
        <router-view class="view"/>
    </div>
</template>

<script>
import * as JoyCon from "./components/joycon/index.js";
import {connectedJoyCons,JoyConLeft} from "./components/joycon";
import {leftControls,rightControls} from "@/components/control"
import osc from "osc/dist/osc-browser.min.js";
import {readConfig} from "@/components/utils";
import {leftOperationsMap} from "@/components/hotkey";

window.oscPort = new osc.WebSocketPort({
    url: "ws://localhost:8081",
    metadata: true
});
oscPort.open()
oscPort.on("ready", function () {
    console.log('A Web Socket connection has been established')
});
let noteOn = 'on';
let noteOff = 'off';
let leftControl = 'left';
let rightControl = 'right';

export default {
    name: "default.vue",
    data(){
        return {
            inputCBKS:[],
            inputDetailCBKS:[],
            actionStatus:{
                RightShake:noteOff,
                LeftShake:noteOff,
            }
        }
    },
    mounted() {
        let me = this
        me.hotkeys = readConfig()
        me.watchStatus()
    },
    computed: {
        currentRouteName() {
            return this.$route.name;
        }
    },
    provide() {
        return {
            connect: this.connect,
            clearAllRegisterEvents:this.clearAllEventsOfSubComponents,
            addInputCBK:this.addInputCBK,
            addInputDetailCBK:this.addInputDetailCBK,
            refreshRootConfig:this.refreshRootConfig
        }
    },
    methods:{
        clearAllEventsOfSubComponents(){
            let me = this;
            me.inputCBKS = []
            me.inputDetailCBKS = []
        },
        refreshRootConfig(){
            let me = this
            me.hotkeys = readConfig()
        },
        getFrequency (note) {
            var notes = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#'],
                octave,
                keyNumber;

            if (note.length === 3) {
                octave = note.charAt(2);
            } else {
                octave = note.charAt(1);
            }

            keyNumber = notes.indexOf(note.slice(0, -1));

            if (keyNumber < 3) {
                keyNumber = keyNumber + 12 + ((octave - 1) * 12) + 1;
            } else {
                keyNumber = keyNumber + ((octave - 1) * 12) + 1;
            }

            // Return frequency of note
            return 440 * Math.pow(2, (keyNumber- 49) / 12);
        },
        control(joyCon, packet){
            let me = this
            if (!packet || !packet.actualOrientation) {
                return;
            }
            if (joyCon instanceof JoyConLeft) {
                for (const control of leftControls) {
                    me.updateControl(control, packet,'left');
                }
            } else {
                for (const control of rightControls) {
                    me.updateControl(control, packet,'right');
                }
            }
        },
        updateControl (control, packet, side)  {
            let me = this
            me.lastPacket = packet;
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
            // for action
            // for normal buttons
            // console.log(newValue);
            if (Math.abs(newValue - control.last_value) > control.threshold) {
                let status = !!newValue?noteOn:noteOff;
                if(control.name==='LVerticalMove'){
                    console.log('n',control.name,control.computePercent(newValue))
                }
                me.sendOSC(control,status,side,newValue,packet)
                me.inputDetailCBKS.forEach((func)=>{
                    // bind value to
                    func && func(control,status)
                })
                // console.log(control.name,newValue,control.last_value);
                control.last_value = newValue;
            }
        },
        isFreestyle(control){
            let me = this
            let note = me.hotkeys[name]
            if(control.name==='RVerticalMove' && note!==''){
                return true
            }
        },
        rightControlOSC(control, status,newValue,packet){
            let me = this
            let name = control.name
            let note = me.hotkeys[name]
            let frequency;
            if(me.isFreestyle(control)){
                frequency = control.computeFrequency(newValue,packet)
            }
            if(!note){
                // console.log("the note doesn't exist")
                return
            }
            if(!frequency){
                frequency = me.getFrequency(note)
            }
            let str = {
                instrument:'recorder',
                frequency:frequency,
                status,
                name:control.name
            }
            oscPort.send({
                address: "/message",
                args: [
                    {
                        type: "s",
                        value: JSON.stringify(str)
                    }
                ]
            });
            console.log("send OSC",name,status,frequency)
        },
        leftControlOSC(control,status,newValue){
            if(status===noteOff){
                return
            }
            let operationMap = {
                upAmplitude : {name:'upAmplitude',value:+0.1},
                downAmplitude : {name:'downAmplitude',value:-0.1},
                closeSound:{name:'closeFreestyle',value:0},
                upAttack : {name:'upAttack',value:+0.1},
                downAttack : {name:'downAttack',value:-0.1},
                upRelease : {name:'upRelease',value:+0.1},
                downRelease : {name:'downRelease',value:-0.1},
                upFrequency : {name:'upFrequency',value:+1},
                downFrequency : {name:'downFrequency',value:-1},
                upDepth : {name:'upDepth',value:+1},
                downDepth : {name:'downDepth',value:-1},
                upMix : {name:'upMix',value:+1},
                downMix : {name:'downMix',value:-1},
                upReverbTime : {name:'upMix',value:+0.1},
                downReverbTime : {name:'downReverbTime',value:-0.1},
                upPreDelay : {name:'upPreDelay',value:+0.1},
                downPreDelay : {name:'downPreDelay',value:-0.1},
                amplitude:{name:'amplitude',value:(v)=>{return control.computePercent(v)}}
            }
            let me = this
            let name = control.name
            let controlName = me.hotkeys[name]
            // find corresponding key & value
            let operation = ''
            let operationValue = ''
            for (const k in operationMap) {
                if(leftOperationsMap[k]===controlName){
                    operation=operationMap[k].name
                    let value = operationMap[k].value
                    if(typeof value === 'function'){
                        value = value(newValue)
                    }
                    operationValue = value
                }
            }
            if(!operation){
                return
            }
            let str = {
                instrument:'control',
                operation,
                value:operationValue,
                name:name
            }
            oscPort.send({
                address: "/message",
                args: [
                    {
                        type: "s",
                        value: JSON.stringify(str)
                    }
                ]
            });
        },
        sendOSC(control,status,side,newValue,packet){
            let me = this
            // get frequency
            // know the action of press
            // differ left or right controller
            // diff left and right
            // left => operations
            // right => notes
            if(side===leftControl){
                me.leftControlOSC(control,status,newValue)
            }
            if(side===rightControl){
                me.rightControlOSC(control,status,newValue,packet)
            }

            // oscPort.close()
        },
        async connect(){
            let me = this
            let r = await JoyCon.connectJoyCon();
            if(!!connectedJoyCons.size){
                me.$notify("Joy-Con connected");
            }
        },
        addInputCBK(func){
            let me = this;
            me.inputCBKS.push(func)
        },
        addInputDetailCBK(func){
            let me = this;
            me.inputDetailCBKS.push(func)
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
                        me.control(joyCon, event.detail)
                        // custom event
                        me.inputCBKS.forEach((func)=>{
                            func && func(joyCon, event.detail)
                        })
                        // me.updateBothControls(joyCon, event.detail);
                        // me.visualize(joyCon, event.detail);
                    });
                }
            }, 2000);
        },
      home(){
          let me = this
          me.$router.push("/")
      }
    }
}
</script>

<style scoped>
    body,html{
        background: #000;
        height: 100%;
    }
    .container{
        width: 100%;
        min-height: 100vh;
        font-family: "Source Code Pro", monospace;
        background: #000;
        color:#fff;
    }
    .arrow-back{
        width: 22px;
        position: absolute;
        top:10px;
        left:10px;
        fill: #FFFFFF;
        z-index:10;
        cursor: pointer;
    }
    .gamepad{
        width: 30px;
        position: absolute;
        top:10px;
        left:50px;
        fill: #FFFFFF;
        z-index:10;
        cursor: pointer;
    }
</style>
