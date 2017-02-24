package;

#if !macro
import hl.Gme;

class WaveWriter {

	static function run() {
		var filename = "test.nsf";
		var sample_rate = 44100;
		var track = 0;
		var sec = 10;
		var args = Sys.args();
		var i = 0;
		var len = args.length;

		while (i < len) {
			var val:String = args[i];
			switch (val) {
			case "-r", "--rate":
				Macors.parseAsInt(sample_rate);
			case "-t", "--track":
				Macors.parseAsInt(track);
			case "-s", "--sec":
				Macors.parseAsInt(sec);
			default:
				filename = val;
			}
		++ i;
		}

		Sys.println('track: $track, sample_rate: $sample_rate, sec: $sec');

		if (!sys.FileSystem.exists(filename) && sys.FileSystem.isDirectory(filename))
			throw "No such file: " + filename;

		var byte = sys.io.File.getBytes(filename);

		var file = sys.io.File.write("out.wav", true);

		var emu = new Gme(gme_nsf_type, sample_rate);

		try {
			emu.load(byte.length, byte);
			emu.startTrack(track);
			makeWav(sample_rate, sec, file, emu);
			Sys.println("save as out.wav");
		} catch(err: Dynamic) {
			trace(err);
		}
		file.close();
		emu.free();
	}

	static function makeWav(rate, sec, file:sys.io.FileOutput, emu:Gme) {
		var sample_count = 0;
		var size = 2048;
		var buf = haxe.io.Bytes.alloc(size * 2); // sizeof(short) == 2

		file.seek(header_size, SeekBegin);
		while (emu.tell() < sec * 1000) {
			emu.play(size, buf);
			file.writeFullBytes(buf, 0, buf.length);
			sample_count += size;
		}

		var ds = sample_count * 2;
		var rs = header_size - 8 + ds;
		var frame_size = 2 * 2;
		var bps = rate * frame_size;
		file.seek(0, SeekBegin);
		Macors.writeHeader(
			'R', 'I', 'F', 'F',
			rs >>  0, rs >>  8,     // length of rest of file
			rs >> 16, rs >> 24,
			'W', 'A', 'V', 'E',
			'f', 'm', 't', ' ',
			0x10, 0, 0, 0,          // size of fmt chunk
			1, 0,                   // uncompressed format
			2, 0,                   // channel count
			rate >>  0, rate >>  8, // sample rate
			rate >> 16, rate >> 24,
			bps >>  0, bps >> 8,    // bytes per second
			bps >> 16, bps >> 24,
            frame_size, 0,          // bytes per sample frame
			16, 0,                  // bits per sample
			'd', 'a', 't', 'a',
			ds >>  0, ds >>  8,     // size of sample data
			ds >> 16, ds >> 24
		);
	}

	static inline var header_size = 0x2C;

	static function main() {
		run();
	}
}
#else
import haxe.macro.Expr;
#end
class Macors {
	macro static public function parseAsInt(expr) return macro @:mergeBlock {
		++ i;
		if ( i < len ) {
			val = args[i];
			$expr = Std.parseInt(val);
			if ($expr == 0) throw "TODO"; // is null ???
		}
	}

	macro static public function writeHeader(es:Array<haxe.macro.Expr>) {
		var a = [];
		for (i in 0...es.length) {
			switch (es[i].expr) {
			case EConst(CString(s)):
				a.push( macro file.writeByte(
					$v{ StringTools.fastCodeAt(s, 0) }
				));
			default:
				a.push( macro file.writeByte(
					${es[i]}
				));
			}
		}
		return macro $b{a};
	}
}
