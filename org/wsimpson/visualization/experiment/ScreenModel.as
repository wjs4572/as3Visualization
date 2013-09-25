package org.wsimpson.visualization.experiment
/**
* @name		ScreenModel.as
* Purpose	Imports and maintains access to files loaded
* @author	William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe Classes
	import flash.events.Event;
	
	// Formatting
	import org.wsimpson.store.ColorStore;
	import org.wsimpson.store.OrderStore;
	import org.wsimpson.store.StyleStore;
	import org.wsimpson.styles.Style;
	
	// Debugging
	import org.wsimpson.util.DebugUtil;
	
	// Manager (Factory)
	import org.wsimpson.manager.LoadManager;
	
	// Log (Future refactor to factory)
	import org.wsimpson.manager.LogManager;		

	// Object Management
	import org.wsimpson.visualization.experiment.ScreenManager;
	
	public class ScreenModel
	{
		// Configuration File constants
		public static const CONFIG_FILE = "./xml/config.xml";	// Expected location of the configuration XML
		public static const CONFIG_FILE_TYPE = "xml";			// Expected location of the configuration XML
		
		// Logging Constants
		public static const LOGGING_CGI = "logManager";			// The id of the URL that references the logging CGI

		// Static Error codes
		public static const DUPLICATE_SCREEN_IDS = 0;			// Indicates that more than one screen has the same id
		public static const NEXT_SCREEN_NOTFOUND = 1;			// A nonexistent next screen has been requested
		public static const PREV_SCREEN_NOTFOUND = 2;			// A nonexistent previous screen has been requested
		public static const STYLE_SCREEN_NOTFOUND = 3;			// A specified style has not been found
		public static const GLYPH_CONTENT_TYPE = 4;				// A specified GLYPH type has not been found
		public static const DEFAULT_ERROR = 5;					// A generic error screen
		public static const FILE_NOT_FOUND = 6;					// A resource file has not been found

		// Other contant values
		public static const STYLESHEET_FILE = "stylesheet";		// CSS File
		public static const SCREEN_FILE = "screens";			// Error screens
		public static const ERROR_FILE = "error_messages";		// Error screens
		public static const MESSAGE_NEXT = "next";				// Log messages	
		public static const MESSAGE_PREV = "prev";				// Log messages	
		public static const MESSAGE_SELECTION = "selection";	// Log messages	
		public static const MESSAGE_START = "start";			// Log messages	
		public static const MESSAGE_FILE_COMPLETE = 
										"file_complete";		// Log messages	
		public static const MESSAGE_SESSION_COMPLETE = 
										"session_complete";		// Log messages	
		public static const MESSAGE_CONTACT_INFO = 
										"contact_info_sent";	// Log messages	
		public static const MESSAGE_SESSION_DATA = 
										"session_data_sent";	// Log messages
		public static const MESSAGE = "{Message}";				// Substitution String
	
		// File ID
		public static const FILE_CONFIG = "config";				// The reference for the configuration XML
		public static const FILE_COLORS= "Color_Matrix";		// The reference for the color scales XML
		public static const FILE_GLYPH_LABELS = "glyph_labels";	// The reference for the color scales XML

		// Instance Variables
		private var controller:Object;						// The ScreenControl Class
		private	var _debugger:DebugUtil;					// Output and diagnostic window		
		private	var loadManager:LoadManager;				// Imports Files
		private	var colorStore:ColorStore;					// Manages color scales used
		private	var styleStore:StyleStore;					// Manages styles used for formatting
		private	var urlStore:OrderStore;						// Manages URL used for formatting
		private	var config:XML;								// Imports XML Files
		private	var fileOrderArr:Array;						// Contains file order
		private	var fileObj:Object;							// Contains file references
		private	var dataObj:Object;							// Contains collected data
		private	var currentFile:Number;						// Display file to show
		private	var displayScreens:ScreenManager;			// Display file to show
		private	var errorScreens:ScreenManager;				// Display file to show
		private	var logFiles:LogManager;					// LogFileManager	
		private var messagePattern:RegExp;					// Regular Expression for the error message content		
		private var messageStr:String;						// Regular Expression for the error message content
		
		// Private Instance Variables required for Singleton Creation
		private static var instance:ScreenModel = new ScreenModel();	// Tracks the instantiated class
		
		// Private Instance Variables
		private var styleObj:Object;									// An Associative array of StyleSheets

		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		**		  http://www.munkiihouse.com/?page_id=2
		******************************************************************************************************/
		
		public function ScreenModel() {
			if (instance) 
			{
				throw new Error("Instantiation failed: Use ScreenModel.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():ScreenModel {
			return instance;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
				
		public function initialize(inController:Object)
		{
			this.controller = inController;
			this._debugger = DebugUtil.getInstance();
			this.fileOrderArr = new Array();
			this.fileObj = new Object();
			this.dataObj = new Object();
			this.displayScreens = null;
			
			// Substitution Pattern
			this.messagePattern = new RegExp(MESSAGE);
						
			
			// Assign Screen reference formatting
			this.currentFile = 0;
			this.errorScreens = null;
			this.messageStr	= "";	
			
			// Get Style Factory
			this.styleStore = StyleStore.getInstance();
			
			// Get Loader Factory
			this.loadManager = LoadManager.getInstance();
			
			// Get Log File Factory
			this.logFiles = LogManager.getInstance();
			
			// Load the configuratin file
			this.loadManager.addFile(FILE_CONFIG,CONFIG_FILE_TYPE,CONFIG_FILE);
			this.loadManager.loadFiles(this.configLoaded);
		}

		/**
		*  Name:  	retrieveErrorScreen
		*  Purpose:	Initiate the load of the error screen
		*  @param inErrorCode Number The number of the error screen defined
		*  @param inMsg String Message specific to this occurrence		
		*/
		public function retrieveErrorScreen(inErrorCode:Number,inMsg:String=""):XML
		{
			var tempBool:Boolean;
			tempBool = (this.errorScreens != null) && (this.errorScreens.screenExists(inErrorCode));
			this.messageStr = inMsg;
			
			if (tempBool)
			{
				this.errorScreens.jumpToScreen(inErrorCode);
			} else
			{
				this.errorScreens.jumpToScreen(DEFAULT_ERROR);
			}
			return this.errorScreens.getCurrentScreen();
		}
		
		// Should only return one element
		public function retrieveActiveScreen():XML
		{
			return 	this.displayScreens.getCurrentScreen();
		}

		//Returns presence of previous screen
		public function hasPrevScreen():Boolean		{
			return (this.displayScreens.hasPrevScreen() || this.hasPrevFile());
		}
		
		//Returns presence of next screen
		public function hasNextScreen():Boolean		{
			return (this.displayScreens.hasNextScreen() || this.hasNextFile());
		}
		
		//Updates to the next screen
		public function nextScreen():void {
			this.dataObj[this.currentFile].logFile.logEntry(this.retrieveMessage(MESSAGE_NEXT));	
			if (this.displayScreens.hasNextScreen())
			{
				this.displayScreens.nextScreen();
			} else if (this.hasNextFile())
			{
				this.dataObj[this.currentFile].logFile.logEntry(this.retrieveMessage(MESSAGE_FILE_COMPLETE));

				if (this.urlStore.hasValue(LOGGING_CGI))
				{
					var tempURL:String;
					tempURL = this.urlStore.getValue(LOGGING_CGI).toString();		
					this.logFiles.uploadLog(tempURL);
				}
				this.nextFile();
			}
		}
		
		//Should only return one element
		public function recordEventTemplate(inEntryStr:String):String {
			return this.dataObj[this.currentFile].logFile.logEntryTemplate(inEntryStr);
		}

		//Should only return one element
		public function recordEvent(inEntryStr:String):void {
			this.dataObj[this.currentFile].logFile.logEntry(inEntryStr);
		}
		
		//Should only return one element
		public function prevScreen():void {
			this.dataObj[this.currentFile].logFile.logEntry(this.retrieveMessage(MESSAGE_PREV));
			if (this.displayScreens.hasPrevScreen())
			{
				this.displayScreens.prevScreen();
			} else if (this.hasPrevFile())
			{			
				this.prevFile();
			}
		}
		
		//final log
		public function complete():void {			
			// Timestamp the session end
			this.dataObj[this.currentFile].logFile.logEntry(this.retrieveMessage(MESSAGE_SESSION_COMPLETE));

			if (this.urlStore.hasValue(LOGGING_CGI))
			{
				var tempURL:String;
				tempURL = this.urlStore.getValue(LOGGING_CGI).toString();
				this.logFiles.uploadLog(tempURL);
			}
		}

		// Creates the order list for displaying the collections
		public function traceFileOrder():void
		{
			for (var i:Number = 0; i < this.fileOrderArr.length; i++)
			{
				trace("The file array order " + i + " orderID = " + this.fileOrderArr[i] + " fileRef = " + this.fileObj[this.fileOrderArr[i]])
			}
		}	
		
		/**
		*  Name:  	loadScreenFiles
		*  Purpose:	Load the files used by the screen.
		*
		*	@param inXML XML The resources required by the screen
		*	@param inFunction Function callback function
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function loadScreenFiles(inXML:XML,inFunction:Function):void
		{
			var tempBool:Boolean;
			tempBool = this.updateLoadManager(inXML);
			if ((tempBool) && (inXML != null))
			{
				this.loadManager.loadFiles(inFunction);
			} else 
			{	
				inFunction();
			}
		}

		/**
		*  Name:  	retrieveFile
		*  Purpose:	Retrieve the file requested from the load manager.
		*
		*	@param inNameStr String The id of the file to retrieve.
		*	@returns String
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function retrieveFile(inNameStr:String):Object
		{
			var tempObj:Object;
			tempObj = this.loadManager.getFile(inNameStr);

			// If there is no error message received return the value;
			return (this.messageStr == "") ?
				tempObj :
				tempObj.replace(this.messagePattern,this.messageStr);
		}

		/**
		*  Name:  	retrieveFileType
		*  Purpose:	Retrieve the file type requested from the load manager.
		*
		*	@param inNameStr String The id of the file to retrieve.
		*	@returns String
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function retrieveFileType(inNameStr:String):String
		{
			return this.loadManager.getFileType(inNameStr);
		}
		
		// Returns CSS files specified in the Configuration XML
		public function retrieveMessage(inStr:String):String
		{
			return this.config..message.(@type == inStr).text();
		}
		
		/**
		*  Name:  	retrieveStyle
		*  Purpose:	Retrieve the file requested from the load manager.
		*
		*	@param inNameStr String The id of the file to retrieve.
		*	@returns Style A Object of the custom class Style
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function retrieveStyle(inNameStr:String):Style
		{
			return (this.styleStore.hasStyle(inNameStr)) ? this.styleStore.getCustomStyle(inNameStr) : null;
		}	
		
		/**
		*  Name:  	retrieveDef
		*  Purpose:	Retrieve the Object definition requested.
		*
		*	@param inNameStr String the id of the object definition to retrieve.
		*	@returns XML The XML for the requested object definition
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function retrieveDef(inNameStr:String):XML
		{
			var tempXMLList:XMLList;
			tempXMLList = this.config..object.(@name == inNameStr);
			if (tempXMLList.length() > 1)
			{
				this._debugger.warningTrace("There are multiple definitions for the " + inNameStr + " object.");
			}
			return tempXMLList[0];
		}

		/**
		*  Name:  	retrieveLogResponse
		*  Purpose:	Retrieve the server response.
		*
		*	@returns String The server response to the log upload
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function retrieveLogResponse():String
		{
			return logFiles.getResponse();
		}
		
		/******************************************************************************************************
		** Events
		******************************************************************************************************/

		/**
		*  Name:  	configLoaded
		*  Purpose:	Configuration file has completed loading
		*/
		public function configLoaded():void
		{
			this.config = new XML(this.retrieveFile(FILE_CONFIG));
			this.urlStore = new OrderStore();
			this.urlStore.importXMLList(this.retrieveURLFiles());
			if (this.updateLoadManager(this.config))
			{
				this.loadManager.loadFiles(this.fileLoadingComplete);
			} else
			{
				this._debugger.warningTrace("The config.xml has no files to load");
			}
		}
		
		/**
		*  Name:  	fileLoadingComplete
		*  Purpose:	Resources have completed loading
		*/
		public function fileLoadingComplete():void
		{
			// List files loaded
			this.loadManager.listFileReferences();

			// Set Error Screens for this application
			this.updateErrorScreens();
			
			// Set Formmatting Styles for this application
			this.updateStyleStore();

			// Set Display Sets for this application
			try 
			{
				this.updateDisplaySets();
			} catch (e:Error)
			{
				this._debugger.errorTrace("Screen loading failed: " + e.message);
				(DebugUtil.getInstance()).errorTrace(e.getStackTrace());
			}
			
			// Load colors
			this.updateColors();
			
			// Callback controller when all is loaded
			this.controller.preloadComplete();
		}
		
		/******************************************************************************************************
		** PRIVATE - Load Resources
		******************************************************************************************************/

		// Updates the Singleton containing the color scale definitions
		private function updateColors():void
		{
			this.colorStore = ColorStore.getInstance();
			this.colorStore.initColorScales(this.retrieveFile(FILE_COLORS).toString());
		}
		
		// Returns whether another screen file is available
		private function hasNextFile():Boolean
		{
			return (this.currentFile != (this.fileOrderArr.length - 1));
		}
		
		// Returns whether another screen file is available
		private function hasPrevFile():Boolean
		{
			return (this.currentFile > 0);
		}
		
		// Returns whether another screen file is available
		private function nextFile():void
		{
			this.currentFile++;
			this.updateDisplayXML();
		}
		
		// Returns whether another screen file is available
		private function prevFile():void
		{
			this.currentFile--;
			this.updateDisplayXML();
			this.displayScreens.jumpToLastScreen();
		}
		
		// Returns files specified in the Configuration XML
		private function retrieveFiles(inXML:XML):XMLList
		{
			return inXML..file;
		}
		
		// load new screen resource files
		private function updateLoadManager(inXML:XML):Boolean
		{
			var tempXMLList:XMLList;
			var tempBool:Boolean;
			tempBool = true;
			tempXMLList = this.retrieveFiles(inXML);
			for each (var item:XML in tempXMLList)
			{
				// If this file or a previous have not been loaded then return true
				tempBool = (this.loadManager.addFile(item.toString(),item.@content_type.toString(),item.@href.toString(),item.@desc.toString()) ||
							tempBool);
			}
			return ((tempXMLList.length() > 0) && tempBool);
		}
		
		// Returns Display Sets of Screens (Collections) specified in the Configuration XML
		private function retrieveCollection():XMLList
		{
			return this.config..collection;
		}		
		
		// Get Display XML
		private function updateDisplayXML():void
		{
			var tempObj:Object; // Object reference for readability;
			var tempXML:XML;
			var tempStr:String;
			
			tempStr = this.fileOrderArr[this.currentFile];
			tempObj = this.fileObj[tempStr];
			tempStr += "-" + tempObj.label;
			// If this display file has been previously viewed retain the previous data for it.
			tempXML = (!tempObj.viewed) ?  new XML(this.retrieveFile(tempObj.label)) : null;		
			this.dataObj[this.currentFile] = (this.dataObj[this.currentFile]) ? this.dataObj[this.currentFile] : new Object();
			this.dataObj[this.currentFile].logFile = (!tempObj.viewed) ? 
									this.logFiles.getLogFile(tempStr,this.controller.sessionUID()) :
									this.dataObj[this.currentFile].logFile;
			tempObj.display = 	(!tempObj.viewed) ? 
								new ScreenManager(tempXML) : 
								this.dataObj[this.currentFile].screenManager;
			this.dataObj[this.currentFile].screenManager = this.displayScreens = tempObj.display;
			tempObj.viewed = true;
		}
		
		// Creates the order list for displaying the collections
		private function updateDisplaySets():void
		{
			var tempXMLList:XMLList;
			var tempBool:Boolean;
			tempXMLList = this.retrieveCollection();
			tempBool = false;
			
			// Process Collections
			for each (var item:XML in tempXMLList)
			{
				var fileXMLList:XMLList;	// files containing display screens
				fileXMLList = item..file.(@content == SCREEN_FILE);
				for each (var fileNode:XML in fileXMLList)
				{
					var tempStr:String; // Combine the collection orderID and file orderID to create unique order id
					tempStr = item.@orderID + "-" + fileNode.@orderID;

					this.fileOrderArr.push(tempStr);
					this.fileObj[tempStr] = new Object();
					this.fileObj[tempStr].label = fileNode.text();
					this.fileObj[tempStr].collection = item.@orderID;
					
					// Initiate flag to indicate whether this has been previously viewed.
					this.fileObj[tempStr].viewed = false;
				}
				tempBool = (tempBool || (fileXMLList.length() > 0));
			}


			if (!tempBool)
			{
				throw new Error("Screen Retrieval failed: No screens loaded.");
			} else 
			{
				this.fileOrderArr.sort();
				//this.traceFileOrder();
				this.updateDisplayXML();
			}
		}

		// Returns CSS files specified in the Configuration XML
		private function retrieveCSSFiles():XMLList
		{
			return this.config..file.(@content== STYLESHEET_FILE);
		}

		// Returns URL files specified in the Configuration XML
		private function retrieveURLFiles():XMLList
		{
			return this.config..url;
		}
		
		// Returns files specified in the Configuration XML
		private function updateStyleStore():void
		{
			var tempXMLList:XMLList;
			tempXMLList = this.retrieveCSSFiles();
			for each (var item:XML in tempXMLList)
			{
				var tempStr:String;
				tempStr = item.toString();
				this.styleStore.setStyleCSS(tempStr,this.retrieveFile(tempStr).toString());
			}
		}
		
		// Returns Error file specified in the Configuration XML
		private function retrieveErrorFile():XMLList
		{
			return this.config..file.(@content == ERROR_FILE);
		}
		
		// Creates the ScreenManager for the Error Screens
		private function updateErrorScreens():void
		{
			var tempXMLList:XMLList;
			tempXMLList = this.retrieveErrorFile();
			if (tempXMLList.length() > 1) {
				throw new Error("Instantiation failed: More than one Error file received.");
			} else if (tempXMLList.length() == 1)
			{
				var tempXML:XML;
				tempXML = new XML(this.retrieveFile(tempXMLList.toString()));
				this.errorScreens = new ScreenManager(tempXML);
			}
		}

	}
}