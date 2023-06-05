<template>
    <div class="container">
        <details class="controller instruction use-instruction">
            <summary>Use Instruction</summary>
            <ol class="detail">
                <li><button id="start" class="glow-on-hover" type="button">HOVER ME, THEN CLICK</button></li>
                <li>Select the entire screen and share the system audio</li>
                <li>No idea how to play? just play the demo below </li>
                <li><button class="pure-button submit" @click="mario">Mario play</button></li>
                <li><button class="pure-button submit" @click="freestyle">Freestyle mode</button></li>
            </ol>
        </details>
        <div id="showcase" class="col">
            <canvas></canvas>
            <div id="legend">
                <div class="key-item">
                    <div class="key-color pink"></div><div class="key-text">Root Mean Squared (RMS)</div>
                </div>
                <div class="key-item">
                    <div class="key-color yellow"></div><div class="key-text">Spectral Centroid</div>
                </div>
                <div class="key-item">
                    <div class="key-color blue"></div><div class="key-text">Spectral Rolloff</div>
                </div>
            </div>
            <div id="chroma"></div>
            <div id="mfcc"></div>
        </div>
        <hr>
    </div>
</template>

<script>
import {Audio,AudioGet,GetMeyda} from "./audio";
import {
    Scene,
    PerspectiveCamera,
    LineBasicMaterial,
    WebGLRenderer,
    DirectionalLight,
    Vector3,
    ArrowHelper,
    Group,
    BufferAttribute,
    BufferGeometry,
    Line,
} from "three";

