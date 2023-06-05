<template>
    <div class="container">
        <div class="sub-container clearfix">
            <!--    <div>-->
            <!--        <input id="show-visualize" type="checkbox" checked="true" />-->
            <!--        <label for="show-visualize">Visualize Joycons</label>-->
            <!--        <input id="show-debug" type="checkbox" />-->
            <!--        <label for="show-debug">Show debug info</label>-->
            <!--    </div>-->
            <h1 class="container-title">Custom Hotkeys</h1>
            <div class="left-container">
                <h2 class="form-title center">Left Controller</h2>
                <form class="pure-form pure-form-aligned center">
                    <fieldset>
                        <div class="pure-control-group">
                            <label for="aligned-name">Up</label>
                            <select class="custom-select select" v-model="form.Up">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Down</label>
                            <select class="custom-select select" v-model="form.Down">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Left</label>
                            <select class="custom-select select" v-model="form.Left">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Right</label>
                            <select class="custom-select select" v-model="form.Right">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">L</label>
                            <select class="custom-select select" v-model="form.L">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">ZL</label>
                            <select class="custom-select select" v-model="form.ZL">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Vertical Move</label>
                            <select class="custom-select select" v-model="form.LVerticalMove">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
<!--                        <div class="pure-control-group">-->
<!--                            <label for="aligned-name">Orientation Beta</label>-->
<!--                            <select class="custom-select select" v-model="form.lOrientationBeta">-->
<!--                                <option v-for="item in leftOperations">{{item}}</option>-->
<!--                            </select>-->
<!--                        </div>-->
<!--                        <div class="pure-control-group">-->
<!--                            <label for="aligned-name">Orientation Gamma</label>-->
<!--                            <select class="custom-select select" v-model="form.lOrientationGamma">-->
<!--                                <option v-for="item in leftOperations">{{item}}</option>-->
<!--                            </select>-->
<!--                        </div>-->
<!--                        <div class="pure-control-group">-->
<!--                            <label for="aligned-name">Orientation Alpha</label>-->
<!--                            <select class="custom-select select" v-model="form.lOrientationBetaAlpha">-->
<!--                                <option v-for="item in leftOperations">{{item}}</option>-->
<!--                            </select>-->
<!--                        </div>-->
                    </fieldset>
                </form>
            </div>
            <figure class="joycon-view">
                <div id="joycon-l" class="joycon productId8198">
                    <div id="joystick-left" class="joystick"></div>
                    <div class="buttons">
                        <button id="up"></button>
                        <button id="left"></button>
                        <button id="down"></button>
                        <button id="right"></button>
                    </div>
                    <span id="minus"></span>
                    <i id="capture"></i>
                    <strong class="back-buttons" id="l"></strong>
                </div>
                <div id="joycon-r" class="joycon productId8199">
                    <div id="joystick-right" class="joystick"></div>
                    <div class="buttons">
                        <button id="x"></button>
                        <button id="y"></button>
                        <button id="b"></button>
                        <button id="a"></button>
                    </div>
                    <span id="plus"></span>
                    <i id="home"></i>
                    <strong class="back-buttons" id="r"></strong>
                </div>
            </figure>
            <div class="right-container">
                <h2 class="form-title center">Right Controller</h2>
                <form class="pure-form pure-form-aligned center">
                    <fieldset>

                        <div class="pure-control-group">
                            <label for="aligned-name">A</label>
                            <select class="custom-select select" v-model="form.A">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">B</label>
                            <select class="custom-select select" v-model="form.B">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">X</label>
                            <select class="custom-select select" v-model="form.X">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Y</label>
                            <select class="custom-select select" v-model="form.Y">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">R</label>
                            <select class="custom-select select" v-model="form.R">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">ZR</label>
                            <select class="custom-select select" v-model="form.ZR">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Home</label>
                            <select class="custom-select select" v-model="form.HomeButton">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Plus</label>
                            <select class="custom-select select" v-model="form.PlusButton">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">SR</label>
                            <select class="custom-select select" v-model="form.SRButton">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">SL</label>
                            <select class="custom-select select" v-model="form.slButton">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Stick Top</label>
                            <select class="custom-select select" v-model="form.LStickTop">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Stick Down</label>
                            <select class="custom-select select" v-model="form.LStickDown">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Stick Left</label>
                            <select class="custom-select select" v-model="form.LStickLeft">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Stick Right</label>
                            <select class="custom-select select" v-model="form.LStickRight">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>

                        <div class="pure-control-group">
                            <label for="aligned-name">Vertical Move</label>
                            <select class="custom-select select" v-model="form.RVerticalMove">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                    </fieldset>
                </form>
            </div>
            <button class="pure-button submit" @click="submit">Submit</button>
            <div id="debug">
                <div id="debug-left">
                    <pre></pre>
                    <p>Acceleration</p>
                    <meter id="acc-x" min="-1" max="1"></meter>
                    <meter id="acc-y" min="-1" max="1"></meter>
                    <meter id="acc-z" min="-1" max="1"></meter>
                    <br/>
                    <p>Gyroscope</p>
                    <meter id="gyr-x" min="-1" max="1"></meter>
                    <meter id="gyr-y" min="-1" max="1"></meter>
                    <meter id="gyr-z" min="-1" max="1"></meter>
                </div>

                <div id="debug-right">
                    <pre></pre>
                    <p>Acceleration</p>
                    <meter id="acc-x" min="-1" max="1"></meter>
                    <meter id="acc-y" min="-1" max="1"></meter>
                    <meter id="acc-z" min="-1" max="1"></meter>
                    <br/>
                    <p>Gyroscope</p>
                    <meter id="gyr-x" min="-1" max="1"></meter>
                    <meter id="gyr-y" min="-1" max="1"></meter>
                    <meter id="gyr-z" min="-1" max="1"></meter>
                </div>
            </div>
        </div>

    </div>
