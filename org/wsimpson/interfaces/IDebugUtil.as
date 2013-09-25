package org.wsimpson.interfaces

/*
** Title:	IDebugUtil
** Purpose: Provides debug window to be used with the tool
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/

{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public interface IDebugUtil
	{
	  
		/************************************************************************************************************************************
		**  PUBLIC
		************************************************************************************************************************************/
	
		/**
		*  Name:  setforat
		*  Purpose:  Sets the display format for the debugger window text
		*  @param passed_txt_format	TextFormat	Assigns text formatting
		*
		*/
		function setformat(passed_txt_format:TextFormat):void;

		/**
		*  Name:  wTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/		
		function wTrace(received_string:String):void ;

		/**
		*  Name:  functionTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/			
		function functionTrace(received_string:String):void ;

		/**
		*  Name:  eventTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/		
		function eventTrace(received_string:String);

		/**
		*  Name:  warningTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/	
		function warningTrace(received_string:String):void ;
		
		/**
		*  Name:  errorTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/	
		function errorTrace(received_string:String) ;

		// Clear trace history
		function clear():void ;
		
		// Hide the debug window
		function hide():void ;

		// Hide the debug window
		function show():void ;

		/**
		*  Name:  assignDebugState
		*  Purpose:   Toggles the specified debug state, which controls what trace statement values are kept for display..  Except for DEBUB_ALL and DEBUG_NONE, which are global.
		*		Timestamp is always treated independently
		*  @param inState NumberUsing the public constants for debug states that can be toggled
		* <br/>
		* states supported:
		* <ul>
		* <li> DEBUG_ALL - Show all debugging statements<li/>
		* <li> DEBUG_TRACE -  Display trace statements<li/>
		* <li> DEBUG_TIMESTAMP -  Display timestamps<li/>
		* <li> DEBUG_FUNCTIONS - Display functions<li/>
		* <li> DEBUG_EVENTS - Display event trace statements<li/>
		* <li> DEBUG_NONE - Turn off all debugging<li/>
		* </ul>
		*/	
		function assignDebugState(inState:int):void ;

	} // interface
}
