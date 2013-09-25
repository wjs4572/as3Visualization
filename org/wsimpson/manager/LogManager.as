package org.wsimpson.manager

/*
** Title:	LogManager.as
** Purpose: Manages the basic events
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	// Loaders
	import org.wsimpson.loaders.Upload;	

	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.LogUtil;
	
	public class LogManager	{
		// Private Constants
		public static const CONTENT = "{content}";				// Substitution String		
		private const LOG_FILE = 
					"<log_files>{content}</log_files>";				// Begin tag requires substitution 	
	
		// Private Instance Variables required for Singleton Creation
		private static var instance:LogManager = new LogManager();	// Tracks the instantiated class
		
		// Private Instance Variables
		private var _contentPattern:RegExp;							// Regular Expression for the content pattern
		private	var _debugger:DebugUtil;							// Output and diagnostic window
		private var _dataLogXML:XML;								// Final file of all the logged data			
		private var _logArr:Array;									// An array of log files
		private var _response:String;								// The file response from the server
		private var _loader:Upload;									// Only one log maintained by this manager
		
		
		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		**		  http://www.munkiihouse.com/?page_id=2
		******************************************************************************************************/
		
		public function LogManager() {
			if (instance) 
			{
				throw new Error("Instantiation failed: Use LogManager.getInstance() instead of new.");
			} else
			{
				this._debugger = DebugUtil.getInstance();
						
				// Substitution Pattern
				this._contentPattern = new RegExp(CONTENT);
				this._loader = new Upload();
				this._response = "";
			}
		}
		
		public static function getInstance():LogManager {
			return instance;
		}	

		/******************************************************************************************************
		**  Public
		******************************************************************************************************/
		
		/**
		*  Name:  	getLogFile
		*  Purpose:	Returns a file as a string
		*  @param inFileID String The id of the file with the order it is presented.
		*  @param inSessionID String The id of the participant.
		*  @return 	Object		The new LogUtil object returned
		*/
		public  function getLogFile(inFileID:String,inSessionID:String):Object {
			this._logArr = (this._logArr) ? this._logArr : new Array();
			this._logArr.push(new LogUtil(inFileID,inSessionID));
			return this._logArr[this._logArr.length - 1];
		}

		/**
		*  Name:  	concatLogs
		*  Purpose:	Combine each of the individual logs into a single log
		*  @return 	String	Full log
		*/
		public  function concatLogs():String {
			var tempStr:String;
			tempStr = "";
			for (var i:Number = 0; i < this._logArr.length; i++)
			{
				tempStr += this._logArr[i];
			}
			return tempStr;
		}

		/**
		*  Name:  	uploadLog
		*  Purpose:	create the log file and upload it to the server
		*  @param inURL String The URL of the CGI that will process the uploaded contents
		*/
		public  function uploadLog(inURL:String):void {
			var dataStr:String;
			var tempStr:String;
			
			// Define log template
			dataStr = LOG_FILE;
			
			// Build complete log
			tempStr = this.concatLogs();
			
			// Ensure that the file is written to multiple times
			this._dataLogXML = new XML(dataStr.replace(this._contentPattern,tempStr));			
			this._loader.uploadXML(this._dataLogXML.toString(),inURL,this.logUpLoaded);
		}

		/**
		*  Name:  	getResponse
		*  Purpose:	Get the server resposne
		*  @return String The server response
		*/
		public function getResponse():String
		{
			return this._response;
		}		
		/******************************************************************************************************
		**  Event
		******************************************************************************************************/
		
		/**
		*  Name:  	logUpLoaded
		*  Purpose:	Resources have completed loading
		*  @param 	inFile	Object	Upload response
		*/
		public function logUpLoaded(inFile:Object):void
		{
				this._response = inFile.toString();
		}
	}
}