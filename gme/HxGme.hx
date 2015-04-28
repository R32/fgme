package gme;

import cpp.NativeArray;
import cpp.NativeString;
import cpp.Pointer;
import haxe.io.BytesData;

@:buildXml('
<files id="haxe"><compilerflag value="-I${haxelib:fgme}/project/gme-master/gme" /></files>
<target id="haxe"><lib name="${haxelib:fgme}/project/gme.lib"/></target>
')
@:headerCode("#include <gme.h>")
@:headerClassCode('
	Music_Emu* emu;
	short * buff;	
	void handleError(const char* str){
		if (str) {
			fprintf(stderr, "[game-music-emu Error]: %s", str);
			exit(EXIT_FAILURE);
		}
	}
')
@:cppFileCode('
	static gme_type_t gme_type_array[] = {
		gme_ay_type,
		gme_gbs_type,
		gme_gym_type,
		gme_hes_type,
		gme_kss_type,
		gme_nsf_type,
		gme_nsfe_type,
		gme_sap_type,
		gme_spc_type,
		gme_vgm_type,
		gme_vgz_type};
')
class HxGme {
	@:extern var emu:Dynamic;
	@:extern var buff:Dynamic;
	@:extern var handleError:Dynamic->Void;
	
	var bufferSample:Int;
	var s2fLoop:Int;
	@:void
	public function new() {
		untyped __cpp__("
			emu = NULL;
			buff = (short * ) malloc(sizeof(short) * 2 * 8192); // Fixed buff size
		");
	}
	
	@:void
	public function typeInit(type:Int, sample_rate:Int) {
		untyped __cpp__("			
			switch(sample_rate){
				case 22050:
					bufferSample = 4096;
					s2fLoop = 2;
					break;
				case 11025:
					bufferSample = 2048;
					s2fLoop = 4;
					break;
				default:
					bufferSample = 8192;
					s2fLoop = 1;
					if(sample_rate != 44100) sample_rate = 44100;
					break;
			}		
			
			gme_remove();
			
			emu = gme_new_emu(gme_type_array[type], sample_rate);
		");
	}
	
	@:void
	public function gme_remove(){
		untyped __cpp__("
			if (emu != NULL) {
				gme_delete(emu);
				emu = NULL;
			}
		");		
	}
	
	@:void
	public function setFade(start_msec:Int){
		untyped __cpp__("gme_set_fade(emu,start_msec);");
	}
	
	@:void
	public function load(byte:BytesData){
		_load(Pointer.arrayElem(byte, 0), byte.length);
	}
	
	@:void
	function _load(data:Pointer<#if cpp Unsigned_char__ #elseif neko neko.NativeString #end>,len:Int){
		untyped __cpp__('
			if (emu != NULL) {
				handleError(gme_load_data(emu, (void*)data, len));
				handleError(gme_start_track(emu, 0));
			}else{
				handleError("load: emu is null");
			}	
		
		');
	}
	
	@:void
	public function open_file(path:String){
		untyped __cpp__("
			if (emu != NULL) {
				handleError(gme_load_file(emu, path.__s));
				handleError(gme_start_track(emu, 0));
			}
		");
	}
	
	@:void
	public function play32(stream : cpp.Pointer<cpp.Float32>,len:Int){
		untyped __cpp__("	
			handleError(gme_play(emu, len, buff));
			// float stream
			// short buff
			int i, j, loop = s2fLoop;
			float s1, s2;
			int n = 0, m = 0;
			
			len >>= 1;
			
			for (i = 0; i < len; i+=1 ) {
				s1 = buff[n++] / 32768.0;
				s2 = buff[n++] / 32768.0;
				for (j = 0; j < loop; j+=1 ){
					stream[m++] = s1;
					stream[m++] = s2;
				}
			}
		");
	}
	
	public function trackCount():Int{
		return untyped __cpp__("gme_track_count(emu)");
	}
	
	public function trackEnded():Bool{
		return (untyped __cpp__("gme_track_ended(emu)"));
	}
}