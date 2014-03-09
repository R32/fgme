package  ui{
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenuItem;
	import flash.system.Capabilities;
	

	
	import ming.Config;
	import ming.GmeCore;
	import Fixme;

	/*
		只配置 蓝色小动画以及右键菜单,
		
		初使化 音量,等其它配置不在这里实现
	
	*/
	public class UiConfig {
		private const _local:Object = {
				'zh' : {
					AutoTrack : ['取消自动音轨','自动选译音轨'],
					OrderPlay  : ['取消顺序播放','顺序播放'],
					AnimLite  : ['关闭蓝色小动画','打开蓝色小动画'],
					FadeOut	  : ['调整淡出时间']
				} ,
				'en' :	{
					AutoTrack  : ['Cancel Auto Track','Auto Select Track'],
					OrderPlay  : ['Cancel Order Play','Order Play'],
					AnimLite  : ['Turn Off Blue-Effect','Turn on Blue-Effect'],
					FadeOut	  : ['Set the fade-out']
				}
		};
		
		
		private var _lang:String;		
		private var _ftf:TextInput;		// inputText
		
		private var _coreCfg:Config;	// ming.Config
		private var _panel:Panel;
		
		private var _main:Fixme;
		private var _menu:ContextMenu;	
		private var _list:Object;		//contextitems list
		
		// 是否显示蓝色动画??default = true
		private var _useAnimBlue:Boolean = true;	
		
		public function UiConfig() {
			// constructor code
			this._lang = /zh/i.test(Capabilities.language) ? 'zh' : 'en';
			
			this._main = Fixme.Instance;
			
			this._coreCfg = _main.core.cfg;
			

			this.parseCfg(_main.pra);
			
			this.initFtf();
			
			this.initContextMenu();
		}
		
		function parseCfg(cfg:Object){
			var k:String,path:String
			for(k in cfg){
				switch(k){
					case 'file':
						path = cfg[k];
						break;
					/// 下边三个属性那边已经处理了,	
					/*
					case 'order':
						if(_coreCfg.useOrderPlay !== _coreCfg.isTrue(cfg[k])){
							_coreCfg.toggleOrderPlay()
						}
						break;
					case 'track':
						if(_coreCfg.useAutoTrack !== _coreCfg.isTrue(cfg[k])){
							_coreCfg.toggleAutoTrack();
						}
						break;	
					case 'fadeout':
						_coreCfg.fadeout = Number(cfg[k]);
						break;
					*/
					//下边是本类的变量设置
					case 'blue':
						_useAnimBlue = _coreCfg.isTrue(cfg[k]);
						break;
					case 'open':
						_main.panel.disableOpenButton = !_coreCfg.isTrue(cfg[k]);
						break;
					case 'volume':
						_main.core.volume = Number(cfg[k]);
						_main.panel.volume = _main.core.volume;
						break;
					default:
						break;
				}// end switch
			}// end for in
			if(path){
				new Ff(path);
			}	
		}
		
		//public function get main(){
			//return this._main;
		//}
		
		public function set lang(la:String){
			if(la in _local){
				this._lang = la;
			}
		}
		
		public function get useAnimBlue():Boolean{
			return _useAnimBlue;
		}
		
		public function set useAnimBlue(b:Boolean){
			if(b){
				if(!_useAnimBlue){
					_useAnimBlue = true;
					_list.animBlue.caption = _local[_lang].AnimLite[0];
					// 直接修改 panel属性,暂时不通过事件传递,Anim方法会自动检测 是否于播放中
					_main.panel.vBtns.Anim(true);	
				}
			}else if(this._useAnimBlue){
				this._useAnimBlue = false;
				_list.animBlue.caption = _local[_lang].AnimLite[1];
				_main.panel.vBtns.Anim(false);
			}
		}
	
		
		private function initContextMenu(){
			_list = {
				'orderPlay' : new ContextMenuItem(_local[_lang].OrderPlay[_coreCfg.useOrderPlay ? 0 : 1]),
				'autoTrack' : new ContextMenuItem(_local[_lang].AutoTrack[_coreCfg.useAutoTrack ? 0 : 1]),
				'animBlue'	: new ContextMenuItem(_local[_lang].AnimLite[this.useAnimBlue ? 0 : 1]),
				'fadeOut'	: new ContextMenuItem(_local[_lang].FadeOut[0])
			}
			_menu  = new ContextMenu();
			_menu.hideBuiltInItems();
			
			_menu.customItems.push(_list.orderPlay);
			_menu.customItems.push(_list.fadeOut);
			_menu.customItems.push(_list.autoTrack);
			_menu.customItems.push(_list.animBlue);
			
			_list.autoTrack.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,_menuAutoTrack);
			_list.orderPlay.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,_menuOrderPlay);
			_list.fadeOut.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,_menuFadeOut);
			_list.animBlue.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,_menuAnimBlue);
			_main.contextMenu = _menu;
		}
		
		private function _menuAutoTrack(event:ContextMenuEvent){
			this._coreCfg.toggleAutoTrack();
			if(this._coreCfg.useAutoTrack){
				_list.autoTrack.caption = _local[_lang].AutoTrack[0];
			}else{
				_list.autoTrack.caption = _local[_lang].AutoTrack[1];
			}
		}
		private function _menuOrderPlay(event:ContextMenuEvent){
			this._coreCfg.toggleOrderPlay();
			if(this._coreCfg.useOrderPlay){
				_list.orderPlay.caption = _local[_lang].OrderPlay[0];
			}else{
				_list.orderPlay.caption = _local[_lang].OrderPlay[1];
			}
		}
		//显示 _ftf 就好
		
		private function _menuFadeOut(event:ContextMenuEvent){
			if(!_main.contains(_ftf) && event.target.enabled){
				_main.panel.addChild(_ftf);
				_ftf.text = String(~~(_coreCfg.fadeoutTime/1000)); // ming.config
				_ftf.x = _main.panel.vTrack.x - _ftf.width;
				_ftf.y = _main.panel.vTrack.y
				_ftf.visible = true;
				_ftf.alpha =1;
				_ftf.editable = false;	// 只是用这个来存放一个变量,有时候stage.Event.mouse_leave 工作不正常
				_ftf.stage.addEventListener(Event.MOUSE_LEAVE, _onMouseLeave);
			}
		}
		private function _onMouseLeave(event:Event){
			if(_ftf.editable){
				_ftf.stage.removeEventListener(Event.MOUSE_LEAVE, _onMouseLeave);
				_main.panel.removeChild(_ftf);
			}
			
		}
		
		private function _menuAnimBlue(event:ContextMenuEvent){
			this.useAnimBlue = !this.useAnimBlue;
		}
		
		private function initFtf(){
			var tf:TextFormat = new TextFormat('ceriph 05_53',8,0x2D89EF,null);
			tf.align = 'center';
			
			_ftf = new TextInput();
			_ftf.imeMode = null;
			_ftf.maxChars = 3;
			_ftf.restrict = '0-9';
			_ftf.x =20;
			_ftf.y =12;
			_ftf.width = 30;
			_ftf.height = 14;
			_ftf.setStyle('textFormat',tf);
			_ftf.alpha = 0.8;
			
			_ftf.addEventListener(KeyboardEvent.KEY_DOWN,_ftfOnKeyDown);
			_ftf.addEventListener(MouseEvent.MOUSE_OUT,_ftfonMouseOut);
			_ftf.addEventListener(MouseEvent.MOUSE_OVER,_ftfMouseOver);
			
		}
	
		private function _ftfOnKeyDown(event:KeyboardEvent):void{
				if(event.keyCode===13){
					this._coreCfg.fadeout = Number(_ftf.text);	// ming.Config
					_ftf.visible = false;
				}else if(event.keyCode===27){
					_ftf.visible = false;
				}
				event.stopImmediatePropagation();
		}
		private function _ftfonMouseOut(event:MouseEvent){
			_ftf.alpha = 0.85;
			event.stopImmediatePropagation();
		}
		private function _ftfMouseOver(event:MouseEvent){
			if(!_ftf.editable) _ftf.editable = true;
			if(_ftf.alpha < 1) _ftf.alpha = 1;
			event.stopImmediatePropagation();
		}
		

	}
	
}
