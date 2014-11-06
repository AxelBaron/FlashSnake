package  
{
	/**
	 * Classe utilisée par l'application elle-même
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// Imports pour le jeu :
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	
	//la classe suivante (PlateformEvent) doit être importée afin de pouvoir 
	//lancer (dispatchEvent) des événement à l'application Plateform
	import classes.PlateformEvent;
	
	/**
	 * Gabarit de classe document pour Plateform
	 * @author Axel Baron
	 * @version finale
	 */
	 
	 
	 
	 
	 
	public class Snake extends MovieClip
	{
		// Différentes pages ecran du jeu.1 acceuil, 2 jeu, 3 Game Over
		private var _accueil:MovieClip;
		private var _jeu:MovieClip;
		private var _pointage:MovieClip;
		
		//Variables utilisés pour le fonctionnement du jeu
		public var tableau:Array;
		private var _music:Sound;
		private var _channel:SoundChannel;
		public var dir:String;
		private var _pomme:MovieClip;
		private var _longeurSerpent:int;
		public static var check:Boolean;
		var timer:int;
		public var ms:int;
		
		// Varibles qui extendent de classes situés dans les autre fichiers
		public var tete:carre;
		var _uneboule:boule;

		
		
		
		
		public function Snake() :void
		{
			/*IMPORTANT !!!!!!!
			* Appelée lorsque l'application est initialisée sur la scène
			* Cette fonction est nécessaire afin d'éviter des erreurs possibles
			* @param	e Event.ADDED_TO_STAGE
			*/
			if (stage) init()
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
				
		
		
		
		// Fonction initiale, qui crée la musique, initialise des variables
		// et crée la page d'accueil.
		private function init(e:Event = null):void 
		{
			//destruction de l'écouteur d'ajout à la scène
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//creation de l'instance
			check = false;
			
			_music = new music();
			//jouer la musiaue en loop (999 fois)
			_channel = _music.play(0, 999);
			
			//ecouteur de click
			
			
			//ajouter a l'affichage
			_accueil = new AccueilMC();
			_accueil.btnJouer.addEventListener(MouseEvent.CLICK, onStartGame);
			addChild(_accueil);
		}
		
		
		
		
		
		
		// Quand on clic sur jouer, cette fonction est appellé.
		// Elle appelle la fonction startGame, qui contient la mécanique de jeu.
		private function onStartGame(e:MouseEvent):void 
		{
			//enlever l'accueil de l'affichage si elle est présente
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
		
		
		
		
		
		
		
		
		public function startGame():void 
		{	
			// Permet de ne pas devoir cliquer sur le jeu pour utiliser les touches
			stage.focus=stage;
			
			// Initialisation de variables utilies pour le jeu.
			check=false;
			_pointage = new PointageMC();
			_pointage.btnReJouer.buttonMode=true;
			_pointage.btnReJouer.addEventListener(MouseEvent.CLICK, onEndGame);
			tableau= new Array();
			tete=new carre();
			dir="down";


			// Appel Fontion pour mettre les boules de départ avec le serpent.
			addboule();
			
			// Ecouteur de clavier et apelle de multiples fonction a chaque frame.
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownListener);
			_jeu.addEventListener(Event.ENTER_FRAME,gameloop);
			
			// Placement pomme départ
			_pomme = new pomme();
			addChild(_pomme);
			_pomme.x = random(20, 480);
			_pomme.y = random(20, 480);
			
			
		}
		
		
		//Gestion des touche, ce qu'il se passe quand on appuyes dessus.
		private function keyDownListener(e:KeyboardEvent):void{

				if(check==false){
				// Systeme de vérification avec false et dir.Il est impossible d'enchainer
				// la touche haut/bas et gauche/droite l'une après l'autre.
				// Impossible de se manger la queue via une fausse manip.
					
					// Si on appuie sur la touche bas, la tete du serpant décend de 25px.
					if (e.keyCode == Keyboard.DOWN && dir != "up") {
						tete.yi=25;
						tete.xi=0;
						dir = "down";
						check = true;
					}
					
					// Si on appuie sur la touche haut, la tete du serpant monte de 25px.
					if (e.keyCode == Keyboard.UP && dir != "down") {
						tete.yi=-25;
						tete.xi=0;
						dir = "up";
						check = true;
					}
					
					// Si on appuie sur la touche gauche, la tete du serpant décale de 25px.
					if (e.keyCode == Keyboard.LEFT && dir != "right") {
						tete.yi=0;
						tete.xi=-25;
						dir = "left";
						check = true;
					}
					
					// Si on appuie sur la touche droite, la tete du serpant décale de 25px.
					if (e.keyCode == Keyboard.RIGHT && dir != "left") {
						tete.yi=0;
						tete.xi=25;
						dir = "right";
						check = true;
					}
				}
		}
		
		
		
		
		// Fonction apellé à chaque frame.
		//Elle vérifie les colision possibles avec le serpent et le fait se déplacer.
		private function gameloop(e:Event){
			deplaceboule();
			detectcolision();
			
			// Fin du jeu, si le serpent sort de l'écran.
			// Il semblerait que la colision soit calculée par rapport au coin gauche de
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
			
		
			
			
			
			
			
		// Fonction Collision pomme/tete du serpent
		private function detectcolision(){
				if(tete.hitTestObject(_pomme)) {
				
				// replacement de la pomme si colision avec tete.
				_pomme.x = random(10, 490);
				_pomme.y = random(10, 490);
				_longeurSerpent++;
				
				// La longeur du corps augmente
				nouvelleboule();
				
				}
				
				// Boucle pour gerer la colision de la tete du serpent avec sa queue.
				for (var a:int = 3; a< tableau.length; a++){ 
					if(tete.hitTestObject(tableau[a])) {
						// Si colision entre les deux, game over !
						gameOver();
					}
				}
		}
		
		
		
		
		
		// Fonction appellé au démarage du jeu.Elle place la tete et la queue du serpent
		// au départ du jeu.
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
		
			
			
		// Fonction qui gere l'ajout de "queue" lorsque le serpent mange une pomme.
		function nouvelleboule():void{
			
			_uneboule = new boule();
			_uneboule.x=tableau[tableau.length-1].ancienx;
			_uneboule.y=tableau[tableau.length-1].ancieny;
			tableau.push(_uneboule);
			_jeu.addChild(_uneboule);
				
			}
		
			
		// Fonction qui fait suivre le chemin de le tete par les queues 
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
		public function sleep(ms):void {
			timer= getTimer();
			while(true) {
				if(getTimer() - timer >= ms) {
				break;
				}
			}
		}
		
		
		
		
		// Fonction random, qui est apellée pour le placement de pomme.
		function random(min:Number, max:Number):Number {
						return Math.random()*(max-min)+min;
		}
		
					
					
					
					
		// Fonction qui affiche le game over. Détruit des varibles et affiche le score.			
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
			_pointage.txtPointage.text=_longeurSerpent.toString();
			dispatchEvent(new PlateformEvent(PlateformEvent.SET_HIGHSCORE,true,false,_longeurSerpent));
			addChild(_pointage);
			_longeurSerpent=0;
				
		}
		
		
		
		
		// Fonction appellé à la fin du jeu. Détruit des variable et relance le jeu.		
		private function onEndGame(e:MouseEvent):void 
		{
			//enlever l'accueil de l'affichage si elle est présente
			//si la page contient accueil, alors on la retire
			if (contains(_pointage)){
				dispatchEvent(new PlateformEvent(PlateformEvent.RESTARTED,true));
				removeChild(_pointage);
				_pointage.btnReJouer.removeEventListener(MouseEvent.CLICK, onEndGame);
			}
			
			//creation de la page jeu si elle n'existe pas deja
			if (_jeu == null){
				_jeu = new JeuMC();
				addChild(_jeu);
				startGame();
			}
			
		}
		
		
		
		/**
		 * ******************************************************************************************************************************************************
		 * Fonctions Plateform Publiques
		 * Ces fonctions sont appelées par l'application mère et non par vous
		 * ATTENTION : Vous devez ajouter les instructions voulues dans les fonctions, mais vous ne devez pas les effacer ou changer leur nom
		 * ******************************************************************************************************************************************************
		 */
		
		
		//Appelée lorsque l'utilisateur ferme le jeu. Elle détruit toutes les varibles.
		public function unloadApp():void {
		
			
				if( _accueil != null && contains(_accueil)){
					removeChild(_accueil);
					_accueil.btnJouer.removeEventListener(MouseEvent.CLICK, onStartGame);
				}
				
				if (_music != null){
					_channel.stop();
					_music = null;
				}
			
				if( _jeu != null && contains(_jeu)){
					stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownListener);
					removeChild(_jeu);
					_jeu.removeEventListener(Event.ENTER_FRAME,gameloop);
					
					if (tete != null && contains(tete)){
						removeChild(tete);
					}
					if (_pomme != null && contains(_pomme)){
						removeChild(_pomme);
					}
					
					if (_uneboule != null && contains(_uneboule)){
						removeChild(_uneboule);
					}
					
					for(var i:int=1;i<tableau.length;i++){
					_jeu.removeChild(tableau[i]);
					}
				}
				
				
				if( _pointage != null && contains(_pointage)){
					removeChild(_pointage);
					_pointage.btnReJouer.removeEventListener(MouseEvent.CLICK, onEndGame);
				}
				
				
		}
	
	}
}