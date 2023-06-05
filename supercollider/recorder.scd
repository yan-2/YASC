(

Server.killAll;
s.clear;
s.freeAll;
Pdef.all.stop;
Window.closeAll;

// flute synthDef

SynthDef(\waveguideFlute, {
	arg scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 20000, gate = 1, amp = 1, out = 0, atk = 0.1, rel = 0.2, vdep = 0.3, vfr = 5;
	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;
	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;
	ifqc = freq;
	kenv1 = EnvGen.kr(Env.new([ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' ), gate);
	kenv2 = EnvGen.kr(Env.new([ 0.0, 1.0, 1.0, 0.0 ], [ atk, dur - 0.02, rel ], 'linear' ), gate, doneAction: 2);
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1.0, 1.0, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear'), gate);
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar(vfr, 0, 0.1 * kenvibr * vdep );
	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;
	fdbckArray = LocalIn.ar( 1 );
	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );
	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );
	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );
	fdbckArray = [ aflute1 ];
	LocalOut.ar( fdbckArray );
	signalOut = avalue;
	OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ] * amp );
}).add;

// reverb synthDef

SynthDef(\reverb, {
	arg in, preDelay = 0.1, revTime = 0.3, revCut = 4500, revMix = 0.6, amp = 1, out = 0;
	var dry, wet, temp, sig;
	dry = In.ar(in, 2);
	temp = In.ar(in, 2);
	wet = 0;
	temp = DelayN.ar(temp, 0, 2, preDelay);
	16.do{
		temp = AllpassN.ar(temp, 0.03, {Rand(0.001, 0.05)}!2, revTime);
		temp = LPF.ar(temp, revCut);
		wet = wet + temp;
	};
	sig = XFade2.ar(dry, wet, 0.02 * revMix - 1, amp);
	Out.ar(out, sig);
}).add;

s.waitForBoot({

// reverb setup

~reverbBus = Bus.audio(s, 2);
~reverbSynth = Synth.new(\reverb, [\in, ~reverbBus]).register;

// retrieve the current IP and port

~on.free;
~control.free;
~freestyle.free;

n = NetAddr.new("127.0.0.1", 57120);

// default params for OSC control

~control_volume = 0.5;
~control_att = 0.1;
~control_release = 0.2;
~control_vibFre = 5;
~control_vibDep = 30;

// define osc

~synthDict = ();
~freestyleSynth=nil;
~freestyleSwitch= false;
~freq = 400;
~closeSound = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var name = msg[3];
	if( ~freestyleSwitch==false,{
	~freestyleSwitch = true;
	},{
	~freestyleSwitch = false;
	~freestyleSynth.free;
	~freestyleSynth=nil;
	})
}, '/freestyle/switch');
~freestyle = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var name = msg[3];
	var synth;
	var freq = msg[2];
		// ~freestyleSynthsss.isNil.postln;
		// ~freestyleSwitch.postln;
		// ~freestyleSynth.isNil.postln;
		if( (~freestyleSwitch==true),{
			if( (~freestyleSynth.isNil),{
			~freestyleSynth = Synth.new(\waveguideFlute,[
				// \ibreath,0.005,
			\freq, freq,
			\atk, ~control_att,
			\rel, ~control_release,
			\vdep, ~control_vibDep / 100,
			\vfr, ~control_vibFre,
			\amp, ~control_volume,
			\out, ~reverbBus
		]);
			// ~synthDict.put(name, synth);
		},{
			~freestyleSynth.set(\freq,freq)
		})
		});


}, '/play/freestyle');
~on = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var freq = msg[2];
	var name = msg[3];
		// name.postln;
	if( status == 'on',{
		var synthTest = ~synthDict.at(name);
		var synth;
		if(synthTest.notNil) {
			synthTest.free;
			~synthDict.removeAt(name);
		};
		synth = Synth.new(\waveguideFlute,[
			\freq, freq,
			\atk, ~control_att,
			\rel, ~control_release,
			\vdep, ~control_vibDep / 100,
			\vfr, ~control_vibFre,
			\amp, ~control_volume,
			\out, ~reverbBus
		]);
		~synthDict.put(name, synth);
	},{
		var synth = ~synthDict.at(name);
		if(synth.notNil) {
			synth.free;
			~synthDict.removeAt(name);
		};

	})
}, '/play/recorder');