</template>

<script>
import {connectJoyCon, connectedJoyCons, JoyConLeft} from '../components/joycon';
import {noteOptions,leftOperations,defaultHotkeys} from '../components/hotkey';
export default {
    name: "start.vue",
    inject: ['clearAllRegisterEvents','addInputCBK','refreshRootConfig'],
    data(){
        return {
            noteOptions,
            leftOperations,
            form:{
                ...defaultHotkeys
            }
        }
    },
    unmounted() {
        let me = this;
        me.clearAllRegisterEvents()
    },
    mounted() {
        let me = this
        me.refreshConfig()
        // const debugLeft = document.querySelector('#debug-left');
        // const debugRight = document.querySelector('#debug-right');
        // const showVisualize = document.querySelector('#show-visualize');
        // const showDebug = document.querySelector('#show-debug');
        const rootStyle = document.querySelector('.sub-container').style;
        const visualize = (joyCon, packet) => {
            if (!packet || !packet.actualOrientation) {
                return;
            }

            const {
                actualAccelerometer: accelerometer,
                buttonStatus: buttons,
                actualGyroscope: gyroscope,
                actualOrientation: orientation,
                actualOrientationQuaternion: orientationQuaternion,
            } = packet;

            if (joyCon instanceof JoyConLeft) {
                rootStyle.setProperty('--left-alpha', `${orientation.alpha}deg`);
                rootStyle.setProperty('--left-beta', `${orientation.beta}deg`);
                rootStyle.setProperty('--left-gamma', `${orientation.gamma}deg`);
            } else {
                rootStyle.setProperty('--right-alpha', `${orientation.alpha}deg`);
                rootStyle.setProperty('--right-beta', `${orientation.beta}deg`);
                rootStyle.setProperty('--right-gamma', `${orientation.gamma}deg`);
            }

            if (joyCon instanceof JoyConLeft) {
                const joystick = packet.analogStickLeft;
                const joystickMultiplier = 10;
                document.querySelector('#joystick-left').style.transform = `translateX(${
                    joystick.horizontal * joystickMultiplier
                }px) translateY(${joystick.vertical * joystickMultiplier}px)`;

                document.querySelector('#up').classList.toggle('highlight', buttons.up);
                document
                    .querySelector('#down')
                    .classList.toggle('highlight', buttons.down);
                document
                    .querySelector('#left')
                    .classList.toggle('highlight', buttons.left);
                document
                    .querySelector('#right')
                    .classList.toggle('highlight', buttons.right);
                document
                    .querySelector('#capture')
                    .classList.toggle('highlight', buttons.capture);
                document
                    .querySelector('#l')
                    .classList.toggle('highlight', buttons.l || buttons.zl);
                document
                    .querySelector('#l')
                    .classList.toggle('highlight', buttons.l || buttons.zl);
                document
                    .querySelector('#minus')
                    .classList.toggle('highlight', buttons.minus);
                document
                    .querySelector('#joystick-left')
                    .classList.toggle('highlight', buttons.leftStick);
            } else {
                const joystick = packet.analogStickRight;
                const joystickMultiplier = 10;
                document.querySelector('#joystick-right').style.transform = `translateX(${
                    joystick.horizontal * joystickMultiplier
                }px) translateY(${joystick.vertical * joystickMultiplier}px)`;

                document.querySelector('#a').classList.toggle('highlight', buttons.a);
                document.querySelector('#b').classList.toggle('highlight', buttons.b);
                document.querySelector('#x').classList.toggle('highlight', buttons.x);
                document.querySelector('#y').classList.toggle('highlight', buttons.y);
                document
                    .querySelector('#home')
                    .classList.toggle('highlight', buttons.home);
                document
                    .querySelector('#r')
                    .classList.toggle('highlight', buttons.r || buttons.zr);
                document
                    .querySelector('#r')
                    .classList.toggle('highlight', buttons.r || buttons.zr);
                document
                    .querySelector('#plus')
                    .classList.toggle('highlight', buttons.plus);
                document
                    .querySelector('#joystick-right')
                    .classList.toggle('highlight', buttons.rightStick);
            }

            // if (showDebug.checked) {
            //     const controller = joyCon instanceof JoyConLeft ? debugLeft : debugRight;
            //     controller.querySelector('pre').textContent =
            //         JSON.stringify(orientation, null, 2) +
            //         '\n' +
            //         JSON.stringify(orientationQuaternion, null, 2) +
            //         '\n' +
            //         JSON.stringify(gyroscope, null, 2) +
            //         '\n' +
            //         JSON.stringify(accelerometer, null, 2) +
            //         '\n';
            //     const meterMultiplier = 300;
            //     controller.querySelector('#acc-x').value =
            //         accelerometer.x * meterMultiplier;
            //     controller.querySelector('#acc-y').value =
            //         accelerometer.y * meterMultiplier;
            //     controller.querySelector('#acc-z').value =
            //         accelerometer.z * meterMultiplier;
            //
            //     const gyroscopeMultiplier = 300;
            //     controller.querySelector('#gyr-x').value =
            //         gyroscope.rps.x * gyroscopeMultiplier;
            //     controller.querySelector('#gyr-y').value =
            //         gyroscope.rps.y * gyroscopeMultiplier;
            //     controller.querySelector('#gyr-z').value =
            //         gyroscope.rps.z * gyroscopeMultiplier;
            // }
        };
        me.addInputCBK(function(joyCon, detail) {
            visualize(joyCon, detail);
        })

        // showDebug.addEventListener('input', (e) => {
        //     document.querySelector('#debug').style.display = e.target.checked
        //         ? 'flex'
        //         : 'none';
        // });
    },
    methods:{
        refreshConfig(){
            let me = this
            me.form = me.$utils.readConfig()
        },
        submit(){
            let me = this
            me.$utils.save2Storage(me.form)
            me.$notify("Save Succeed");
            me.refreshRootConfig()
        }
    }
}


