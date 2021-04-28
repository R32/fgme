package;

import Gme;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

class Main {

	public var gme : Gme;
	public var count : Int;

	public function new() {
		var cinit = new cmodule.libgme.CLibInit();
		@:privateAccess Gme.cgme = cinit.init();
		gme = new Gme();
		gme.load(new NsfZelda2());
		count = gme.trackCount();
		gme.play();
		var stage = flash.Lib.current.stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		var info = gme.trackInfo();
		trace('game: ${info.game}, author: ${info.author}, size: ${info.length}');
		trace("*Press UP/LEFT, DOWN/RIGHT to switch track*" + " [0~" + (count-1) + "]");
		showTrack();
	}

	function showTrack() {
		trace('track: ${gme.track}');
	}

	function onKeyDown( event : KeyboardEvent ) {
		var code = event.keyCode;
		var prev = gme.track;
		var curr = prev;
		switch (code) {
		case Keyboard.LEFT, Keyboard.UP:
			if (--curr < 0)
				curr = count - 1;
		case Keyboard.RIGHT, Keyboard.DOWN:
			if (++curr == count)
				curr = 0;
		default:
		}
		if (prev != curr) {
			gme.track = curr;
			showTrack();
		}
	}

	public static function main() {
		var inst = new Main();
	}
}

@:file("Zelda 2.nsf") class NsfZelda2 extends flash.utils.ByteArray{}