~demo = OSCFunc({ |msg, time, addr, recvPort|
		Pdef(\demo, Pbind(
			\instrument, \waveguideFlute,
			// \dur, 4,
			\amp,1,
			\dur, Pseq([Pn(Pseq([ 3,3,3, 2,  2, 1, 2, 4/3,4/3,4/3, 2,  1,  2,  2,  1,  1,  3]), 2)]/6.5),
			\midinote, Pseq([Pn(Pseq([62, 57, 54, 59, 61, 60, 59, 57, 66, 69, 71, 67, 69, 66, 62, 64, 61]), 2)])
		)).play;
}, '/play/demo');

~control = OSCFunc({ |msg, time, addr, recvPort|
	var operation = msg[1];
	var value = msg[2];
		// operation.postln;

	defer {
	if((operation=='upAmplitude')||(operation=='downAmplitude'),{
		var temp = ~volumeSlider.value+value;
		~volumeSlider.value_(temp);
		~control_volume = temp;
	});
	if((operation=='amplitude'),{
		var temp = value;
				temp.postln;
		~volumeSlider.value_(temp);
		~control_volume = temp;
	});
	/*if((operation=='closeFreestyle'),{
		var temp = value;
		~volumeSlider.value_(temp);
		~control_volume = temp;
	});*/
	if((operation=='upAttack')||(operation=='downAttack'),{
		var temp = ~attAmpBox.value+value;
		~attAmpKnob.valueAction_(temp.explin(0.001, 10, 0, 1));
		~attAmpBox.value_(temp);
		~control_att = temp;
	});
	if((operation=='upRelease')||(operation=='downRelease'),{
		var temp = ~relAmpBox.value+value;
		~relAmpKnob.valueAction_(temp.linlin(0.001, 10, 0, 1));
		~relAmpBox.value_(temp);
		~control_release = temp;
	});
	if((operation=='upFrequency')||(operation=='downFrequency'),{
		var temp = ~vibFreBox.value+value;
		~vibFreKnob.valueAction_(temp.linlin(0.1, 6, 0, 1));
		~vibFreBox.value_(temp);
		~control_vibFre = temp;
	});
	if((operation=='upDepth')||(operation=='downDepth'),{
		var temp = ~vibDepBox.value+value;
		~vibDepKnob.valueAction_(temp.linlin(0, 100, 0, 1));
		~vibDepBox.value_(temp);
		~control_vibDep = temp;
	});
	if((operation=='upMix')||(operation=='downMix'),{
		var temp = ~revMixBox.value+value;
		~revMixKnob.valueAction_(temp.linlin(0, 100, 0, 1));
		~revMixBox.value_(temp);
	});
	if((operation=='upReverbTime')||(operation=='downReverbTime'),{
		var temp = ~revTimeBox.value+value;
		~revTimeKnob.valueAction_(temp.linlin(0.001, 10, 0, 1));
		~revTimeBox.value_(temp);
	});
	if((operation=='upPreDelay')||(operation=='downPreDelay'),{
		var temp = ~revPreBox.value+value;
		~revPreKnob.valueAction_(temp.linlin(0.001, 3, 0, 1));
		~revPreBox.value_(temp);
	});
	~synthDict.keysValuesDo.do {
		|key, value|
		key.set(
			\atk,~control_att,
			\rel, ~control_release,
			\vdep,~control_vibDep/100,
			\vfr,~control_vibFre,
			\amp,~control_volume,
		);

	};
	~freestyleSynth.set(
			\atk,~control_att,
			\rel, ~control_release,
			\vdep,~control_vibDep/100,
			\vfr,~control_vibFre,
			\amp,~control_volume,
		);
	};



}, '/control');

// creates the window for the GUI

l = Window.screenBounds.width;
h = Window.screenBounds.height;

w = Window("YASC", Rect(
	5 * l / 6,
	0,
	l / 6,
	h - 30 ));
w.front.alwaysOnTop_(true).asView.fixedSize_(Size.new(l / 6, h - 30));

v = UserView(w, Rect(0, 0, l/6, h));
v.background = Color.black;


// creates a composite view

p = 80;

~fluteLabel = StaticText(w, Rect(( l / 12 ) - 75, 10, 150, 60)).string_("YASC").align_(\center).stringColor_(Color.white).font_(Font("Roboto",50));

