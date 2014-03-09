package ming {
	
	import ming.GameMusicEmu;
	import flash.utils.ByteArray;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Effect{
		
		/**
		 * @private
		 */
		internal var gme:GameMusicEmu;
		
		/**
		 * @private
		 */
		internal var baCur:ByteArray;
		
		/**
		 * @private
		 */
		internal var timer:Timer;
		
		// Fzip, index
		public function Effect():void{
			// constructor code
			this.gme = new GameMusicEmu(22050,1);// 第二个声音通道
			this.timer = new Timer(300)
			this.timer.addEventListener(TimerEvent.TIMER,_onTimer)
		}
		private function stop():void{
			this.gme.stop();
			this.timer.stop()
		}
		// 播放一个声响,需要主声道随便加载一个文件,这个才能正常加载
		public function play(ba:ByteArray,type:String,track:uint = 0):void{
			
			if(this.gme.isPlaying){
				this.gme.stop();
				this.timer.stop();
			}
			if(!(this.baCur && this.baCur===ba)){
				if(this.gme.emulatorType!==type){
					this.gme.init(type);
				}
				
				this.gme.loadData(ba);
				this.baCur = ba;
			}
			
			if(this.gme.track!==track){
				this.gme.track=track;
			}
			
			this.gme.setFade(5*1000);// 5秒限制
			this.gme.play();
			this.timer.start()
			
		}
		
		private function _onTimer(event:TimerEvent):void{
			if(this.gme.trackEnded()){
				this.stop();
			}
		}
		
		
		


	}
	
}
