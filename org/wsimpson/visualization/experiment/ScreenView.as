package org.wsimpson.visualization.experiment
/*
** Title:	ScreenView.as
** Purpose: Interactive for selecting color scales
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe Classes
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;	
	import flash.text.TextField;

	// UI Components
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.DebugUtilConst;
	import org.wsimpson.ui.ButtonBase;	
	import org.wsimpson.ui.cell.Cell;
	import org.wsimpson.ui.GlyphConst;
	import org.wsimpson.ui.Overlay;
	import org.wsimpson.ui.screen.Screen;
	import org.wsimpson.visualization.experiment.button.Arrow;	
	import org.wsimpson.visualization.experiment.screen.Intro;
	import org.wsimpson.visualization.experiment.screen.Flight_Grid;
	import org.wsimpson.visualization.experiment.screen.Flight_Schedule;
	import org.wsimpson.visualization.experiment.screen.Glyphs;
	import org.wsimpson.visualization.experiment.screen.GlyphGrid;
	import org.wsimpson.visualization.experiment.screen.Summary;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.ScreenModel;	
	import org.wsimpson.visualization.experiment.ScreenError;
	
	// Managers
	import org.wsimpson.visualization.experiment.infoglyph.manager.ScheduleGlyphManager;
	
	// Utils
	import org.wsimpson.util.DispalyObjectContainerUtil;

	public class ScreenView
	{
		// Public Constants
		public static const DEFAULT_STYLESHEET = "Default_CSS";					// The name of the default stylesheet
		public static const NAV_NEXT = "Next";									// Navigation button (use with CSS)
		public static const NAV_PREV = "Previous";								// Navigation button (use with CSS)
		public static const SCREEN_ERROR = "error";								// Screen layout
		public static const SCREEN_INTRO = "intro";								// Screen layout
		public static const SCREEN_SUMMARY = "summary";							// Screen layout
		public static const SCREEN_FLIGHT_SCHEDULE = "flight_schedule_display";	// Screen layout
		public static const SCREEN_GLYPHS = "glyph_display";					// Screen layout
		public static const SCREEN_GRID = "grid_display";						// Screen layout
		public static const SCREEN_FLIGHT_GRID = "flight_grid_display";			// Screen layout
		public static const TRANSITION = "Transition";							// Screen layout tranition
		
		// UI Optimization
		public static const TASK_GLYPH = "Task_Glyph";							// Glyph type		
		public static const GLYPH_COUNT = 700;									// glyphcount
		
		// Private Instance Variables
		private	var _debugger:DebugUtil;			// Output and diagnostic window
		private var _transition:Overlay;			// Transition overlay of the Display Object	
		private var _showOverlayBool:Boolean;		// Toggle
		private var _glyphsCreatedBool:Boolean;		// Ensures that Glyphs are only created once
		private	var controller:MovieClip;			// References the active stage
//		private	var selector:EditCellAttributes;	// Graphic data point
		private	var screenXML:XML;					// Imports XML Files
		private var screenID:String;				// The unique ID assigned to the screen
		private	var nextButton:Arrow;				// Next Button
		private	var prevButton:Arrow;				// Next Button
		private var screenEvents:Array;				// Record of loggable events per screen
		private	var currentScreen:Screen;			// Stores screen for addition and removal
		private	var screenError:ScreenError;		// Provides an external singleton for accessing the error reporting
		
		// XML Definition
		private static const TEMPLATE_SCREEN_LOG_ENTRY = 
			"<screen id=\"{ID}\" layout=\"{LAYOUT}\">\n\t<data>\n\t\t{MESSAGE}\n\t</data>\n</screen>";
		private static const SCREEN_ID = "{ID}";	// Field to replace
		private static const SCREEN_LAYOUT = 
			"{LAYOUT}";								// Field to replace
		private static const SCREEN_MSG = 
			"{MESSAGE}";							// Field to replace	
		
		// Patterns
		private var idPattern:RegExp;				// Regular Expression pattern
		private var loPattern:RegExp;				// Regular Expression pattern
		private var dataPattern:RegExp;				// Regular Expression pattern
		
		// Public Properties
		public	var model:ScreenModel;				// Model from MVC Design Pattern

		// Constructor
		public function ScreenView(targetMC:MovieClip)
		{
			this._debugger = DebugUtil.getInstance();
			
			// MVC
			this.model = ScreenModel.getInstance();
			this.controller = targetMC;
			
			// Data
			this.screenXML = null;
			this.screenID = "";
			this._glyphsCreatedBool = false;
			this._showOverlayBool = false;

			// Define Patterns
			this.idPattern = new RegExp(SCREEN_ID);
			this.loPattern = new RegExp(SCREEN_LAYOUT);
			this.dataPattern = new RegExp(SCREEN_MSG);			
	
			// Initialize error reporting singleton
			this.screenError = ScreenError.getInstance();
			this.screenError.init(this);
			
			// Initialize the Screns
			this.init();
		}
		
		/******************************************************************************************************
		**  Events
		******************************************************************************************************/
		
		/**
		*  Name:  	reportError
		*  Purpose:  An click event has occurred with a button.
		*  @param inErrorCode Number The number of the error screen defined		
		*  @param inMsg String Message specific to this occurrence	
		*/
		public function reportError(inErrorCode:Number,inMsg:String=""):void {
			if (this.currentScreen)
			{
				this.currentScreen.leaveScreen();
			}
			this.controller.errorScreen(inErrorCode,inMsg);
		}

		/**
		*  Name:  	mouseEvent
		*  Purpose:  An click event has occurred with a button.
		*/
        public function mouseEvent(inMC:MovieClip,event:Event):void {

			switch(event.type)
			{
				case flash.events.MouseEvent.CLICK:
				case flash.events.MouseEvent.DOUBLE_CLICK:
					this.clickEvent(inMC);
				break;
				case flash.events.MouseEvent.MOUSE_OVER:
				case flash.events.MouseEvent.MOUSE_OUT:
					// Do nothing
				break;
				default:
					this._debugger.warningTrace("Unexpected Mouse Event in ScreenView " + inMC.buttonLabel);
				break;
			}
		}

		/**
		*  Name:  	clickEvent
		*  Purpose:  An click event has occurred with a button.
		*/
        public function clickEvent(inMC:MovieClip):void {
			switch(inMC.buttonLabel)
			{
				case NAV_PREV:
					this.fadeOutScreen();		
					this.currentScreen.leaveScreen();
					this.prevPage();
				break;
				case NAV_NEXT:
					this.fadeOutScreen();				
					this.nextPage();
				break;
				default:
					this._debugger.warningTrace("Unexpected Button click in ScreenView " + inMC.buttonLabel);
				break;
			}
		}

		/******************************************************************************************************
		**  Public
		******************************************************************************************************/

		/**
		*  Name:  	displayScreen
		*  Purpose:  The RGB color value of the data cell.
		*/
        public function displayScreen(inXML:XML):void {		
			this.screenXML = inXML;
			this.screenID = this.screenXML.@UID;
			this.screenEvents = new Array();
			this.currentScreen = null;

			switch(this.screenXML.@layout.toString())
			{
				case SCREEN_ERROR:
				case SCREEN_INTRO:
					this.currentScreen = new Intro(this,this.screenXML);
				break;
				case SCREEN_SUMMARY:
					this.currentScreen = new Summary(this,this.screenXML);
				break;
				case SCREEN_FLIGHT_GRID:
					this.currentScreen = new Flight_Grid(this,this.screenXML);	
				break;
				case SCREEN_FLIGHT_SCHEDULE:
					this._showOverlayBool = true;
					this.currentScreen = new Flight_Schedule(this,this.screenXML);
				break;
				case SCREEN_GLYPHS:
					this.currentScreen = new Glyphs(this,this.screenXML);
				break;
				case SCREEN_GRID:
					this.currentScreen = new GlyphGrid(this,this.screenXML);	
				break;
				default:
					this._debugger.warningTrace("Required attribute not found - layout!");
				break;
			}
			if (this.currentScreen != null)
			{
				this.controller.addChild(this.currentScreen);
			}
			// Ensures that the transition remains on top of the display list
			this.controller.addChild(this._transition);	
			
			//this.traceDisplayList();
			
			// Buttons will display by default
			this.nextButton.state = (this.model.hasNextScreen() && (this.screenXML.@nextButton.toString() != "false")) ? ButtonBase.BUTTON_UP : ButtonBase.BUTTON_HIDDEN;
			this.prevButton.state = (this.model.hasPrevScreen() && (this.screenXML.@prevButton.toString() != "false")) ? ButtonBase.BUTTON_UP : ButtonBase.BUTTON_HIDDEN;
		}

		/**
		*  Name:  	createGlyphs
		*  Purpose:	Initiate the creation of the screenGlyphs to ensure faster display
		*/
		public function createGlyphs():void
		{
			var tempGlyphManager:ScheduleGlyphManager;
			if (!this._glyphsCreatedBool)
			{
				// Establish glyph manager
				this._glyphsCreatedBool = true;				
				tempGlyphManager = new ScheduleGlyphManager();
				tempGlyphManager.setDef(this.model.retrieveDef(TASK_GLYPH));
				for (var i:Number = 0; i < GLYPH_COUNT; i++)
				{
					var tempGlyph:MovieClip;
					tempGlyph = tempGlyphManager.getGlyph(i);
					tempGlyph.id = TASK_GLYPH;
					tempGlyph.label = TASK_GLYPH;
					tempGlyph.rolloverStr = TASK_GLYPH;
					tempGlyph.style = this.model.retrieveStyle(DEFAULT_STYLESHEET);
					tempGlyph.assigned = false;
				}
			}
		}

		/**
		*  Name:  	hidePreloader
		*  Purpose:	Initiate the load of the next screen
		*/
		public function hidePreloader():void
		{
			this.controller.hidePreloader();
		}
		
		/**
		*  Name:  	showPreloader
		*  Purpose:	Initiate the load of the next screen
		*/
		public function showPreloader():void
		{
			this.controller.showPreloader();		
		}				
		
 		/**
		*  Name:	fadeInScreen
		*  Purpose: Starts a timed fade in
		*/
        public function fadeInScreen():void {
			this._transition.fadeOutOverlay();
		}

 		/**
		*  Name:	traceDisplayList
		*  Purpose: Starts a timed fade in
		*/
        public function traceDisplayList():void {
			DispalyObjectContainerUtil.traceDisplayList(this.controller);
		}
		
		/**
		*  Name:	fadeOutScreen
		*  Purpose: starts a timed fade out
		*/
        public function fadeOutScreen():void {
			this.controller.addChild(this._transition);		
			//this._transition.fadeInOverlay();
		}

		/**
		*  Name:	recordEvent
		*  Purpose: Adds a log entry
		*/
        public function recordEvent(inEntryStr:String):void {
			this.screenEvents.push(inEntryStr);
		}
		
		/**
		*  Name:	recordEventTemplate
		*  Purpose: Adds a log entry
		*/
        public function recordEventTemplate(inEntryStr:String):String {
			return this.model.recordEventTemplate(inEntryStr);
		}

		/**
		*  Name:	linkEventLog
		*  Purpose: Gets the final location of the log file
		*/
        public function linkEventLog():String {
			return this.model.retrieveLogResponse();
		}
		
		/**
		*  Name:	logEvents
		*  Purpose: Adds a log entry
		*/
        public function logsEvent():void {
			var tempStr:String;
			var msgStr:String;
			msgStr = TEMPLATE_SCREEN_LOG_ENTRY;
			tempStr = "";
			for (var i:uint=0; i < this.screenEvents.length; i++)
			{
				tempStr += this.screenEvents[i];
			}
			msgStr = msgStr.replace(this.idPattern,this.screenID);
			msgStr = msgStr.replace(this.loPattern,this.screenXML.@layout);
			msgStr = msgStr.replace(this.dataPattern,tempStr);	
			this.model.recordEvent(msgStr);
		}
		
		/**
		*  Name:	retrieveMessage
		*  Purpose: Adds a log entry
		*  @param inStr String The token identifying the message to retrieve, for use with the log file.
		*  @return String The message retrieved
		*/
        public function retrieveMessage(inStr:String):String {
			return this.model.retrieveMessage(inStr);
		}

		/**
		*  Name:	prevPage
		*  Purpose: Goes to the previous page
		*/
        public function prevPage():void {		
			this.logsEvent();	
			
			// Load new screen and if it exists return to this class with a call to displayScreen
			this.controller.prevScreen();
		}
		
		/**
		*  Name:	nextPage
		*  Purpose: Goes to the next page
		*/
        public function nextPage():void {		
			this.logsEvent();	
			this.currentScreen.leaveScreen();
			
			// Load new screen and if it exists return to this class with a call to displayScreen
			this.controller.nextScreen();
		}
			
		/******************************************************************************************************
		**  Private
		******************************************************************************************************/
		
		private function addNextArrow()
		{
			this.nextButton = new Arrow();
			this.nextButton.x = 860;
			this.nextButton.y = 702;
			this.nextButton.style = this.model.retrieveStyle(DEFAULT_STYLESHEET);
			this.nextButton.buttonLabel = NAV_NEXT;
			this.nextButton.addButtonListener(this.mouseEvent);
			this.controller.addChild(this.nextButton);
			this.nextButton.hideButton();
		}
		
		private function addPrevArrow()
		{		
			this.prevButton = new Arrow();
			this.controller.addChild(this.prevButton);
			this.prevButton.x = 723;
			this.prevButton.y = 702;
			this.prevButton.flipHorizontal();
			this.prevButton.style = this.model.retrieveStyle(DEFAULT_STYLESHEET);
			this.prevButton.buttonLabel = NAV_PREV;
			this.prevButton.addButtonListener(this.mouseEvent);
			this.prevButton.hideButton();			
		}

		private function addTransitionOverlay()
		{
			var defXML:XML; 		// definition for the transition overlay
			var tempObj:Object; 	// definition for the transition overlay
			tempObj = new Object();
			
			defXML = this.model.retrieveDef(TRANSITION);
			tempObj["color"] = defXML.@["default_color"].toString();
			
			this._transition = new Overlay(defXML,tempObj);
			this.controller.addChild(this._transition);
		}
		
		private function init()
		{
			// Display Navigation
			this.addNextArrow();
			this.addPrevArrow();
			
			// Create a matching Transition Overlay
			this.addTransitionOverlay();			
		}
	}
}