export default {
    name: "stft.vue",
    mounted() {
        let me = this
        me.bindEvent()
    },
    methods:{
        freestyle(){
            let str = {
                instrument:'freestyle',
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
        mario(){
            let str = {
                instrument:'mario',
            }
            console.log('send mario')
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
        bindEvent(){
            let me = this
            let button = document.getElementById('start');
            button.onclick = ()=>{
                me.init()
            }
        },
        async init(){
            var scale = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"];
            const bufferSize = 1024;
            let a = await Audio(bufferSize);

            var aspectRatio = 16 / 10;
            var scene = new Scene();
            var camera = new PerspectiveCamera(40, aspectRatio, 0.1, 1000);

            var initializeFFTs = function(number, pointCount) {
                var ffts = [];
                for (var i = 0; i < number; i++) {
                    ffts.push(
                        // Array.apply(null, Array(pointCount)).map(Number.prototype.valueOf, 0)
                        Array(pointCount).fill(0)
                    );
                }

                return ffts;
            };

            var material = new LineBasicMaterial({
                color: 0x00ff00,
            });

            var yellowMaterial = new LineBasicMaterial({
                color: 0x00ffff,
            });

            var ffts = initializeFFTs(20, bufferSize);
            var buffer = null;

            var renderer = new WebGLRenderer({
                canvas: document.querySelector("canvas"),
            });

            function resize() {
                renderer.domElement.style.width = "100%";
                renderer.domElement.style.height = "auto";

                var resolution = (renderer.domElement.clientWidth / 16) * 10;
                renderer.setPixelRatio(window.devicePixelRatio ? window.devicePixelRatio : 1);

                renderer.setSize(resolution * aspectRatio, resolution);
                renderer.domElement.style.width = "100%";
                renderer.domElement.style.height = "auto";

                camera.aspect = (resolution * aspectRatio) / resolution;
                camera.updateProjectionMatrix();
            }

            resize();
            window.addEventListener("resize", resize);

            var directionalLight = new DirectionalLight(0xffffff, 0.5);
            directionalLight.position.set(0, 1, 1);
            scene.add(directionalLight);

            camera.position.z = 5;

            // Unchanging variables
            const length = 1;
            const hex = 0xffff00;
            const dir = new Vector3(0, 1, 0);
            const rightDir = new Vector3(1, 0, 0);
            const origin = new Vector3(1, -6, -15);

            // Variables we update
            let centroidArrow = new ArrowHelper(dir, origin, length, hex);
            let rolloffArrow = new ArrowHelper(dir, origin, length, 0x0000ff);
            let rmsArrow = new ArrowHelper(rightDir, origin, length, 0xff00ff);
            let lines = new Group(); // Lets create a seperate group for our lines
            // let loudnessLines = new Group();
            scene.add(centroidArrow);
            scene.add(rolloffArrow);
            scene.add(rmsArrow);
            // Render Spectrogram
            for (let i = 0; i < ffts.length; i++) {
                if (ffts[i]) {
                    let geometry = new BufferGeometry(); // May be a way to reuse this

                    let positions = new Float32Array(ffts[i].length * 3);

                    geometry.addAttribute("position", new BufferAttribute(positions, 3));
                    geometry.setDrawRange(0, ffts[i].length);

                    let line = new Line(geometry, material);
                    lines.add(line);

                    positions = line.geometry.attributes.position.array;
                }
            }

            let bufferLineGeometry = new BufferGeometry();
            let bufferLine = new Line(bufferLineGeometry, material);
            {
                let positions = new Float32Array(bufferSize * 3);
                bufferLineGeometry.addAttribute(
                    "position",
                    new BufferAttribute(positions, 3)
                );
                bufferLineGeometry.setDrawRange(0, bufferSize);

                positions = bufferLine.geometry.attributes.position.array;
            }
            scene.add(bufferLine);
            scene.add(lines);

            let features = undefined;
            let chromaWrapper = document.querySelector("#chroma");
            let mfccWrapper = document.querySelector("#mfcc");

            function render() {
                features = AudioGet([
                    "amplitudeSpectrum",
                    "spectralCentroid",
                    "spectralRolloff",
                    "loudness",
                    "rms",
                    "chroma",
                    "mfcc",
                ]);
                if (features) {
                    if (chromaWrapper && features.chroma) {
                        chromaWrapper.innerHTML = features.chroma.reduce(
                            (acc, v, i) =>
                                `${acc}
          <div class="chroma-band" style="background-color: rgba(0,${Math.round(
                                    255 * v
                                )},0,1)">${scale[i]}</div>`,
                            ""
                        );
                    }

                    if (mfccWrapper && features.mfcc) {
                        mfccWrapper.innerHTML = features.mfcc.reduce(
                            (acc, v, i) =>
                                `${acc}
          <div class="mfcc-band" style="background-color: rgba(0,${
                                    Math.round(v + 25) * 5
                                },0,1)">${i}</div>`,
                            ""
                        );
                    }

                    ffts.pop();
                    ffts.unshift(features.amplitudeSpectrum);
                    const windowedSignalBuffer = GetMeyda()._m.signal;

                    for (let i = 0; i < ffts.length; i++) {
                        // @ts-ignore
                        var positions = lines.children[i].geometry.attributes.position.array;
                        var index = 0;

                        for (var j = 0; j < ffts[i].length * 3; j++) {
                            positions[index++] = 10.7 + 8 * Math.log10(j / ffts[i].length);
                            positions[index++] = -5 + 0.1 * ffts[i][j];
                            positions[index++] = -15 - i;
                        }

                        // @ts-ignore
                        lines.children[i].geometry.attributes.position.needsUpdate = true;
                    }

                    // Render Spectral Centroid Arrow
                    if (features.spectralCentroid) {
                        // SpectralCentroid is an awesome variable name
                        // We're really just updating the x axis
                        centroidArrow.position.set(
                            10.7 + 8 * Math.log10(features.spectralCentroid / (bufferSize / 2)),
                            -6,
                            -15
                        );
                    }

                    // Render Spectral Rolloff Arrow
                    if (features.spectralRolloff) {
                        // We're really just updating the x axis
                        var rolloff = features.spectralRolloff / 22050;
                        rolloffArrow.position.set(10.7 + 8 * Math.log10(rolloff), -6, -15);
                    }
                    // Render RMS Arrow
                    if (features.rms) {
                        // We're really just updating the y axis
                        rmsArrow.position.set(-11, -5 + 10 * features.rms, -15);
                    }

                    if (windowedSignalBuffer) {
                        // Render Signal Buffer
                        let positions = bufferLine.geometry.attributes.position.array;
                        let index = 0;
                        for (var i = 0; i < bufferSize; i++) {
                            // @ts-ignore
                            positions[index++] = -11 + (22 * i) / bufferSize;
                            // @ts-ignore
                            positions[index++] = 4 + windowedSignalBuffer[i] * 5;
                            // @ts-ignore
                            positions[index++] = -25;
                        }
                        bufferLine.geometry.attributes.position.needsUpdate = true;
                    }
                }

                requestAnimationFrame(render);
                renderer.render(scene, camera);
            }

            render();
        }
    },
}
</script>

<style lang="less" scoped>

canvas {
    width: 100%;
    height: auto;
}

.key-item {
    font-size: small;
    text-align: center;
    display: inline-block;
    margin: 0 15px;
    vertical-align: middle;
}

.key-color {
    border: 1px solid;
    display: inline-block;
    width: 10px;
    height: 10px;
    margin: 0 5px 0 0;
    vertical-align: middle;
}

.key-text {
    display: inline-block;
    vertical-align: middle;
}

.key-color.pink {
    background-color: #ff00ff;
}

.key-color.yellow {
    background-color: #ffff00;
}

.key-color.blue {
    background-color: #0000ff;
}

div#legend {
    text-align: center;
    vertical-align: middle;
}

#showcase #chroma::before {
    content: 'Chroma bands:';
    margin-right: 10px;
    display: inline-block;
    text-align: center;
}

#showcase #chroma {
    margin-top: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
}

