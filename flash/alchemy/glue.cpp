#include "AS3.h"
#include "gme.h"

#define PERSAMPLE (8192)
#define FREQUENCY (44100)

static Music_Emu* emu = NULL;
static short* i16buf = NULL;
static float* f32buf = NULL;
static AS3_Val gg_lib = NULL;

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

static void ggInit() {
}

static void gg_reg(AS3_Val lib, const char *name, AS3_ThunkProc p) {
	AS3_Val fun = AS3_Function(NULL, p);
	AS3_SetS(lib, name, fun);
	AS3_Release(fun);
}

// typedef const char* gme_err_t;
/* Error string returned by library functions, or NULL if no error (success) */
#define SUCCESS(r)   (!(r))
#define FAILED(r)      (r)

static AS3_Val release(void* self, AS3_Val args) {
	if (emu) {
		gme_delete(emu);
		emu = NULL;
	}
	if (i16buf) {
		free(i16buf);
		free(f32buf);
		i16buf = NULL;
		f32buf = NULL;
	}
	return AS3_Null();
}

static AS3_Val load(void* self, AS3_Val args) {
	int len = 0;
	unsigned char *data = NULL;
	AS3_Val byteArray = AS3_Undefined();

	AS3_ArrayValue(args,"AS3ValType,IntType", &byteArray, &len);

	if (!emu)
		emu = gme_new_emu(gme_nsf_type , FREQUENCY);

	if (!emu)
		return AS3_Ptr(NULL);

	if (!i16buf) {
		i16buf = (short*)malloc(sizeof(short) * PERSAMPLE);
		f32buf = (float*)malloc(sizeof(float) * PERSAMPLE);
	}

	data = (unsigned char *)malloc(len);

	AS3_ByteArray_readBytes(data, byteArray, len);

	gme_err_t hr = gme_load_data(emu, data, len);

	if (SUCCESS(hr))
		hr = gme_start_track(emu, 0);

	if (FAILED(hr)) {
		free(i16buf);
		free(f32buf);
		i16buf = NULL;
		f32buf = NULL;
	}
	free(data);
	return AS3_Ptr(i16buf);
}

static AS3_Val startTrack(void* self, AS3_Val args){
	int track = 0;
	AS3_ArrayValue(args, "IntType", &track);
	return SUCCESS(gme_start_track(emu, track)) ? AS3_True() : AS3_False();
}

static AS3_Val trackCount(void* self, AS3_Val args){
	return AS3_Int(gme_track_count(emu));
}

static AS3_Val trackEnded(void* self, AS3_Val args){
	return AS3_Int(gme_track_ended(emu));
}

static AS3_Val trackInfo(void* self, AS3_Val args){
	int track = 0;
	AS3_ArrayValue(args, "IntType", &track);

	gme_info_t* info;
	if(gme_track_info(emu, &info, track)) {
		return AS3_Null();
	} else {
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
			info->play_length
		);
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
	return SUCCESS(gme_seek(emu, msec)) ? AS3_True() : AS3_False();
}

// deprecated
static AS3_Val play(void* self, AS3_Val args) {
	AS3_Val byteArray = AS3_Undefined();
	AS3_ArrayValue(args, "AS3ValType", &byteArray);
	if (FAILED(gme_play(emu, PERSAMPLE, i16buf)))
		return AS3_Null();
	int i = 0;
	while(i < PERSAMPLE) {
		f32buf[i] = i16buf[i] / 32768.0f; // Math.pow(2, 15);
		i++;
	}
	AS3_ByteArray_writeBytes(byteArray, (void*)f32buf , (sizeof(float) * PERSAMPLE));
	return AS3_Null();
}

static AS3_Val playInner(void* self, AS3_Val args) {
	gme_play(emu, PERSAMPLE, i16buf);
	return AS3_Null();
}

static AS3_Val setTempo(void* self, AS3_Val args) {
	double tempo = 0;
	AS3_ArrayValue(args, "DoubleType", &tempo);
	gme_set_tempo(emu, tempo);
	return AS3_Null();
}

static AS3_Val setFade(void* self, AS3_Val args) {
	int start_msec = 0;
	AS3_ArrayValue(args, "IntType", &start_msec);
	gme_set_fade(emu, start_msec);
	return AS3_Null();
}

static AS3_Val stereoDepth(void* self, AS3_Val args) {
	double depth = 0;
	AS3_ArrayValue(args, "DoubleType", &depth);
	gme_set_stereo_depth(emu, depth);
	return AS3_Null();
}

static AS3_Val typeInit(void* self, AS3_Val args) {
	int type = 5; // NSF
	AS3_ArrayValue(args, "IntType", &type);
	if (emu) {
		gme_delete(emu);
		emu = NULL;
	}
	emu = gme_new_emu(gme_type_array[type] ,FREQUENCY);
	return emu ? AS3_True() : AS3_False();
}

int main(int argc, char* argv[]){
	ggInit();
	gg_lib = AS3_Object("");
	gg_reg(gg_lib, "load", load);
	gg_reg(gg_lib, "typeInit", typeInit);
	gg_reg(gg_lib, "play", play);
	gg_reg(gg_lib, "playInner", playInner);
	gg_reg(gg_lib, "release", release);
	gg_reg(gg_lib, "tell", tell);
	gg_reg(gg_lib, "seek", seek);
	gg_reg(gg_lib, "setTempo", setTempo);
	gg_reg(gg_lib, "setFade", setFade);
	gg_reg(gg_lib, "stereoDepth", stereoDepth);
	gg_reg(gg_lib, "trackInfo", trackInfo);
	gg_reg(gg_lib, "startTrack", startTrack);
	gg_reg(gg_lib, "trackCount", trackCount);
	gg_reg(gg_lib, "trackEnded", trackEnded);
	AS3_LibInit(gg_lib);
	return 0;
}
