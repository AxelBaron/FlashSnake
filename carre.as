package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	// La classe boule prend les propriétes et variables de le classe Element.
	public class carre extends Element  {
		// La tete se déplace vers le bas par défault au début du jeu
		public var xi:int=0;
		public var yi:int=25;
		
		public function carre() {
		this.addEventListener(Event.ENTER_FRAME,bouger);
			
		}
		
		// Fonction qui permet de bouger le tete du serpent, appellé à chaque frame.
		public function bouger(e:Event):void{
			this.ancienx=this.x;
			this.ancieny=this.y;
			this.x= this.x+xi;
			this.y= this.y+yi;
			Snake.check=false;
		}
			
		// Fonction de destruction de l'enterframe.		
		public function destroy():void{
				this.removeEventListener(Event.ENTER_FRAME,bouger);
		}
	}
}
