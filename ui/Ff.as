package ui {
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class Ff extends URLLoader{
		public var fname:String;
		public var ftype:String;
		private var _main:Fixme
		
		public function Ff(url:String) {
			// constructor code
			var p:Array;
			super(new URLRequest(url))
			this.dataFormat = "binary";
			
			_main = Fixme.Instance;
			
			p = _main.core.pfname(url,true);
			
			if(p && p.length){
				this.fname = p[0];
				this.ftype = p[1];
				this.addEventListener(Event.COMPLETE, _onLoaded);
			}
		}
		
		function _onLoaded(event:Event){
			this._main.core.load(this.data,this.ftype,this.fname);
			this._main = null;
			//desctory ??
		}
	}
	
}
