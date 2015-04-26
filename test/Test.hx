package;

import gme.SoundGme;
import sdl.Event;
import sdl.Sdl;
import gme.HxGme;
import haxe.Resource;
import sys.FileSystem;


class Test{
	
	static function start() {		
		var snd = new gme.SoundGme();
		
		Sdl.loop(function(){		
			
		});
	}
	
	public static function main() {
		Sdl.init();
		
		try{
			start();
		}catch(er:Dynamic){
			sdl.Sdl.message("ERROR",Std.string(er),true);		
		}
		
		Sdl.quit();
		Sys.println("DONE!");
	}
	
	public static inline var SAMPLEBUFF:Int = 8192;
}

@:enum abstract SampleRate(Int){
	var High = 44100;
	var Midd = 22050;
	var Low = 2048;
}
