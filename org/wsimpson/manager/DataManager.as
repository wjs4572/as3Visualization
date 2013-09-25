package org.wsimpson.manager

/*
** Title:	DataManager.as
** Purpose: Manages the basic events
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	// Utilities
	import org.wsimpson.util.DebugUtil;	
	import org.wsimpson.util.LogUtil;
	
	public class DataManager	{
		// Private Instance Variables required for Singleton Creation
		private static var instance:DataManager = new DataManager();	// Tracks the instantiated class
		
		// Private Instance Variables
		private	var _debugger:DebugUtil;		// Output and diagnostic window		
		private var logArr:Array;				// An array of log files
		
		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		**		  http://www.munkiihouse.com/?page_id=2
		******************************************************************************************************/
		
		public function DataManager() {
			if (instance) 
			{
				throw new Error("Instantiation failed: Use TextStyle.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():DataManager {
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
			this.logArr = (this.logArr) ? this.logArr : new Array();
			this.logArr.push(new LogUtil(inFileID,inSessionID));
			return this.logArr[this.logArr.length - 1];
		}

		/**
		*  Name:  	concatLogs
		*  Purpose:	Combine each of the individual logs into a single log
		*  @return 	String	Full log
		*/
		public  function concatLogs():String {
			var tempStr:String;
			tempStr = "";
			for (var i:Number = 0; i < this.logArr.length; i++)
			{
				tempStr += this.logArr[i];
			}
			return tempStr;
		}
		
	}
}