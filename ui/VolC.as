package ui {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	
	public class VolC extends MovieClip {
		
		/*
			--- Flash 元件---		
			vTf		simpleButton 
			vSlide	ui.Vslide
			vMixer  simpleButton 	mixer-btn- 
			vAuthor TextField
			
		*/
		
		function get vol():uint{
			return this.vSlide.value;	// 0~100
		}
		
		function set vol(n:uint){
			if(n>100 || isNaN(n)){
				n = 100;
			}else if(n < 0){
				n = 0;
			}
			this.vTf.text = ''+n;
			this.vSlide.value = n;
		}

		
		public function VolC() {
			this.addEventListener(Event.ADDED_TO_STAGE,this.__init);
		}
		function __init(event:Event){
			this.removeEventListener(Event.ADDED_TO_STAGE, __init);
	
			
			this.vSlide.init();
			
			this.vSlide.addEventListener(Vslide.UPDATE, _volumeUpdate);
			
			// init log
			this.vAuthor.htmlText = '<a href="http://t.qq.com/hot_up" target="_blank">fixme</a>'
			
			this.vAuthor.alpha = 0.9;
			this.vMixer.alpha = 0.8;
			this.vTf.alpha = 0.8;
			this.vSlide.enable = true;
			
			
			this.addEventListener(MouseEvent.CLICK,this._dispatch);
			this.addEventListener(MouseEvent.MOUSE_OVER,this._alphaHight);
			this.addEventListener(MouseEvent.MOUSE_OUT,this._alphaLow);
		}
		
		function _dispatch(event:MouseEvent){
			var which:String;
			
			event.stopPropagation();
			
			if(event.target !==this && this.contains(event.target as DisplayObject)){
				which = event.target.name;
			}else{
				return;
			}
			
			switch(which){
				case 'vTf':
					this._volumeMax();
					break;
				case 'vMixer':
					break;
				default://trace('未知点击');
					return;
					break;
			}
			this.dispatchEvent(new MbtnEvent(which));
		}
		
		// 这个绑定可能会移除,由外部来控制
		private function _volumeMax(){
			this.vol = 100;
		}
		
		private function _volumeUpdate(event:Event){
			this.vTf.text = event.currentTarget.value + '';
			this.dispatchEvent(new MbtnEvent(event.currentTarget.name));
		}
		
		
		private function _alphaLow(event:MouseEvent){
			if(event.target!==this){
				event.target.alpha = 0.8;
			}
			event.stopPropagation();
		}
		private function _alphaHight(event:MouseEvent){
			if(event.target!==this){
				event.target.alpha = 1;
			}
			event.stopPropagation();
		}
	}
	
}
