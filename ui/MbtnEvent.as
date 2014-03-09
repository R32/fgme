package ui{
	
	import flash.events.Event;
	public class MbtnEvent extends Event{
		
		private var _which:String;
		
		public static const BTNCLICK:String = 'btnclick'
		
		public function MbtnEvent(which:String = '',type:String = 'btnclick',  bubbles:Boolean = true, cancelable:Boolean = false){
			_which = which;
			super(type, bubbles, cancelable)
		}
		
		public function get which():String{
			return _which;
		}
		
		override public function clone():Event {
			return new MbtnEvent(_which, type, bubbles, cancelable);
		}
		override public function toString():String {
			return "[MbtnEvent which=\"" + _which + "\" type=\"" + type + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
		}
	}
}
