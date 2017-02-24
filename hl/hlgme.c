#define HL_NAME(n) hgme_##n

#include "hl.h"
#include "gme.h"

typedef struct Music_Emu hl_gme;

static gme_type_t get_gme_type(int t) {
	switch (t) {
	case 0: return gme_ay_type;  // extern vars
	case 1: return gme_gbs_type;
	case 2: return gme_gym_type;
	case 3: return gme_hes_type;
	case 4: return gme_kss_type;
	case 5: return gme_nsf_type;
	case 6: return gme_nsfe_type;
	case 7: return gme_sap_type;
	case 8: return gme_spc_type;
	case 9: return gme_vgm_type;
	case 10: return gme_vgz_type;
	default: return gme_nsf_type;
	}
}

static void handleError(const char* s) {
	if (s) {
		fprintf(stderr,"[game-music-emu Error]: %s\n", s);
		exit(EXIT_FAILURE);
	}
}

HL_PRIM hl_gme* HL_NAME(new)(int t, int sample_rate) {
	return gme_new_emu(get_gme_type(t), sample_rate);
}

HL_PRIM void HL_NAME(free)(hl_gme* emu) {
	if (emu != NULL) gme_delete(emu);
}

HL_PRIM void HL_NAME(play)(hl_gme* emu, int buffer_sample, vbyte* out) {
	if (buffer_sample > 8192) buffer_sample = 8192;
	handleError(gme_play(emu, buffer_sample, (short*)out)); // Note: vbyte* => short*
}

HL_PRIM void HL_NAME(load)(hl_gme* emu, int size, vbyte* data) {
	handleError(gme_load_data(emu, data, size));
	handleError(gme_start_track(emu, 0));
}

/* Seek to new time in track. Seeking backwards or far forward can take a while. */
HL_PRIM void HL_NAME(seek)(hl_gme* emu, int ms) {
	handleError(gme_seek(emu, ms));
}

/* Number of milliseconds (1000 = one second) played since beginning of track */
HL_PRIM int HL_NAME(tell)(hl_gme* emu) {
	return gme_tell(emu);
}

HL_PRIM void HL_NAME(startTrack)(hl_gme* emu, int track) {
	handleError(gme_start_track(emu, track));
}

/* True if a track has reached its end */
HL_PRIM int HL_NAME(track_ended)(hl_gme* emu) {
	return gme_track_ended(emu);
}

/* Set time to start fading track out. Once fade ends track_ended() returns true.
Fade time can be changed while track is playing. */
HL_PRIM void HL_NAME(fade)(hl_gme* emu, int start_ms) {
	gme_set_fade(emu, start_ms);
}


#define _GME _ABSTRACT(hl_gme)
DEFINE_PRIM(_GME, new, _I32 _I32);
DEFINE_PRIM(_VOID, free, _GME);
DEFINE_PRIM(_VOID, play, _GME _I32 _BYTES);
DEFINE_PRIM(_VOID, load, _GME _I32 _BYTES);
DEFINE_PRIM(_VOID, seek, _GME _I32);
DEFINE_PRIM(_I32, tell, _GME);
DEFINE_PRIM(_VOID, startTrack, _GME _I32);
DEFINE_PRIM(_I32, track_ended, _GME);
DEFINE_PRIM(_VOID, fade, _GME _I32);
