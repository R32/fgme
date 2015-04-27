package {	
	
	import cmodule.libgme.CLibInit;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class Gme extends EventDispatcher{
		
		private var _libgme:Object;
		
		private var _snd:Sound;
		
		private var _sndChannel:SoundChannel;
		public function get sndChannel():SoundChannel { return _sndChannel; }
		
		private var _sndTf:SoundTransform;
		
		private var _isPlaying:Boolean;
		public function get isPlaying():Boolean { return _isPlaying; }
		
		private var _isPausing:Boolean;
		public function get isPausing():Boolean { return _isPlaying; }
		
		private var _buffer:int;
		public function get buffer():int { return _buffer; }
		
		
		private var _sample_rate:int;
		public function get sample_rate():int { return _sample_rate; }
		
		private var _volume:Number;
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			if (value > 1.0) value = 1.0;
			if (value < 1.0) value = 0.0;
			
			_volume = value;
			
			_sndTf.volume = value;
			if(_sndChannel != null) {
				_sndChannel.soundTransform = _sndTf;
			}
		}
		
		public function get pan():Number { return _sndTf.pan; }
		public function set pan(value:Number):void {
			if (value > 1.0) value = 1.0;
			if (value < -1.0) value = -1.0; 
			
			_sndTf.pan = value;
			
			if(_sndChannel != null) {
				_sndChannel.soundTransform = _sndTf;
			}
		}
		
		private var _track:int;
		public function get track():int { return _track; }
		public function set track(n:int):void { 
			_track = n;
			_libgme.startTrack(n);
		}
		
		private var _trackCount:int;
		public function get trackCount():int { return _trackCount; }
		
		private var _gme_type:Dictionary;
		private var _type:String;
		public function get type():String { return _type; }
		
		public function Gme(smaple_rate:int = 44100):void {			
			
			_sample_rate = sample_rate;
			switch(smaple_rate){
				case 11025:
					_buffer = 2048;
					break;
				case 22050:
					_buffer = 4096;
					break;
				default:
					_buffer = 8192;
					if(_sample_rate != 44100) _sample_rate = 44100;
					break;
			}
			
			_isPlaying = false;
			_isPausing = false;
			_volume = 1.0;
			_track = 0;
			_trackCount = 0;
			
			_snd = new Sound();
			_sndTf = new SoundTransform();
			
			_gme_type = new Dictionary();
			var list:Array = ["ay", "gbs", "gym", "hes", "kss", "nsf", "nsfe", "sap", "spc", "vgm", "vgz"];
			for (var i:int  = 0; i < list.length; i+=1 ){
				_gme_type[list[i]] = i;
			}
			
			var loader:CLibInit = new CLibInit();
			_libgme = loader.init();
		}
		
		public function init(type:String):void {
			if (type in _gme_type) {
				_type = type;
				_libgme.typeInit(_gme_type[type]);
			}else{
				throw new Error("Unsupported: " + type);
			}
		}
		
		public function trackEnded():Boolean {
			return _libgme.trackEnded();
		}
		
		public function trackInfo():Object {
			return _libgme.trackInfo();
		}
		
		public function get tell():int {
			return _libgme.tell();
		}
		
	
		public function seek(msec:uint):void {
			_libgme.seek(msec);
		}
		
		/**
		* Set time to start fading track out.
		* Once fade ends trackEnded() returns true.
		* @param sec
		*/
		public function setFade(sec:int):void {
			_libgme.setFade(sec);
		}
		
		/**
		* Adjust stereo echo depth. 0.0 = off and 1.0 = maximum. 
		* no effect for GYM, SPC, and Sega Genesis VGM music.
		* @param depth
		*/
		public function stereoDepth(depth:Number):void {
			_libgme.stereoDepth(depth);
		}
		
		/**
		* load data direct.
		* @param data	data contains in ByteArray
		*/
		public function load(data:ByteArray):void{
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			
			// uncompress data if EmulatorType is VGZ.
			if (_type === "vgz") {
				data.writeBytes(data, 10, data.length - 10);
				data.inflate();
			}
			_libgme.load(data, data.length);
			//
			_trackCount =  _libgme.trackCount();
			_track = 0;
			// dispatch event to parent
			dispatchLoadCompleteEvent();
		}
		
		public function play():void{
			if(!_isPlaying){
				_snd.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				_sndChannel = _snd.play(0, 1, _sndTf);
				
				_isPlaying = true;
				_isPausing = false;
			}
		}
		
		public function stop():void {
			_snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			if (_sndChannel != null) {
				_sndChannel.stop();
			}
			_isPlaying = false;
			_isPausing = false;
			seek(0);
		}
		
		public function pause():void {
			if(_isPlaying){
				_snd.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				if (_sndChannel != null) {
					_sndChannel.stop();
				}
				_isPlaying = false;
				_isPausing = true;
			}
		}
		
		private function onSampleData(e:SampleDataEvent):void{		
			e.data.length = _buffer;
			e.data.endian = Endian.LITTLE_ENDIAN;
			//e.position = 0;
			_libgme.play(e.data);
		}
		
		private function dispatchLoadCompleteEvent():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}