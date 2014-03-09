package  {
	import flash.external.ExternalInterface;
	import ming.event.GmeFileEvent;
	import ming.event.GmePlayEvent;
	/*
		如果不想使用这些外部 JS,直接在主类注释掉,然后再发布
	*/
	public class Ex4YUI{
		
		private var _host:Fixme;
		
		private var _pra:Object
		
		private var _useYUI:Boolean;
		
		private var _JSCallback:String;
		
		public function Ex4YUI() {
			// constructor code
			_host = Fixme.Instance;
			if(ExternalInterface.available){
				_pra = _host.pra;
				if(_pra['YUIBridgeCallback'] &&
			 	_pra['YUISwfId'] &&
			  	_pra['yId']
			  	 ){
					_useYUI = true;
				}else if(_pra['callback']){
				// use custom callback
					_JSCallback = _pra['callback'];
				}else{
					// use default callback
					_JSCallback = 'onFixmeData';
				}
				ExternalInterface.marshallExceptions = true;
				_host.core.addEventListener(GmeFileEvent.FILECHANGE, _onDataChange);
				_host.core.addEventListener(GmePlayEvent.PLAYCHANGE, _onPlayChange);
				this.bind();
			}
		}
		
		function bind(){
			var k:String,api:Array,
			hs:Object = {
				'fbit'		:	_host.core.pbit,
				'fplay'		:	_host.play,
				'fcontrol'	:	this.control,
				'fprops'		:	this.prop
			}
			api = [
				'fplay ( index:uint , track:int = -1 ):Boolean',
				'fbit ( index:uint , track:int = -1 ):void',
				'fcontrol(how:String =[pause, resume, stop, next, prev, tracknext, trackPrev, mixOff, toggleOrder]):*;   ',
				'fprop (propname:String = [ isPlaying, isPausing, playingIndex, selectedIndex, info, data, volume,orderPlay ] , value:Number = -1 ):*  @value只对 volume , selectedIndex 起作用',
				'FLASHVAL => file , order = true, track = true, fadeout = 65 , blue = true , open = true , volume = 1.0'
			];
			for(k in hs){
				ExternalInterface.addCallback(k , hs[k]);
			}
			this.sendData({'api' : api},'swfReady');
		}
		//针对那些没有参数的方法调用
		function control(how:String):*{
			var ret:*;//undefined
			switch(how){
				case 'pause':
					ret = _host.pause();
					break;
				case 'resume':
					ret = _host.resume();
					break;
				case 'stop':
					ret = _host.stop();
					break;
				case 'next':
					ret = _host.playNext();
					break;
				case 'prev':
					ret = _host.playPrev();
					break;
				case 'trackNext':
					ret = _host.trackNext();
					break;
				case 'trackPrev':
					ret = _host.trackPrev();
					break;
				case 'mixOff':
					ret = _host.mixerStop();
					break;
				case 'toggleOrder':
					ret = _host.core.cfg.toggleOrderPlay();
					break;
				case 'disable_open':
					_host.panel.disableOpenButton = true;
					break;
				case 'enable_open':
					_host.panel.disableOpenButton = false;
					break;
				case 'disable_blue':
					_host.panel.cfg.useAnimBlue = false;
					break;
				case 'enable_blue':
					_host.panel.cfg.useAnimBlue = true;
					break;	
			}
			return ret;
		}
		/**
		*
		*
		*@param [value=-1]{Number} 只针对 volume,selectedIndex生效
		*/
		function prop(which:String,value:Number = -1):*{
			var ret:*// error
			switch(which){
				case 'isPlaying':
					ret = _host.core.isPlaying;
					break;
				case 'isPausing':
					ret = _host.core.isPausing;
					break;
				case 'playingIndex'://正在播放中的索引
					ret = _host.core.index;
					break;
				case 'selectedIndex':// 单击选中的索引
					if(value >= 0){
						this.select(value);
					}
					ret = _host.panel.list.selectedIndex;
					break;
				case 'info':
					ret	= _host.core.info;
					break;
				case 'data':
					ret	= _host.core.list;
					break;
				case 'volume':
					if(value >= 0 && value<=1){
						_host.core.volume = value;
						_host.panel.volume = _host.core.volume;
					}
					ret = _host.core.volume;
					break
				case 'orderPlay':
					ret = _host.core.cfg.useOrderPlay;
					break;
				default:
					break;
			}
			return ret;
		}		

		function select(index:int):void{
			if(index > -1 && index < _host.core.list.length){
				_host.core.index = index;
				_host.panel.list.selectedIndex = index;
				_host.panel.list.scrollToIndex(index);
				_host.panel.title = _host.core.item['label'];
			}
		}
		
		/*function setOrderPlay(b:Boolean):void{
			if(b){
				if(!_host.core.cfg.useAutoTrack){
					_host.core.cfg.toggleOrderPlay();
				}
			}else if(_host.core.cfg.useAutoTrack){
				_host.core.cfg.toggleOrderPlay();
			}
		}*/
		
		
		//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		private function _onDataChange(event:GmeFileEvent){
			var data:Object = {};
			
			switch(event.changeType){
				case GmeFileEvent.ERROR:	//Nothing
					break;
				case GmeFileEvent.ADDED:
					//this.panel.dp.addItemAt(this.core.list[0],0); //默认是放到第一个,
					data['data'] = [ _host.core.list[0] ];
					break;
				case GmeFileEvent.UPDATE:
					data['data'] = _host.core.list.length ? _host.core.list : [];
					break;
				default:
					break;
			}
			data['changeType'] = event.changeType;
			sendData(data,	event.type);
		}
		
		private function _onPlayChange(event:GmePlayEvent){
			var data:Object = {};
			data['changeType'] = event.state;
			sendData(data,	event.type);
		}
		
		function sendData(obj:Object,eventType:String = ''){
			if(_useYUI){
				this.YUISend(eventType	,	obj);
			}else{
				obj['type'] = eventType;
				OrSend(obj)
			}
		}
		
		function YUISend(eventType:String , data:Object = null){
			var pra = this._pra;
			ExternalInterface.call('YUI.applyTo',pra['yId'],pra['YUIBridgeCallback'],[pra['YUISwfId'],{'type':eventType,'response':data}]);
		}
		function OrSend(data:Object){
			try{
				ExternalInterface.call('window.'+this._JSCallback,data);
			}catch(err){}
		}
		
		
		static public function log(str:*){
			if(ExternalInterface.available){
				ExternalInterface.call('console.log',str);
			}
		}
		

	}
	
}