#showcase .chroma-band {
    flex: 0 1 28px;
    height: 28px;
    display: inline-block;
    text-align: center;
    padding-top: 7px;
    font-size: 10px;
    color: #ffffff;
}

#showcase #mfcc::before {
    content: 'MFCC bands:';
    margin-right: 10px;
    display: inline-block;
    text-align: center;
}

#showcase #mfcc {
    margin-top: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
}

#showcase .mfcc-band {
    flex: 0 1 28px;
    height: 28px;
    display: inline-block;
    text-align: center;
    padding-top: 7px;
    font-size: 10px;
    color: #ffffff;
}
img {
    max-width: 100%;
}

.glow-on-hover {
    text-align: center;
    width: 220px;
    height: 50px;
    border: none;
    outline: none;
    color: #fff;
    background: #111;
    cursor: pointer;
    position: relative;
    //left:50%;
    //margin-left: -110px;
    //margin-top: 20px;
    z-index: 0;
    border-radius: 10px;
}

.glow-on-hover:before {
    content: '';
    background: linear-gradient(45deg, #ff0000, #ff7300, #fffb00, #48ff00, #00ffd5, #002bff, #7a00ff, #ff00c8, #ff0000);
    position: absolute;
    top: -2px;
    left:-2px;
    background-size: 400%;
    z-index: -1;
    filter: blur(5px);
    width: calc(100% + 4px);
    height: calc(100% + 4px);
    animation: glowing 20s linear infinite;
    opacity: 0;
    transition: opacity .3s ease-in-out;
    border-radius: 10px;
}

.glow-on-hover:active {
    color: #000
}

.glow-on-hover:active:after {
    background: transparent;
}

.glow-on-hover:hover:before {
    opacity: 1;
}

.glow-on-hover:after {
    z-index: -1;
    content: '';
    position: absolute;
    width: 100%;
    height: 100%;
    background: #111;
    left: 0;
    top: 0;
    border-radius: 10px;
}

@keyframes glowing {
    0% { background-position: 0 0; }
    50% { background-position: 400% 0; }
    100% { background-position: 0 0; }
}

.container {
    background: black;
}
.use-instruction{
    top:10px;
}
.instruction {
    position: absolute;
    left:50%;
    transform:translate(-50%,0);
    cursor: pointer;
    font-size: 16px;
    text-align: center;
    ol {
        margin:0 auto;
        max-width: 80ch;
    }
    li {
        margin:15px auto;
        list-style-type: decimal;
    }
    .detail{
        margin-top:15px;
    }
}
</style>
