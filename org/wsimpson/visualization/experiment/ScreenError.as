package org.wsimpson.visualization.experiment

/*
** Title:	ScreenError.as
** Purpose: Reports Errors
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.ScreenView;
	
	public class ScreenError	{
		// Private Instance Variables required for Singleton Creation
		private static var instance:ScreenError = new ScreenError();	// Tracks the instantiated class
		
		// Private Instance Variables
		private var view:ScreenView;		// The View of MVC		
		
		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		**		  http://www.munkiihouse.com/?page_id=2
		******************************************************************************************************/
		
		public function ScreenError() {
			if (instance) 
			{
				throw new Error("Instantiation failed: Use ScreenError.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():ScreenError {
			return instance;
		}	

		/******************************************************************************************************
		**  Public
		******************************************************************************************************/
		/**
		*  Name:  	init
		*  Purpose: Provides a singleton reference to the View class reportError Method
		*  @param inView ScreenView The View class implements a reportError function that this can call.
		*/
		public  function init(inView:ScreenView):void {
			this.view = inView;
		}
		
		/**
		*  Name:  	reportError
		*  Purpose:  An click event has occurred with a button.
		*  @param inErrorCode Number The number of the error screen defined		
		*  @param inMsg String Message specific to this occurrence	
		*/
		public function reportError(inErrorCode:Number,inMsg:String=""):void {
			this.view.reportError(inErrorCode,inMsg);
		}

	}
}