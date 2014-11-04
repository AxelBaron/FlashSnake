package  
{
	/**
	 * Classe utilisée par l'application elle-même
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	//la classe suivante (PlateformEvent) doit être importée afin de pouvoir lancer (dispatchEvent) des événement à l'application Plateform
	import classes.PlateformEvent;
	
	// Imports pour le jeu :
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	/**
	 * Gabarit de classe document pour Plateform
	 * @author ...
	 * @version ...
	 */
	public class Snake extends MovieClip
	{
		// Différents tableaux de jeux. 1 acceuil, 2 jeu, 3 Game Over
		private var _accueil:MovieClip;
		private var _jeu:MovieClip;
		private var _pointage:MovieClip;
		
		//Variables utilisés pour le fonctionnement du jeu
		public var tableau:Array;
		public var tete:carre;
		private var _music:Sound;
		private var _channel:SoundChannel;
		public var dir:String;
		private var _pomme:MovieClip;
		private var _longeurSerpent:int;
		var _uneboule:boule;
		public static var check:Boolean=false;

		public function Snake() :void
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
		
		// Fonction qui gere le fonctionnement de la page d'acceuil.
		private function init(e:Event = null):void 
		{
			//destruction de l'écouteur d'ajout à la scène
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//creation de l'instance
			_accueil = new AccueilMC();
			
			_music = new music();
			//association d'un canal pour contrôler le son, si nécessaire
			//jouer la musiaue en loop (999 fois)
			//_channel = _music.play(0, 999);
			
			//ecouteur de click
			// Je sais pas pouquoi quand je met sa les controles ne marchent plus.
			//_accueil.btnJouer.buttonMode=true;
			_accueil.btnJouer.addEventListener(MouseEvent.CLICK, onStartGame);
			
			
			//et on dit que quand on clik, le jeu va commencer (ctrl+shit+1) sur onStartGame
			
			//ajouter a l'affichage
			addChild(_accueil);
		}
		
		// Fonction qui La creation de la page d'accueil.
		private function onStartGame(e:MouseEvent):void 
		{
			//enlever l'accueil de l'affichage si elle est présente
			//si la page contient accueil, alors on la retire
			if (contains(_accueil)){
				removeChild(_accueil);
			}
			
			//creation de la page jeu si elle n'existe pas deja
			if (_jeu == null){
				_jeu = new JeuMC();
			}
			
			//ajout du jeu a l'affichage
			addChild(_jeu);
			startGame();
		}
		
		private function onEndGame(e:MouseEvent):void 
		{
			//enlever l'accueil de l'affichage si elle est présente
			//si la page contient accueil, alors on la retire
			if (contains(_pointage)){
				removeChild(_pointage);
				_pointage.btnReJouer.removeEventListener(MouseEvent.CLICK, onEndGame);
			}
			
			//creation de la page jeu si elle n'existe pas deja
			if (_jeu == null){
				_jeu = new JeuMC();
				addChild(_jeu);
				startGame();
			}
			
			//ajout du jeu a l'affichage
			
		}
		
		public function startGame():void 
		{	
			stage.focus=stage;
			check=false;
			_pointage = new PointageMC();
			_pointage.btnReJouer.buttonMode=true;
			_pointage.btnReJouer.addEventListener(MouseEvent.CLICK, onEndGame);
			tableau= new Array();
			tete=new carre();
			dir="down";


			// Fontion pour mettre les boules de bases avec le serpent.
			addboule();
			// ne pas mettre dans stage car sa va planter l'appli du prof.
			// Il faut mettre ca dans un truc jeu, voir code du tp2
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownListener);
			_jeu.addEventListener(Event.ENTER_FRAME,gameloop);
			
			// Placement pomme départ
			_pomme = new pomme();
			addChild(_pomme);
			_pomme.x = random(20, 480);
			_pomme.y = random(20, 480);
			
			
		}
		
		
		//c'est ca qui demarre la mecanique du jeu
		private function keyDownListener(e:KeyboardEvent):void{

			// Si on appuie sur la touche bas, la tete du serpant décend de 25px.
				if(check==false){
					
				
					if (e.keyCode == Keyboard.DOWN && dir != "up") {
						tete.yi=25;
						tete.xi=0;
						dir = "down";
						check = true;
					}
					
					if (e.keyCode == Keyboard.UP && dir != "down") {
						tete.yi=-25;
						tete.xi=0;
						dir = "up";
						check = true;
					}
					
					if (e.keyCode == Keyboard.LEFT && dir != "right") {
						tete.yi=0;
						tete.xi=-25;
						dir = "left";
						check = true;
					}
					
					if (e.keyCode == Keyboard.RIGHT && dir != "left") {
						tete.yi=0;
						tete.xi=25;
						dir = "right";
						check = true;
					}
				}
		}
		
		
		private function gameloop(e:Event){
			deplaceboule();
			detectcolision();
			
			// Fin du jeu, si le serpent sort de l'écran.
			// Je rencontre un problème. Il semblerait
			// que la colision soit calculée par rapport au coin gauche de
			// la tête du serpent. Quand la tête sort à droite ou en bas de la scène,
			// il faut attendre qu'elle traverse complètement la scène avant
			//  de lancer un "gameover". Du coup, j'ai réduit la zonne de colision
			// pour que celle-ci entre en colision directement dès que la 
			// tête du serpent touche un bord de le scène.
			// (500 taille de la scene - 25 taille de la tete du serpant)
			if(tete.x < 0 || tete.x > 475 || tete.y <0 || tete.y > 475) 
				{
					// Appeler Fin partie
					gameOver();
				}
				
			}
			
		
		// Collision pomme et tete du serpent
		private function detectcolision(){
				if(tete.hitTestObject(_pomme)) {
				
				// replacement de la pomme remplacer par rand_range
				_pomme.x = random(10, 490);
				_pomme.y = random(10, 490);
				_longeurSerpent++;
				nouvelleboule();
				// La longeur du corps augmente
				//longeur du corps ++ <- creer une variable pour la longeur du corps.
				}
				
				for (var a:int = 3; a< tableau.length; a++){ 
					if(tete.hitTestObject(tableau[a])) {
						gameOver();
					}
				}
		}
			
		function addboule():void{
			// Ajouter la tete
			tete.x=0;
			tete.y=0;
			tableau.push(tete);
			_jeu.addChild(tableau[0]);
			
			//Ajouter 5 boules de départ
			for(var i:int=1;i<4;i++){
					_uneboule= new boule();
					_uneboule.x=25*i;
					_uneboule.y=0;
					tableau.push(_uneboule);
					_jeu.addChild(tableau[i]);
				}
			
			}
		
		function nouvelleboule():void{
			
			_uneboule = new boule();
			_uneboule.x=tableau[tableau.length-1].ancienx;
			_uneboule.y=tableau[tableau.length-1].ancieny;
			tableau.push(_uneboule);
			_jeu.addChild(_uneboule);
				
			}
			
		function deplaceboule(){
				for(var i:int=1;i<tableau.length;i++){
					tableau[i].ancienx=tableau[i].x;
					tableau[i].ancieny=tableau[i].y;
					tableau[i].x=tableau[i-1].ancienx;
					tableau[i].y=tableau[i-1].ancieny;
				}
				
				//Accélerer ou diminuer la vitesse du jeu !
				sleep(100);
				//check =false;
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
		
		
		function random(min:Number, max:Number):Number {
						return Math.random()*(max-min)+min;
					}
		
		public function gameOver():void  
		{
			_jeu.removeEventListener(Event.ENTER_FRAME,gameloop);
			
			for(var i:int=1;i<tableau.length;i++){
					_jeu.removeChild(tableau[i]);
				}
				
			tableau.length = 0;
			tete.destroy();
			_jeu.removeChild(tete);

			// Enleve la page jeu et ajouter la page pointage
			_jeu = null;
				
			
			trace(_longeurSerpent);
			//_longeurSerpent=0;
				
			_pointage.txtPointage.text=_longeurSerpent.toString();	
			addChild(_pointage);
				
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
				_accueil.btnJouer.removeEventListener(MouseEvent.CLICK, onStartGame);
				_pointage.btnReJouer.removeEventListener(MouseEvent.CLICK, onEndGame);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownListener);
				removeChild(_accueil);
				removeChild(_jeu); 
				removeChild(_pointage); 
				removeChild(tete);
				_channel.stop();
			
		}
	
	}

}