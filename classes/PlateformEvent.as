package classes
{
	import flash.events.Event;
	
	/**
	 * Événements liés à la plateform
	 * @author Jean-Michel Simard
	 */
	public class PlateformEvent extends Event 
	{
		public static const LOAD_APP:String = "loadapp";
		public static const CLOSE_APP:String = "closeapp";
		public static const SET_HIGHSCORE:String = "sethighscore";
		public static const GET_HIGHSCORE:String = "gethighscore";
		public static const SOUND_CHANGE:String = "soundchange";
		
		public static const INFOS:String = "infos";
		public static const RESTARTED:String = "restarted";
		
		public var score:Number = 0;
		/**
		 * Événement de Plateform
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 * @param	_score Le score à transmettre
		 */
		public function PlateformEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, _score:Number = 0) 
		{ 
			super(type, bubbles, cancelable);
			score = _score;
		} 
		
		public override function clone():Event 
		{ 
			return new PlateformEvent(type, bubbles, cancelable, score);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PlateformEvent", "type", "bubbles", "cancelable","score", "eventPhase"); 
		}
		
	}
	
}