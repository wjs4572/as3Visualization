package org.wsimpson.loaders

/*
** Title:	Upload.as
** Purpose: Class for Uploading files to the server
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
** See for tutorial:  ActionScript 3 Cookbook:  pg 50-51
*/
{
	// Adobe Event Class
	import flash.events.Event;	

	// Adobe Networking Classes
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	// Debugging
	import org.wsimpson.util.DebugUtil;
	
	// Loaders
	import org.wsimpson.loaders.Loader;
	
	public class Upload extends Loader
	{
		// Private Instance Variables
        private var _debugger:DebugUtil;
	
		
		// Constructor
		public function Upload()
		{
			this._debugger = DebugUtil.getInstance();
			this.loadCompleteBool = false;
		}
		/*******************************************************************************************
		**  PUBLIC	*******************************************************************************/
		/**
		*  Name:  	uploadXML
		*  Purpose: Upload XML to the server
		*  @param 	inFile			String		Thie XML file as a string
		*  @param 	inURLStr		String		The URL for the file being loaded
		*  @param 	inCallback		Function	Hides the functionality of an XML file load
		*/
		public function uploadXML(inFile:String,inURLStr:String, inCallback:Function):void
		{
			var XMLDataIn:XML;
			XMLDataIn = new XML(inFile);

			this.infile = inFile;
			this.callback = inCallback;
			this.pathStr = inURLStr;
			
			// Initialize the Loader
			this.urlLoader = new URLLoader();
			this.configureListeners(this.urlLoader);
			this.urlLoader.addEventListener(Event.COMPLETE, loadXMLComplete);
			
			// Build the request
			this.request = new URLRequest(inURLStr);
			this.request.contentType = "text/xml";
			this.request.data = XMLDataIn;
			this.request.method = URLRequestMethod.POST;

			this.urlLoader.load(this.request);
		}


		/*******************************************************************************************
		** LOAD COMPLETE HANDLERS  *****************************************************************
		*******************************************************************************************/
		
		/**
		*  Name:  	loadXMLComplete
		*  Purpose:	Read in the external file
		*  @param 	e	Event	Event information
		*/
		public override function loadXMLComplete(e:Event):void
		{
			try 
			{
				//this.infile = new XML(e.target.data);
				this.infile = e.target.data;
			} catch(e)
			{
				this._debugger.errorTrace("The infile is not valid XML " + this.pathStr);
				this._debugger.errorTrace(e.getStackTrace());
			}
			this.loadCompleteBool = true;
			this.callback(this.infile);
		}
		
    }	
}