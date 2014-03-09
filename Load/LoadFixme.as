package  {
	
	import flash.display.Sprite;
	import flash.events.Event
	import flash.display.Loader;
	import LZMA;
	import flash.geom.ColorTransform;

	// 135-168   203 252
	public class LoadFixme extends Sprite {
		
		[Embed(source = "fixme-pb-0-0-2.lzma", mimeType = "application/octet-stream")]
		var fx:Class
	
		//[Embed(source = "../../nsf.zip", mimeType = "application/octet-stream")]
		//var file:Class
		
		public var lzma:Function;	//要实现的
		
		public function LoadFixme() {
			// constructor code
			
			
			lzma = LZMA.decode;
			var ld:Loader = new Loader();
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE,_onLoaded);
			ld.loadBytes(lzma(new fx));
			this.stage.addEventListener(Event.RESIZE,_onresize);
			this._onresize();
		}
		
		function _onresize(event:Event = null):void{
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0,0,this.stage.stageWidth,this.stage.stageHeight);
		}
		
		function _onLoaded(event:Event){
			var fixme:Sprite = event.target.content as Sprite;
			fixme.x = 0;
			fixme.y = 0;
			this.addChild(fixme);
			//file && fixme['core'].load(new file, 'zip','mario');
		}
	}
	
}