</script>

<style lang="less" scoped>
@import "./start/joycon.css";
.container {
    position: relative;
    /*top:20px;*/
    color-scheme: dark light;
    --left-alpha: 0deg;
    --left-beta: 0deg;
    --left-gamma: 0deg;
    --right-alpha: 0deg;
    --right-beta: 0deg;
    --right-gamma: 0deg;
    --left-joy-con-color: #00b2dc;
    --right-joy-con-color: #ff493e;
}
.sub-container{
    /*display: inline-block;*/
    width: 950px;
    padding: 30px;
    margin:30px auto;
    border:1px solid white;
}

.container ol {
    padding-inline-start: 22px;
}

.container{
    position: relative;
    padding: 20px;
    /*top:60px;*/
}
.container-title{
    text-align: center;
    margin-bottom: 30px;
}
input{
    border-color:#fff;
}
.center{
    text-align: center;
}
.custom-select{
    color: black;
}
.joycon-view{
    width: 250px;
    margin: 0 0 0 20px;
    height: auto;
}
.clearfix::after {
    content: "";
    clear: both;
    display: table;
}
.left-container,.joycon-view,.right-container{
    float: left;
}
.left-container{
    display: inline-block;
    .pure-form-aligned .pure-control-group label{
        width: 6em;
    }
    .select{
        width: 300px;
    }
}
.right-container{
    /*width: 270px;*/
    display: inline-block;
}
.select{
    width: 120px;
}
.txt-left{
    text-align: left;
}
.txt-right{
    text-align: right;
}
.right-container{
     .pure-form-aligned .pure-control-group label{
         width: 3em;
     }
 }

.submit{
    display: block;
    width: 90px;
    position: relative;
    left: 470px;
}
</style>
