package;

import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.Memory;

class Gme {

	public var isPlaying(default, null) : Bool;

	public var isPausing(default, null) : Bool;

	public var track(default, set) : Int;

	var snd : Sound;

	var channel : SoundChannel;

	var transform : SoundTransform;

	var type : GmeType;

	var samplePtr : Int;

	public function new() {
		snd = new Sound();
		samplePtr = 0;
		transform = new SoundTransform();
	}

	public function load( file : ByteArray, type : GmeType = NSF) : Bool {
		@:bypassAccessor this.track = 0;
		this.type = type;
		if (cgme.typeInit(this.type)) {
			file.endian = Endian.LITTLE_ENDIAN;
			file.position = 0;
			samplePtr = cgme.load(file, file.length);
		}
		return samplePtr != 0;
	}

	public function play() {
		if (isPlaying || samplePtr == 0)
			return;
		snd.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		channel = snd.play(0, 1, transform);
		isPlaying = true;
		isPausing = false;
	}

	public function stop() {
		snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		if (channel != null) {
			channel.stop();
			channel = null;
		}
		isPlaying = false;
		isPausing = false;
		cgme.seek(0);
	}

	public function pause() {
		if (!isPlaying)
			return;
		snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		if (channel != null) {
			channel.stop();
			channel = null;
		}
		isPlaying = false;
		isPausing = true;
	}

	public inline function trackEnded() return cgme.trackEnded();

	public inline function trackCount() return cgme.trackCount();

	public inline function trackInfo() return cgme.trackInfo(this.track);

	public inline function tell() return cgme.tell();

	public inline function seek( msec : Int) cgme.seek(msec);

	public inline function fade( sec : Int ) cgme.setFade(sec);

	public inline function release() cgme.release();

	static inline var BYTESPERSEC = 8192;

	@:deprecated function onSampleDataSlow( e : SampleDataEvent ) {
		var data = e.data;
		data.length = (BYTESPERSEC * 4);
		data.endian = Endian.LITTLE_ENDIAN;
		cgme.play(data);
	}

	function onSampleData( e : SampleDataEvent ) {
		var data = e.data;
		data.length = (BYTESPERSEC * 4);   // sizeof(float)
		data.endian = Endian.LITTLE_ENDIAN;
		cgme.playInner();                  // fill buffer in samplePtr
		var ptr = this.samplePtr;
		var max = ptr + (BYTESPERSEC * 2); // sizeof(short)
		while (ptr < max) {
			data.writeFloat(Memory.signExtend16(Memory.getUI16(ptr)) / 32768.);
			ptr += 2;
		}
	}

	function set_track( t : Int ) : Int {
		this.track = t;
		cgme.startTrack(t);
		return t;
	}

	static var cgme : Null<CGme>;
}

typedef CGme = {

	/**
	 Returns a pointer to the short buffer.
	*/
	function load( data : ByteArray, size : Int ) : Int;

	function typeInit( type : GmeType ) : Bool;

	function play( pcm : ByteArray ) : Void;

	function playInner() : Void;

	function tell() : Int;

	function seek( microsec : Int ) : Bool;

	function startTrack( track : Int ) : Bool;

	function trackCount() : Int;

	function trackEnded() : Bool;

	function trackInfo( track : Int ) : TrackInfo;

	/**
	 Set time to start fading track out.
	 Once fade ends trackEnded() returns true.
	*/
	function setFade( sec : Int ) : Void;

	/**
	 Adjust stereo echo depth. 0.0 = off and 1.0 = maximum.
	 no effect for GYM, SPC, and Sega Genesis VGM music.
	*/
	function stereoDepth( sec : Float ) : Void;

	function release() : Void;
}

typedef TrackInfo = {
	system       : String,
	game         : String,
	song         : String,
	author       : String,
	copyright    : String,
	comment      : String,
	dumper       : String,
	length       : Int,
	intro_length : Int,
	loop_length  : Int,
	play_length  : Int,
}

enum abstract GmeType(Int) {
	var AY = 0;
	var GBS;
	var GYM;
	var HES;
	var KSS;
	var NSF;
	var NSFE;
	var SAP;
	var SPC;
	var VGM;
	var VGZ;
}
