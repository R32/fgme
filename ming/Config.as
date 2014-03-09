package  ming{
	
	import flash.utils.ByteArray;
	import flash.events.EventDispatcher;
	
	import ming.event.GmeCfgEvent;
	import ming.GameMusicEmu;

	public class Config extends EventDispatcher{
		
		private var _useAutoTrack:Boolean;	// 自动选译 音轨
		
		private var _useOrderPlay:Boolean;	// 自动跳到下一曲
		
		private var _fadeoutTime:Number;	// 淡出时时
		
		
		private var _param1:Boolean;		// 我不喜欢这样,感觉不太好,临时处理一下
		
		
		public function get useAutoTrack():Boolean{
			return this._useOrderPlay && this._useAutoTrack;
		}
		
		public function get useOrderPlay():Boolean{
			return this._useOrderPlay;
		}
	
		public function get fadeoutTime():Number{
			return this._fadeoutTime;
		}
		
		
		/**
		 * 单位为 秒
		 */
		public function set fadeout(n:Number):void{
			var max:Number = 10*99;// 990
			if(n<10){
				n = 10;
			}else if(n > max){
				n = max
			}
			if(n){// isNaN
				this._fadeoutTime = n*1000;
				this.dispatchEvent(new GmeCfgEvent(GmeCfgEvent.FADEOUT));
			}
		}
		
		/**
		 * 配置文件 
		 * @param	cfg see parseCfg()
		 */
		public function Config(cfg:Object):void{
			this.fadeout = 65;
			this._useOrderPlay = true;
			this._useAutoTrack = true;
			
			if (cfg) {
				this.parseCfg(cfg);	
			}
		}
		
		/**
		 * 
		 * @param	cfg {order = > true|false , track = > true|false , fadeout => Number()} 
		 */
		public function parseCfg(cfg:Object):void{
			for(var k:String in cfg){
				switch(k){
					case 'order':
						this._useOrderPlay = isTrue(cfg[k]);
					case 'track':
						this._useAutoTrack = isTrue(cfg[k]);
						break;
					case 'fadeout':
						this.fadeout = Number(cfg[k]);
						break;
					default:
						break;
				}
			}
		}
		
		// 主要对 flashVal传过来的 true,false 的字符串形式
		public function isTrue(val:*):Boolean{
			var ret:Boolean
			switch(typeof val){
				case 'string':	ret = (val).toLowerCase()==='true';
					break;
				case 'boolean': ret = val;
					break;
				default:	ret = Boolean(val);
					break;
			}
			return ret;
		}
		
		public function toggleOrderPlay():void{
			
			this._useOrderPlay = !this._useOrderPlay;
			
			this.dispatchEvent(new GmeCfgEvent(GmeCfgEvent.ORDER));
		}
		
		public function toggleAutoTrack():void{
			this._useAutoTrack = !this._useAutoTrack;
			
			this.dispatchEvent(new GmeCfgEvent(GmeCfgEvent.TRACK));
		}
		
		/**
		 * 如果发生二次,则返回true,很别扭的一个函数,包括那个变量
		 * 
		 * @private
		 * @param	clear
		 * @return
		 */
		public function nsfAutoTrack(clear:Boolean = false):Boolean{
			var ret:Boolean = false;
			if(clear){
				this._param1 = false
			}else{
				if(this._param1){
					ret = true
					this._param1 = false;
				} else{
					this._param1 = true;
				}
			}
			return ret
		}
		
		public function nsfTrackStart(ba:ByteArray):uint{
			ba.position = 7;
			return ba.readUnsignedByte()-1;
		}
		/*// 暂时都用不上
		function nsfTrackCount(ba:ByteArray):uint{
			ba.position = 6;
			return  ba.readUnsignedByte();
		}
		
		function nsfAuthor(ba:ByteArray):String{
			ba.position = 46;
			return this.readString(ba,32);
		}
		
		function nsfCopyright(ba:ByteArray):String{
			ba.position = 78;
			return this.readString(ba,32);
		}
		
		function nsfTitle(ba:ByteArray):String{
			ba.position = 14;
			return readString(ba,32);
		}
		
		function readString(ba:ByteArray,len:uint):String{
			var ch:uint,ret:Array = [];
			
			while(len--){
				ch = ba.readUnsignedByte()
				if(ch===0){
					break
				}
				ret.push(String.fromCharCode(ch))
			}
			return ret.join("");
		}
		*/
	}
	
}
