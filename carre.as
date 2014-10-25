package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class carre extends Element  {
		public var xi:int=0;
		public var yi:int=25;
		
		public function carre() {
		this.addEventListener(Event.ENTER_FRAME,bouger);
			
		}
		
		public function bouger(e:Event):void{
			this.ancienx=this.x;
			this.ancieny=this.y;
			this.x= this.x+xi;
			this.y= this.y+yi;
		}
			
			public function destroy():void{
				this.removeEventListener(Event.ENTER_FRAME,bouger);
			}
	
	}
}
