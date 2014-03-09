package ui {
	import flash.display.DisplayObject
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	/*
		event: btnclick, which = [play,pause,stop,prev,next,open]
	*/
	
	public class Buttons extends MovieClip {
		
		private var myTween:TweenMax;
		// bPlay,bPause,bStop,bPrev,bNext,bOpen
		private const COL:Array = ['bPlay','bStop','bPrev','bNext','bOpen'];//,'bPause'
		
		public function Buttons() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE,this.__init);
		}
		function __init(event:Event){
			this.removeEventListener(Event.ADDED_TO_STAGE,this.__init);
			
			//this.addChild(this.bPause);//移到最前
			this.bPause.visible = false;
			
			for(var i=0; i<this.COL.length; i+=1){
				if(this[COL[i]].mouseEnabled){
					this[COL[i]].alpha = 0.85;
				}
			}
			this.addEventListener(MouseEvent.MOUSE_OUT, _alphaLow);
			this.addEventListener(MouseEvent.MOUSE_OVER, _alphaHight);
			this.addEventListener(MouseEvent.CLICK, _dispatch);
		}		
		
		// 显示还是隐藏 *play* 按钮,当暂停或停止的时候才显示 *play*按扭,
		function showPlay(show:Boolean,anim:Boolean = true){
			if(show){
				if(this['bPause'].visible){
					this['bPause'].visible = false;
					this['bPlay'].visible = true;
					this.Anim(false);
				}
			}else if(this['bPlay'].visible){
				this['bPlay'].visible = false;
				this['bPause'].visible = true;
				anim && this.Anim(true);
			}
		}
		
		// 这个方法将移动到 panel类中去
		function Anim(start:Boolean){
			if(this['bPause'].visible && start){
				if(!this.myTween){//,colorMatrixFilter:{colorize:0x2D89EF, amount:1}
					this.myTween = new TweenMax(this['bPause'], 2 ,{glowFilter:{ color:0x2D89EF, alpha:1, blurX:30, blurY:20,strength:2},yoyo:true,repeat:-1});
				}else{
					this.myTween.resume();
				}
			}else if(this.myTween && !this.myTween.paused()){
				 this.myTween.pause(0,false);
			}
		}
		
		private function _dispatch(event:MouseEvent){
			var which:String;
			
			event.stopPropagation();
			if(event.target !==this && this.contains(event.target as DisplayObject)){
				which = event.target.name;
			}else{
				return;
			}
			
			/*switch(which){
				case 'bPlay':
					break;
				case 'bPause':
						//this.showPlay(true);
					break;
				case 'bStop':
						//this.showPlay(true);
						
					break;
				case 'bPrev':
					
					break;
				case 'bNext':
					
					break;
				case 'bOpen':
					 
					break;
				default:
					 break;
			}*/
			
			this.dispatchEvent(new MbtnEvent(which));//which.slice(1).toLowerCase()
		}
		
		
		// 希望可以有一种更好的写法来处理 pause 键的mouseout及over事件,这样写很混乱
		// override ???
		private function _alphaLow(event:MouseEvent){
				if(event.target ===	this  || event.target === this['bPause']){
					return;
				}
				event.target.alpha = 0.85;
				event.stopPropagation();
		}
		private function _alphaHight(event:MouseEvent){
				if(event.target ===this  || event.target === this['bPause']){
					return;
				}
				event.target.alpha = 1;
				event.stopPropagation();
		}
	}
	
}


