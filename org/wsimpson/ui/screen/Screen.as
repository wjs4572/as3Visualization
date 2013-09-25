package org.wsimpson.ui.screen
/*
** Title:	Screen.as
** Purpose: Abstract Class for creating screens
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{	
	// Adobe Classes
	import flash.display.Sprite;
	
	// Visualization Application Classes
	import org.wsimpson.interfaces.IScreen;	
	
	public class Screen extends Sprite implements IScreen
	{
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
		public function Screen()
		{
			super();
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
		
		public function leaveScreen():void
		{
			// Leaving the Screen:  Introduction Screens have no action
		}
		
	}
}