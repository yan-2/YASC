# YASC
The goal of the project is to to develop an interactive recorder performance tool, incorporating
Joy-Con controllers via a web interface for gesture-based inputs and SuperCollider for sound
synthesis.
<div>
<img style="width: 500px" src="./readme-image/YASC.png">
<div>

## Video Introduction
https://youtu.be/O9uG8ymz72E

## Requirements
+ Node.js>=v16
+ SuperCollider software
+ Latest Edge (fully tested)

## Dependency Installation

```bash
cd /server
npm install
```
## Connect Joy-Con controllers
Connect your Joy-Con controllers to PC via Bluetooth: click the button below until your PC detects and connects them.
<div>
<img width="250px" src="./readme-image/bluetooth.png">
<div>

## Introduction of Joy-Con controllers
Joy-Con controllers consist of two individual units, each containing an analog stick, an array of buttons, a gyroscope and motion sensors (accelerometers). In this project, the left controller is used to control synthesis parameters and the right one is responsible for playing notes.
<div>
<img width="300px" src="./readme-image/joy-con-map.png">
<div>

## Run the website and SuperCollider
1. Run server first.
```bash
node /server/index.js
```
2. Open the address shown in console. http://127.0.0.1:8081/
3. Open the files in /supercollider in SuperCollider and run the relative code.
4. Follow the instructions on website and enjoy.

## Overall Structure
The system tracks interaction with Joy-Con controllers and use their serial messages as input. The web system acts as the central interface, providing
users with an intuitive and interactive tool to set up and customize their performance experience. SuperCollider serves as sound synthesis engine: it generates the sound according to the commands sent from web system via Open Sound Control (OSC) protocol. Finally, the audio output can be captured by web system to provide a visual feedback.      
<div>
<img width="600px" src="./readme-image/overall.png">
<div>

## Website Introduction
+ Welcome to our home page! On this page, you'll find three links to different functions.
+ <b>Clicking on the logo</b> allows you to connect your controllers to the web system.
+ You can also connect via <b>game-pad icon</b> on the top-left of the page.
<div>
<img width="500px" src="./readme-image/home.png">
<div>

+ Hotkey page: an interface to personalize your recorder experience. Through this page, <b>Joy-Con controller buttons can be mapped to different functions</b>.
+ The left controller is responsible for adjusting synthesis parameters in SuperCollider while the right controller is dedicated to play notes. 
+ Additionally, each motion of the Joy-Con controller can be captured and shown in the middle of the page: in this way, you can visually test the working condition of your devices. 
<div>
<img width="500px" src="./readme-image/hotkey3.png">
<div>

+ Dino game page: an interactive training tool designed to <b>help you familiarize with custom hotkeys</b>: the jumping action is triggered by the correct Joy-Con button (previously mapped in Hotkey Page). 
+ As the game progresses, the speed increases to raise the challenge level.
<div>
<img width="500px" src="./readme-image/dino-instruction.png">
<div>

<div>
<img width="500px" src="./readme-image/dino-2.png">
<div>

+ Performance page: an immersive audio-visual experience tool which <b>represents the output sound spectrum</b>.
+ Following the instructions, <b>click the button and share the entire screen and system audio</b>.
+ Additionally, a short Mario audio audio sample is prepared for beginners to follow.
<div>
<img width="500px" src="./readme-image/stft-instruction.png">
<div>
<div>
<img width="500px" src="./readme-image/stft.png">
<div>
<div>
<img width="500px" src="./readme-image/actual-playing.png">
<div>

## SuperCollider introduction
+ The recorder sound is generated by SuperCollider. Here's the simple GUI where you can edit some synthesis parameters and see the changes performed through Joy-Con controllers. 
<div>
<img width="120px" src="./readme-image/gui.png">
<div>

## To do
+ Recorder sound improvement at high frequency.
+ Hint of keys and actions in Dino game.
+ Customize note options.
