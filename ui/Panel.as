package ui {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//组件
	import fl.controls.List;
	import fl.data.DataProvider;
	import fl.events.DataChangeEvent;
	import fl.events.DataChangeType;
	
	import ui.myCellRenderer;
	import ming.GmeCore;
	
	
	
	public class Panel extends MovieClip {
		
		/* public 下边几项使用Flash创建定义,需要在元件里边更改属性
		vTitle	-- TextFiled
		vTrack	-- TextFiled
		vBtns	-- ui.Buttons	
		vHeader	-- ui.VolC	
		*/

		
		//public var mixer:mySoundMixer;
		// 数据处理
		public var list:List;
		public var dp:DataProvider;
		public var cfg:UiConfig;
		
		public function Panel() {
			// constructor code
			
			this.addEventListener(Event.ADDED_TO_STAGE,this.__init);
			this.x = 0;
			this.y = 0;
		}
		
		function __init(event:Event){
			this.removeEventListener(Event.ADDED_TO_STAGE,this.__init);
			//this._cfg = Config.getGlobal();
			
			this.title = 'hot'+'up'+'@'+'q' + 'q.' + 'c' + 'o' + 'm';
			this.vTrack.text = 'ver:'+GmeCore.version;
			this.tabChildren = false
			
			
			//list compment
			this.dp = new DataProvider();
			this.list = new List();
			this.list.setStyle('cellRenderer',myCellRenderer);
			this.list.dataProvider = dp;
			this.list.width = this.parent.width-1;
			this.list.x = 1;
			this.list.y = 48;
			this.list.rowHeight = 17;
			this.list.rowCount = 7;
			this.list.visible = false;
			
			this.addChildAt(this.list,0);
			
			this.vTitle.alpha = 0.8;
			this.vTrack.alpha = 0.8;
			this.vTitleZh.alpha = 0.8;
			
			this.dp.addEventListener(DataChangeEvent.DATA_CHANGE,_onDataChange);
			
			this.cfg = new UiConfig();
		}
		
		// TO Delete ??? 好像可以用不这个事件
		private function _onDataChange(event:DataChangeEvent){
			switch(event.changeType){
				case 'removeAll': return;
					break;
				case 'change':
					break;
				case 'add':
					break;
			}
			
			if(this.dp.length){
				if(!this.list.visible){
					this.list.visible = true;
				}
				this.list.selectedIndex = 0;
				this.list.scrollToIndex(0);
			}else{
				this.list.visible = false;
			}
		}
				
		// 设置 track 标题
		public function setTrack(track:uint=1,trackCount:uint=1){
			if(trackCount>1){
				this.vTrack.text = '-' + (track+1) +'/'+trackCount;
			}else{
				this.vTrack.text = '- 1/1';
			}
		}
		
		//	--- Setter ---
		// 设置标题
		public function set title(title:String){
			
			var unicode:Boolean = false;
			var len:int = title.length;	
			for(var i:int = 0; i<len; i+=1){
				if(title.charCodeAt(i) > 255){
					unicode = true;
					break;
				}
			}
			
			if(len && unicode){
				this.vTitleZh.visible = true;
				this.vTitleZh.text = title;
				this.vTitle.visible = false;
			}else{
				this.vTitle.visible = true;
				this.vTitle.text = title;
				this.vTitleZh.visible = false;
			}
		}
		
		public function set volume(f:Number){
			this.vHeader.vol = f * 100;
		}
		public function get volume():Number{
			return this.vHeader.vol / 100;
		}
		//禁用 *打开文件* 按扭
		public function set disableOpenButton(b:Boolean){
			if(b){
				
				this.vBtns['bOpen'].mouseEnabled = false
				this.vBtns['bOpen'].alpha = 0.6;
			}else{
				this.vBtns['bOpen'].mouseEnabled = true
				this.vBtns['bOpen'].alpha = 0.85;
			}
		}
		//设置 显示 *暂停* *播放* 按扭
		public function set Playing(b:Boolean){
			this.vBtns.showPlay(!b, this.cfg.useAnimBlue);	// 取反
		}
	
		// 播放音乐时,显示一个蓝色的小动画于 *暂停*按钮上
		public function set anim(b:Boolean){
			this.vBtns.Anim(b);
		}

	}
}
