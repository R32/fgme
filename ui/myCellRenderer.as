package ui {
	
	import fl.controls.listClasses.CellRenderer;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import fl.events.ComponentEvent;
	import fl.controls.listClasses.ListData;
	
	public class myCellRenderer extends CellRenderer{
		var outTf:TextFormat;
		var overTf:TextFormat;
		
		private var isOverState:Boolean;
		
		public function myCellRenderer() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE,this.__init);
		}
		
		private function __init(event:Event){
			this.removeEventListener(Event.ADDED_TO_STAGE,this.__init);
			outTf = new TextFormat();
			overTf = new TextFormat();
			
			
			outTf.color =0xF3F3F3;
			outTf.font = "ceriph 05_53";
			outTf.size = 8;
			overTf.color =0x131313;
			overTf.font = "ceriph 05_53";
			overTf.size =8;
			
			
			
			this.alpha = 0.8;
			
			this.setStyle('textFormat',outTf);
			
			this.addEventListener(MouseEvent.MOUSE_OVER,_highLight)
			this.addEventListener(MouseEvent.MOUSE_OUT,_lowLight);
		}

		private function _highLight(event:MouseEvent = null){
			if(!this.isOverState){
				this.alpha = 1;
				this.setStyle('textFormat',overTf);
				this.isOverState = true
			}
			if(event is MouseEvent){
				event.stopPropagation();
			}
 
		}
		private function _lowLight(event:MouseEvent = null){
			if(!this.selected){
				this.alpha = 0.8;
				this.setStyle('textFormat',outTf);
				this.isOverState = false;
			}
			if(event is MouseEvent){
				event.stopPropagation();
			}
		}
		
       // override public function set listData(ld:ListData):void { 
            //super.listData = ld; 
       // }
		//  
		override public function set selected(value:Boolean):void{
			super.selected = value;
			if(value){
				this._highLight();
			}else if(this.isOverState){
				this._lowLight();
			}
		}
		
		override public function set label(value:String):void{
				
				var unicode:Boolean = false;
				
				for(var i:int = 0,len:int = value.length; i<len; i+=1){
					if(value.charCodeAt(i) > 255){
						unicode = true;
						break;
					}
				}
				this.setStyle('embedFonts', !unicode );
				
				super.label = value;
		}
      
		

	}
	
}
