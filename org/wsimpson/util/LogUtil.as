package org.wsimpson.util
/**
* @name		LogUtil.as
* Purpose	Manages access to the screen file data
* @author	William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	// Debugging
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.StringUtil;

	public class LogUtil
	{
		private const LOG_DATE = "{datetime}";						// Substitution String
		private const LOG_DATE_UNFORMATTED = "{raw_time}";			// Substitution String
		private const FILE_ID = "{id}";								// Substitution String
		private const SESSION_ID = "{session}";						// Substitution String
		private const CONTENT = "{content}";						// Substitution String
		private const LOG_FILE = 
				"<log id={id} session={session}>{content}</log>";	// Begin tag requires substitution 
		private const LOG_ENTRY = 
				"<entry datetime={datetime} rawTime={raw_time}>{content}</entry>";		// Begin tag requires substitution
	
		// Instance Variables
		private	var _debugger:DebugUtil;					// Output and diagnostic window
		private	var fileID:String;							// File and order ID
		private	var sessionID:String;						// Session ID
		private	var logArr:Array;							// Log ordered
		private var contentPattern:RegExp;					// Regular Expression for the content pattern
		private var datePattern:RegExp;						// Regular Expression for the date pattern
		private var rawPattern:RegExp;						// Regular Expression for the unformatted date pattern
		private var idPattern:RegExp;						// Regular Expression for the file id pattern
		private var sessionPattern:RegExp;					// Regular Expression for the session id pattern

		/**
		*  Name:  	Constructor
		*  Purpose:	Stores and uploads screen file data
		*
		*	@param inFileID String The id of the file with the order it is presented.
		*	@param inSessionID String The id of the participant.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function LogUtil(inFileID:String,inSessionID:String)
		{
			this._debugger = DebugUtil.getInstance();
			
			// File Identification
			this.fileID = inFileID;
			this.sessionID = inSessionID;
			
			// Substitution Pattern
			this.contentPattern = new RegExp(CONTENT);
			this.datePattern = new RegExp(LOG_DATE);
			this.rawPattern = new RegExp(LOG_DATE_UNFORMATTED);
			this.idPattern = new RegExp(FILE_ID);
			this.sessionPattern = new RegExp(SESSION_ID);
			
			// create log store
			this.logArr = new Array();
			this.logEntry("The log start time");
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		public function logEntryTemplate(inStr:String):String
		{
			var tempDate:Date;
			var dateStr:String;
			var logStr:String;
			tempDate = new Date();

			dateStr = 	StringUtil.doubeQuoteStr(tempDate.toLocaleString() + 
						" s" + tempDate.getSeconds() + ":" + tempDate.getMilliseconds());
			logStr = LOG_ENTRY;
			logStr = logStr.replace(this.rawPattern,StringUtil.doubeQuoteStr((tempDate.time).toString()));
			logStr = logStr.replace(this.datePattern,dateStr);
			return logStr.replace(this.contentPattern,inStr);
		}
		
		public function logEntry(inStr:String):void
		{
			var tempDate:Date;
			var dateStr:String;
			var logStr:String;
			tempDate = new Date();
			dateStr = 	StringUtil.doubeQuoteStr(tempDate.toLocaleString() + 
						" s" + tempDate.getSeconds() + ":" + tempDate.getMilliseconds());
			logStr = LOG_ENTRY;
			logStr = logStr.replace(this.rawPattern,StringUtil.doubeQuoteStr((tempDate.time).toString()));
			logStr = logStr.replace(this.datePattern,dateStr);
			this.logArr.push(logStr.replace(this.contentPattern,inStr));
		}
		
		public function toString():String
		{
			return this.createLogXML();
		}
		
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/
		
		private function createLogXML():String
		{
			var tempStr:String; 	// log entries
			var contentStr:String;  // log entries
			tempStr = LOG_FILE;
			tempStr = tempStr.replace(this.idPattern,StringUtil.doubeQuoteStr(this.fileID));
			tempStr = tempStr.replace(this.sessionPattern,StringUtil.doubeQuoteStr(this.sessionID));
			contentStr = "";
			
			for (var i:int; i < this.logArr.length; i++)
			{
				contentStr += this.logArr[i] + "\n";
			}
			return tempStr.replace(this.contentPattern,contentStr);
		}
	}
}