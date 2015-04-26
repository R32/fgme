package gme;
import cpp.Float32;
import cpp.Pointer;

@:buildXml('
<copyFile name="SDL2.dll" from="${haxelib:hxsdl}/SDL2/lib/x86/" />
')
class SoundGme extends sdl.SoundChannel{
	
	public var gme:gme.HxGme;
	
	
	public function new() {
		gme = new gme.HxGme();
		gme.typeInit(5, SAMPLE_RATE);
		gme.load(haxe.Resource.getBytes("batman.nsf").getData());
		super(BUFFERSAMPLE);
	}
	
	override function onSample(stream:cpp.Pointer<cpp.Float32>, len:Int) {
		gme.play32(stream, len);
	}
	
	public inline static var SAMPLE_RATE:Int = 44100;
	public inline static var BUFFERSAMPLE:Int = 8192;
}