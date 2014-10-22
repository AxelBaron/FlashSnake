package  
{
	/**
	 * Classe utilisée par l'application elle-même
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	/**
	 * Important !!!!!
	 * la classe suivante (PlateformEvent) doit être importée afin de pouvoir lancer (dispatchEvent) des événement à l'application Plateform
	 */
	import classes.PlateformEvent;
	
	/**
	 * Gabarit de classe document pour Plateform
	 * @author Axel Baron
	 * @version ...
	 */
	public class ClickVite extends MovieClip
	{
		/**
		 * Constructeur de la classe
		 */
		private var _accueil:MovieClip;
		private var _jeu:MovieClip;
		private var _pointage:MovieClip;
		
		//jeu
		
		public var tableau:Array= new Array();
		public var tete:carre=new carre();
		private var _music:Sound;
		private var _channel:SoundChannel;
		public var dir:String ="down";
		
		public function ClickVite() :void
		{
			/**
			 * IMPORTANT !!!!!!!
			 */
			if (stage) init()
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * ******************************************************************************************************************************************************
		 * Fonctions internes privées
		 * Ces fonctions sont utiles à votre application (mécanique interne)
		 * Vous pouvez en créer comme bon vous semble
		 * ******************************************************************************************************************************************************
		 */
		
		/**
		 * Appelée lorsque l'application est initialisée sur la scène
		 * Cette fonction est nécessaire afin d'éviter des erreurs possibles
		 * @param	e Event.ADDED_TO_STAGE
		 */
		private function init(e:Event = null):void 
		{
			//destruction de l'écouteur d'ajout à la scène
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			///////////////////////////////////////////////////////////
			///point d'entrée de votre application commence ici //
			///////////////////////////////////////////////////////////
			
			//code...
			//creation de l'instance
			_accueil = new AccueilMC();
			
			_music = new music();
			//association d'un canal pour contrôler le son, si nécessaire
			//bon pour les musique, son devant joueur en boucle, etc.
			//jouer la musiaue en loop (999 fois)
			_channel = _music.play(0, 999);
			

			
			//ecouteur de click
			_accueil.btnJouer.addEventListener(MouseEvent.CLICK, onStartGame);
			//et on dit que quand on clik, le jeu va commencer (ctrl+shit+1) sur onStartGame
			
			//ajouter a l'affichage
			addChild(_accueil);
		}
		
		private function onStartGame(e:MouseEvent):void 
		{
			//enlever l'accueil de l'affichage si elle est présente
			if (contains(_accueil))
			//si la page contient accueil, alors on la retire
			{
					removeChild(_accueil);
			}
			
			//creation de la page jeu si elle n'existe pas deja
			if (_jeu == null)
			{
					_jeu = new JeuMC();
			}
			
			//ajout du jeu a l'affichage
			addChild(_jeu);
			
			
			//jeux snake a mettre ici !
			tete.x=0;
			tete.y=0;
			tableau.push(tete);
			for(var i:int=1;i<5;i++){
				var uneboule:boule= new boule();
				uneboule.x=25*i;
				uneboule.y=0;
				
				tableau.push(uneboule);
			}
	
			for(i=0;i< tableau.length;i++){
				_jeu.addChild(tableau[i]);
			}
			// ne pas mettre dans stage car sa va planter l'appli du prof.
			// Il faut mettre ca dans un truc jeu, voir code du tp2
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownListener);
			_jeu.addEventListener(Event.ENTER_FRAME,deplaceboule);
			
			
		}
		
		//c'est ca qui demarre la mecanique du jeu
		private function keyDownListener(e:KeyboardEvent):void{

			// Si on appuie sur la touche bas, la tete du serpant décend de 25px.
					
					if (e.keyCode == Keyboard.DOWN && dir != "up") {
						tete.yi=25;
						tete.xi=0;
						dir = "down";
					}
					
					if (e.keyCode == Keyboard.UP && dir != "down") {
						tete.yi=-25;
						tete.xi=0;
						dir = "up";
					}
					
					if (e.keyCode == Keyboard.LEFT && dir != "right") {
						tete.yi=0;
						tete.xi=-25;
						dir = "left";
					}
					
					if (e.keyCode == Keyboard.RIGHT && dir != "left") {
						tete.yi=0;
						tete.xi=25;
						dir = "right"; 
					}
		}
		
		
		
		private function deplaceboule(e:Event){
				for(var i:int=1;i<tableau.length;i++){
					tableau[i].ancienx=tableau[i].x;
					tableau[i].ancieny=tableau[i].y;
					tableau[i].x=tableau[i-1].ancienx;
					tableau[i].y=tableau[i-1].ancieny;
				}
				
				//Accélerer ou diminuer la vitesse du jeu !
				sleep(100);
		}
		
		// Fonction Sleep trouvé sur internet. Elle met le jeu en pause
		function sleep(ms:int):void {
			var init:int = getTimer();
			while(true) {
				if(getTimer() - init >= ms) {
				break;
				}
			}
		}
		
		// Faire passer le serpent de part et d'autre de la scene
		// Gérer l'apparition des pommes
		// Fonction pour ajouter une boule pour la queue du serpant quand une pomme est manger
		// Colision. Si il y a, afficher le panneau de Game Over.
		
		/**
		 * ******************************************************************************************************************************************************
		 * Fonctions Plateform Publiques
		 * Ces fonctions sont appelées par l'application mère et non par vous
		 * ATTENTION : Vous devez ajouter les instructions voulues dans les fonctions, mais vous ne devez pas les effacer ou changer leur nom
		 * ******************************************************************************************************************************************************
		 */
		
		/**
		 * Appelée lorsque l'utilisateur ferme le jeu
		 * Il faut détruire les différents écouteur encore existants, détruire les sons, les timers, etc.
		 */
		public function unloadApp():void {
			///ici vous devez détruire tout ce qui ne l'est pas déja (écouteur, movieClip, sons, timer, références, etc..)
			//detruire les timers si ils existent
			
			//Détruire la musique ?
			
		}
	}
}