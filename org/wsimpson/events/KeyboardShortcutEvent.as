package org.wsimpson.events
/*
** Title:	KeyboardShortcutEvent
** Purpose: Events for the Keyboard Manager Class
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{

	import flash.events.Event;
	
	public class KeyboardShortcutEvent extends Event
	{
		// Public Instance Variables
		public static var APP_CLOSE:String = Event.CLOSE;	// Event indicates to close the application
		
		// Constructor
		function KeyboardShortcutEvent(inType:String)
		{
			super(inType);
		}

	}
}