package org.wsimpson.loaders

/*
** Title:	Loader.as
** Purpose: Class for importing files
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
** See for tutorial:  http://www.kirupa.com/developer/flashcs3/using_xml_as3_pg2.htm
*/
{
	// Adobe Library
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	
	// Debugging
	import org.wsimpson.util.DebugUtil;
	
	public class Loader
	{
		// Public Instance Variables (unChecked Parameter values)
        public var infile:String;						// The XML file load
        public var nameStr:String;						// Refernce name of the file
        public var pathStr:String;						// URL file is being loaded from
		public var httpStatus:int;						// Status returned by the loader
		public var bytes_loaded:int;					// Reflects load progress
		public var bytes_total:int;						// Reflects load progress

		// Protected Instance Variables
        protected var loadCompleteBool:Boolean;			// Indicates file load has completed
        protected var callback:Function;					// Callback Function
		protected var imageLoader:flash.display.Loader;	// Required for loading binary files
		protected var urlLoader:URLLoader;				// Required for loading text files
		protected var request:URLRequest;					// Required for loading files
		
		// Private Instance Variables
        private var _debugger:DebugUtil;
	
		// Constructor
		public function Loader()
		{
			this._debugger = DebugUtil.getInstance();
			this.loadCompleteBool = false;
		}
		/*******************************************************************************************
		**  PUBLIC	*******************************************************************************/
		/**
		*  Name:  	importXML
		*  Purpose:	Confirm whether value is in the range
		*  @param 	inName			String		The string used to identify this resource
		*  @param 	inURLStr		String		The URL for the file being loaded
		*  @param 	inContentType	String		The Content Type
		*  @param 	inCallback		Function	Hides the functionality of an XML file load
		*/
		public function importXML(inName:String,inURLStr:String, inContentType:String,inCallback:Function):void
		{
			this.nameStr = inName;
			this.callback = inCallback;
			this.pathStr = inURLStr;
			this.urlLoader = new URLLoader();
			this.urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			this.configureListeners(this.urlLoader);
			this.urlLoader.addEventListener(Event.COMPLETE, loadXMLComplete);
			this.request = new URLRequest(inURLStr);
			this.request.contentType = inContentType;
			this.urlLoader.load(this.request);
		}
	
		/**
		*  Name:  	importFile
		*  Purpose:	Confirm whether value is in the range
		*  @param 	inName		String		The string used to identify this resource
		*  @param 	inURLStr	String		The URL for the file being loaded
		*  @param 	inContentType	String		The Content Type
		*  @param 	inCallback	Function	Hides the functionality of an XML file load
		*/
		public function importFile(inName:String,inURLStr:String, inContentType:String,inCallback:Function):void
		{
			this.nameStr = inName;
			this.callback = inCallback;
			this.pathStr = inURLStr;
			this.imageLoader = new flash.display.Loader();
			this.configureListeners(this.imageLoader.contentLoaderInfo);
			this.imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			
			this.request = new URLRequest(inURLStr);
			this.request.contentType = inContentType;
			this.imageLoader.load(this.request);
		}

		/*******************************************************************************************
		** LOAD COMPLETE HANDLERS  *****************************************************************
		*******************************************************************************************/
		
		/**
		*  Name:  	loadXMLComplete
		*  Purpose:	Read in the external file
		*  @param 	e	Event	Event information
		*/
		public function loadXMLComplete(e:Event):void
		{
			try 
			{
				this.infile = new XML(e.target.data);
			} catch(e)
			{
				this._debugger.errorTrace("The infile is not valid XML " + this.pathStr);
				this._debugger.errorTrace(e.getStackTrace());
			}
			this.loadCompleteBool = true;
			this.callback(this.nameStr,this.infile);
		}
		
		/**
		*  Name:  	loadComplete
		*  Purpose:	Read in the external file
		*  @param 	e	Event	Event information
		*/
		public function loadComplete(e:Event):void
		{
			this.loadCompleteBool = true;
			this.callback(this.nameStr,this.imageLoader.content);
		}
		
		/*******************************************************************************************
		** HANDLERS	********************************************************************************
		*******************************************************************************************/
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
            this.httpStatus = event.status;
        }
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			if (this.pathStr.indexOf(".css") < 0)
			{
				this._debugger.errorTrace("An IO Error has occured.\n\n The file:  " + this.pathStr + " \n\n Didn't load.\n\n" + event.text);
			}
		}

        private function securityErrorHandler(event:SecurityErrorEvent):void {
			this._debugger.errorTrace("An Security Error has occured.\n\n The file:  " + this.pathStr + "\n");
        }

        private function initHandler(event:Event):void {
            // Do Nothing (May record to log in the future)
        }

        private function openHandler(event:Event):void {
            // Do Nothing (May record to log in the future)
        }

        private function progressHandler(event:ProgressEvent):void {
			this.bytes_loaded = event.bytesLoaded;
			this.bytes_total = event.bytesTotal;
        }

        private function unLoadHandler(event:Event):void {
            // Do Nothing (May record to log in the future)
        }
		
		/*******************************************************************************************
		** HANDLERS	********************************************************************************
		*******************************************************************************************/

		// Based on Adobe examples for the flash.display.Loader and the flash.net.URLLoader
	    protected function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.INIT, initHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(Event.UNLOAD, unLoadHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        }
    }	
}