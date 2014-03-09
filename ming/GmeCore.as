package ming{
	/*
		Events
			GmeFileEvent
				['error','added','update']
				通常update将会清除所有旧数据,因为目前只管理一个zip文件
				added 会把新增的 文件插在 索引0的位置上
			GmePlayEvent
				['tracknext','trackprev','prev','next','stop']
				主动调用函数不会触发这些事件,这几个事件
				
			public cfg
					GmeCfgEvent	用于在修改配置文件后更新 gme状态
	*/
	import deng.fzip.FZip;
	import deng.fzip.FZipFile
	import deng.fzip.FZipErrorEvent
	import ming.*;
	import ming.event.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	/**
	 * 当更改 <b>配置</b> 后, which = track|order|fadeout
	 * 
	 * @eventType ming.event.GmeCfgEvent.CONFIGCHANGE
	 */
	[Event(name = "configchange", type = "ming.event.GmeCfgEvent")]
	
	
	/**
	 * 当 <b>播放状态</b>发生改变时, <b>注意:</b>主动调用相关播放方法不会触发这个事件
	 * 
	 * state = load|stop|next|prev|tracknext|trackprev
	 * 
	 * @eventType ming.event.GmePlayEvent.PLAYCHANGE
	 */
	[Event(name = "playchange", type = "ming.event.GmePlayEvent")]
	
	
	/**
	 * 当加载 <b>文件</b> 后, changeType = update|added|error
	 * 
	 * @eventType ming.event.GmeFileEvent.FILECHANGE
	 */
	[Event(name = "filechange", type = "ming.event.GmeFileEvent")]
	
	/**
	 * 主类
	 * @author hotup@qq.com
	 */
	public class GmeCore extends EventDispatcher{
		
		public static var version:String = '0.0.1';
		
		public var  cfg:Config; //在外部对这个值进行检测
		
		private var _dp:Array;	// 本来想用 dataProveder的,可是要装载的组件还是蛮大的
		private var _dpindex:int;
		
		/**
		 * @private
		 */
		internal var zip:FZip;
		
		/**
		 * @private
		 */
		internal var gme:GameMusicEmu;
		
		/**
		 * @private
		 */
		internal var bit:Effect;
		
		/**
		 * @private
		 */
		internal var timer:Timer;	

		/**
		 * @private
		 */
		internal var baCur:ByteArray;
		
		/**
		 * @private
		 */
		internal var lzma:Function;
		
		/**
		 * 0
		 * @param	cfg 可以直接使用主类的 loaderInfo.parameters 作为参数
		 * @param	lzma_decode lzma解压方法,为了减小核心大小,而从最外部传递就可以,如果缺失,将无法解压lzma压成的zip文档
		 * @param	main_sprite 主类,用于C++端域名锁定,
		 */
		public function GmeCore(cfg:Object = null,lzma_decode:Function = null , main_sprite:* = null):void {
			
			this._dp = [];
			this._dpindex = -1;
			
			this.cfg = new Config(cfg);
			
			this.lzma = lzma_decode;
			
			//GameMusicEmu.SPRITE = main_sprite;
			
			this.gme = new GameMusicEmu();
			this.bit = new Effect();
			
			this.timer = new Timer(300);
			this.timer.addEventListener(TimerEvent.TIMER,this._onTimer)
			
			this.zip	= new FZip("utf-8+");	//反正这个不会乱码
			this.zip.addEventListener(Event.COMPLETE,_zipLoaded);
			this.zip.addEventListener(FZipErrorEvent.PARSE_ERROR,_zipLoaded);
			this.cfg.addEventListener(GmeCfgEvent.CONFIGCHANGE,_onCfgChange);
		}
		
		
		//>>>>>>>>>>>>>>>>> Getter <<<<<<<<<<<<<<<<<<<<
		
		/*
		 * 返回音乐文件总数量,这个值好像不对,因为会包含目录在里边
		public function get fcount():uint{
			return zip.getFileCount();
		}
		*/		 
		
		
		/**
		 * 清单文件
		 */
		public function get list():Array{
			if(!this._dp && this.zip.getFileCount()){
				this._dp = _getfileList();
			}
			return this._dp;
		}
		// 小心使用
		public function set list(d:Array):void{
			this._dp = d;
			this._dpindex = 0;
		}
		
		/**
		 * 返回当前 索引值
		 */
		public function get index():int{
			return this._dpindex;
		}
		public function set index(n:int):void{
			if(n>-1 && n<this._dp.length){
				this._dpindex = n;
			}
		}
		
		/**
		 * 返回 this.index 所指向的 item
		 */
		public function get item():Object{
			if(this.index>-1 && this.list.length){
				return this.list[ this.index ];
			}
			return null;
		}
		
		/**
		 * 应该在相应的文件 GmePlayEvent.LOAD 事件之后再调用此函数,获取一些信息
		 */
		public function get info():Object{
			var info:Object;
			if(this.baCur){
				if(this.gme.emulatorType === 'hes'){
					info = this.gme.trackInfo(4);
				}else if(this.gme.emulatorType === 'kss'){
					info = this.gme.trackInfo(43);
				}else{
					info = this.gme.trackInfo(0)
				}
			}
			return info
		}
		
		private function _getfileList():Array{
			var ps:Array,fz:FZipFile,i:uint,len:uint = zip.getFileCount();
			var data:Array = [];
			for(i=0; i<len; i+=1){
				fz = zip.getFileAt(i);
				ps = pfname(fz.filename);
				if(ps){
					data.push({
						'data' : i,
						'label': ps[0],
						'type' : ps[1]
					});
				}			
			}
			data.sortOn('label');
			return data.length ? data : null;
		}
		
		/**
		* @param findex 注意是文件索引,不是item索引, item.data 中存放了 findex 值
		* @return 文件
		*/
		public function fcontent(findex:uint):ByteArray{
			return zip.getFileAt(findex).content
		}
		
		/**
		 * 从数据加载文件
		 * @param	ba
		 * @param	type zip|data|EmulatorType[...]
		 * @param	name 如果加载的文件类型为 zip|data 则可以省略这个参数
		 */
		public function load(ba:ByteArray,type:String,name:String = ''):void{
			type = type.toLowerCase();
			switch(type){
				case 'zip':
					zip.loadBytes(ba);	
					break;
				case 'data':
						lzma && zip.loadBytes(lzma( ba ));
					break;
				default : // 单个文件
					if(EmulatorType[type.toUpperCase()] && name){
						try{
							zip.addFile(name,ba,false);
							
							this._dp.unshift({
								'data'	: zip.getFileCount()-1,
								'label' : name,
								'type'	: type
							});
							this._dpindex = 0;
							this.dispatchEvent(new GmeFileEvent(GmeFileEvent.ADDED));
						}catch(err:Error){
							this.dispatchEvent(new GmeFileEvent(GmeFileEvent.ERROR));
						}
					}
			}
	
		}
		
		/**
		 *  分析url文件名(包含扩展名),返回 扩展名 和 文件名(不包含扩展名)
		 * @param	url
		 * @param	zip if true.对不文件进行合法性检察
		 * @return 返回[0]->文件名 [1]->扩展名
		 */
		public function pfname(url:String,zip:Boolean = false):Array{
			var a:Array = url.replace(/\\/g,'\/').split('\/');
				a =	a[ a.length-1 ].split('.');
			if(a.length===2){
				a[0] = a[0].replace(/^\s+|\s+$/g,'');
				a[1] = a[1].replace(/^\s+|\s+$/g,'').toLowerCase();
				if(zip || EmulatorType[a[1].toUpperCase()]){//不检察zip文件
					return a
				}
			}
			return null
		}
		
		/**
		 * 从另外的一个声道播放一个简单声音,最长不会超过5秒.
		 * @param	index
		 * @param	track
		 */
		public function pbit(index:uint,track:int = -1):void{
			var item:Object;
			if(index>-1 && index<this.list.length){
				item	=	this.list[index];
				this.bit.play(this.fcontent(item.data),item.type,track);
			}
		}
		
		/**
		 * 播放从数据文件加载
		 * @param	ba 音乐数据文件
		 * @param	type 类型
		 * @param	track 音轨,负值则使用默认值
		 */
		private function dataPlay(ba:ByteArray=null,type:String='',track:int = -1):void{
			this.stop();
			if(ba && type){
				if(!(this.baCur && this.baCur ===ba)){
					if(this.gme.emulatorType !== type){
						this.gme.init(type);
					}
					// load Data
					this.gme.loadData(ba);
					this.baCur = ba;
					// loadDataComplated
					
					if(track === -1 && this.cfg.useAutoTrack && type === 'nsf'){
						this.gme.track = this.cfg.nsfTrackStart(ba);
					}
					// 加载数据之后,就和 gme的dispatchLoadCompleteEvent 事件一样,但是在设置 track之后才发生
					this.dispatchEvent(new GmePlayEvent(GmePlayEvent.LOAD));
				}
			}
			if(track>-1 && track<this.gme.trackCount){
				this.gme.track = track;
			} 
			this.resume();
		}
		
		/**
		 * 恢复播放
		 * @return
		 */
		public function resume():Boolean{
			if(this.baCur){
				this.cfg.useOrderPlay && this.gme.setFade(this.cfg.fadeoutTime);
				this.gme.play();
				this.timer.start();
			}
			return this.isPlaying
		}
		
		/**
		 * 停止播放
		 * @return
		 */
		public function stop():Boolean{
			if(this.gme.isPausing || this.gme.isPlaying){
				this.timer.stop();
				this.gme.stop();
			}
			return !(this.isPlaying && this.isPausing);
		}
		
		/**
		 * 暂停播放
		 * @return
		 */
		public function pause():Boolean{
			if(this.gme.isPlaying){
				this.timer.stop();
				this.gme.pause();
			}
			return this.isPausing;
		}
		
		/**
		 * @copy GameMusicEmu#volume
		 */
		public function get volume():Number{
			return this.gme.volume;
		}
		public function set volume(v:Number){
			this.gme.volume = v;
		}
		
		/**
		 * @copy GameMusicEmu#isPlaying
		 */
		public function get isPlaying():Boolean{
			return gme.isPlaying;
		}
		
		/**
		 * @copy GameMusicEmu#isPausing
		 */
		public function get isPausing():Boolean{
			return gme.isPausing;
		}
		
		/**
		 * @copy GameMusicEmu#track
		 */
		public function set track(n:uint){
			if(track>-1 && track<this.gme.trackCount){
				this.gme.track = track;
			}
		}
		public function get track():uint{
			return this.gme.track;
		}
		
		/**
		 * @copy GameMusicEmu#trackCount
		 */
		public function get trackCount():uint{
			return this.gme.trackCount;
		}
		
		/**
		 * Number of milliseconds (1000 = one second)
		 * played since beginning of track
		 */
		public function get tell():uint{
			return this.gme.tell();
		}
		
		/**
		 * 播放
		 * @param	index 这个值是位于数组 list 中的索引值
		 * @param	track 音轨, -1 表示使用默认值
		 * @return
		 */
		public function play(index:uint,track:int=-1):Boolean{
			var item:Object;
			if(index>-1 && index<this.list.length){
				this.index = index;
				item	=	this.item;
				this.dataPlay(this.fcontent(item.data),item.type,track);
			}
			return this.isPlaying;
		}
		
		/**
		 * 跟据偏移值来播放
		 * @param	offset 如果提供的偏移值超出界限,自动停止并且触发相应事件
		 * @return
		 */
		public function offsetPlay(offset:int=0):Boolean{
			var index:int,
				item:Object,
				ret:Boolean = false;
			if(offset){
				
				index = this.index + offset;
				
				if(index > -1 && index < this.list.length){
					this.index = index;
				}else{
					this.gme.track = 0;
					if(this.stop()){
						this.dispatchEvent(new GmePlayEvent(GmePlayEvent.STOP));
					}
					return ret;
				}
			}
			if (this.index > -1) {
				ret = true;
				item = this.item;
				this.dataPlay(this.fcontent(item.data),item.type);
			}
			return ret
		}
		/**
		 * 播放下一曲
		 * @return if false.
		 */
		public function playNext():Boolean{
			return this.offsetPlay(1);
		}
		
		/**
		 * 播放上一曲
		 * @return if false.
		 */
		 public function playPrev():Boolean{
			return this.offsetPlay(-1);
		}
		
		/**
		 * 播放下一个音轨
		 * @return if false.则会尝试播放<b>下一曲</b>.
		 */
		public function trackNext():Boolean{
			if((this.gme.track+1) <this.gme.trackCount){
				this.stop();
				this.gme.track+=1;	// 调整 track将会自动跳曲
				this.resume();
				return true;
			}
			// 失败跳到下一曲,成功后并触发相应事件
			if(this.playNext()){
				this.dispatchEvent(new GmePlayEvent(GmePlayEvent.NEXT));
			}
			return false;
		}
		
		/**
		 * 播放上一个音轨
		 * @return if false.则会尝试播放<b>上一曲</b>.
		 */
		public function trackPrev():Boolean{
			if(this.gme.trackCount > 1 && (this.gme.track - 1) > -1){
				this.stop()
				this.gme.track-=1;
				this.resume()
				return true;
			}
			// 失败跳到上一曲,成功后并触发相应事件
			if(this.playPrev()){
				this.dispatchEvent(new GmePlayEvent(GmePlayEvent.PREV));
			}
			return false;
		}
		
		
		/**
		 * for debug, 用for in 的方式遍历对象,并且以trace的方式输出
		 * @param	obj
		 * @param	str 一些描述之类的文字
		 */
		public function forin(obj:Object,str:String="forin"){
			trace('>>>>>>>>>>>>>>>>>> ',str,' <<<<<<<<<<<<<<<<<<<<')
			for(var k:String in obj){
				trace(k,' ---> ',obj[k])
			}
		}
		
		/**
		 * 事件监听,Timer 会触发一些自动化的事件
		 * @param	event
		 */
		private function _onTimer(event:Event){
			if(this.gme.trackEnded()){
				if(this.cfg.useAutoTrack && this.track>15 && this.tell<2500){
					if(this.cfg.nsfAutoTrack() && this.playNext()){
						this.dispatchEvent(new GmePlayEvent(GmePlayEvent.NEXT))
					}
				}else{
					this.cfg.nsfAutoTrack(true);
					if(this.cfg.useOrderPlay){
						this.trackNext() && this.dispatchEvent(new GmePlayEvent(GmePlayEvent.TRACKNEXT));
					}else if(this.stop()){
						this.dispatchEvent(new GmePlayEvent(GmePlayEvent.STOP));
					}
				}
			}
		}
		
		/**
		 * 事件监听,当 cfg 的一些值发生改变时
		 * @param	event
		 */
		private function _onCfgChange(event:GmeCfgEvent){
				
				if(this.gme.isPlaying){
					switch(event.which){
						case GmeCfgEvent.FADEOUT: // 淡出时间,自动应用到下一首中去
							//this.gme.setFade(this.tell + this.cfg.fadeoutTime);
							break;
						case GmeCfgEvent.ORDER:// 自动播放
							if(this.cfg.useOrderPlay){
								this.gme.setFade(this.tell + this.cfg.fadeoutTime);
							}else{
								this.gme.setFade(int.MAX_VALUE);
							}
							break;
						case GmeCfgEvent.TRACK:	//自动音轨只会影响到下一次的播放,所以留空
							break;
						default:
							break;
						}
				}
				
		}
		
		/**
		 * 事件监听,当加载 压缩文件 完成之后
		 * @param	event
		 */
		private function _zipLoaded(event:Event):void{
			if(event.type === Event.COMPLETE){
				
				this.list = this._getfileList();//setter
				
				dispatchEvent(new GmeFileEvent(GmeFileEvent.UPDATE));
			}else{
				dispatchEvent(new GmeFileEvent(GmeFileEvent.ERROR));
			}
		}

	}
	
}
