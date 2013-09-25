package org.wsimpson.visualization.experiment
/**
* @name		ScreenControl.as
* Purpose	Interactive for selecting color scales
* @author	William Simpson
* Note:		De Facto Controller
* Copyright (c) 2010 William J Simpson - All Rights Reserved
*/
{
	// Adobe Classes
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	
	// Tool for creating Unique ID
	import ascb.util.NumberUtilities;
	
	// Formatting
	import org.wsimpson.format.NumberFormat;

	// Debugging
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.DebugUtilConst;
	
	// Data Sources
	import org.wsimpson.store.OrderStore;
	import org.wsimpson.visualization.experiment.ScreenModel;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.ScreenView;
	
	public class ScreenControl extends MovieClip
	{
		// File ID
		public static const SURVEY_PARTICIPANT = "PID";		// The unique identifier generated during the HTML survey for the participant
		public static const SURVEY_CARD = "CARD";			// The randomly selected card that is used to choose a session display order

		// XML Definition
		private static const TEMPLATE_PARAM = 
			"<parameters>\n\t{Message}\n\t</parameters>";
		public static const MESSAGE = "{Message}";				// Substitution String	
		
		// Instance Variables
		private	var _debugger:DebugUtil;					// Output and diagnostic window
		private	var _screenModel:ScreenModel;				// Manage access to the various ScreenControl
		private	var _screenView:ScreenView;					// View Class for displaying ScreenControl
		private var _bInit:Boolean;							// Init has been reached
		private var _bReady:Boolean;						// Init has been reached
		private var _bPreloadComplete:Boolean;				// Init has been reached
		private	var _appStage:Object;						// References the active stage
		private	var _participantUID:String;					// UniqueID created on load
		private	var _activeScreen:XML;						// Screen currently displayed
		private var _parameters:Object;						// Associative Array of parameters passed to the Flash Object
		private	var _hashStore:OrderStore;					// Manages Name / Value recording
		
		// Constructor
		function ScreenControl(inStage:Object)
		{
			this._appStage = inStage;
			this._debugger = DebugUtil.getInstance();
			this._debugger.assignDebugState(DebugUtilConst.DEBUG_TRACE);			
			this._debugger.assignDebugState(DebugUtilConst.DEBUG_TIMESTAMP);			
			this._debugger.initialize();
			this._debugger.wTrace("ScreenControl.constructor -> Testing the javascript console ");
			this._debugger.wTrace("ScreenControl.constructor -> this._appStage.alpha " + this._appStage.alpha);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			this._bInit = false;
			this._bReady = false;
			this._bPreloadComplete = false;
			this._hashStore = new OrderStore();
			
			// Get Model Singleton
			this._screenModel = ScreenModel.getInstance();
			
			// Setup listeners
			this.addEventListener(IOErrorEvent.IO_ERROR,errorEvent);
			this._parameters = this._appStage.parameters;

			// Unique Identifier Generation
			this.assignUID();
			
			// Load content
			this._screenModel.initialize(this);
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/

		/**
		*  Name:  	errorEvent
		*  Purpose:  Catches error events
		*/				
		private function errorEvent(event:ErrorEvent):void
		{
			var tempStr:String;
			tempStr = (event == null) ? "Unknown" : event.toString();
			
			// Initialize the display
			if (this._screenView)
			{
				this._screenView.reportError(ScreenModel.DEFAULT_ERROR,"\nError = " + tempStr);
			} else
			{
				this._debugger.errorTrace("\nError = " + tempStr);
			}
		}

		private function onEnterFrame(event:Event):void
		{
			if(framesLoaded == totalFrames)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				this.x = this.y = 0;
				addChild(this._debugger);
				//this._debugger.show();
				this._bReady = true;
				this.initialize();
			}
		}
		
		/**
		*  Name:  	screenFilesLoaded
		*  Purpose:	Resources have completed loading
		*/
		public function screenFilesLoaded():void
		{
			this._screenView.createGlyphs();
			this.hidePreloader();
			this._debugger.wTrace("ScreenControl.screenFilesLoaded ");
			if (this._activeScreen != null)
			{
				this._screenView.displayScreen(this._activeScreen);
			}
		}

		/**
		*  Name:  	hidePreloader
		*  Purpose:	Initiate the load of the next screen
		*/
		public function hidePreloader():void
		{
			this._appStage.preloader.visible = false;
		}
		
		/**
		*  Name:  	showPreloader
		*  Purpose:	Initiate the load of the next screen
		*/
		public function showPreloader():void
		{
			this._appStage.preloader.visible = true;
			
			// This pushes the preloader to the top of the z axis (i.e. in front of everything else)
			this._appStage.addChild(this._appStage.preloader);		
		}		
		
		/**
		*  Name:  	nextScreen
		*  Purpose:	Initiate the load of the next screen
		*/
		public function nextScreen():void
		{
			if (this._screenModel.hasNextScreen())
			{
				this.showPreloader();
				this._screenModel.nextScreen();
				
				// Ensure that the Model file sends the complete data
				if (!this._screenModel.hasNextScreen())
				{
					this.finish();
				}
				this.showScreen();
			} else {
				this._debugger.warningTrace("There are no more screens.  The _screenView should not be showing the \"next\" button");
			}
		}
		
		/**
		*  Name:  	errorScreen
		*  Purpose:	Initiate the load of the error screen
		*  @param inErrorCode Number The number of the error screen defined
		*  @param inMsg String Message specific to this occurrence		
		*/
		public function errorScreen(inErrorCode:Number,inMsg:String=""):void
		{
			this._activeScreen = this._screenModel.retrieveErrorScreen(inErrorCode,inMsg);
			// Uses Callback function of the loadScreenfiles to call screenFilesLoaded
			this._screenModel.loadScreenFiles(this._activeScreen,this.screenFilesLoaded);
		}
		
		/**
		*  Name:  	finish
		*  Purpose:	Initiate the load of the next screen
		*/
		public function finish():void
		{
			this._screenModel.complete();
		}
		
		/**
		*  Name:  	prevScreen
		*  Purpose:	Initiate the load of the previous screen
		*/
		public function prevScreen():void
		{
			if (this._screenModel.hasPrevScreen())
			{
				this.showPreloader();
				this._screenModel.prevScreen();
				this._activeScreen = this._screenModel.retrieveActiveScreen();
				this._screenView.displayScreen(this._activeScreen);
				this.hidePreloader();
			} else {
				this._debugger.warningTrace("There are no more screens.  The _screenView should not be showing the \"next\" button");
			}
			// Note:  Need to start a preloader animation
		}

		/******************************************************************************************************
		** Public
		*******************************************************************************************************/
		
		public function sessionUID():String
		{
			return this._participantUID;
		}
		
		/******************************************************************************************************
		** Callbacks
		*******************************************************************************************************/
	
		public function initialize():void
		{
			if ((!this._bInit) && this._bReady && this._bPreloadComplete)
			{
				this.init();
			}
		}	

		public function preloadComplete():void
		{
			this._bPreloadComplete = true;
			this.initialize();
		}

		/******************************************************************************************************
		**  PRIVATE - Initialize
		******************************************************************************************************/

		// Assigns the session paramters				
		private function assignUID():void
		{
			this._participantUID = "PID-";
			this._participantUID += (this._parameters[SURVEY_PARTICIPANT]) ? this._parameters[SURVEY_PARTICIPANT] : "anonymous";
			this._participantUID += "_UID-" + NumberUtilities.getUnique().toString();
		}
		
		// Initialize the UI
		private function init()
		{
			this._bInit = true;
			
			// Create the Screen
			this._screenView = new ScreenView(this);
							
			this.showScreen();
		}
		
		private function getParameterStr():String
		{
			this._hashStore.newObj();
			for (var hashStr in this._appStage.parameters)
			{
				this._hashStore.addNameValue(hashStr,this._appStage.parameters[hashStr]);
			}
			return this._hashStore.toXMLString(this._hashStore.getObj());
		}
		
		// load the screen
		private function showScreen():void
		{
			try
			{
				var inEntryStr:String;
				this._activeScreen = this._screenModel.retrieveActiveScreen();
				// Uses callback function, this.screenFilesLoaded()

				this._screenModel.loadScreenFiles(this._activeScreen,this.screenFilesLoaded);
				
				inEntryStr = TEMPLATE_PARAM;
				inEntryStr = inEntryStr.replace(MESSAGE,this.getParameterStr());
				this._screenModel.recordEvent(inEntryStr);
			} catch(error:IOErrorEvent)
			{
				this.errorEvent(error);
			} catch(error:TypeError)
			{
				this.errorEvent(error);
			} catch(error:Error)
			{
				this.errorEvent(error);
			} finally
			{
				// This always executes
			}
		}

	}
}