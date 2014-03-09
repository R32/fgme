package ui {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/*
		音量控制
		
		--- Flash 元素 ---
		
		vMask --- MovieClip 
		
	*/
	public class Vslide extends MovieClip {
		
		

		static const UPDATE:String = 'vslideChange'
		
		
		private var _step:Number
		private var _max:Number;
		private var _min:Number;
		
		private var _value:Number;
		private var _disable:Boolean;
		
		public function Vslide() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE,this.__init);
		}
		
		function get value():uint{
			return _value;
		}
		
		function set value(n:uint){
			if(n>100 || isNaN(n)){
				n = 100;
			}else if(n<0){
				n = 0;
			}
			_value = n;
			vMask.x = ~~((n-100)/2);
		}
		
		function set enable(b:Boolean){
			if(b){
				this.alpha = 0.8;
				this.buttonMode = true;
				_disable = false;
			}else{
				this.alpha = 0.3;
				this.buttonMode = false;
				_disable = true;
			}
		}
		
		
		private function __init(event:Event){
			this.removeEventListener(Event.ADDED_TO_STAGE,this.__init);
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.CLICK,_x2);
		}
		// 将 MouseEvent.localX 的值转换成 0~100之间的数,UI宽度为50
		private function _x2(event:MouseEvent){
			 // event.localX<<1 ?
			if(!this._disable){ 
				this.value = ~~(event.localX*2);
				this.dispatchEvent(new Event(UPDATE));	//监听这个类的事件,获得 value的值就行了
			}
			event.stopPropagation();
		}
		
		function init(max:Number =100,min:Number = 0){
			_max = max;
			_min = min;
			_step = (max - min)/100;
		}
		/**
		*@param n{Number} 如果  init 的初使值不是默认值,即 max=100,min=0;
		*	则传值时则需要调用这个方法将值转换成 0~100之间的数字
		*	事实上,这个函数本来应该放在 set value 内部的,不想弄得太复杂
		*/
		function cvt(n:Number):uint{
			if(n > _max){
				n = _max;
			}else if(n < _min){
				n = _min;
			}
			return ~~(n/_step);// 返回0~100的数字
		}
	}
	
}
