package gme;

import cpp.NativeArray;
import cpp.NativeString;
import cpp.Pointer;
import haxe.io.BytesData;

@:buildXml('
<files id="haxe"><compilerflag value="-I${haxelib:hxgme}/project/gme-master/gme" /></files>
<target id="haxe"><lib name="${haxelib:hxgme}/project/gme.lib"/></target>
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
class HxGme {
	@:extern var emu:Dynamic;
	@:extern var buff:Dynamic;
	@:extern var handleError:Dynamic->Void;
	
	var bufferSample:Int;
	
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
			gme_remove();
			switch(type){
				case 0: emu = gme_new_emu(gme_ay_type, sample_rate);
					break;
				case 1: emu = gme_new_emu(gme_gbs_type, sample_rate);
					break;
				case 2: emu = gme_new_emu(gme_gym_type, sample_rate);
					break;
				case 3: emu = gme_new_emu(gme_hes_type, sample_rate);
					break;
				case 4: emu = gme_new_emu(gme_kss_type, sample_rate);
					break;
				case 5: emu = gme_new_emu(gme_nsf_type, sample_rate);
					break;
				case 6: emu = gme_new_emu(gme_nsfe_type, sample_rate);
					break;
				case 7: emu = gme_new_emu(gme_sap_type, sample_rate);
					break;
				case 8: emu = gme_new_emu(gme_spc_type, sample_rate);
					break;
				case 9: emu = gme_new_emu(gme_vgm_type, sample_rate);
					break;
				case 10: emu = gme_new_emu(gme_vgz_type, sample_rate);
					break;	
			}
			
			switch(sample_rate){
				case 22050: bufferSample = 2048;
					break;
				case 11025: bufferSample = 4096;
					break;
				default:  bufferSample = 8192;
					break;
			}
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
			int i, j, loop;
			float s1, s2;
			int n = 0, m = 0;
				
			switch(bufferSample){
				case 8192:
					loop = 1;
					break;
				case 4096:
					loop = 2;
					break;
				case 2048:
					loop = 4;
					break;
				default:
					handleError(\"Unsupported SampleBuff\");
					break;
			}
			
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