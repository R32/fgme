package  ming.event{
	import flash.events.Event;
	// 这个类好像都用不到了
	public class GmePlayEvent extends Event{

		private var _state:String;
		
		static public const PLAYCHANGE:String = 'playchange';
		
		// 一些自动事件
		static public const LOAD:String = 'load';	// 加载数据,如果同一文件不会出现重复加载
		static public const STOP:String = 'stop';	// 停止播放
		static public const NEXT:String = 'next';	
		static public const PREV:String = 'prev';
		static public const TRACKNEXT:String = 'tracknext';
		static public const TRACKPREV:String = 'trackprev';
		public function GmePlayEvent(state:String , bubbles:Boolean = false, cancelable:Boolean = false) {
			// constructor code
			this._state = state;
			super(GmePlayEvent.PLAYCHANGE , bubbles, cancelable)
		}
		
		/**
		 * state 有以下值.
		 * 
		 * <table class="innertable">
		 *  <tr>
		 *   <th> state </th>
		 *   <th> value </th>
		 * </tr>
		 *  <tr>
		 * 	  <td><code> GmePlayEvent.LOAD </code></td>
		 *    <td><code> load </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code> GmePlayEvent.STOP </code></td>
		 *    <td><code> stop </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code> GmePlayEvent.NEXT </code></td>
		 *    <td><code> next </code></td>
		 * </tr>
		 *  <tr>
		 * 	  <td><code> GmePlayEvent.PREV </code></td>
		 *    <td><code> prev </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code> GmePlayEvent.TRACKNEXT </code></td>
		 *    <td><code> tracknext </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code> GmePlayEvent.TRACKPREV </code></td>
		 *    <td><code> trackprev </code></td>
		 * </tr>
		 * </table>
		 */
		public function get state():String{
			return this._state;
		}
		
		override public function clone():Event {
			return new GmePlayEvent(this._state, this.bubbles, this.cancelable);
		}
		override public function toString():String {
			return "[GmePlayEvent type=\"" + type + "\" state=\"" + _state + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
		}

	}
}
