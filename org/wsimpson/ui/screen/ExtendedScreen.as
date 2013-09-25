package org.wsimpson.ui.screen
/*
** Title:	Screen.as
** Purpose: Abstract Class for creating screens
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Utility classes
	import org.wsimpson.util.TextFieldUtil;

	// Adobe UI
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize	
	
	// UI Interfaces
	import org.wsimpson.interfaces.IScreen;

	// UI Classes
	import org.wsimpson.ui.DisplayArea;	
	import org.wsimpson.ui.screen.Screen;
	
	// Style Definitions
	import org.wsimpson.styles.Style;
	
	public class ExtendedScreen extends Screen implements IScreen
	{
		protected var fileArr:Array;				// Array of files loaded for display		
		protected var daObj:Object;					// Associative array of Display Areas
	
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
		public function ExtendedScreen()
		{
			super();
			
			// Associative Array of Display Areas
			this.daObj = new Object();
			
			// Array of TextFields
			this.fileArr = new Array();			
		}

		/******************************************************************************************************
		** Public
		*******************************************************************************************************/
		
		public function addTextField(inContent:String, inStyle:StyleSheet):TextField
		{
			var tempTF:TextField;
			tempTF = TextFieldUtil.newTextField(inContent,inStyle);
			this.fileArr.push(tempTF);
			return tempTF;
		}
		
		public  function addDisplayArea(inTarget:String,defXML:XML,inDesc:String,inStyle:Object):void
		{		
			var tempDA:DisplayArea; // Display area 			

			// Target Display area				
			tempDA = new DisplayArea(defXML,inStyle,inDesc);
			this.daObj[inTarget] = tempDA;
			this.daObj[inTarget].name = inTarget;			
			tempDA.showDisplayArea();
			this.addChild(tempDA);
		}

		
	}
}