b = CompositeView(w, Rect(20, p, ( l / 6 ) - 40, h - p - 50));
v.drawFunc = {
	Pen.strokeColor_(Color.fromHexString("#E6E7F2").alpha_(0.5));
	Pen.width_(3);
	Pen.strokeRect(Rect(20, p, ( l / 6 ) - 40, h - p - 50));
	Pen.fillStroke;
};

~envLabel = StaticText(b, Rect(0, 20, ( l / 6 ) - 40, 20)).string_("AMPLITUDE ENVELOPE").align_(\center).stringColor_(Color.white).font_(Font("Roboto",13));

t = ( l / 6 ) - 40;

// creates the knob, the numerical box and the label for amplitude envelope attack

~attAmpKnob = Knob(b, Rect(( t / 2 ) - 57.5, 60, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1)).color_([Color.white, Color.cyan, Color.red, Color.black]);
~attAmpKnob.action_({
	arg obj;
	var atk = obj.value.linexp(0, 1, 0.001, 10);
	~control_att = obj.value;
	~attAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
});

~attAmpBox = NumberBox(b, Rect(( t / 2 ) - 22.5, 60, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~attAmpBox.action_({
	arg obj;
	~control_att = obj.value;
	~attAmpKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~attAmpLabel = StaticText(b, Rect(( t / 2 ) - 22.5, 40, 80, 20)).string_("Attack (s)").align_(\left).stringColor_(Color.white).font_(Font("Roboto",11));

// creates the knob, the numerical box and the label for amplitude envelope release

~relAmpKnob = Knob(b, Rect(( t / 2 ) - 57.5, 115, 30, 30)).value_(0.2.explin(0.001, 10, 0, 1)).color_([Color.white, Color.cyan, Color.red, Color.black]);
~relAmpKnob.action_({
	arg obj;
	var rel = obj.value.linexp(0, 1, 0.001, 10);
	~control_release = obj.value.linexp(0, 1, 0.001, 10);
	~relAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
});

~relAmpBox = NumberBox(b, Rect(( t / 2 ) - 22.5, 115, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.2);
~relAmpBox.action_({
	arg obj;
	~control_release = obj.value;
	~relAmpKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

	~relAmpLabel = StaticText(b, Rect(( t / 2 ) - 22.5, 95, 80, 20)).string_("Release (s)").align_(\left).stringColor_(Color.white).font_(Font("Roboto",11));

~vibLabel = StaticText(b, Rect(0, 165, ( l / 6 ) - 40, 20)).string_("VIBRATO CONTROLS").align_(\center).stringColor_(Color.white).font_(Font("Roboto",13));

// creates the knob, the numerical box and the label for vibrato frequency

~vibFreKnob = Knob(b, Rect(( t / 2 ) - 57.5, 205, 30, 30)).value_(5.linlin(0.1, 6, 0, 1)).color_([Color.white, Color.cyan, Color.red, Color.black]);
~vibFreKnob.action_({
	arg obj;
	var vfr = obj.value.linlin(0, 1, 0.1, 6);
	~control_vibFre = obj.value.linlin(0, 1, 0.1, 6);
	~vibFreBox.value_(obj.value.linlin(0, 1, 0.1, 6));
});

~vibFreBox = NumberBox(b, Rect(( t / 2 ) - 22.5, 205, 80, 30)).clipLo_(0.1).clipHi_(6).decimals_(1).value_(5);
~vibFreBox.action_({
	arg obj;
	~control_vibFre = obj.value;
	~vibFreKnob.valueAction_(obj.value.linlin(0.1, 6, 0, 1));
});

~vibFreLabel = StaticText(b, Rect(( t / 2 ) - 22.5, 185, 80, 20)).string_("Frequency (Hz)").align_(\left).stringColor_(Color.white).font_(Font("Roboto",11));

// creates the knob, the numerical box and the label for vibrato depth

~vibDepKnob = Knob(b, Rect(( t / 2 ) - 57.5, 260, 30, 30)).value_(30.linlin(0, 100, 0, 1)).color_([Color.white, Color.cyan, Color.red, Color.black]);
~vibDepKnob.action_({
	arg obj;
	var vdep = obj.value.linlin(0, 1, 0, 100);
	~control_vibDep = obj.value.linlin(0, 1, 0, 100);
	~vibDepBox.value_(obj.value.linlin(0, 1, 0, 100));
});

~vibDepBox = NumberBox(b, Rect(( t / 2 ) - 22.5, 260, 80, 30)).clipLo_(0).clipHi_(100).decimals_(0).value_(30);
~vibDepBox.action_({
	arg obj;
	~control_vibDep = obj.value;
	~vibDepKnob.valueAction_(obj.value.linlin(0, 100, 0, 1));
});

~vibDepLabel = StaticText(b, Rect(( t / 2 ) - 22.5, 240, 80, 20)).string_("Depth (%)").align_(\left).stringColor_(Color.white).font_(Font("Roboto",11));

// creates a composite view for the reverb controls

~revLabel = StaticText(b, Rect(0, 310, ( l / 6 ) - 40, 20)).string_("REVERB CONTROLS").align_(\center).stringColor_(Color.white).font_(Font("Roboto",13));

// creates the knob, the numerical box and the label for reverb mix

~revMixKnob = Knob(b, Rect(( t / 2 ) - 57.5, 350, 30, 30)).value_(60.linlin(0, 100, 0, 1)).color_([Color.white, Color.cyan, Color.red, Color.black]);
~revMixKnob.action_({
	arg obj;
	var revMix = obj.value.linlin(0, 1, 0, 100);
	~revMixBox.value_(obj.value.linlin(0, 1, 0, 100));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\revMix, revMix);
	};
});

~revMixBox = NumberBox(b, Rect(( t / 2 ) - 22.5, 350, 80, 30)).clipLo_(0).clipHi_(100).decimals_(0).value_(60);
~revMixBox.action_({
	arg obj;
	~revMixKnob.valueAction_(obj.value.linlin(0, 100, 0, 1));
});

~revMixLabel = StaticText(b, Rect(( t / 2 ) - 22.5, 330, 80, 20)).string_("Mix D/W (%)").align_(\left).stringColor_(Color.white).font_(Font("Roboto",11));

// creates the knob, the numerical box and the label for reverb time

~revTimeKnob = Knob(b, Rect(( t / 2 ) - 57.5, 405, 30, 30)).value_(0.3.explin(0.001, 10, 0, 1)).color_([Color.white, Color.cyan, Color.red, Color.black]);
~revTimeKnob.action_({
	arg obj;
	var revTime = obj.value.linexp(0, 1, 0.001, 10);
	~revTimeBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\revTime, revTime);
	};
});

~revTimeBox = NumberBox(b, Rect(( t / 2 ) - 22.5, 405, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.3);
~revTimeBox.action_({
	arg obj;
	~revTimeKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~revTimeLabel = StaticText(b, Rect(( t / 2 ) - 22.5, 385, 80, 20)).string_("Time (s)").align_(\left).stringColor_(Color.white).font_(Font("Roboto",11));

// creates the knob, the numerical box and the label for reverb pre-delay

~revPreKnob = Knob(b, Rect(( t / 2 ) - 57.5, 460, 30, 30)).value_(0.1.explin(0.001, 3, 0, 1)).color_([Color.white, Color.cyan, Color.red, Color.black]);
~revPreKnob.action_({
	arg obj;
	var preDelay = obj.value.linexp(0, 1, 0.001, 3);
	~revPreBox.value_(obj.value.linexp(0, 1, 0.001, 3));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\preDelay, preDelay);
	};
});

~revPreBox = NumberBox(b, Rect(( t / 2 ) - 22.5, 460, 80, 30)).clipLo_(0).clipHi_(3).decimals_(3).value_(0.1);
~revPreBox.action_({
	arg obj;
	~revPreKnob.valueAction_(obj.value.explin(0.001, 3, 0, 1));
});

~revPreLabel = StaticText(b, Rect(( t / 2 ) - 22.5, 440, 80, 20)).string_("Pre-Delay (s)").align_(\left).stringColor_(Color.white).font_(Font("Roboto",11));

// VOLUME

~volumeSlider = Slider.new(b, Rect(55, 523, 30, 183)).orientation_(\vertical).background_(Color.fromHexString("#E6E7F2")).focusColor_(Color.blue(alpha:0.5)).value_(0.5);

ServerMeterView.new(s, b, 100@500, 0, 2);

~volumeSlider.action_({
	arg obj;
	~control_volume= obj.value;
});
})

)