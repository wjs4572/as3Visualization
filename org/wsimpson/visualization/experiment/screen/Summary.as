package org.wsimpson.visualization.experiment.screen
/*
** Title:	Summary.as
** Purpose: Screen for finalizing the interaction with the participant.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe UI
	import flash.text.TextField;
	
	// UI Components
	import org.wsimpson.visualization.experiment.screen.Intro;	

	// Utitlies
	import org.wsimpson.util.DebugUtil;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.ScreenView;	
	
	public class Summary extends Intro
	{
		// Constants
		private const RETURN_FIELD = "{RETURN}";	// Substitution String
	
		// Private Instance Variables
		private	var _debugger:DebugUtil;			// Output and diagnostic window	
		private var _returnPattern:RegExp;			// Regular Expression for the return placement pattern		
		
		/**
		*  Name:  	Constructor
		*  Purpose:	Creates a screen from the imported XML
		*
		*	@param inView ScreenView From design pattern, MVC, the View for UI
		*	@param screenXML XML XML definition for the screen to display
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function Summary(inView:ScreenView,screenXML:XML)
		{
			super(inView,screenXML);
			
			this._debugger = DebugUtil.getInstance();
			this._returnPattern = new RegExp(RETURN_FIELD);			
		}
		 
		/******************************************************************************************************
		**  Protected
		******************************************************************************************************/

		// Returns the files contained here
		protected override function init():void
		{
			var tempStr:String;
			var tempLinkStr:String;
			super.init();
			tempLinkStr = this.view.linkEventLog();
			for (var i:Number = 0; i < this.textFields.length; i++)
			{
				tempStr = this.textFields[i].htmlText;	
				if (tempStr.match(this._returnPattern).length > 0)
				{
					this.textFields[i].htmlText = tempStr.replace(this._returnPattern,tempLinkStr);
					this.textFields[i].selectable = true;
				}
			}
		}
		
	}
}