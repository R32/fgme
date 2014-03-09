package  ming.event{
	import flash.events.Event;
	
	public class GmeCfgEvent extends Event{

		private var _which:String;
		
		static public const CONFIGCHANGE:String = 'configchange';
		
		static public const TRACK:String = 'track';
		static public const ORDER:String = 'order';
		static public const FADEOUT:String = 'fadeout';
		
		
		public function GmeCfgEvent(which:String ,  bubbles:Boolean = false, cancelable:Boolean = false) {
			// constructor code
			this._which = which;
			super(GmeCfgEvent.CONFIGCHANGE, bubbles, cancelable)
		}
		/**
		 * which有以下值.
		 *
		 * <table class="innertable">
		 *  <tr>
		 *   <th> which </th>
		 *   <th>value</th>
		 * </tr>
		 *  <tr>
		 * 	  <td><code> GmeCfgEvent.TRACK </code></td>
		 *    <td><code> track </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code> GmeCfgEvent.ORDER </code></td>
		 *    <td><code> order </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code> GmeCfgEvent.FADEOUT </code></td>
		 *    <td><code> fadeout </code></td>
		 * </tr>
		 * </table>
		 */
		public function get which():String{
			return this._which;
		}
		
		override public function clone():Event {
			return new GmeCfgEvent(this._which, bubbles, cancelable);
		}
		override public function toString():String {
			return "[GmeCfgEvent type=\"" + type + "\" which=\"" + _which + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
		}

	}
}