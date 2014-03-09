package  ming.event{
	import flash.events.Event;

	public class GmeFileEvent extends Event{

		private var _changeType:String;
		
		static public const FILECHANGE:String = 'filechange';
		//changeType
		static public const UPDATE:String = 'update';
		static public const ADDED:String = 'added';
		static public const ERROR:String = 'error';
		
		
		public function GmeFileEvent(changeType:String , bubbles:Boolean = false, cancelable:Boolean = false) {
			// constructor code
			this._changeType = changeType;
			super(GmeFileEvent.FILECHANGE,bubbles,cancelable)
		}
		/**
		 * changeType 有以下值.
		 * 
		 * <table class="innertable">
		 *  <tr>
		 *   <th> changeType </th>
		 *   <th> value </th>
		 * </tr>
		 *  <tr>
		 * 	  <td><code>GmeFileEvent.UPDATE</code></td>
		 *    <td><code> update </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code>GmeFileEvent.ADDED</code></td>
		 *    <td><code> added </code></td>
		 * </tr>
		 * 
		 *  <tr>
		 * 	  <td><code>GmeFileEvent.ERROR</code></td>
		 *    <td><code> error </code></td>
		 * </tr>
		 * </table>
		 */
		public function get changeType():String{
			return this._changeType;
		}
		
		override public function clone():Event {
			return new GmeFileEvent(this._changeType, bubbles, cancelable);
		}
		override public function toString():String {
			return "[GmeFileEvent type=\"" + type + "\" changeType=\"" + _changeType + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
		}

	}
}
