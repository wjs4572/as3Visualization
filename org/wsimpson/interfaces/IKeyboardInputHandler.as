package org.wsimpson.interfaces

/*
** Title:	IKeyboardInputHandler.as
** Purpose: Interface implemented by the class managing keyboard events
** Author:  William Simpson
** Note: 	This code is based on code from:
**			Sanders, W., Cumaranatunge, C., William, S., & Chandima, C. (2007). 
**				ActionScript 3.0 Design Patterns: Object Oriented Programming Techniques 
**				(illustrated edition.). Adobe Developer Library.
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/

{
	import flash.events.KeyboardEvent;
	
	public interface IKeyboardInputHandler
	{
		function keyHandler(event:KeyboardEvent):void;
    }
}