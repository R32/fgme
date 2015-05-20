package{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.SoundMixer;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	
	import Gme;
	

	
	[SWF(width=512,height=400,backgroundColor=0x000000,frameRate=30)]	
	public class Test extends Sprite{
		
		[Embed(source="../../test/batman.nsf",mimeType="application/octet-stream")]
		private var Byte_batman:Class;
		
		private const PLOT_HEIGHT:int = 200;
		private const CHANNEL_LENGTH:int = 256;
		
		private var gme:Gme;
		private var ba:ByteArray;
		private var g:Graphics;
		private var tf:TextField;

		public function Test(){
			super();
			tf = new TextField();
			tf.width = stage.stageWidth;
			tf.height = stage.stageWidth;
			tf.textColor = 0xffffff;
			this.addChild(tf);
			
			gme = new Gme();
			gme.init("nsf");
			gme.load(new Byte_batman());		
			gme.track = 0;
			gme.play();
			
			printInfo();	

			ba = new ByteArray();
			g = this.graphics;
			stage.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
		}
		
		private function printInfo():void{
			tf.text = "";
			tf.appendText("\t\t\t**press arrow key to switching track**\n");
			tf.appendText("track length:  " + gme.trackCount + "\n");
			tf.appendText("track current: " + gme.track + "\n");
			tf.appendText("------------------------------------\n");
			var info:Object = gme.trackInfo(gme.track);
			for(var k:String in info){
				tf.appendText(k + ": " + info[k] + "\n");
			}
		}
		
		private function _onKeyUp(event:KeyboardEvent):void {
			var n:int = gme.track;
			switch(event.keyCode){
				case Keyboard.UP: 
				case Keyboard.LEFT: n -= 1;
				break;
				
				case Keyboard.RIGHT:
				case Keyboard.DOWN: n += 1;
				break;
			}
			
			if(n >= gme.trackCount){
				n = 0;
			}else if(n < 0){
				n = gme.trackCount - 1;
			}
			gme.stop();
			gme.track = n;
			gme.play();
			printInfo();
		}
		
		private function _onEnterFrame(event:Event):void {
			ba.position = 0;
			SoundMixer.computeSpectrum(ba, false, 0);			
			g.clear();
			
			g.lineStyle(0, 0xffffff); // 0x6600cc
			g.moveTo(0, PLOT_HEIGHT);
			
			var n:Number = 0;
			var i:int = 0;
			for (i = 0; i< this.CHANNEL_LENGTH ; i++) {
				n = ba.readFloat() * PLOT_HEIGHT;
				g.lineTo( i * 2, PLOT_HEIGHT - n);
			}
			
			//g.lineStyle(0, 0xcc0066);
			//g.moveTo(0, PLOT_HEIGHT);		
			//for (i = 0; i< this.CHANNEL_LENGTH ; i++) {
			//	n = ba.readFloat() * PLOT_HEIGHT;
			//	g.lineTo( i * 2, PLOT_HEIGHT - n);
			//}
		}
		
	}

}