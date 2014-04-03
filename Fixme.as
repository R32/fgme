package {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.FileFilter;

	import ui.*;
	import ming.*;
	import ming.event.*;
	//import lib.LZMA;
	import flash.events.MouseEvent;
	import fl.events.ListEvent;
	import com.anttikupila.revolt.RevoltEdit;
	import flash.events.KeyboardEvent;
	import flash.utils.setTimeout;


	public class Fixme extends Sprite {

		const _W:Number = 135;
		const _H:Number = 168;

		private static var _self:Fixme;

		public var core:GmeCore;

		public var panel:Panel;

		public var re:RevoltEdit;

		public var file:FileReference;
		var ff:FileFilter;

		// 这二个Getter为了从外部加载 Fixme,这样可以减少 130K左右的大小
		public function get pra ():Object {
			// 如果不从网页读取变量,自行修改 ming.Config,ui.UIConfig这二个文件的属性
			if (this.parent === stage) {
				return this.loaderInfo.parameters;
			} else {
				return this.parent['loaderInfo'].parameters;
			}
		}
		/*
		LZMA.decode,如果不从 load处加载,可以换成 return LZMA.decode,并且import lib.LZMA,
		如果返回值为 null, 只是无法解析通过lzma压缩的文件
		*/
		public function get lzma ():Function {
			if (this.parent === stage) {
				return null;// 
			} else {
				return this.parent['lzma'];//load 类要声明这个变量
			}
		}

		public function Fixme () {
			// constructor code
			_self = this;
			addEventListener (Event.ADDED_TO_STAGE,_init);
		}



		public function _init (event:Event = null):void {

			removeEventListener (Event.ADDED_TO_STAGE,_init);
			//一些设置
			this.stage.quality = "low";
			this.stage.scaleMode = "noScale";
			this.stage.align = "TL";
			//初使化
			this.core = new GmeCore(this.pra,this.lzma,null);//如果要进行域名锁定的话替换 null 为 this
			this.core.addEventListener (GmeFileEvent.FILECHANGE, _onFileChange);
			this.core.addEventListener (GmePlayEvent.PLAYCHANGE, _onPlayChange);


			this.panel = new Panel();
			this.addChild (this.panel);
			this.panel.addEventListener (MbtnEvent.BTNCLICK,_onMbtnClick);
			this.panel.list.addEventListener (ListEvent.ITEM_DOUBLE_CLICK, _onDblClick);
			this.panel.list.addEventListener (KeyboardEvent.KEY_DOWN, _onKeyDown);

			// init this.file;
			this.file = new FileReference();
			this.ff = new FileFilter('nsf,spc,gbs,ay,gym,hes,kss,nsfe,sap,vgm,vgz,zip...','*.zip;*.data;*.nsf;*.spc;*.ay;*.gbs;*.gym;*.hes;*.kss;*.nsfe;*.sap;*.vgm;*.vgz');
			this.file.addEventListener (Event.COMPLETE,_onFileLoaded);
			this.file.addEventListener (Event.SELECT,_onFileSelected);


			this.re = new RevoltEdit(this,_W,_H);
			//this.re.x = this.panel.x;
			//this.re.y = this.panel.y;
			this.re.addEventListener ('close',_onRevoltClose);
			this.stage.addEventListener (Event.RESIZE ,resize);
			setTimeout(this.resize,50);
			/* 
			init extend Javascript 设置 disable_js 禁用 JS 扩展,
			如果在文件系统下 ExternalInterface.available的值也为 true,但是....
			这个放最后一行执行,不会影响到
			*/
			this.core.cfg.isTrue(this.pra['js']) && new Ex4YUI();
		}

		//
		function syncPanel (track:Boolean = false) {
			this.panel.Playing = this.core.isPlaying;
			if (track) {
				this.panel.setTrack (this.core.track,this.core.trackCount);
			}
		}

		// --- 大部分方法都将绑定到 JS中去,所以直接用方法而不是 Setter
		function play (index:uint , track:int = -1):Boolean {
			var ret:Boolean = this.core.play(index,track);
			syncPanel (true);
			return ret;
		}

		function resume ():Boolean {
			var ret:Boolean = this.core.resume();
			syncPanel (false);
			return ret;
		}

		function pause ():Boolean {
			var ret:Boolean = this.core.pause();
			syncPanel (false);
			return ret;
		}

		function stop ():Boolean {
			var ret:Boolean = this.core.stop();
			syncPanel (false);
			return ret;
		}

		function playNext ():Boolean {
			var ret:Boolean = this.core.playNext();
			syncPanel (true);
			return ret;
		}

		function playPrev ():Boolean {
			var ret:Boolean = this.core.playPrev();
			syncPanel (true);
			return ret;
		}

		function trackNext ():Boolean {
			var ret:Boolean = this.core.trackNext();
			syncPanel (true);
			return ret;
		}

		function trackPrev ():Boolean {
			var ret:Boolean = this.core.trackPrev();
			syncPanel (true);
			return ret;
		}

		function mixerStart ():Boolean {
			if (! this.panel.cfg.useAnimBlue) {
				this.panel.anim = false;
			}
			this.core.isPlaying && this.re.start();
			return this.core.isPlaying;
		}

		function mixerStop ():void {
			if (this.re.visible) {
				this.re.stop ();
			}
			// 主动调用 re.stop()函数不会触发 Close 事件,恢复按钮动画
			if (this.panel.cfg.useAnimBlue) {
				this.panel.anim = true;
			}
		}

		// Handler
		private function _onFileLoaded (event:Event):void {
			var p:Array = this.core.pfname(this.file.name,true);
			this.core.load (this.file.data,p[1],p[0]);
		}
		private function _onFileSelected (event:Event):void {
			this.file.load ();
		}
		private function _onFileChange (event:GmeFileEvent):void {
			switch (event.changeType) {
				case GmeFileEvent.ERROR ://Nothing
					break;
				case GmeFileEvent.ADDED :
					this.panel.dp.addItemAt (this.core.list[0],0);
					//默认是放到第一个,;
					break;
				case GmeFileEvent.UPDATE :
					if (this.core.list.length) {
						this.panel.dp.length && this.panel.dp.removeAll();
						this.panel.dp.addItems (this.core.list);
					}
					break;
				default :
					break;
			}
		}

		/*
		这些是由**自动**播放时产生的事件,比如点击下一曲,但是已经没有下一曲了就会触发 STOP,
		当**自动**跳到下一 track 或 music时,会触发相应事件,
		*/
		private function _onPlayChange (event:GmePlayEvent):void {
			switch (event.state) {
				case GmePlayEvent.LOAD :
					this.panel.title = this.core.item['label'];
					break;
				case GmePlayEvent.NEXT :
					break;
				case GmePlayEvent.STOP :
					break;
				case GmePlayEvent.PREV :
					break;
				case GmePlayEvent.TRACKNEXT :
					break;
				case GmePlayEvent.TRACKPREV :
					break;
			}
			this.panel.Playing = this.core.isPlaying;
			this.panel.setTrack (this.core.track,this.core.trackCount);

			if (this.panel.list.selectedIndex !== this.core.index) {
				this.panel.list.selectedIndex = this.core.index;
				this.panel.list.scrollToIndex (this.panel.list.selectedIndex);
			}
		}

		private function _onMbtnClick (event:MbtnEvent):void {
			event.stopImmediatePropagation ();
			//停止事件流;
			switch (event.which) {
					// Class VolC
				case 'vMixer' :
					this.mixerStart ();
					break;
				case 'vTf' :
					this.core.volume = 1;//this.volume = 1会重复更新 vTf的值以及 vSlide的值
					break;
				case 'vSlide' :
					this.core.volume = this.panel.volume;
					break;

					// Class buttons
				case 'bPlay' :
					if(this.core.index > -1){
						this.core.isPausing ? this.resume() : this.play (this.panel.list.selectedIndex);
					}
					// 自动播放并不是以 list.selectedIndex为原点,而是core.index;
					break;
				case 'bPause' :
					this.pause ();
					break;
				case 'bStop' :
					this.stop ();
					break;
				case 'bPrev' :
					if(this.core.index > -1){
						this.core.trackCount === 1 ? this.playPrev():this.trackPrev();
					}
					break;
				case 'bNext' :
					if(this.core.index > -1){
						this.core.trackCount === 1 ? this.playNext():this.trackNext();
					}
					break;
				case 'bOpen' :
					this.file.browse ([this.ff]);
					break;
				default :
					break;
			}
		}

		private function _onRevoltClose (event:Event):void {
			this.mixerStop ();
		}

		private function _onDblClick (event:ListEvent):void {
			this.play (event.index);
		}
		private function _onKeyDown (event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 13 :
					if (!(this.core.isPlaying && this.panel.list.selectedIndex===this.core.index)) {
						this.play (this.panel.list.selectedIndex);
						this.panel.list.scrollToSelected ();
					}
					break;
				case 37 :
					this.core.trackCount === 1 ? this.playPrev():this.trackPrev();
					break;
				case 39 :
					this.core.trackCount === 1 ? this.playNext():this.trackNext();
					break;
				case 32 :
					this.core.isPlaying ? this.pause():this.resume();
					break;
			}
		}

		public function resize (event:Event = null):void {
			var sx:Number,sy:Number,scale:Number;

			sx = this.stage.stageWidth / _W;
			sy = this.stage.stageHeight / _H;
			scale = Math.min(sx,sy);
			this.re.scaleX = sx;
			this.re.scaleY = sy;

			this.panel.scaleX = this.panel.scaleY = scale;
			this.panel.x = (this.stage.stageWidth - this.panel.width)/2;
			this.panel.y = (this.stage.stageHeight- this.panel.height)/2;
			//trace(this.panel.width,this.panel.height);
		}

		public static function get Instance () {
			return _self;
		}

	}

}