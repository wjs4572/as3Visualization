package org.wsimpson.manager

/*
** Title:	LoadManager.as
** Purpose: Manages the basic events
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
    //import flash.display.MovieClip;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;	
	import org.wsimpson.loaders.Loader;
	
	public class LoadManager	{
		// Private Instance Variables required for Singleton Creation
		private static var instance:LoadManager = new LoadManager();	// Tracks the instantiated class
		
		// Private Instance Variables
		private	var _debugger:DebugUtil;			// Output and diagnostic window		
		private var resourceObj:Object;				// An Associative array of Resource Files
        private var callback:Function;				// The function called when all files are loaded
		
		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		**		  http://www.munkiihouse.com/?page_id=2
		******************************************************************************************************/
		
		public function LoadManager() {
			if (instance) 
			{
				throw new Error("Instantiation failed: Use LoadManager.getInstance() instead of new.");
			} else {
				this._debugger = DebugUtil.getInstance();
			}
		}
		
		public static function getInstance():LoadManager {
			return instance;
		}	

		/******************************************************************************************************
		**  Public
		******************************************************************************************************/

		public  function listFileReferences():void {
			for (var tempName:String in resourceObj)
			{
				trace(	"File ID:  " + tempName + 
						", File url:  " + resourceObj[tempName].urlStr + 
						", File type:  " + resourceObj[tempName].fileType + 
						", File description:  " + resourceObj[tempName].fileDesc);
			}
		}
		
		public  function listFiles():void {
			for (var tempName:String in resourceObj)
			{
				trace(	"File ID:  " + tempName +
						", File contents:  " + resourceObj[tempName].contents);
			}
		}

		/**
		*  Name:  	getFile
		*  Purpose:	Returns a file
		*  @param 	inName		String		The string used to identify this resource
		*  @return 	Object		The URL for the file being loaded
		*/
		public  function getFile(inName:String):Object {
			return (this.resourceObj[inName] == null) ? null : this.resourceObj[inName].contents;
		}
		
		/**
		*  Name:  	getFileType
		*  Purpose:	Returns a fileType
		*  @param 	inName		String		The string used to identify this resource
		*  @return 	String		The file type
		*/
		public  function getFileType(inName:String):String {
			return (this.resourceObj[inName] == null) ? null : this.resourceObj[inName].fileType;
		}
		
		/**
		*  Name:  	addFile
		*  Purpose:	Adds a file to be loaded
		*  @param 	inName		String		The string used to identify this resource
		*  @param 	inType	String		The type of file being loaded, may be required to use different loader classes.
		*  @param 	inURLStr	String		The URL for the file being loaded
		*  @param 	inDescription	String	Optional file description
		*  @return	Boolean Indicates a successful add
		*/
		public  function addFile(inName:String, inType:String, inURLStr:String, inDescription:String = ""):Boolean {
			var tempBool:Boolean;
			this.resourceObj = (this.resourceObj == null) ? new Object() : this.resourceObj;
			tempBool = ((this.resourceObj[inName] == null) || (this.resourceObj[inName].urlStr != inURLStr));
			if (tempBool)
			{
				this.resourceObj[inName] =  new Object();
				this.resourceObj[inName].urlStr = inURLStr;
				this.resourceObj[inName].loadedBool = false;
				this.resourceObj[inName].fileType = inType;
				this.resourceObj[inName].fileDesc = inDescription;
				this.resourceObj[inName].loader = new Loader();
			}
			return tempBool;
		}
		
		/**
		*  Name:  	replaceFile
		*  Purpose: Replaces an existing file to be loaded
		*  @param 	inName		String		The string used to identify this resource
		*  @param 	inURLStr	String		The URL for the file being loaded
		*/
		public  function replaceFile(inName:String,inURLStr:String):void {
			if ((this.resourceObj == null) || (this.resourceObj[inName] == null))
			{
				throw new Error("Attempt to replace a nonexistent entry in Load Manager failed: Object does not exist");
			}
			this.resourceObj[inName].urlStr = inURLStr;
			this.resourceObj[inName].loadedBool = false;
		}
		
		/**
		*  Name:  	removeFile
		*  Purpose:	Confirm whether value is in the range
		*  @param 	inName		String		The string used to identify this resource
		*/
		public  function removeFile(inName:String):void {
			this.resourceObj[inName] = null;
		}
		
		/**
		*  Name:  	loadFiles
		*  Purpose:	Initiate the file loades
		*  @param 	inCallback	Function	Hides the functionality of an XML file load
		*/
		public function loadFiles(inCallback:Function):void
		{
			var tempBool:Boolean;  // Determine if all the files are already loaded
			tempBool = true;
			this.callback = inCallback;
			for (var tempName:String in resourceObj)
			{
				tempBool &&= this.resourceObj[tempName].loadedBool;
				
				// Do not reload a previously loaded file
				if (!this.resourceObj[tempName].loadedBool)
				{
					switch(this.resourceObj[tempName].fileType)
					{
						case "image/jpeg":
						case "image/png":
							this.resourceObj[tempName].loader.importFile(tempName,this.resourceObj[tempName].urlStr,this.resourceObj[tempName].fileType,this.resourceLoaded);					
						break;
						case "text/css":
						case "application/xml":
						case "application/html":
						default:
							this.resourceObj[tempName].loader.importXML(tempName,this.resourceObj[tempName].urlStr,this.resourceObj[tempName].fileType,this.resourceLoaded);
						break;
					}
				}
			}
			if (tempBool)
			{
				this.callback();
			}
		}	
		
		/****************************************************************************************************************
		** Event Handler
		****************************************************************************************************************/
		
		/**
		*  Name:  	resourceLoaded
		*  Purpose:	Resources have completed loading
		*  @param 	inName	String	The string used to identify this resource.	
		*  @param 	inFile	Object	The file loaded.
		*/
		public function resourceLoaded(inName:String,inFile:Object):void
		{
			this.resourceObj[inName].contents = inFile;
			this.resourceObj[inName].loadedBool = true;
			
			
			// Remove the file loader
			this.resourceObj[inName].loader = null;
			if (this.allLoaded())
			{
				this.callback();
			}
		}
		
		/**
		* Name: statusRequest
		* Purpose:  Determine if null was received due to an unfinished load
		* @param inName String The name of the resource
		* @return Number Percentage complete
		*/
		public function statusRequest(inName:String):Number
		{
			return ((this.resourceObj[inName].loader.bytes_loaded / this.resourceObj[inName].loader.bytes_total) * 100);
		}
		/****************************************************************************************************************
		** Private
		****************************************************************************************************************/
		
		public  function allLoaded():Boolean {
			var tempBool:Boolean;
			tempBool = true;
			for (var tempName:String in resourceObj)
			{
				tempBool &&= this.resourceObj[tempName].loadedBool;
			}
			return tempBool;
		}
	}
}