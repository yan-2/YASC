// flute synth

(

SynthDef("waveguideFlute", {
	arg scl = 0.2, freq = 440, bend = 0, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 20000, gate = 1, amp = 2, out = 0, atk = 0.1, rel = 0.2, vdep = 0.3, vfr = 5;
	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;
	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;
	ifqc = freq * bend.midiratio;
	kenv1 = EnvGen.kr(Env.new([ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' ), gate);
	kenv2 = EnvGen.kr(Env.new([ 0.0, 1.0, 1.0, 0.0 ], [ atk, dur - 0.02, rel ], 'linear' ), gate, doneAction: 2);
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 0.3, 0.3, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear'), gate);
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( vfr, 0, 0.1 * kenvibr );
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
	OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ] );
}).add;

)

// reverb synth

(

SynthDef(\reverb, {
	arg in, preDelay = 0.1, revTime = 0.3, revCut = 4500, revMix = 0.6, amp = 1, out = 0;
	var dry, wet, temp, sig, env;
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

)

// reverb synth and bus creation

~reverbBus = Bus.audio(s, 2);
~reverbSynth = Synth.new(\reverb, [\in, ~reverbBus]);
~reverbSynth.register;

// MIDI polyphonic synthesizer

(

MIDIClient.init;
MIDIIn.connectAll;

~liftednotes = Array.newClear(128);
~bend = 8192;

MIDIdef.noteOn(\noteOn, {
	arg velocity, noteNumber, channel, source;
	~notes[noteNumber] = Synth.new(
		"waveguideFlute",
		[   \freq, noteNumber.midicps,
			\amp, 2 * velocity.linexp(1, 127, 0.01, 0.3),
			\atk, ~attAmpKnob.value.linexp(0, 1, 0.001, 10),
			\rel, ~relAmpKnob.value.linexp(0, 1, 0.001, 10),
			\vfr, ~vibFreKnob.value.linlin(0, 1, 0.1, 6),
			\vdep, ~vibDepKnob.value.linlin(0, 1, 0, 100),
			\gate, 1,
			\bend, ~bend.linlin(0, 16383, -1, 1),
			\out, ~reverbBus
		]);
	~notes[noteNumber].register;
});

MIDIdef.noteOff(\noteOff, {
	arg velocity, noteNumber, channel, source;
	~notes[noteNumber].set(\gate, 0);
	~notes[noteNumber] = nil;
		});

MIDIdef.bend(\bendWheel, {
	arg value, channel, source;
	~bend = value;
	~notes.do{
		arg synth;
		synth.set(\bend, value.linlin(0, 16383, -1, 1))};
	}, chan: 0);

)

// GUI

(

Window.closeAll;

// creates the window for the GUI

w = Window("BeatFlute", Rect(
	( Window.screenBounds.width - 550 ) / 2,
	( Window.screenBounds.height - 190 ) / 2,
	550,
	190));
w.front.alwaysOnTop_(true).asView.fixedSize_(Size.new(550, 190));
w.onClose_({
	s.freeAll;
});

// creates a composite view for the amplitude envelope controls and the relative label

b = CompositeView(w, Rect(10, 10, 260, 80)).background_(Color.new255(120, 120, 120, 210));

~envLabel = StaticText(b, Rect(0, 0, 260, 20)).string_("AMPLITUDE ENVELOPE").align_(\center).stringColor_(Color.white);

// creates the knob, the numerical box and the label for amplitude envelope attack

~attAmpKnob = Knob(b, Rect(10, 40, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~attAmpKnob.action_({
	arg obj;
	var atk = obj.value.linexp(0, 1, 0.001, 10);
	~attAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};
});

~attAmpBox = NumberBox(b, Rect(45, 40, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~attAmpBox.action_({
	arg obj;
	~attAmpKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~attAmpLabel = StaticText(b, Rect(45, 20, 80, 20)).string_("Attack (s)").align_(\left).stringColor_(Color.white);

// creates the knob, the numerical box and the label for amplitude envelope release

~relAmpKnob = Knob(b, Rect(135, 40, 30, 30)).value_(0.2.explin(0.001, 10, 0, 1));
~relAmpKnob.action_({
	arg obj;
	var rel = obj.value.linexp(0, 1, 0.001, 10);
	~relAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\rel, rel);
		};
	};
});

~relAmpBox = NumberBox(b, Rect(170, 40, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.2);
~relAmpBox.action_({
	arg obj;
	~relAmpKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~relAmpLabel = StaticText(b, Rect(170, 20, 80, 20)).string_("Release (s)").align_(\left).stringColor_(Color.white);

// creates a composite view for the vibrato depth control and the relative label

c = CompositeView(w, Rect(280, 10, 260, 80)).background_(Color.new255(120, 120, 120, 210));

~envLabel = StaticText(c, Rect(0, 0, 260, 20)).string_("VIBRATO CONTROLS").align_(\center).stringColor_(Color.white);

// creates the knob, the numerical box and the label for vibrato frequency

~vibFreKnob = Knob(c, Rect(10, 40, 30, 30)).value_(5.linlin(0.1, 6, 0, 1));
~vibFreKnob.action_({
	arg obj;
	var vfr = obj.value.linlin(0, 1, 0.1, 6);
	~vibFreBox.value_(obj.value.linlin(0, 1, 0.1, 6));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\vfr, vfr);
		};
	};
});

~vibFreBox = NumberBox(c, Rect(45, 40, 80, 30)).clipLo_(0.1).clipHi_(6).decimals_(1).value_(5);
~vibFreBox.action_({
	arg obj;
	~vibFreKnob.valueAction_(obj.value.linlin(0.1, 6, 0, 1));
});

~vibFreLabel = StaticText(c, Rect(45, 20, 80, 20)).string_("Frequency (Hz)").align_(\left).stringColor_(Color.white);

// creates the knob, the numerical box and the label for vibrato depth

~vibDepKnob = Knob(c, Rect(135, 40, 30, 30)).value_(30.linlin(0, 100, 0, 1));
~vibDepKnob.action_({
	arg obj;
	var vdep = obj.value.linlin(0, 1, 0, 100);
	~vibDepBox.value_(obj.value.linlin(0, 1, 0, 100));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\vdep, vdep);
		};
	};
});

~vibDepBox = NumberBox(c, Rect(170, 40, 80, 30)).clipLo_(0).clipHi_(100).decimals_(0).value_(30);
~vibDepBox.action_({
	arg obj;
	~vibDepKnob.valueAction_(obj.value.linlin(0, 100, 0, 1));
});

~vibDepLabel = StaticText(c, Rect(170, 20, 80, 20)).string_("Depth (%)").align_(\left).stringColor_(Color.white);

// creates a composite view for the reverb controls

d = CompositeView(w, Rect(80, 100, 385, 80)).background_(Color.new255(120, 120, 120, 210));

~revLabel = StaticText(d, Rect(0, 0, 385, 20)).string_("REVERB CONTROLS").align_(\center).stringColor_(Color.white);

// creates the knob, the numerical box and the label for reverb mix

~revMixKnob = Knob(d, Rect(10, 40, 30, 30)).value_(60.linlin(0, 100, 0, 1));
~revMixKnob.action_({
	arg obj;
	var revMix = obj.value.linlin(0, 1, 0, 100);
	~revMixBox.value_(obj.value.linlin(0, 1, 0, 100));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\revMix, revMix);
	};
});

~revMixBox = NumberBox(d, Rect(45, 40, 80, 30)).clipLo_(0).clipHi_(100).decimals_(0).value_(60);
~revMixBox.action_({
	arg obj;
	~revMixKnob.valueAction_(obj.value.linlin(0, 100, 0, 1));
});

~revMixLabel = StaticText(d, Rect(45, 20, 80, 20)).string_("Mix D/W (%)").align_(\left).stringColor_(Color.white);

// creates the knob, the numerical box and the label for reverb time

~revTimeKnob = Knob(d, Rect(135, 40, 30, 30)).value_(0.3.explin(0.001, 10, 0, 1));
~revTimeKnob.action_({
	arg obj;
	var revTime = obj.value.linexp(0, 1, 0.001, 10);
	~revTimeBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\revTime, revTime);
	};
});

~revTimeBox = NumberBox(d, Rect(170, 40, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.3);
~revTimeBox.action_({
	arg obj;
	~revTimeKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~revTimeLabel = StaticText(d, Rect(170, 20, 80, 20)).string_("Time (s)").align_(\left).stringColor_(Color.white);

// creates the knob, the numerical box and the label for reverb pre-delay

~revPreKnob = Knob(d, Rect(260, 40, 30, 30)).value_(0.1.explin(0.001, 3, 0, 1));
~revPreKnob.action_({
	arg obj;
	var preDelay = obj.value.linexp(0, 1, 0.001, 3);
	~revPreBox.value_(obj.value.linexp(0, 1, 0.001, 3));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\preDelay, preDelay);
	};
});

~revPreBox = NumberBox(d, Rect(295, 40, 80, 30)).clipLo_(0).clipHi_(3).decimals_(3).value_(0.1);
~revPreBox.action_({
	arg obj;
	~revPreKnob.valueAction_(obj.value.explin(0.001, 3, 0, 1));
});

~revPreLabel = StaticText(d, Rect(295, 20, 80, 20)).string_("Pre-Delay (s)").align_(\left).stringColor_(Color.white);

)