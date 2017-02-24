package hl;

private typedef Emu = hl.Abstract<"hl_gme">

abstract Gme(Emu) from Emu to Emu {
	public inline function new(type:EmuType, sample_rate:Int)
		this = Gme.create(type, sample_rate);

	@:hlNative("hgme", "free") public function free() { }

	@:hlNative("hgme", "load") public function load(size: Int, data: hl.Bytes):Void { }

	// Note: "out" is 16-bit(short)
	@:hlNative("hgme", "play") public function play(buffer_sample: Int, out: hl.Bytes):Void { }

	@:hlNative("hgme", "seek") public function seek(ms:Int):Void { }
	@:hlNative("hgme", "tell") public function tell():Int { return -1; }

	@:hlNative("hgme", "startTrack") public function startTrack(track:Int):Void { }
	@:hlNative("hgme", "track_ended") public function track_ended():Int { return -1;}

	@:hlNative("hgme", "new") static function create(type:EmuType, sample_rate:Int):Emu { return null; }
}

@:enum abstract EmuType(Int) {
	var gme_ay_type = 0;
	var gme_gbs_type = 1;
	var gme_gym_type = 2;
	var gme_hes_type = 3;
	var gme_kss_type = 4;
	var gme_nsf_type = 5;
	var gme_nsfe_type = 6;
	var gme_sap_type = 7;
	var gme_spc_type = 8;
	var gme_vgm_type = 9;
	var gme_vgz_type = 10;
}
