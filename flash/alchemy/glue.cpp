#include "AS3.h"
#include "gme.h"

static int bufferSample = 8192;
static int s2fLoop = 1;
static Music_Emu* emu = NULL;

static short* buf = NULL;
static float* fbuf = NULL;

static AS3_Val gg_lib = NULL;
static AS3_Val no_params = NULL;
static AS3_Val zero_param = NULL;
static AS3_Val ByteArray_class = NULL;

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
	gme_vgz_type
};


static void ggInit(){
	no_params = AS3_Array("");
	zero_param = AS3_Int(0);
	AS3_Val flash_utils_namespace = AS3_String("flash.utils");
	ByteArray_class = AS3_NSGetS(flash_utils_namespace, "ByteArray");
	AS3_Release(flash_utils_namespace);
}

static void gg_reg(AS3_Val lib, const char *name, AS3_ThunkProc p) {
	AS3_Val fun = AS3_Function(NULL, p);
	AS3_SetS(lib, name, fun);
	AS3_Release(fun);
}

static void handleError(const char* str){
	if ( str ){
		//fprintf(stderr, "[game-music-emu Error]: %s", str);
		exit(EXIT_FAILURE);
	}
}

static void freeMusicEmu(){
	if (emu != NULL) {
		gme_delete(emu);
		emu = NULL;
	}
}

static AS3_Val flash_exit(void* self, AS3_Val args){
	freeMusicEmu();
	free(buf);
	free(fbuf);
	buf = NULL;
	fbuf = NULL;
	return AS3_Null();
}

static AS3_Val load(void* self, AS3_Val args){
	int len = 0;
	unsigned char *data = NULL;	
	AS3_Val byteArray = NULL;
	
	AS3_ArrayValue(args,"AS3ValType,IntType", &byteArray, &len);
	
	if(buf!=NULL && emu!=NULL){
		
		data = (unsigned char *)malloc(len);
		
		AS3_ByteArray_readBytes(data, byteArray, len);
		
		handleError( gme_load_data(emu, data, len) );
		
		handleError(gme_start_track(emu, 0));
		
		free(data);
	}
	return AS3_Null();
}

static AS3_Val startTrack(void* self, AS3_Val args){	
	int track = 0;
	
	AS3_ArrayValue(args, "IntType", &track);
				   
	handleError( gme_start_track(emu, track) );
	return AS3_Null();
}

static AS3_Val trackCount(void* self, AS3_Val args){	
	return AS3_Int( gme_track_count(emu) );
}

static AS3_Val trackEnded(void* self, AS3_Val args){	
	return AS3_Int(gme_track_ended(emu));
}

static AS3_Val trackInfo(void* self, AS3_Val args){
	int track = 0;
	AS3_ArrayValue(args, "IntType", &track);
	
	gme_info_t* info;
	if( gme_track_info(emu, &info, track) ){
		return AS3_Null();
	}else{
		AS3_Val ret = AS3_Object(
		"system:StrType,"
		"game:StrType,"
		"song:StrType,"
		"author:StrType,"
		"copyright:StrType,"
		"comment:StrType,"
		"dumper:StrType,"
		"length:IntType,"
		"intro_length:IntType,"
		"loop_length:IntType,"
		"play_length:IntType",
		
		info->system,
		info->game,
		info->song,
		info->author,
		info->copyright,
		info->comment,
		info->dumper,
		info->length,
		info->intro_length,
		info->loop_length,
		info->play_length);
		
		gme_free_info(info);		
		
		return ret;
	}
	
}

static AS3_Val tell(void* self, AS3_Val args){	
	return AS3_Int(gme_tell(emu));
}

static AS3_Val seek(void* self, AS3_Val args){
	int msec = 0;
	AS3_ArrayValue(args, "IntType", &msec);	
	handleError( gme_seek(emu, msec) );
	return AS3_Null();
}


static inline void write2float(short* byte,float *fbuf, int len ,int loop){
	int n = 0, m = 0;
	float s1 , s2;
	for(int i=0 ; i < len ; i += 1){// 16位读
		s1 = byte[n++]/32768.0f;
		s2 = byte[n++]/32768.0f;
		for(int j = 0; j < loop ; j += 1){// 32位写
			fbuf[m++] = s1;
			fbuf[m++] = s2;
		}
	}
} 

static AS3_Val play(void* self, AS3_Val args){
	AS3_Val byteArray = AS3_Undefined();

	AS3_ArrayValue(args, "AS3ValType", &byteArray);
	
	handleError( gme_play(emu, bufferSample << 1, buf) ); // NOTE: 注意这个变量值的变化
	
	write2float( buf , fbuf , bufferSample ,s2fLoop);
	//AS3_ByteArray_writeBytes(byteArray, (void*)buf , (bufferSample << 1) * sizeof(short) );//
	AS3_ByteArray_writeBytes(byteArray, (void*)fbuf , (bufferSample << 1) * sizeof(float) );
	
	return AS3_Null();
}

static AS3_Val setTempo(void* self, AS3_Val args){
	double tempo = 0;
	
	AS3_ArrayValue(args, "DoubleType", &tempo);			   
				   
	gme_set_tempo(emu, tempo);
	
	return AS3_Null();
}

static AS3_Val setFade(void* self, AS3_Val args){	
	int start_msec = 0;
	AS3_ArrayValue(args, "IntType", &start_msec);
	gme_set_fade(emu, start_msec);	
	return AS3_Null();
}

static AS3_Val stereoDepth(void* self, AS3_Val args){
	double depth = 0;
	
	AS3_ArrayValue(args, "DoubleType", &depth);
	
	gme_set_stereo_depth(emu, depth);
	
	return AS3_Null();
}

static AS3_Val typeInit(void* self, AS3_Val args){
	int sample_rate = 44100;
	int type = 5;
	AS3_ArrayValue(args, "IntType,IntType", &sample_rate, &type);
	
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
	
	freeMusicEmu();
	
	emu = gme_new_emu(gme_type_array[type] ,sample_rate);
	
	return AS3_Null();
}



int main(int argc, char* argv[]){
	
	buf= (short *)malloc(sizeof(short) * 2 * 8192);
	fbuf= (float *)malloc(sizeof(float) * 2 * 8192);
	
	ggInit();	
	gg_lib = AS3_Object("");	
	gg_reg(gg_lib, "load", load);
	gg_reg(gg_lib, "typeInit", typeInit);
	gg_reg(gg_lib, "play", play);
	gg_reg(gg_lib, "flash_exit", flash_exit);
	gg_reg(gg_lib, "tell", tell);
	gg_reg(gg_lib, "seek", seek);
	gg_reg(gg_lib, "setTempo", setTempo);
	gg_reg(gg_lib, "setFade", setFade);
	gg_reg(gg_lib, "stereoDepth", stereoDepth);
	gg_reg(gg_lib, "trackInfo", trackInfo);
	gg_reg(gg_lib, "startTrack", startTrack);
	gg_reg(gg_lib, "trackCount", trackCount);
	gg_reg(gg_lib, "trackEnded", trackEnded);
	// notify that we initialized -- THIS DOES NOT RETURN!
	AS3_LibInit(gg_lib);	
	return 0;
}
